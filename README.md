# xugudb-exporter

虚谷数据库（XuguDB）Prometheus 监控套件 —— 产品发布仓库。

数据库运行状态、性能、容量、锁与事务、日志与安全、服务器资源的完整监控：
**48 个采集域 / 88 项数据库指标 + 主机·进程·备份指标、10 分区 72 面板 Grafana 仪表盘、29 条中文告警规则**。
单二进制部署，无外部依赖，支持单机与分布式集群。

适用数据库：XuguDB 12.x　当前版本：v1.2.0

## 快速开始

### 方式一：Docker Compose 演示栈（评估推荐）

```bash
cd deploy
XUGU_DSN="IP=数据库IP;DB=SYSTEM;User=SYSDBA;PWD=***;Port=5138;CHAR_SET=UTF8" docker compose up -d
# Grafana: http://localhost:3000 (admin/admin)，"XuguDB" 目录下仪表盘已自动导入
```

### 方式二：二进制部署（生产）

```bash
# 按平台选择 bin/ 下二进制（linux 386/amd64/arm64、windows amd64、macOS amd64/arm64）
export XUGU_DSN="IP=数据库IP;DB=SYSTEM;User=SYSDBA;PWD=***;Port=5138;CHAR_SET=UTF8"
./bin/xugu-exporter-linux-amd64 --web.listen-address :9156
curl localhost:9156/metrics
```

随后将 `:9156` 加入 Prometheus 抓取、引入 `rules/xugu-alerts.yml`、在 Grafana 导入 `dashboards/xugu-overview.json`。
完整步骤见 **`手册/`** 下的正式文档，或 `docs/deployment-guide.md`。

## 目录结构

```
手册/         正式交付文档（DOCX + PDF，含封面/目录/页眉页脚）
bin/          六平台采集器二进制（linux 386/amd64/arm64、windows amd64、macOS amd64/arm64）
configs/      运行配置模板 + 指标定义（外置覆盖起点）
dashboards/   Grafana 仪表盘（导入即用）
rules/        Prometheus 告警规则（29 条）
deploy/       Docker Compose / systemd / Prometheus·Grafana 配置模板
scripts/      卡死 SQL 一键诊断脚本
docs/         Markdown 源文档 + 功能截图（正式文档的来源）
```

## 正式文档（手册/）

推荐阅读 PDF；DOCX 可编辑。

| 文档 | 内容 | 下载 |
|------|------|------|
| 产品手册 | 功能规格、72 面板逐一图文详解、告警规格、使用说明 | [PDF](手册/虚谷数据库监控系统-产品手册.pdf) · [DOCX](手册/虚谷数据库监控系统-产品手册.docx) |
| 部署与运维手册 | 安装部署、配置管理、故障处理、系统字典参考 | [PDF](手册/虚谷数据库监控系统-部署与运维手册.pdf) · [DOCX](手册/虚谷数据库监控系统-部署与运维手册.docx) |
| 指标参考手册 | 88 指标清单、每条采集 SQL 与解释、设计说明 | [PDF](手册/虚谷数据库监控系统-指标参考手册.pdf) · [DOCX](手册/虚谷数据库监控系统-指标参考手册.docx) |

### Markdown 源文档（docs/）

| 文档 | 内容 |
|------|------|
| [部署说明手册](docs/deployment-guide.md) | 部署方式、配置项速查、性能开关、验收清单、常见问题 |
| [产品手册](docs/产品手册.md) | 功能规格、72 面板图文详解、告警规格、使用限制 |
| [指标参考](docs/metrics-reference.md) | 48 采集域 88 指标，每条来源 SQL 及解释 |
| [指标设计说明](docs/metrics-design.md) | 字段→指标→综合指标设计与版本迁移对照 |
| [测试报告](docs/test-report.md) | 验证结论与已知限制 |
| [XuguDB 运行行为参考](docs/xugudb-reference-notes.md) | 日志级别、锁体系、存储模型、状态码编码表 |
| [字段有效性参考](docs/field-validation-matrix.md) | 系统字典字段有效性矩阵 |
| [产品包清单](docs/package-manifest.md) | 文件结构说明 |

## 特性摘要

- **配置驱动**：采集 SQL 全部外置 YAML，`metrics_files` 覆盖同名采集域即可定制，无需重新编译
- **单机/集群一体化**：统一 `SYS_ALL_*` 全局虚表，集群专属指标按节点数自动启停
- **崩溃与备份检测**：E19002 致命错误码 + 异常堆栈文件（exception_stack.trc）双告警；备份/归档文件落地实况（扫描 mount.ini）
- **卡死 SQL 诊断**：执行中语句带 OS 线程号，配套 pstack 一键诊断脚本
- **服务器资源内置采集**：CPU / 内存（OOM 风险）/ 磁盘余量与 7 天预测，开箱即用
- **性能三层开关**：按域关停 / 全局降频 / 白名单启用，适配大数据量环境
