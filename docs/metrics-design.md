# 指标设计：字段 → 单指标 → 综合指标

> 依据：docs/field-validation-matrix.md（2026-07-06 真实库 XuguDB 12.0.0 全字段验证）与 docs/test-plan.md §5。
> 本文回答三个问题：每个有效字段怎么变成指标（单指标设计）；哪些字段组合成什么运维语义（综合指标设计）；
> 无效/不确定字段为什么不采集。

## 1. 设计原则

1. **只暴露经验证有效的字段**；无效字段不建指标，不确定字段必须在 help 中注明限制。
2. **exporter 只做原始值与最小换算**（块数×块大小→字节、DATETIME→Unix秒、毫秒→秒）；
   比率/速率/差值一律放在 PromQL（面板/告警）层，保证口径可追溯、可复算。
3. 命名 `xugu_<对象>_<度量>_<单位>`：容量 `_bytes`、时刻 `_timestamp_seconds`、时长 `_seconds`、
   累计 `_total`、持久化位置量 `_position`（gauge 类型但可 rate()）。
4. 公共 label：`node`（SYS_ALL_* 的 NODEID），`instance` 由 Prometheus 注入。

## 2. 字段级设计表（按数据源对象）

### SYS_ALL_RUN_INFO（单行/节点，核心计数器）

| 字段 | 有效性(实测) | 单指标 | 综合指标参与 |
|------|------------|--------|--------------|
| NODEID | 确定 | → label `node` | 全部 |
| CURR_T | 确定 | 不采集（采样时刻无监控价值） | - |
| REQ_N / BUFF_R_N | **无效-恒零** | 不采集。原“缓冲命中率”体系整体废弃 | - |
| DISK_R_N / DISK_R_BYTES | 确定-动态 | `xugu_disk_reads_total` / `xugu_disk_read_bytes_total` (counter) | IOPS、读吞吐 |
| DISK_W_N / DISK_W_BYTES | 确定-动态(懒刷盘) | `xugu_disk_writes_total` / `xugu_disk_written_bytes_total` (counter) | IOPS、写吞吐 |
| NET_R_BYTES / NET_W_BYTES | **无效-恒零** | 不采集。原“网络吞吐”面板废弃 | - |
| LOCK_REQ_N | **无效-恒零** | 不采集 | - |
| DEAD_LOCK_N | **无效-恒零**（真实死锁 20 分钟不计数，见 SC-5） | 不采集。死锁监控改由长事务兜底 | - |
| S/X/IS/IX/SIX_LOCK_N | 确定-动态 | `xugu_locks{mode}`（UNION 透视） | 锁模式分布 |
| LOCK_WAIT_N | **无效-恒零**（行锁阻塞不计数） | 不采集，改用 LWAITERS 计数 | - |
| ACT_TRANS_NUM | 确定-动态 | `xugu_active_transactions` | 双口径事务对比 |
| MIN_TRANS_ID | 确定 | 不采集（无独立语义） | - |
| MAX_TRANS_ID | 确定-动态 | `xugu_transaction_id_max`（持久化高水位） | **TPS 近似** |
| XLOG_WPOS | 确定-动态 | `xugu_xlog_write_position` | WAL 写速率、检查点延迟 |
| XLOG_CKPT | 确定-动态 | `xugu_xlog_checkpoint_position` | 检查点延迟 |
| SEND/RECV_MSG_N | 不确定-集群 | `xugu_cluster_messages_*_total`（cluster_only） | 集群消息速率 |
| DELAY_STO_N / DROPED_STO_N | 不确定（全程0，场景未覆盖） | 不采集，待集群/删除场景复验 | - |
| FREE_STO_N | 确定-动态 | `xugu_free_stores` | 存储段余量 |

### SYS_ALL_SESSIONS（行集，43 列）

| 字段 | 有效性 | 设计 |
|------|--------|------|
| SQL | **无效-恒NULL**（执行中亦 NULL） | 不可用。活跃判定改用 THD_SESSION（见下） |
| STATUS | 确定-动态（112=空闲 114=执行中，SC-2 验证） | `xugu_sessions_by_status{node,status}` |
| DB_NAME / USER_NAME | 确定 | `xugu_sessions_by_source{node,db,username}` |
| MEM_SIZE | 确定 | SUM → `xugu_sessions_memory_bytes{node}` |
| CMD_START_T | 确定 | 与 THD_SESSION join 取 MIN → `xugu_session_oldest_statement_start_timestamp_seconds` |
| TRANS_START_T | 确定 | 不单独采集（事务时长由 SYS_TRANS.START_T 承担） |
| 其余 35 列（ISO_LEVEL/CHAR_SET/配置类） | 确定-静态 | 会话级配置，无聚合监控价值，不采集 |
| （行数本身） | 确定 | COUNT → `xugu_sessions{node}` |

### SYS_ALL_THD_SESSION（活跃语句的唯一可靠来源）

| 字段 | 设计 |
|------|------|
| （行数） | COUNT → `xugu_sessions_active{node}`：出现在本表 = 正在执行语句 |
| SQL | 有值（实测），但文本不入指标（高基数）；排障时直接查库 |
| STATE | 不确定（观测 19=执行），暂不采集 |

### SYS_ALL_TRANS

| 字段 | 设计 |
|------|------|
| （行数） | COUNT → `xugu_transactions_active{node}`；注意等待首锁的事务不在本表（SC-3 实测） |
| START_T | MIN → `xugu_transaction_oldest_start_timestamp_seconds{node}` |
| MODIFY_COUNT | 不确定（UPDATE 持锁期间仍 0），不采集 |
| IS_PROXY/R_NODE 等 | 分布式路由信息，不采集 |

### SYS_ALL_MONITORS（42 键值对）

- 9 键恒零无效（REQUEST_NUM、BUFF_VISIT_NUM、CMIT/UNDO/ALL_MODI_NUM、LOCK_REQ/WAIT_NUM、NET_*）→ 不采集；
- 21 键与 RUN_INFO 同源重复（DISK_*、XLOG_*、*_LOCK_NUM、ACT_TRANS_NUM、MIN/MAX_TRANS_ID、DEAD_LOCK_NUM）→ 不重复采集；
- LMSG/SMSG_BUF_NUM 静态缓冲配置 → 不采集；
- **12 个 `*_MEM` 内存池键有效** → `xugu_memory_pool_bytes{node,pool}`。

### SYS_ALL_MEM_STATUS（单行/节点）

全部字段确定有效。块数×块大小换算为字节后暴露 9 个 gauge：
`xugu_buffer_pool_bytes/_free/_dirty/_lru`、`xugu_sga_bytes/_free/_peak`、`xugu_swap_bytes/_free`。

### 锁视图（SYS_ALL_LWAITERS / LOWNERS / GLOCKS / GOWNERS / GWAITERS）

| 对象 | 实测结论 | 设计 |
|------|----------|------|
| LWAITERS | **仅表级锁等待可见**；行锁阻塞全程 0（SC-3/SC-4 对照） | COUNT → `xugu_lock_waiters`，help 注明限制 |
| LOWNERS | 行/表锁持有者均可见（含事务锁 LOCK_TYPE=8） | COUNT → `xugu_lock_owners`；明细 join → `xugu_lock_wait_info`（info 型，值恒1） |
| GLOCKS/GWAITERS | 单机=本地锁镜像，集群语义 | cluster_only：`xugu_global_locks` / `xugu_global_lock_waiters` |

### 容量对象（SYS_ALL_TABLESPACES × SYS_CTL_VARS / SYS_ALL_DATAFILES）

| 字段 | 设计 |
|------|------|
| TOTAL/FREE_CHUNK_NUM × CHUNK_SIZE | `xugu_tablespace_bytes` / `xugu_tablespace_free_bytes`；**系统空间 FREE 恒 0 属正常**，使用率只对 DATA/TEMP 计算 |
| MEDIA_ERROR | `xugu_tablespace_media_error`（0/1） |
| DATAFILE_NUM | `xugu_tablespace_datafiles` |
| DATAFILES.CURR_SIZE(MB) | SUM×1024² → `xugu_datafile_bytes`（与表空间口径差 ≤1 chunk，MS-13 验证） |
| MAX_SIZE/STEP_SIZE | 静态配置，不采集 |

### 日志文件表（SLOWSQL / ERROR / EVENT / TRACE / COMMAND）

| 对象 | 设计 |
|------|------|
| SLOWSQL_LOG | 累计 `xugu_slowsql_total{node}`(counter)；近10分钟窗口 `xugu_slowsql_recent` + `xugu_slowsql_recent_max_duration_seconds`（SYSDATE 窗口，空窗口输出 0/缺失） |
| ERROR_LOG | `xugu_errorlog_total{node,level}`(counter)；全表扫描是最慢采集域（1.4s@13.6万行），TTL 60s 缓解 |
| EVENT_LOG | `xugu_eventlog_total{node,type}`(counter) |
| TRACE_LOG | 存在(1.1万行)但为 SQL 跟踪明细，量大且需开关驱动，暂不采集（矩阵记录） |
| COMMAND_LOG | 0 行（未开命令日志），不采集 |

### 其他堆表/虚表

| 对象 | 设计 |
|------|------|
| SYS_CLUSTERS | `xugu_node_state{node,node_type}`、`xugu_node_boot_timestamp_seconds`、`xugu_node_stores/major_stores`、`xugu_cluster_nodes{state}`；**CPU_LOAD 恒50疑似桩值**，保留指标但 help/面板明示勿作依据 |
| SYS_GSTORES | STORE_STA 分组 → `xugu_gstores{sta}`（健康=1，实测修正了文档口径 41） |
| SYS_DATABASES | `xugu_database_online{db}` |
| SYS_USERS | `xugu_users` / `xugu_users_locked` / `xugu_users_expired`（SC-9 验证锁定计数） |
| SYS_ALL_FORBIDDEN_IPS | `xugu_forbidden_ips`（禁测场景，语义按文档） |
| SYS_RECYCLEBIN | `xugu_recyclebin_objects`（SC-8 验证增减） |
| SYS_VARS | 8 个关键参数 → `xugu_setting{name}`（true/false→1/0） |
| SYS_JOBS / SYS_BACKUP_* | `xugu_jobs/_enabled`、`xugu_backup_plans_enabled/_items/_next_run_timestamp_seconds`（空表 COALESCE 保证输出） |
| SYS_AUDIT_DEFS/RULES、SYS_PROFILES、SYS_STO_ZONES、SYS_ALL_RESTORES | 本环境 0 行，语义未验证 → 暂不采集，矩阵中记录待复验 |

## 3. 综合指标（PromQL 层，面板/告警使用）

| 综合指标 | 表达式 | 用途/阈值 |
|----------|--------|-----------|
| 连接使用率 | `100 * sum(xugu_sessions) / xugu_max_connections` | 总览 gauge；告警 80%/95% |
| 会话活跃率 | `sum(xugu_sessions_active) / sum(xugu_sessions)` | 容量规划参考 |
| TPS（近似） | `sum(rate(xugu_transaction_id_max[$__rate_interval]))` | 事务速率面板（含内部事务；替代无效的提交/回滚计数） |
| WAL 写入速率 | `rate(xugu_xlog_write_position[$__rate_interval])` | 写负载实时指标（物理写为懒刷盘不实时） |
| 检查点延迟 | `xugu_xlog_write_position - xugu_xlog_checkpoint_position` | >2GB 告警；宕机恢复时间代理 |
| 磁盘 IOPS / 吞吐 | `rate(xugu_disk_reads_total[...])` 等 4 条 | 性能行 |
| 缓冲池使用率 | `1 - xugu_buffer_pool_free_bytes / xugu_buffer_pool_bytes` | 替代无效的命中率 |
| 脏页占比 | `xugu_buffer_pool_dirty_bytes / xugu_buffer_pool_bytes` | 刷盘压力 |
| DATA 空间使用率 | `100*(1 - free/total){type="DATA_SPACE"}` | bargauge/告警 85%/95%，**必须按 type 过滤** |
| 7 天写满预测 | `predict_linear(xugu_tablespace_free_bytes{type="DATA_SPACE"}[1d], 7*86400) < 0` | 容量预警（面板用 6h 窗、clamp_min 0） |
| 最长事务时长 | `time() - min(xugu_transaction_oldest_start_timestamp_seconds)` | >30min 告警；**死锁兜底信号**（12.0.0 死锁无自动检测） |
| 最长语句时长 | `time() - min(xugu_session_oldest_statement_start_timestamp_seconds)` | >10min 告警（失控查询） |
| 双口径事务差 | `sum(xugu_active_transactions) - sum(xugu_transactions_active)` | ≈等待首锁的事务数（行锁排队深度的间接信号） |
| 错误日志速率 | `increase(xugu_errorlog_total{level="ERROR"}[5m])` | >50 告警 |
| 慢 SQL 压力 | `xugu_slowsql_recent` | >20 告警（窗口口径，替代 increase 差分） |
| 采集健康 | `sum(1 - xugu_collector_success)` | >0 面板红显 |
| 节点存活/仓储健康 | `xugu_node_state != 2`、`sum(xugu_gstores{sta!="1"}) > 0` | 集群告警 |

## 4. 已废弃指标与迁移对照

| 旧指标（≤v1） | 处置 | 替代 |
|---------------|------|------|
| xugu_requests_total | 删除（恒0） | TPS 近似：rate(xugu_transaction_id_max) |
| xugu_buffer_reads_total + 命中率面板/告警 | 删除（恒0） | 缓冲池使用率/脏页占比 |
| xugu_net_read/sent_bytes_total | 删除（恒0） | 集群版用 xugu_cluster_messages_*_total |
| xugu_lock_requests_total | 删除（恒0） | - |
| xugu_lock_waiting | 删除（恒0） | xugu_lock_waiters（表级锁口径） |
| xugu_deadlocks_total + 死锁告警 | 删除（真实死锁不计数） | 长事务告警兜底 + 阻塞链人工排查 |
| xugu_monitor{name}（42键透传） | 删除（9死键+21重复） | xugu_memory_pool_bytes{pool}（12 有效键） |
| xugu_slowsql_max_duration_milliseconds | 删除（全表历史最大值，误导） | xugu_slowsql_recent_max_duration_seconds（近10分钟） |
