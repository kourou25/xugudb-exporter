# XuguDB 12.0.0 监控参考笔记（文档结论 + 实测修正）

> 汇总本项目开发过程中从官方文档（D:\claude-www\docs-develop）、always-sql 运维脚本库
> 与真实库实测得到的全部关键事实，避免重复分析。逐字段证据见 field-validation-matrix.md，
> 指标设计见 metrics-design.md，用例见 test-plan.md，常用脚本验证见 ../always-sql/validation-report.md。

## 1. 错误日志级别体系（SYS_ERROR_LOG.EX_LEVEL，9 级）

| 级别 | 含义 | 监控权重 |
|------|------|----------|
| NOTICE | 事务执行中的警告 | 低 |
| USEREX | 用户定义错误（RAISE 等） | 低 |
| ERROR | 命令级错误（使用错误/违反约束） | 中（激增才告警） |
| ABORT | 事务被中止（含 KILL） | **高** |
| DLOCK | 死锁（对应错误码 E14001） | **高** |
| L06 | 陈旧事务（活动事务号差超约 600 万） | **高** |
| SYSEX | 系统内部异常（存取保护/存储异常） | **致命** |
| NETER | 网络错误（E1011 发送失败等） | 中 |
| MEMER | 内存错乱 | **致命** |

- `error_level` 参数（当前=3）：0 不记/1 只记大于命令级/2 不记警告/≥3 全记。
- 日志按 `errlog_size`（默认 100MB）滚动归档（重命名 SLOWSQL_yy_mm_dd... 式后缀），
  归档时表计数回落——counter 型指标出现回落属正常。
- 出处：docs-develop/src/content/management/log/error_log.md、
  reference/system-configuration-parameter/xugu.ini/log/error_level.md。

## 2. 事件日志类型（SYS_EVENT_LOG.EVENT_TYPE，16 主类）

BACKUP、CKPT/CKPT1（全量/增量检查点）、CLU_EVENT（节点接入/死亡）、SYS_START/SYS_START_ERR、
DB_OPEN、DEAD_LOCK、EXCEPTION（系统线程异常）、IB_ERR（Infiniband）、KILL_TRANS、MEDIA_ERR、
MIGRATE（存储均衡）、MOUNT_ERR*、REPAIR*（REDO 恢复）、RESTORE*、SYS_EXIT、XLOG_REG。
监控重点：CLU_EVENT、EXCEPTION、MEDIA_ERR、REPAIR_ERR、SYS_START_ERR。
出处：management/log/event_log.md（含 57 条明细格式）。

## 3. 错误码分段（ERR_CODE）

| 码段 | 类别 | 告警级候选 |
|------|------|-----------|
| E1xxx | 网络/连接会话 | E1011 发送失败 |
| E2xxx | 权限/安全 | - |
| E3xxx | 存储/数据块 | E3032/E3033 数据块错（严重） |
| E5xxx | 索引/系统表 | E5021 对象不存在 |
| E10xxx | SQL 语法/参数 | - |
| E14xxx | 锁/事务 | **E14001 死锁** |
| E15xxx | 记录/行数据 | - |
| E17xxx | 数据类型 | - |
| E19xxx | 系统/内存 | **E19002 存取保护、E19003 非法指令、E19016/17 内存分配释放（致命）** |

## 4. 锁体系（官方文档 + 实测）

- **全局锁管理**：LOCK_TYPE 枚举 1-13：1 库级 / 2 对象操作 / 3 对象存储维护 / 5 全局存储 /
  6 局部存储读写 / 7 局部存储迁移 / **8 事务锁(LOCK_ID=事务号)** / 9 用户名 / 10 数据装载 /
  11 全局存储修复 / 12 表分区扩展 / 13 全局临时表。
- **LOCK_ID 解析**：对象 ID = `BIT_AND(LOCK_ID, 4294967295)`（低 32 位）；高位低 24 位=库 ID。
  对象名解析：`SYS_OBJECTS`（用户对象，OBJ_TYPE 1-30 枚举见 always-sql/常用运维监控脚本.sql），
  系统表回落 `SYS_SYSTEM_TABLES.TABLE_ID`。
- **SYS_LOWNERS/LWAITERS = 实时锁视图**；**SYS_GLOCKS = 懒释放全局锁（非实时）**：
  非排他锁的全局锁延迟到有排他请求时才释放，GLOCKS 数量偏大属正常，不宜直接告警。
- **实测限制（12.0.0 单机）**：行级锁（UPDATE 同行）阻塞不注册到 LWAITERS/LOCK_WAIT_N/
  THD_STATUS 等待状态；等待首锁的事务连 SYS_TRANS 都不出现。行锁交叉死锁不被自动检测
  （实测互等 20 分钟无报错、DEAD_LOCK_N 恒 0），监控上表现为长事务，靠长事务/事务号差告警兜底。
- **处理手段**：`EXEC DBMS_DBA.KILL_TRANS(节点ID, 事务ID);`（官方运维脚本口径）。
- LOCK_LEVEL：S/X/IS/IX/SIX（SIX 文档注明"暂未使用"）。
- **⚠️ RUN_INFO 锁计数列不可信（重要）**：`SYS_ALL_RUN_INFO` 的 `S/X/IS/IX/SIX_LOCK_N` 五列
  在 12.0.0 存在计数漂移，实测出现负值（如 `IS_LOCK_N=-310`、`IX_LOCK_N=-11`）且与
  `SYS_ALL_LOWNERS` 实际持有记录（IS=2）严重不符，三次采样稳定复现。**锁数量必须以
  `SYS_ALL_LOWNERS` 按 `LOCK_LEVEL` 聚合为准**；exporter 的 `xugu_locks{mode}` 已据此改造，
  RUN_INFO 仅用于枚举节点。回归用例 MS-8/MS-8b 固化该校验。

## 5. 会话与线程

- `SYS_SESSIONS.SQL` **仅 prepare 语句时有值**（文档+实测一致，直接执行的语句为空，
  prepare 的带 "GTONG0:" 前缀）→ 通用活跃会话判定必须用 `SYS_ALL_THD_SESSION`（含 SQL 文本）。
- SESSIONS.STATUS 实测：112=空闲、114=执行中。
- 工作线程 `SYS_THD_STATUS.TYPE=9`；STATE：0=空闲，锁/资源等待状态集={2,4,5,6,8,11,12}
  （官方运维脚本口径）；实测行锁等待线程不进入该状态集。

## 6. 集群编码（SYS_CLUSTERS）

- NODE_TYPE 位掩码：1 主M + 2 副M + 4 存储S + 8 查询Q + 16 工作W + 32 变更；29=M+S+Q+W（单机全角色）。
- NODE_STATE：0 未联机 / 1 刚加入 / 2 正常运行 / 3 出错 / 4 宕机。
- CPU_LOAD 实测恒 50（疑似桩值，勿作依据）。

## 7. 容量与存储

- **数据文件自动扩展**：`MAX_SIZE=-1` 不设上限，按 `STEP_SIZE`（实测 64MB）增长——
  表空间"使用率"是已分配空间口径，高使用率≈即将触发扩展，真正硬限制是磁盘剩余空间。
- 系统空间（GSYS/UNDO_SYS/LSYS）按需整块分配，FREE 恒 0 属正常，使用率只对 DATA/TEMP 有意义。
- CHUNK_SIZE=8MB（SYS_CTL_VARS）；库级存储估算 = SYS_GSTORES 按 DB_ID 计数 × 8MB。
- GSTORES 健康态 STORE_STA=1（实测；文档口径 41 不适用于 12.0.0）。

## 8. 计数器有效性（12.0.0 实测恒零，来源 field-validation-matrix.md）

无效：REQ_N、BUFF_R_N（缓冲命中体系）、NET_R/W_BYTES、LOCK_REQ_N、DEAD_LOCK_N
及 SYS_MONITORS 同源死键 → 缓冲命中率/网络吞吐/提交回滚速率在此版本无法实现。
复验修正：LOCK_WAIT_N/LOCK_WAIT_NUM 为活字段（表级锁瞬时等待计数，行锁不计入），
与 LWAITERS 计数口径等价，指标层保留 LWAITERS 口径避免重复。
替代：TPS≈rate(MAX_TRANS_ID)、写负载=rate(XLOG_WPOS)、缓冲池使用率=1-free/total。

## 9. 系统字典中不存在的表（14，参考资料有误，非版本缺失）

SYS_CACHE_STATUS、SYS_IO_STATUS、SYS_LOCK_WAITS、SYS_DEAD_LOCKS、SYS_ROW_LOCKS、
SYS_TABLE_LOCKS、SYS_META_LOCKS、SYS_TRANS_LOCKS、SYS_PAGE_STATUS、SYS_LOG_STATUS、
SYS_REDO_STATUS、SYS_CHECKPOINT、SYS_STORAGE_STATUS、SYS_AUDIT_RESULTS（审计实为 SYS_AUDIT_RULES）。
经确认这些表本身不是 12.0.0 系统字典成员，系本地参考资料（skill/早期计划）错误。

## 10. 其他运维要点（来自 always-sql 验证，详见 validation-report.md）

- 失效对象（VALID=FALSE 的视图/过程/触发器/包）用 always-sql/依赖对象重编译.sql 生成 RECOMPILE 修复。
- HISTORY_SQL 表不存在（E5021）——历史 SQL 需靠 SYS_COMMAND_LOG（需 `SET reg_command TO true` 开启）。
- 命令日志/DDL 日志开关：`SET reg_command TO true` / `SET reg_ddl TO true`（可按节点）。
- 慢 SQL 的 ELAPSE_TIME 有 ±5ms 误差属正常。
- 表碎片率查询 join 重，只适合 30-60 分钟级低频或手工执行。
