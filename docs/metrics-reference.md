# 指标参考手册：指标清单与 SQL 对照（自动生成）

> 由 `tools/gen_metrics_reference.py` 从 `configs/metrics-default.yml` 生成，请勿手改。
> 每个采集域=一条 SQL；TTL=结果缓存（该周期内重复抓取不re执行 SQL）；
> "仅集群"域在单机自动跳过。另有引擎内置指标与主机指标见文末。

## 采集域总览

| # | 采集域 | 指标数 | TTL | 仅集群 | 模式 |
|--|--|--|--|--|--|
| 1 | info | 1 | 300s |  | rows |
| 2 | node_info | 5 | - |  | rows |
| 3 | sessions | 2 | - |  | rows |
| 4 | sessions_active | 2 | - |  | rows |
| 5 | sessions_by_status | 1 | - |  | rows |
| 6 | sessions_by_source | 1 | - |  | rows |
| 7 | max_connections | 1 | 300s |  | rows |
| 8 | transactions | 2 | - |  | rows |
| 9 | run_info | 10 | - |  | rows |
| 10 | locks_by_mode | 1 | - |  | rows |
| 11 | lock_waiters | 2 | - |  | rows |
| 12 | lock_wait_detail | 1 | - |  | rows |
| 13 | lock_owner_detail | 1 | - |  | rows |
| 14 | glock_waiters | 2 | - | 是 | rows |
| 15 | cluster_msgs | 2 | - | 是 | rows |
| 16 | worker_threads | 1 | - |  | rows |
| 17 | worker_threads_waiting | 1 | - |  | rows |
| 18 | threads_memory | 2 | - |  | rows |
| 19 | active_statements | 1 | - |  | rows |
| 20 | cluster_msg_quality | 1 | - | 是 | keyvalue |
| 21 | memory | 9 | - |  | rows |
| 22 | memory_pools | 1 | - |  | keyvalue |
| 23 | tablespaces | 4 | 60s |  | rows |
| 24 | datafiles | 1 | 60s |  | rows |
| 25 | slowsql | 1 | 60s |  | rows |
| 26 | slowsql_recent | 2 | 60s |  | rows |
| 27 | slowsql_top | 1 | 60s |  | rows |
| 28 | errorlog | 1 | 60s |  | rows |
| 29 | errorlog_top | 1 | 60s |  | rows |
| 30 | errorlog_fatal | 1 | 60s |  | rows |
| 31 | eventlog | 1 | 120s |  | rows |
| 32 | cluster_nodes | 1 | - |  | rows |
| 33 | gstores | 1 | 60s |  | rows |
| 34 | databases | 1 | 120s |  | rows |
| 35 | invalid_objects | 1 | 300s |  | rows |
| 36 | database_storage | 1 | 300s |  | rows |
| 37 | object_storage_top | 1 | 300s |  | rows |
| 38 | schema_storage_top | 1 | 300s |  | rows |
| 39 | storage_fragment | 2 | 300s |  | rows |
| 40 | users | 3 | 120s |  | rows |
| 41 | forbidden_ips | 1 | 120s |  | rows |
| 42 | recyclebin | 1 | 120s |  | rows |
| 43 | settings | 1 | 300s |  | keyvalue |
| 44 | jobs | 2 | 120s |  | rows |
| 45 | backup | 3 | 300s |  | rows |

共 45 个采集域、83 个 SQL 来源指标。

## 指标 ↔ SQL 对照明细

### 采集域 `info`（TTL 300s）

```sql
SELECT VERSION() AS VERSION FROM DUAL
```

**SQL 说明**：调用内置函数 VERSION() 获取版本字符串；DUAL 为单行哑表。版本作为 label 输出，值恒为 1（info 型指标惯例）。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_info` | gauge | version | 虚谷数据库版本信息（值恒为1，版本在 label 中） |

### 采集域 `node_info`

```sql
SELECT NODE_ID AS NODE, NODE_TYPE, NODE_STATE, CPU_LOAD,
       STORE_NUM, MAJOR_NUM, BOOT_TIME
FROM SYS_CLUSTERS
```

**SQL 说明**：读集群节点注册表 SYS_CLUSTERS：状态码/角色位掩码/启动时间/存储段计数。BOOT_TIME 为 DATETIME，引擎自动转 Unix 秒，面板用 time()-x 计算运行时长。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_node_state` | gauge | node, node_type | 节点状态码：0=未联机 1=刚加入 2=正常运行 3=出错 4=宕机（官方文档口径） |
| `xugu_node_cpu_load_percent` | gauge | node | 节点 CPU 负载百分比（12.0.0 单机实测恒为 50，疑似未实现的桩值，仅供集群版参考） |
| `xugu_node_boot_timestamp_seconds` | gauge | node | 节点启动时间(Unix秒)，uptime = time() - 本值 |
| `xugu_node_stores` | gauge | node | 节点存储段总数 |
| `xugu_node_major_stores` | gauge | node | 节点主存储段数（分布式下 < STORE_NUM 表示存在副本/修复中） |

### 采集域 `sessions`

```sql
SELECT NODEID AS NODE, COUNT(*) AS CNT, SUM(MEM_SIZE) AS MEM_BYTES
FROM SYS_ALL_SESSIONS GROUP BY NODEID
```

**SQL 说明**：对全局会话表 SYS_ALL_SESSIONS 按节点计数并求和 MEM_SIZE，得到会话总数与会话内存合计。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_sessions` | gauge | node | 当前会话总数 |
| `xugu_sessions_memory_bytes` | gauge | node | 全部会话占用内存合计(字节) |

### 采集域 `sessions_active`

```sql
SELECT T.NODEID AS NODE, COUNT(*) AS ACTIVE, MIN(S.CMD_START_T) AS OLDEST_CMD
FROM SYS_ALL_THD_SESSION T
JOIN SYS_ALL_SESSIONS S ON T.NODEID=S.NODEID AND T.SESSION_ID=S.SESSION_ID
GROUP BY T.NODEID
```

**SQL 说明**：以线程-会话绑定表 SYS_ALL_THD_SESSION 为准判定"正在执行"（出现在该表即正在执行语句；SYS_SESSIONS.SQL 列仅 prepare 语句有值，不能做通用判定）。回联 SYS_ALL_SESSIONS 取 CMD_START_T 最小值，得到运行最久语句的开始时间。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_sessions_active` | gauge | node | 正在执行语句的会话数(SYS_ALL_THD_SESSION 口径，含 exporter 自身) |
| `xugu_session_oldest_statement_start_timestamp_seconds` | gauge | node | 运行中最久语句的开始时间(Unix秒)，最长语句时长 = time() - 本值 |

### 采集域 `sessions_by_status`

```sql
SELECT NODEID AS NODE, STATUS, COUNT(*) AS CNT
FROM SYS_ALL_SESSIONS GROUP BY NODEID, STATUS
```

**SQL 说明**：按 SYS_ALL_SESSIONS.STATUS 状态码分组计数（112=空闲、114=执行中）。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_sessions_by_status` | gauge | node, status | 按状态码分组的会话数(实测 112=空闲 114=执行中) |

### 采集域 `sessions_by_source`

```sql
SELECT NODEID AS NODE, DB_NAME AS DB, USER_NAME AS USERNAME, COUNT(*) AS CNT
FROM SYS_ALL_SESSIONS GROUP BY NODEID, DB_NAME, USER_NAME
```

**SQL 说明**：按 库+用户 分组的会话计数，用于定位连接来源；基数随库/用户数增长，可用 disabled_groups 关停。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_sessions_by_source` | gauge | node, db, username | 按数据库/用户分组的会话数 |

### 采集域 `max_connections`（TTL 300s）

```sql
SELECT NODEID AS NODE, TO_NUMBER(VAR_VALUE) AS MAX_CONN
FROM SYS_ALL_VARS WHERE VAR_NAME='max_conn_num'
```

**SQL 说明**：从全局参数表 SYS_ALL_VARS 取 max_conn_num 并 TO_NUMBER 转数值；用 ALL 表保证集群下各节点分别输出（集群总容量=各节点之和）。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_max_connections` | gauge | node | 节点最大连接数(max_conn_num)；集群总容量 = sum(本指标) |

### 采集域 `transactions`

```sql
SELECT NODEID AS NODE, COUNT(*) AS CNT, MIN(START_T) AS OLDEST
FROM SYS_ALL_TRANS GROUP BY NODEID
```

**SQL 说明**：对活跃事务表 SYS_ALL_TRANS 按节点计数并取最早 START_T。注意：等待行锁且尚未获得首个锁的事务不会出现在该表。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_transactions_active` | gauge | node | 活跃事务数。注意：等待行锁且尚未获得首个锁的事务不在此列（实测） |
| `xugu_transaction_oldest_start_timestamp_seconds` | gauge | node | 最老活跃事务开始时间(Unix秒)。长事务持续增长可能是行锁互等死锁——12.0.0 死锁不被自动检测(实测互等20分钟无检出)，需人工介入 |

### 采集域 `run_info`

```sql
SELECT NODEID AS NODE, DISK_R_N, DISK_R_BYTES, DISK_W_N, DISK_W_BYTES,
       ACT_TRANS_NUM, MAX_TRANS_ID, XLOG_WPOS, XLOG_CKPT, FREE_STO_N,
       MAX_TRANS_ID-MIN_TRANS_ID AS TRANS_SPAN
FROM SYS_ALL_RUN_INFO
```

**SQL 说明**：读单行运行计数器表 SYS_ALL_RUN_INFO：物理读写(懒刷盘语义)、WAL 写入/检查点位置、事务ID高水位与跨度(MAX-MIN，L06 预警)、空闲存储段。仅保留有效字段。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_disk_reads_total` | counter | node | 累计磁盘物理读次数(缓冲全命中时不增长) |
| `xugu_disk_read_bytes_total` | counter | node | 累计磁盘物理读字节数 |
| `xugu_disk_writes_total` | counter | node | 累计磁盘物理写次数(脏页懒刷盘，写入首先体现在 WAL) |
| `xugu_disk_written_bytes_total` | counter | node | 累计磁盘物理写字节数 |
| `xugu_active_transactions` | gauge | node | 当前活跃事务数(RUN_INFO 口径) |
| `xugu_transaction_id_max` | gauge | node | 事务ID高水位(持久化,重启不清零)。rate() 即事务开启速率，可作 TPS 近似(含内部事务) |
| `xugu_xlog_write_position` | gauge | node | WAL 日志写入位置(字节,持久化)。rate() 即 WAL 写入速率，是写负载的实时指标 |
| `xugu_xlog_checkpoint_position` | gauge | node | WAL 检查点位置(字节,持久化)，检查点延迟 = write_position - 本值 |
| `xugu_free_stores` | gauge | node | 空闲存储段数量 |
| `xugu_transaction_id_span` | gauge | node | 最大与最小活动事务号之差。超过 600万 会触发 L06 陈旧事务异常（官方文档），持续增长说明有事务长期不结束 |

### 采集域 `locks_by_mode`

```sql
SELECT NODEID AS NODE, 'S'   AS MODE, S_LOCK_N   AS CNT FROM SYS_ALL_RUN_INFO UNION ALL
SELECT NODEID, 'X',   X_LOCK_N   FROM SYS_ALL_RUN_INFO UNION ALL
SELECT NODEID, 'IS',  IS_LOCK_N  FROM SYS_ALL_RUN_INFO UNION ALL
SELECT NODEID, 'IX',  IX_LOCK_N  FROM SYS_ALL_RUN_INFO UNION ALL
SELECT NODEID, 'SIX', SIX_LOCK_N FROM SYS_ALL_RUN_INFO
```

**SQL 说明**：用 5 段 UNION ALL 把 RUN_INFO 的 S/X/IS/IX/SIX 五个锁计数列转成带 mode 标签的行式指标。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_locks` | gauge | node, mode | 当前持有锁数量(按锁模式 S/X/IS/IX/SIX) |

### 采集域 `lock_waiters`

```sql
SELECT (SELECT COUNT(*) FROM SYS_ALL_LWAITERS) AS LWAIT,
       (SELECT COUNT(*) FROM SYS_ALL_LOWNERS)  AS LOWN
FROM DUAL
```

**SQL 说明**：两个标量子查询分别统计锁等待者(SYS_ALL_LWAITERS)与持有者(SYS_ALL_LOWNERS)行数。等待仅表级锁可见。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_lock_waiters` | gauge |  | 当前等待锁的事务数(仅表级锁可见；行锁阻塞不可见，靠长事务发现) |
| `xugu_lock_owners` | gauge |  | 当前持有锁的事务数 |

### 采集域 `lock_wait_detail`

```sql
SELECT W.NODEID AS NODE, W.WAIT_TID,
       CASE W.LOCK_TYPE WHEN 1 THEN '库级' WHEN 2 THEN '对象操作' WHEN 3 THEN '对象存储维护'
            WHEN 5 THEN '全局存储' WHEN 6 THEN '局部存储读写' WHEN 7 THEN '局部存储迁移'
            WHEN 8 THEN '事务' WHEN 9 THEN '用户名' WHEN 10 THEN '数据装载'
            WHEN 11 THEN '全局存储修复' WHEN 12 THEN '表分区扩展' WHEN 13 THEN '全局临时表'
            ELSE TO_CHAR(W.LOCK_TYPE) END AS LOCK_KIND,
       BIT_AND(W.LOCK_ID,4294967295) AS OBJ_ID,
       COALESCE(OB.OBJ_NAME, ST.TABLE_NAME, '') AS OBJ_NAME,
       O.OWNER_TID, O.OWNER_SID, O.LOCK_LEVEL AS OWNER_LEVEL
FROM SYS_ALL_LWAITERS W
JOIN SYS_ALL_LOWNERS O
  ON W.LOCK_TYPE=O.LOCK_TYPE AND W.LOCK_ID=O.LOCK_ID AND W.NODEID=O.NODEID
LEFT JOIN SYS_OBJECTS OB ON W.LOCK_TYPE IN (2,3,10,12,13)
  AND OB.OBJ_ID=BIT_AND(W.LOCK_ID,4294967295)
  AND OB.DB_ID=BIT_AND(TRUNC(W.LOCK_ID/4294967296),16777215)
LEFT JOIN SYS_SYSTEM_TABLES ST ON W.LOCK_TYPE IN (2,3,10,12,13)
  AND ST.TABLE_ID=BIT_AND(W.LOCK_ID,4294967295) AND OB.OBJ_ID IS NULL
```

**SQL 说明**：等待者与持有者按 锁类型+锁ID+节点 关联出阻塞链；CASE 将 LOCK_TYPE 1-13 译为中文；BIT_AND(LOCK_ID,4294967295) 取低 32 位得到对象 ID（高位低 24 位为库 ID），LEFT JOIN SYS_OBJECTS 解析对象名、系统表回落 SYS_SYSTEM_TABLES。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_lock_wait_info` | gauge | node, wait_tid, lock_kind, obj_id, obj_name, owner_tid, owner_sid, owner_level | 锁等待阻塞链：等待事务 wait_tid 被会话 owner_sid(事务 owner_tid) 阻塞，含锁类型与对象名。仅表级锁场景有数据（行锁等待不注册到锁视图） |

### 采集域 `lock_owner_detail`

```sql
SELECT O.NODEID AS NODE, O.OWNER_SID, O.OWNER_TID, O.LOCK_LEVEL,
       CASE O.LOCK_TYPE WHEN 1 THEN '库级' WHEN 2 THEN '对象操作' WHEN 3 THEN '对象存储维护'
            WHEN 5 THEN '全局存储' WHEN 6 THEN '局部存储读写' WHEN 7 THEN '局部存储迁移'
            WHEN 8 THEN '事务' WHEN 9 THEN '用户名' WHEN 10 THEN '数据装载'
            WHEN 11 THEN '全局存储修复' WHEN 12 THEN '表分区扩展' WHEN 13 THEN '全局临时表'
            ELSE TO_CHAR(O.LOCK_TYPE) END AS LOCK_KIND,
       COALESCE(OB.OBJ_NAME, ST.TABLE_NAME, '') AS OBJ_NAME
FROM SYS_ALL_LOWNERS O
LEFT JOIN SYS_OBJECTS OB ON O.LOCK_TYPE IN (2,3,10,12,13)
  AND OB.OBJ_ID=BIT_AND(O.LOCK_ID,4294967295)
  AND OB.DB_ID=BIT_AND(TRUNC(O.LOCK_ID/4294967296),16777215)
LEFT JOIN SYS_SYSTEM_TABLES ST ON O.LOCK_TYPE IN (2,3,10,12,13)
  AND ST.TABLE_ID=BIT_AND(O.LOCK_ID,4294967295) AND OB.OBJ_ID IS NULL
WHERE O.LOCK_LEVEL IN ('X','IX','SIX')
  AND ST.TABLE_NAME IS NULL  -- 过滤系统虚表自锁（exporter 采集查询自身产生的噪音）
LIMIT 20
```

**SQL 说明**：从持有者视图筛选排他类锁（X/IX/SIX），对象名解析同阻塞链；过滤掉解析为系统表的行以排除采集器自身查询产生的自锁噪音，LIMIT 20 控制规模。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_lock_owner_info` | gauge | node, owner_sid, owner_tid, lock_level, lock_kind, obj_name | 当前持有排他类锁(X/IX/SIX)的明细：会话/事务/锁级别/锁类型/对象名（最多20条；已过滤系统虚表自锁噪音，无业务锁时为空） |

### 采集域 `glock_waiters`（仅集群）

```sql
SELECT (SELECT COUNT(*) FROM SYS_ALL_GWAITERS) AS GWAIT,
       (SELECT COUNT(*) FROM SYS_ALL_GLOCKS)   AS GLOCK
FROM DUAL
```

**SQL 说明**：集群全局锁计数（GWAITERS/GLOCKS 行数）。GLOCKS 为懒释放（非排他锁延迟到有排他请求时才释放），数量偏大属正常。仅集群启用。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_global_lock_waiters` | gauge |  | 集群全局锁等待数(分布式) |
| `xugu_global_locks` | gauge |  | 集群全局锁数量。注意：非排他锁的全局锁为懒释放（有排他请求时才释放），数量偏大且缓慢累积属正常，不宜直接告警 |

### 采集域 `cluster_msgs`（仅集群）

```sql
SELECT NODEID AS NODE, SEND_MSG_N, RECV_MSG_N FROM SYS_ALL_RUN_INFO
```

**SQL 说明**：RUN_INFO 中节点间消息收发累计计数。仅集群启用。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_cluster_messages_sent_total` | counter | node | 集群节点间累计发送消息数 |
| `xugu_cluster_messages_received_total` | counter | node | 集群节点间累计接收消息数 |

### 采集域 `worker_threads`

```sql
SELECT NODEID AS NODE, STATE AS CODE,
       CASE STATE WHEN 0 THEN '空闲' WHEN 1 THEN '运行中'
            WHEN 2 THEN '等buffer加锁' WHEN 3 THEN '等自由buffer内存'
            WHEN 4 THEN '等全局锁' WHEN 5 THEN '等全局锁(限时)'
            WHEN 6 THEN '等本地锁' WHEN 7 THEN '等本地锁(限时)'
            WHEN 8 THEN '等局部锁释放' WHEN 9 THEN '等局部锁(限时)'
            WHEN 10 THEN '等事务提交' WHEN 11 THEN '等redo日志内存'
            WHEN 12 THEN '等日志写盘' WHEN 13 THEN '等消息发送窗口'
            WHEN 14 THEN '等数据同步' WHEN 15 THEN '等RFC调用返回'
            WHEN 16 THEN '等RMC调用返回' WHEN 17 THEN '等RBC发送窗口'
            WHEN 18 THEN '等RBC调用返回' WHEN 19 THEN 'RPC读取等数据'
            WHEN 20 THEN 'RPC发送等窗口' WHEN 21 THEN '弹射器读等数据'
            WHEN 22 THEN '弹射器等发送窗口' WHEN 23 THEN '弹射器等管线取消'
            WHEN 24 THEN '等代理事务提交' WHEN 25 THEN '等变更日志记载'
            WHEN 26 THEN '等buffer写盘'
            ELSE '状态'||STATE END AS STATE,
       COUNT(*) AS CNT
FROM SYS_ALL_THD_STATUS WHERE TYPE=9 GROUP BY NODEID, STATE
```

**SQL 说明**：对线程状态表 SYS_ALL_THD_STATUS 过滤 TYPE=9（任务处理线程）按 STATE 分组计数；CASE 按官方状态表把 0-26 译为中文，同时保留原始码为 code 标签。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_worker_threads` | gauge | node, state, code | 工作线程数按状态(TYPE=9，状态语义与 v12.9 官方文档逐条对齐)；等锁/等资源状态短期波动属正常 |

### 采集域 `worker_threads_waiting`

```sql
SELECT COUNT(*) AS CNT FROM SYS_ALL_THD_STATUS
WHERE TYPE=9 AND STATE IN (2,4,5,6,8,11,12)
```

**SQL 说明**：统计处于官方锁/资源等待状态集 {2,4,5,6,8,11,12} 的任务线程数。行锁等待线程不进入该状态集。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_worker_threads_lock_waiting` | gauge |  | 处于锁/资源等待状态的工作线程数（官方状态集；行锁等待不计入，实测） |

### 采集域 `threads_memory`

```sql
SELECT NODEID AS NODE,
       CASE TYPE WHEN 1 THEN '主线程' WHEN 4 THEN '空闲buffer保障' WHEN 5 THEN '脏页提交'
            WHEN 6 THEN 'buffer写盘' WHEN 7 THEN 'redo写盘' WHEN 9 THEN '任务处理'
            WHEN 12 THEN '系统事件' WHEN 13 THEN '存储维护' WHEN 18 THEN '死锁检测'
            WHEN 19 THEN '全局锁' WHEN 23 THEN '大buffer交换' WHEN 27 THEN '回滚维护'
            WHEN 29 THEN '自动分析' ELSE '类型'||TYPE END AS TYPE,
       COUNT(*) AS CNT, SUM(MEM_SIZE) AS MEM
FROM SYS_ALL_THD_STATUS GROUP BY NODEID, TYPE
```

**SQL 说明**：全部线程按 TYPE 分组：线程数与 MEM_SIZE 内存合计；CASE 将常见线程类型译为中文（官方线程类型表 1-36）。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_threads` | gauge | node, type | 线程数按类型(中文语义见官方线程类型表) |
| `xugu_threads_memory_bytes` | gauge | node, type | 线程持有内存按类型合计(字节) |

### 采集域 `active_statements`

```sql
SELECT T.NODEID AS NODE, T.SESSION_ID, T.THD_ID, T.USER_NAME AS USERNAME,
       REPLACE(REPLACE(SUBSTR(T.SQL,1,500),CHR(10),' '),CHR(9),' ') AS SQL,
       MAX((SYSDATE - S.CMD_START_T)*86400) AS SECS
FROM SYS_ALL_THD_SESSION T
JOIN SYS_ALL_SESSIONS S ON T.NODEID=S.NODEID AND T.SESSION_ID=S.SESSION_ID
GROUP BY T.NODEID, T.SESSION_ID, T.THD_ID, T.USER_NAME,
         REPLACE(REPLACE(SUBSTR(T.SQL,1,500),CHR(10),' '),CHR(9),' ')
ORDER BY SECS DESC LIMIT 10
```

**SQL 说明**：以 SYS_ALL_THD_SESSION（含执行中 SQL 文本与 OS 线程号 THD_ID）回联会话表取命令开始时间；(SYSDATE-CMD_START_T)*86400 计算已执行秒数；REPLACE/SUBSTR 清洗换行并截断 500 字符；GROUP BY 防同秒重复序列；按时长倒序取前 10。THD_ID 供 pstack 抓取线程堆栈。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_active_statement_duration_seconds` | gauge | node, session_id, thd_id, username, sql | 正在执行的语句明细(最多10条)：会话/OS线程号/用户/语句(截断500字符)在 label，值为已执行秒数(含 exporter 自身查询)。语句卡死时可对 thd_id 执行 pstack 抓取线程堆栈 |

### 采集域 `cluster_msg_quality`（仅集群）

```sql
SELECT NODEID AS NODE, TARG_NAME, TARG_VALUE FROM SYS_ALL_MONITORS
WHERE TARG_NAME IN ('RESEND_MSG_NUM','DISCARD_MSG_NUM')
```

**SQL 说明**：从 SYS_ALL_MONITORS 键值对取网络重发/丢弃包计数，键名作为 name 标签。仅集群启用。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_cluster_message_events_total` | gauge | name, node | 集群网络质量计数(RESEND_MSG_NUM=重发包 DISCARD_MSG_NUM=丢弃包)，短期增长说明节点间网络异常 |

### 采集域 `memory`

```sql
SELECT NODEID AS NODE,
       BUFF_SIZE*TOTAL_BUFF_NUM  AS BUFF_TOTAL_BYTES,
       BUFF_SIZE*FREE_BUFF_NUM   AS BUFF_FREE_BYTES,
       BUFF_SIZE*DIRTY_BUFF_NUM  AS BUFF_DIRTY_BYTES,
       BUFF_SIZE*LRU_BUFF_NUM    AS BUFF_LRU_BYTES,
       SGA_BLK_SIZE*TOTAL_SGA_MEM AS SGA_TOTAL_BYTES,
       SGA_BLK_SIZE*FREE_SGA_MEM  AS SGA_FREE_BYTES,
       SGA_BLK_SIZE*PEAK_SGA_MEM  AS SGA_PEAK_BYTES,
       SWAP_BLK_SIZE*TOTAL_SWAP_MEM AS SWAP_TOTAL_BYTES,
       SWAP_BLK_SIZE*FREE_SWAP_MEM  AS SWAP_FREE_BYTES
FROM SYS_ALL_MEM_STATUS
```

**SQL 说明**：读内存状态表 SYS_ALL_MEM_STATUS，块数×块大小 换算为字节：数据缓冲池(总/空闲/脏/LRU)、计算内存区 SGA(总/空闲/峰值)、交换区(总/空闲)。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_buffer_pool_bytes` | gauge | node | 数据缓冲池总大小(字节) |
| `xugu_buffer_pool_free_bytes` | gauge | node | 数据缓冲池空闲大小(字节)，缓冲池使用率=1-free/total |
| `xugu_buffer_pool_dirty_bytes` | gauge | node | 脏页占用大小(字节) |
| `xugu_buffer_pool_lru_bytes` | gauge | node | LRU 链上页面大小(字节) |
| `xugu_sga_bytes` | gauge | node | SGA 总大小(字节) |
| `xugu_sga_free_bytes` | gauge | node | SGA 空闲大小(字节) |
| `xugu_sga_peak_bytes` | gauge | node | SGA 峰值用量(字节) |
| `xugu_swap_bytes` | gauge | node | 交换区总大小(字节) |
| `xugu_swap_free_bytes` | gauge | node | 交换区空闲大小(字节) |

### 采集域 `memory_pools`

```sql
SELECT NODEID AS NODE, TARG_NAME, TARG_VALUE
FROM SYS_ALL_MONITORS WHERE TARG_NAME LIKE '%MEM'
```

**SQL 说明**：SYS_ALL_MONITORS 42 个键中仅 12 个 *_MEM 内部内存池键有独立监控价值（其余为无效或与 RUN_INFO 重复），LIKE '%MEM' 过滤后按键值对输出。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_memory_pool_bytes` | gauge | pool, node | 内部内存池占用字节数(CATA=字典 LOCK=锁 TRAN=事务 MSG=消息 NET=网络 MODI=修改 DLCHK=死锁检测等) |

### 采集域 `tablespaces`（TTL 60s）

```sql
SELECT T.NODEID AS NODE, T.SPACE_NAME AS SPACE, T.SPACE_TYPE AS TYPE,
       T.TOTAL_CHUNK_NUM*C.CHUNK_SIZE AS TOTAL_BYTES,
       T.FREE_CHUNK_NUM*C.CHUNK_SIZE  AS FREE_BYTES,
       T.DATAFILE_NUM, T.MEDIA_ERROR
FROM SYS_ALL_TABLESPACES T, SYS_CTL_VARS C
```

**SQL 说明**：SYS_ALL_TABLESPACES 与 SYS_CTL_VARS(单行，提供 CHUNK_SIZE=8MB) 笛卡尔积，块数×块大小得到逻辑分配/空闲字节；系统空间(GSYS/UNDO/LSYS)空闲恒 0 属正常形态。MEDIA_ERROR 为介质错误布尔标志。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_tablespace_bytes` | gauge | node, space, type | 表空间总大小(字节) |
| `xugu_tablespace_free_bytes` | gauge | node, space, type | 表空间空闲大小(字节)。系统空间(GSYS/USYS/LSYS)恒为0属正常，使用率只对 DATA/TEMP 型有意义 |
| `xugu_tablespace_datafiles` | gauge | node, space, type | 表空间数据文件数 |
| `xugu_tablespace_media_error` | gauge | node, space, type | 表空间介质错误(1=有错误，需立即检查存储设备) |

### 采集域 `datafiles`（TTL 60s）

```sql
SELECT D.NODEID AS NODE, T.SPACE_NAME AS SPACE,
       COUNT(*) AS NFILES, SUM(D.CURR_SIZE)*1024*1024 AS BYTES
FROM SYS_ALL_DATAFILES D
JOIN SYS_ALL_TABLESPACES T ON D.NODEID=T.NODEID AND D.SPACE_ID=T.SPACE_ID
GROUP BY D.NODEID, T.SPACE_NAME
```

**SQL 说明**：数据文件表按 表空间 分组求 CURR_SIZE(单位 MB) 合计×1024² 转字节，即数据文件的物理磁盘占用；文件按 STEP_SIZE 自动扩展只增不减。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_datafile_bytes` | gauge | node, space | 数据文件当前大小合计(字节) |

### 采集域 `slowsql`（TTL 60s）

```sql
SELECT NODEID AS NODE, COUNT(*) AS CNT
FROM SYS_ALL_SLOWSQL_LOG GROUP BY NODEID
```

**SQL 说明**：慢 SQL 日志表全量按节点计数（累计口径，日志按 errlog_size 归档时回落）。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_slowsql_total` | counter | node | 慢 SQL 日志累计条数(阈值 slow_sql_time；日志归档时计数可能回落) |

### 采集域 `slowsql_recent`（TTL 60s）

```sql
SELECT COUNT(*) AS CNT, MAX(ELAPSE_TIME)/1000.0 AS MAX_SECS
FROM SYS_ALL_SLOWSQL_LOG
WHERE EX_TIME >= SYSDATE - INTERVAL '10' MINUTE
```

**SQL 说明**：以服务器时钟 SYSDATE - INTERVAL '10' MINUTE 做时间窗过滤，统计近 10 分钟条数与最大耗时(毫秒/1000 转秒)。不带节点分组保证空窗口时也输出 0。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_slowsql_recent` | gauge |  | 近 10 分钟慢 SQL 条数 |
| `xugu_slowsql_recent_max_duration_seconds` | gauge |  | 近 10 分钟慢 SQL 最大耗时(秒)；窗口内无慢 SQL 时本指标缺失 |

### 采集域 `slowsql_top`（TTL 60s）

```sql
SELECT NODEID AS NODE, USER_NAME AS USERNAME, CLIENT_IP, EX_TIME,
       REPLACE(REPLACE(SUBSTR(SQL_STR,1,500), CHR(10), ' '), CHR(9), ' ') AS SQL,
       MAX(ELAPSE_TIME)/1000.0 AS SECS
FROM SYS_ALL_SLOWSQL_LOG
WHERE EX_TIME >= SYSDATE - INTERVAL '1' HOUR
GROUP BY NODEID, USER_NAME, CLIENT_IP, EX_TIME,
         REPLACE(REPLACE(SUBSTR(SQL_STR,1,500), CHR(10), ' '), CHR(9), ' ')
ORDER BY SECS DESC LIMIT 10
```

**SQL 说明**：近 1 小时按耗时 Top10 明细：用户/IP/执行时间/语句(清洗换行、截断 500 字符)进标签，值为耗时秒；GROUP BY 全部标签列防同秒同语句重复序列。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_slowsql_top_duration_seconds` | gauge | node, username, client_ip, ex_time, sql | 近 1 小时 Top10 慢 SQL 明细：用户/客户端IP/执行时间/语句(截断500字符)在 label 中，值为耗时秒 |

### 采集域 `errorlog`（TTL 60s）

```sql
SELECT NODEID AS NODE, EX_LEVEL AS LEVEL, COUNT(*) AS CNT
FROM SYS_ALL_ERROR_LOG GROUP BY NODEID, EX_LEVEL
```

**SQL 说明**：错误日志按 节点+级别 全量计数（9 级：NOTICE/USEREX/ERROR/ABORT/DLOCK/L06/SYSEX/NETER/MEMER）。本域为日志表全量扫描，是最慢采集项，已设 TTL 缓存。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_errorlog_total` | counter | node, level | 错误日志累计条数(按级别：NOTICE警告/USEREX用户/ERROR命令级/ABORT事务中止/DLOCK死锁/L06陈旧事务/SYSEX系统/NETER网络/MEMER内存错乱；日志按 errlog_size 归档时计数回落) |

### 采集域 `errorlog_top`（TTL 60s）

```sql
SELECT NODEID AS NODE, EX_LEVEL AS LEVEL, ERR_CODE,
       "USER" AS USERNAME, CLIENT_IP, EX_TIME,
       REPLACE(REPLACE(SUBSTR(ERR_STR,1,300), CHR(10), ' '), CHR(9), ' ') AS MSG
FROM SYS_ALL_ERROR_LOG
WHERE EX_LEVEL IN ('SYSEX','MEMER','DLOCK','ABORT','L06','NETER')
  AND EX_TIME >= SYSDATE - INTERVAL '1' HOUR
GROUP BY NODEID, EX_LEVEL, ERR_CODE, "USER", CLIENT_IP, EX_TIME,
         REPLACE(REPLACE(SUBSTR(ERR_STR,1,300), CHR(10), ' '), CHR(9), ' ')
ORDER BY EX_TIME DESC LIMIT 20
```

**SQL 说明**：近 1 小时重要级别(SYSEX/MEMER/DLOCK/ABORT/L06/NETER)明细，级别/错误码/用户/IP/消息(截断300字符)进标签；USER 为保留字需引号；GROUP BY 防重复序列。ERROR/NOTICE 级量大不入明细。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_errorlog_important_info` | gauge | node, level, err_code, username, client_ip, ex_time, msg | 近 1 小时重要级错误明细(值恒1)：级别/错误码/用户/IP/时间/消息在 label 中。E19xxx=系统内存类致命，E14001=死锁 |

### 采集域 `errorlog_fatal`（TTL 60s）

```sql
SELECT NODEID AS NODE, ERR_CODE, COUNT(*) AS CNT
FROM SYS_ALL_ERROR_LOG
WHERE ERR_CODE IN (19002, 19003, 19016, 19017, 14001)
GROUP BY NODEID, ERR_CODE
```

**SQL 说明**：对致命/高危错误码专项计数：19002 存取保护(SIGSEGV)、19003 非法指令、19016/19017 内存分配释放失败、14001 死锁。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_fatal_errors_total` | counter | node, err_code | 致命/高危错误累计：19002=存取保护SIGSEGV(检查bin目录exception_stack.trc并提交原厂) 19003=非法指令 19016/19017=内存分配/释放失败 14001=死锁 |

### 采集域 `eventlog`（TTL 120s）

```sql
SELECT NODEID AS NODE, EVENT_TYPE AS TYPE, COUNT(*) AS CNT
FROM SYS_ALL_EVENT_LOG GROUP BY NODEID, EVENT_TYPE
```

**SQL 说明**：事件日志按 节点+事件类型 计数（SYS_START/CKPT/REPAIR/DB_OPEN/CLU_EVENT 等 16 主类）。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_eventlog_total` | counter | node, type | 事件日志累计条数(按事件类型：SYS_START/CKPT/REPAIR/DB_OPEN 等) |

### 采集域 `cluster_nodes`

```sql
SELECT NODE_STATE AS STATE, COUNT(*) AS CNT FROM SYS_CLUSTERS GROUP BY NODE_STATE
```

**SQL 说明**：集群节点按状态码分组计数（0未联机/1刚加入/2正常/3出错/4宕机）。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_cluster_nodes` | gauge | state | 集群节点数(按状态码分组，2=在线；单机恒为1个节点) |

### 采集域 `gstores`（TTL 60s）

```sql
SELECT STORE_STA AS STA, COUNT(*) AS CNT FROM SYS_GSTORES GROUP BY STORE_STA
```

**SQL 说明**：全局存储段按状态码分组计数，健康态=1；扩容/修复期间出现其他状态码。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_gstores` | gauge | sta | 全局存储段数(按状态码，实测健康态=1；扩容/修复期间出现其他状态) |

### 采集域 `databases`（TTL 120s）

```sql
SELECT DB_NAME AS DB, ONLINE FROM SYS_DATABASES WHERE DROPED=FALSE
```

**SQL 说明**：未删除数据库的在线状态（BOOLEAN 自动转 1/0）。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_database_online` | gauge | db | 数据库在线状态(1=在线) |

### 采集域 `invalid_objects`（TTL 300s）

```sql
SELECT (SELECT COUNT(*) FROM SYS_VIEWS WHERE VALID=FALSE)
     + (SELECT COUNT(*) FROM SYS_PROCEDURES WHERE VALID=FALSE)
     + (SELECT COUNT(*) FROM SYS_TRIGGERS WHERE VALID=FALSE)
     + (SELECT COUNT(*) FROM SYS_PACKAGES WHERE VALID=FALSE) AS CNT
FROM DUAL
```

**SQL 说明**：四个标量子查询合计 VALID=FALSE 的视图/过程/触发器/包数量；依赖对象变更后未重编译会失效。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_invalid_objects` | gauge |  | 失效对象总数(视图/过程/触发器/包 VALID=FALSE)；依赖对象变更后未重编译会失效，用 always-sql/依赖对象重编译.sql 修复 |

### 采集域 `database_storage`（TTL 300s）

```sql
SELECT DB.DB_NAME AS DB, COUNT(*)*8388608 AS BYTES
FROM SYS_GSTORES G JOIN SYS_DATABASES DB ON G.DB_ID=DB.DB_ID
GROUP BY DB.DB_NAME
```

**SQL 说明**：SYS_GSTORES 按库分组计数×8MB 估算各库存储占用（每存储段 8MB）。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_database_storage_bytes` | gauge | db | 按数据库的存储占用估算(存储段数×8MB)，来源 SYS_GSTORES |

### 采集域 `object_storage_top`（TTL 300s）

```sql
SELECT DB.DB_NAME AS DB,
       COALESCE(T.TABLE_NAME, ST.TABLE_NAME, '对象'||G.OBJ_ID) AS OBJ,
       COUNT(*)*8388608 AS BYTES
FROM SYS_GSTORES G
JOIN SYS_DATABASES DB ON G.DB_ID=DB.DB_ID
LEFT JOIN SYS_TABLES T ON T.DB_ID=G.DB_ID AND T.TABLE_ID=G.OBJ_ID
LEFT JOIN SYS_SYSTEM_TABLES ST ON G.DB_ID=1 AND ST.TABLE_ID=G.OBJ_ID
GROUP BY DB.DB_NAME, COALESCE(T.TABLE_NAME, ST.TABLE_NAME, '对象'||G.OBJ_ID)
ORDER BY BYTES DESC LIMIT 10
```

**SQL 说明**：存储段按 库+对象 分组计数×8MB；GSTORES.OBJ_ID 即该库 SYS_TABLES.TABLE_ID，据此解析对象名（系统库对象回落 SYS_SYSTEM_TABLES），取 Top10。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_object_storage_bytes` | gauge | db, obj | 存储占用最大的 10 个对象(表/索引)，估算口径 存储段数×8MB |

### 采集域 `schema_storage_top`（TTL 300s）

```sql
SELECT DB.DB_NAME AS DB, SC.SCHEMA_NAME AS SCHEMA_NAME, COUNT(*)*8388608 AS BYTES
FROM SYS_GSTORES G
JOIN SYS_DATABASES DB ON G.DB_ID=DB.DB_ID
JOIN SYS_TABLES T ON T.DB_ID=G.DB_ID AND T.TABLE_ID=G.OBJ_ID
JOIN SYS_SCHEMAS SC ON SC.DB_ID=G.DB_ID AND SC.SCHEMA_ID=T.SCHEMA_ID
GROUP BY DB.DB_NAME, SC.SCHEMA_NAME ORDER BY BYTES DESC LIMIT 10
```

**SQL 说明**：在对象级基础上再联 SYS_SCHEMAS，按 库+模式 汇总存储占用，取 Top10。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_schema_storage_bytes` | gauge | db, schema_name | 存储占用最大的 10 个模式（用户表口径），估算 存储段数×8MB |

### 采集域 `storage_fragment`（TTL 300s）

```sql
SELECT DB.DB_NAME AS DB, SUM(S.ROW_NUM) AS ACTIVE_N, SUM(S.DEL_NUM) AS DEL_N
FROM SYS_ALL_STORES S
JOIN SYS_GSTORES G ON G.GSTO_NO=S.GSTO_NO
JOIN SYS_DATABASES DB ON G.DB_ID=DB.DB_ID
GROUP BY DB.DB_NAME
```

**SQL 说明**：存储段明细表 SYS_ALL_STORES 联全局段取库名，按库汇总有效行(ROW_NUM)与标记删除行(DEL_NUM)；碎片率=deleted/(active+deleted)，由面板计算。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_storage_active_rows` | gauge | db | 按库的存储段有效行数合计 |
| `xugu_storage_deleted_rows` | gauge | db | 按库的存储段标记删除行数合计；碎片率 = deleted/(active+deleted)，高碎片可整理回收 |

### 采集域 `users`（TTL 120s）

```sql
SELECT SUM(CASE WHEN LOCKED=TRUE  THEN 1 ELSE 0 END) AS LOCKED_N,
       SUM(CASE WHEN EXPIRED=TRUE THEN 1 ELSE 0 END) AS EXPIRED_N,
       COUNT(*) AS TOTAL_N
FROM SYS_USERS WHERE IS_ROLE=FALSE
```

**SQL 说明**：账号表（排除角色）统计总数/锁定/过期；CASE WHEN 把 BOOLEAN 转计数。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_users` | gauge |  | 数据库账号总数(不含角色) |
| `xugu_users_locked` | gauge |  | 被锁定的账号数(连续登录失败或人工锁定) |
| `xugu_users_expired` | gauge |  | 已过期的账号数 |

### 采集域 `forbidden_ips`（TTL 120s）

```sql
SELECT COUNT(*) AS CNT FROM SYS_ALL_FORBIDDEN_IPS WHERE IS_FORBIDDEN=TRUE
```

**SQL 说明**：统计当前处于封禁状态的 IP 数（登录连续失败触发）。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_forbidden_ips` | gauge |  | 当前被禁止连接的 IP 数(登录失败超限封禁) |

### 采集域 `recyclebin`（TTL 120s）

```sql
SELECT COUNT(*) AS CNT FROM SYS_RECYCLEBIN
```

**SQL 说明**：回收站对象总数（enable_recycle=on 时 DROP 对象入站）。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_recyclebin_objects` | gauge |  | 回收站对象数(enable_recycle=on 时 DROP 的对象入站) |

### 采集域 `settings`（TTL 300s）

```sql
SELECT NODEID AS NODE, VAR_NAME, VAR_VALUE FROM SYS_ALL_VARS
WHERE VAR_NAME IN ('max_conn_num','slow_sql_time','max_trans_modify',
                   'enable_recycle','enable_audit','enable_monitor',
                   'max_idle_time','error_level')
```

**SQL 说明**：8 个关键参数键值对输出；true/false 自动转 1/0；用 SYS_ALL_VARS 保证集群下按节点区分。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_setting` | gauge | name, node | 关键系统参数当前值(布尔型 true/false 映射为 1/0；集群下按节点区分) |

### 采集域 `jobs`（TTL 120s）

```sql
SELECT COUNT(*) AS TOTAL_N,
       COALESCE(SUM(CASE WHEN ENABLE=TRUE THEN 1 ELSE 0 END), 0) AS ENABLED_N
FROM SYS_JOBS
```

**SQL 说明**：定时作业总数与启用数；COALESCE 保证空表时输出 0 而非缺失。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_jobs` | gauge |  | 定时作业总数 |
| `xugu_jobs_enabled` | gauge |  | 启用中的定时作业数 |

### 采集域 `backup`（TTL 300s）

```sql
SELECT (SELECT COUNT(*) FROM SYS_BACKUP_PLANS WHERE ENABLE=TRUE) AS PLANS_ENABLED,
       (SELECT COUNT(*) FROM SYS_BACKUP_ITEMS) AS ITEMS,
       (SELECT MAX(NEXT_RUN_T) FROM SYS_BACKUP_ITEMS) AS NEXT_RUN
FROM DUAL
```

**SQL 说明**：备份计划/备份项计数与下次执行时间；无备份计划时 NEXT_RUN 为 NULL 自动跳过（指标缺失属文档化行为）。

| 指标 | 类型 | Labels | 说明 |
|--|--|--|--|
| `xugu_backup_plans_enabled` | gauge |  | 启用中的备份计划数 |
| `xugu_backup_items` | gauge |  | 备份项总数 |
| `xugu_backup_next_run_timestamp_seconds` | gauge |  | 下一次备份计划执行时间(Unix秒)；无备份计划时本指标缺失 |

## 引擎内置指标（非 SQL）

| 指标 | 类型 | 说明 |
|--|--|--|
| `xugu_up` | gauge | 数据库可连接性(1=正常) |
| `xugu_exporter_scrape_duration_seconds` | gauge | 单次抓取总耗时 |
| `xugu_collector_success{collector}` | gauge | 各采集域成败(1=成功) |
| `xugu_collector_duration_seconds{collector}` | gauge | 各采集域耗时 |

## 主机指标（host_metrics: true 时启用，gopsutil 内置采集）

| 指标 | 说明 |
|--|--|
| `xugu_host_cpu_usage_percent` | 主机 CPU 使用率 |
| `xugu_host_memory_total_bytes` / `_available_bytes` | 物理内存总量/可用（可用率<10% 有 OOM 风险） |
| `xugu_host_swap_total_bytes` / `_free_bytes` | 交换区 |
| `xugu_host_disk_total_bytes` / `_free_bytes` `{mountpoint,fstype}` | 磁盘分区容量/剩余 |

> 注意：主机指标反映 exporter 所在机器；与数据库异机部署时请设 `host_metrics: false` 并改用 node_exporter/windows_exporter。
