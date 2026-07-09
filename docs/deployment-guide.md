# xugu-exporter 部署说明手册

> 适用版本：v1.2.0　适配数据库：XuguDB 12.x
> 三种部署方式按推荐顺序：Docker Compose（一键演示/评估）→ systemd（生产 Linux）→ 手工二进制。

---

## 1. 部署前准备

### 1.1 选择部署位置（重要）

| 部署位置 | 数据库指标 | 服务器资源指标(xugu_host_*) | 建议 |
|----------|-----------|------------------------------|------|
| **与数据库同机** | ✓ | ✓ 即数据库服务器画像（CPU/内存/OOM/磁盘） | **推荐** |
| 独立监控机 | ✓ | 反映监控机自身（应设 `host_metrics: false`），数据库服务器另装 node_exporter/windows_exporter | 多实例集中监控时 |

### 1.2 数据库侧准备

```sql
-- 1) 监控账号（测试可直接用 SYSDBA；生产建议专号）
CREATE USER MONITOR IDENTIFIED BY '复杂口令';
GRANT DBA TO MONITOR;   -- 或按最小化原则仅授予 SYS_* 系统表 SELECT 权限

-- 2) 慢 SQL 阈值（可选，也可由 exporter 的 set_slow_sql_time 自动设置）
SET slow_sql_time TO 1000;   -- 毫秒；默认值过短会产生大量噪音日志

-- 3) 回收站监控需开启（可选）
SET enable_recycle TO ON;
```

- 连接串**必须连 SYSTEM 库**（系统虚表仅系统库可读）：
  `IP=数据库IP;DB=SYSTEM;User=MONITOR;PWD=***;Port=5138;CHAR_SET=UTF8`
- 分布式集群多 IP 负载均衡：`IPS=ip1,ip2,ip3` 代替 `IP=`。

### 1.3 端口清单

| 组件 | 端口 | 说明 |
|------|------|------|
| xugu-exporter | 9156 | /metrics、/-/healthy |
| Prometheus | 9090 | 时序库与告警求值 |
| Grafana | 3000 | 仪表盘（演示栈 admin/admin） |
| node-exporter | 9100 | 可选，异机部署时装在数据库服务器 |

## 2. 方式一：Docker Compose 一键演示栈（推荐评估用）

```bash
cd deploy
XUGU_DSN="IP=数据库IP;DB=SYSTEM;User=SYSDBA;PWD=***;Port=5138;CHAR_SET=UTF8" docker compose up -d
```

启动后：Grafana http://localhost:3000（admin/admin），"XuguDB" 目录下仪表盘已自动导入；
Prometheus http://localhost:9090 已加载 22+3 条告警规则；node-exporter 采集 compose 宿主机资源。

> 数据库在另一台机器时，请在数据库服务器安装 node_exporter 并把地址填入
> `deploy/prometheus.yml` 的 `job_name: server` targets。

## 3. 方式二：systemd 生产部署（Linux）

```bash
# 1) 选择平台产物并安装（成品包 dist/ 内已含 6 平台二进制）
sudo mkdir -p /opt/xugu-exporter
sudo cp dist/xugu-exporter-1.1.0-linux-amd64 /opt/xugu-exporter/xugu-exporter   # arm64/386 按机器选择
sudo cp dist/xugu-exporter.yml /opt/xugu-exporter/
sudo chmod +x /opt/xugu-exporter/xugu-exporter

# 2) 编辑配置（至少改 dsn；生产建议用环境变量传密码，见 systemd 单元）
sudo vi /opt/xugu-exporter/xugu-exporter.yml

# 3) systemd 单元（模板见 deploy/systemd/xugu-exporter.service）
sudo cp deploy/systemd/xugu-exporter.service /etc/systemd/system/
sudo systemctl daemon-reload && sudo systemctl enable --now xugu-exporter

# 4) 验证
curl -s localhost:9156/-/healthy          # → ok
curl -s localhost:9156/metrics | head     # → xugu_up 1

# 5) Prometheus 侧：把本机 9156 加入抓取，并引入告警规则
#    scrape_configs 加 job；rule_files 引入 rules/xugu-alerts.yml
# 6) Grafana 侧：导入 dashboards/xugu-overview.json，数据源选 Prometheus
```

Windows 服务器：使用 `xugu-exporter-1.1.0-windows-amd64.exe`，可用 NSSM/计划任务注册为服务；
macOS 运维机：darwin-amd64 / darwin-arm64（Apple Silicon）。

## 4. 配置项速查（configs/xugu-exporter.yml）

| 配置 | 默认 | 说明 |
|------|------|------|
| `dsn` | - | 连接串；环境变量 `XUGU_DSN` 优先（避免密码落盘） |
| `listen_address` | :9156 | /metrics 监听地址 |
| `scrape_timeout` | 10s | 每采集域 SQL 超时 |
| `max_open_conns` | 4 | 连接池=采集并发度 |
| `time_location` | Asia/Shanghai | 数据库墙钟时区（影响 uptime/事务时长等换算） |
| `host_metrics` | true | 主机 CPU/内存/磁盘、进程存活、异常堆栈(trc)、备份文件采集（异机部署设 false） |
| `trc_dirs` | [] | 异常堆栈文件(*.trc)附加扫描目录，默认自动发现数据库进程目录 |
| `backup_dirs` | [] | 备份检测附加目录（安装根目录或备份目录），默认自动读 mount.ini 的 /BACKUP、/ARCH |
| `set_slow_sql_time` | 0 | >0 时启动即 `SET slow_sql_time TO n`（毫秒），修正过短默认阈值 |
| `default_ttl` | 0 | 给未设 ttl 的采集域统一加缓存，整体降低指标 SQL 频率 |
| `disabled_groups` | [] | 按名称关停采集域（担心某条 SQL 影响性能时） |
| `disable_default_metrics` | false | 全部关停内置域，只用 metrics_files |
| `metrics_files` | [] | 外置指标定义，同名域覆盖内置（改 SQL 不用改代码） |

### 性能顾虑三层开关（数据量级大时）

1. 单域关停：`disabled_groups: [sessions_by_source, errorlog]`（errorlog 是日志表全量扫描，日志超百万行时建议先关）
2. 整体降频：`default_ttl: 60s`（Prometheus 仍 15s 抓取，但 SQL 每 60s 才真正执行）
3. 全部关停：`disable_default_metrics: true` + 自定义 metrics_files 白名单式启用

## 5. 升级与回滚

- 升级：替换二进制 → `systemctl restart xugu-exporter`；指标定义在二进制内嵌，
  如需热改 SQL 用 `metrics_files` 覆盖同名域，无需换二进制。
- 面板升级：重新导入 dashboards/xugu-overview.json（uid 不变会覆盖更新）。
- 回滚：换回旧二进制即可；指标名变更历史见 docs/metrics-design.md §4 迁移对照表。

## 6. 部署后验收清单

- [ ] `curl :9156/metrics` 输出含 `xugu_up 1`，且 `xugu_collector_success` 全为 1
- [ ] Prometheus Targets 页面 job=xugudb 状态 UP；Rules 页面加载 25 条规则
- [ ] Grafana 仪表盘 9 个分区渲染正常；总览 KPI 有数值
- [ ] `xugu_host_*` 有数据（同机部署）或已接入 node_exporter（异机）
- [ ] 数据文件所在磁盘剩余空间充足（容量告警为磁盘口径：剩余 <10% 与 7 天写满预测；已分配空间使用率仅作扩展时机参考，不告警）

## 7. 常见问题

| 现象 | 原因与处理 |
|------|-----------|
| `SYS_VARS 无权限` | 未连 SYSTEM 库或账号无系统表权限，见 §1.2 |
| 某采集域 success=0 | 查 exporter 日志；版本差异导致 SQL 失败时用 metrics_files 覆盖该域 |
| 面板"缓冲命中率/网络吞吐"缺失 | 12.0.0 相应计数器无效（实测恒零），设计上已移除，见 docs/xugudb-reference-notes.md §8 |
| 阻塞链表格总为空 | 正常：仅表级锁等待可见；行锁阻塞看"最长事务时长"与长事务告警 |
| 死锁没有告警 | 12.0.0 行锁死锁不被自动检测，表现为互等长事务；按告警指引 `EXEC DBMS_DBA.KILL_TRANS(节点,事务)` 处理 |
| 抓取超时 | 增大 scrape_timeout 或对慢域（errorlog）加 ttl/关停 |
