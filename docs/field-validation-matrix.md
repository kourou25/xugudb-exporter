# 系统字典字段有效性矩阵（自动生成）

> 生成: 2026-07-09 15:28:14　工具: tools/verify　依据: docs/test-plan.md
> S0=空闲采样 S1=SC-1 DML 负载后 S2=全部场景后；分类标准见测试计划 §1

## 一、文档有而真实库不存在的表（无效-表不存在）

- SYS_CACHE_STATUS
- SYS_IO_STATUS
- SYS_LOCK_WAITS
- SYS_DEAD_LOCKS
- SYS_ROW_LOCKS
- SYS_TABLE_LOCKS
- SYS_META_LOCKS
- SYS_TRANS_LOCKS
- SYS_PAGE_STATUS
- SYS_LOG_STATUS
- SYS_REDO_STATUS
- SYS_CHECKPOINT
- SYS_STORAGE_STATUS
- SYS_AUDIT_RESULTS

## 二、标量探针字段三段采样与分类

### MONITORS

| 字段 | S0 | S1 | S2 | 分类 | 备注 |
|---|---|---|---|---|---|
| ACT_TRANS_NUM | 1 | 1 | 1 | **确定-静态** |  |
| ALL_MODI_NUM | 0 | 0 | 0 | **无效-恒零** | 定向负载后仍恒 0（FV-3.3/3.4 预期失败成立） |
| BUFF_VISIT_NUM | 0 | 0 | 0 | **无效-恒零** | 定向负载后仍恒 0（FV-3.3/3.4 预期失败成立） |
| CATA_MEM | 19398728 | 19398728 | 19398728 | **确定-静态** |  |
| CMIT_MODI_NUM | 0 | 0 | 0 | **无效-恒零** | 定向负载后仍恒 0（FV-3.3/3.4 预期失败成立） |
| DEAD_LOCK_NUM | 0 | 0 | 0 | **不确定** | 全程 0，场景未覆盖或本环境无此活动 |
| DISCARD_MSG_NUM | 0 | 0 | 0 | **不确定-集群** | 单机不驱动，需分布式环境复验 |
| DISK_READ_BYTES | 71180288 | 71180288 | 71180288 | **确定-静态** |  |
| DISK_READ_NUM | 8689 | 8689 | 8689 | **确定-静态** |  |
| DISK_WRITE_BYTES | 100425728 | 100425728 | 100425728 | **确定-静态** |  |
| DISK_WRITE_NUM | 12259 | 12259 | 12259 | **确定-静态** |  |
| DLCHK_MEM | 129624 | 129624 | 129624 | **确定-静态** |  |
| ENCRYPTOR_MEM | 2097152 | 2097152 | 2097152 | **确定-静态** |  |
| GLOCK_MEM | 1048576 | 1048576 | 1048576 | **确定-静态** |  |
| G_MEM | 16777216 | 16777216 | 16777216 | **确定-静态** |  |
| IS_LOCK_NUM | -315 | -315 | -315 | **确定-静态** |  |
| IX_LOCK_NUM | -11 | -10 | -10 | **确定-动态** |  |
| LMSG_BUF_NUM | 2048 | 2048 | 2048 | **不确定-集群** | 单机不驱动，需分布式环境复验 |
| LOCK_MEM | 1048576 | 1048576 | 1048576 | **确定-静态** |  |
| LOCK_REQ_NUM | 0 | 0 | 0 | **无效-恒零** | 定向负载后仍恒 0（FV-3.3/3.4 预期失败成立） |
| LOCK_WAIT_NUM | 0 | 0 | 0 | **不确定** | 全程 0，场景未覆盖或本环境无此活动 |
| MAX_TRANS_ID | 3134524 | 3135364 | 3135664 | **确定-动态** |  |
| MIN_TRANS_ID | 3134523 | 3135363 | 3135663 | **确定-动态** |  |
| MODI_MEM | 8388608 | 8388608 | 8388608 | **确定-静态** |  |
| MSG_MEM | 20971520 | 20971520 | 20971520 | **确定-静态** |  |
| NET_MEM | 8388608 | 8388608 | 8388608 | **确定-静态** |  |
| NET_READ_BYTES | 0 | 0 | 0 | **无效-恒零** | 定向负载后仍恒 0（FV-3.3/3.4 预期失败成立） |
| NET_SEND_BYTES | 0 | 0 | 0 | **无效-恒零** | 定向负载后仍恒 0（FV-3.3/3.4 预期失败成立） |
| PROC_MEM | 0 | 0 | 0 | **不确定** | 全程 0，场景未覆盖或本环境无此活动 |
| RECV_MSG_NUM | 0 | 0 | 0 | **不确定-集群** | 单机不驱动，需分布式环境复验 |
| REQUEST_NUM | 0 | 0 | 0 | **无效-恒零** | 定向负载后仍恒 0（FV-3.3/3.4 预期失败成立） |
| RESEND_MSG_NUM | 0 | 0 | 0 | **不确定-集群** | 单机不驱动，需分布式环境复验 |
| SEND_MSG_NUM | 0 | 0 | 0 | **不确定-集群** | 单机不驱动，需分布式环境复验 |
| SIX_LOCK_NUM | 0 | 0 | 0 | **不确定** | 全程 0，场景未覆盖或本环境无此活动 |
| SMSG_BUF_NUM | 2048 | 2048 | 2048 | **不确定-集群** | 单机不驱动，需分布式环境复验 |
| S_LOCK_NUM | 0 | 0 | 0 | **不确定** | 全程 0，场景未覆盖或本环境无此活动 |
| TASK_MEM | 2097152 | 2097152 | 2097152 | **确定-静态** |  |
| TRAN_MEM | 2097152 | 2097152 | 2097152 | **确定-静态** |  |
| UNDO_MODI_NUM | 0 | 0 | 0 | **无效-恒零** | 定向负载后仍恒 0（FV-3.3/3.4 预期失败成立） |
| XLOG_CKPT_POS | 273314462 | 273314462 | 273314462 | **确定-静态** |  |
| XLOG_WRT_POS | 273314462 | 277439418 | 277450113 | **确定-动态** |  |
| X_LOCK_NUM | 0 | 0 | 0 | **不确定** | 全程 0，场景未覆盖或本环境无此活动 |

### SYS_ALL_MEM_STATUS

| 字段 | S0 | S1 | S2 | 分类 | 备注 |
|---|---|---|---|---|---|
| BUFF_SIZE | 8192 | 8192 | 8192 | **确定-静态** |  |
| CURR_T | 2026-07-09 15:26:11 | 2026-07-09 15:27:13 | 2026-07-09 15:28:08 | **确定-静态** |  |
| DIRTY_BUFF_NUM | 0 | 1876 | 1874 | **确定-动态** |  |
| FREE_BUFF_NUM | 18451 | 18271 | 18270 | **确定-动态** |  |
| FREE_SGA_MEM | 16384 | 16384 | 16384 | **确定-静态** |  |
| FREE_SWAP_MEM | 512 | 512 | 512 | **确定-静态** |  |
| LRU_BUFF_NUM | 14317 | 14496 | 14495 | **确定-动态** |  |
| NODEID | 1 | 1 | 1 | **确定-静态** |  |
| PEAK_SGA_MEM | 117 | 117 | 117 | **确定-静态** |  |
| SGA_BLK_SIZE | 8192 | 8192 | 8192 | **确定-静态** |  |
| SWAP_BLK_SIZE | 262144 | 262144 | 262144 | **确定-静态** |  |
| TOTAL_BUFF_NUM | 32768 | 32768 | 32768 | **确定-静态** |  |
| TOTAL_SGA_MEM | 16384 | 16384 | 16384 | **确定-静态** |  |
| TOTAL_SWAP_MEM | 512 | 512 | 512 | **确定-静态** |  |

### SYS_ALL_RUN_INFO

| 字段 | S0 | S1 | S2 | 分类 | 备注 |
|---|---|---|---|---|---|
| ACT_TRANS_NUM | 1 | 1 | 1 | **确定-静态** |  |
| BUFF_R_N | 0 | 0 | 0 | **无效-恒零** | 定向负载后仍恒 0（FV-3.3/3.4 预期失败成立） |
| CURR_T | 2026-07-09 15:26:11 | 2026-07-09 15:27:13 | 2026-07-09 15:28:08 | **确定-静态** |  |
| DEAD_LOCK_N | 0 | 0 | 0 | **不确定** | 全程 0，场景未覆盖或本环境无此活动 |
| DELAY_STO_N | 0 | 0 | 0 | **不确定** | 全程 0，场景未覆盖或本环境无此活动 |
| DISK_R_BYTES | 71180288 | 71180288 | 71180288 | **确定-静态** |  |
| DISK_R_N | 8689 | 8689 | 8689 | **确定-静态** |  |
| DISK_W_BYTES | 100425728 | 100425728 | 100425728 | **确定-静态** |  |
| DISK_W_N | 12259 | 12259 | 12259 | **确定-静态** |  |
| DROPED_STO_N | 0 | 0 | 1 | **确定-动态** |  |
| FREE_STO_N | 63197 | 63197 | 63196 | **确定-动态** |  |
| IS_LOCK_N | -315 | -315 | -315 | **确定-静态** |  |
| IX_LOCK_N | -11 | -10 | -10 | **确定-动态** |  |
| LOCK_REQ_N | 0 | 0 | 0 | **无效-恒零** | 定向负载后仍恒 0（FV-3.3/3.4 预期失败成立） |
| LOCK_WAIT_N | 0 | 0 | 0 | **不确定** | 全程 0，场景未覆盖或本环境无此活动 |
| MAX_TRANS_ID | 3134516 | 3135356 | 3135656 | **确定-动态** |  |
| MIN_TRANS_ID | 3134515 | 3135355 | 3135655 | **确定-动态** |  |
| NET_R_BYTES | 0 | 0 | 0 | **无效-恒零** | 定向负载后仍恒 0（FV-3.3/3.4 预期失败成立） |
| NET_W_BYTES | 0 | 0 | 0 | **无效-恒零** | 定向负载后仍恒 0（FV-3.3/3.4 预期失败成立） |
| NODEID | 1 | 1 | 1 | **确定-静态** |  |
| RECV_MSG_N | 0 | 0 | 0 | **不确定-集群** | 单机不驱动，需分布式环境复验 |
| REQ_N | 0 | 0 | 0 | **无效-恒零** | 定向负载后仍恒 0（FV-3.3/3.4 预期失败成立） |
| SEND_MSG_N | 0 | 0 | 0 | **不确定-集群** | 单机不驱动，需分布式环境复验 |
| SIX_LOCK_N | 0 | 0 | 0 | **不确定** | 全程 0，场景未覆盖或本环境无此活动 |
| S_LOCK_N | 0 | 0 | 0 | **不确定** | 全程 0，场景未覆盖或本环境无此活动 |
| XLOG_CKPT | 273314462 | 273314462 | 273314462 | **确定-静态** |  |
| XLOG_WPOS | 273314462 | 277439418 | 277450113 | **确定-动态** |  |
| X_LOCK_N | 0 | 0 | 0 | **不确定** | 全程 0，场景未覆盖或本环境无此活动 |

### SYS_CLUSTERS

| 字段 | S0 | S1 | S2 | 分类 | 备注 |
|---|---|---|---|---|---|
| BOOT_TIME | 2026-07-03 17:52:11 | 2026-07-03 17:52:11 | 2026-07-03 17:52:11 | **确定-静态** |  |
| CPU_LOAD | 50 | 50 | 50 | **不确定-疑似桩值** | 负载前后恒 50 |
| LPU_NUM | 1 | 1 | 1 | **确定-静态** |  |
| MAJOR_NUM | 2303 | 2303 | 2303 | **确定-静态** |  |
| MAX_MSG_SIZE | 8192 | 8192 | 8192 | **确定-静态** |  |
| NODE_ID | 1 | 1 | 1 | **确定-静态** |  |
| NODE_IP | 0.0.0.0:0 | 0.0.0.0:0 | 0.0.0.0:0 | **确定-静态** |  |
| NODE_PORT | 0 | 0 | 0 | **不确定** | 全程 0，场景未覆盖或本环境无此活动 |
| NODE_STATE | 2 | 2 | 2 | **确定-静态** |  |
| NODE_TYPE | 29 | 29 | 29 | **确定-静态** |  |
| PROTO_VERSION | 25001 | 25001 | 25001 | **确定-静态** |  |
| RACK_NO | 0 | 0 | 0 | **不确定-集群** | 单机不驱动，需分布式环境复验 |
| STORE_NUM | 2303 | 2303 | 2303 | **确定-静态** |  |
| STORE_WEIGHT | 0 | 0 | 0 | **不确定-集群** | 单机不驱动，需分布式环境复验 |
| ZONE_NODE_STATE | 0 | 0 | 0 | **不确定-集群** | 单机不驱动，需分布式环境复验 |

### SYS_CTL_VARS

| 字段 | S0 | S1 | S2 | 分类 | 备注 |
|---|---|---|---|---|---|
| CHKPT_XPOS | 273314462 | 273314462 | 273314462 | **确定-静态** |  |
| CHUNK_SIZE | 8388608 | 8388608 | 8388608 | **确定-静态** |  |
| FIRST_T | 2026-03-12 23:08:46 | 2026-03-12 23:08:46 | 2026-03-12 23:08:46 | **确定-静态** |  |
| LAST_T | 2026-07-09 22:17:07 | 2026-07-09 22:17:07 | 2026-07-09 22:17:07 | **确定-静态** |  |
| LAST_XFN | 0 | 0 | 0 | **不确定** | 全程 0，场景未覆盖或本环境无此活动 |
| MIN_REPAIR_XFN | 0 | 0 | 0 | **不确定** | 全程 0，场景未覆盖或本环境无此活动 |
| MIN_RESTORE_XFN | 0 | 0 | 0 | **不确定** | 全程 0，场景未覆盖或本环境无此活动 |
| NEXT_DB_ID | 8 | 8 | 8 | **确定-静态** |  |
| REPAIR_XPOS | 0 | 0 | 0 | **不确定** | 全程 0，场景未覆盖或本环境无此活动 |
| RESTORE_XPOS | 0 | 0 | 0 | **不确定** | 全程 0，场景未覆盖或本环境无此活动 |
| TRANS_ID | 3134520 | 3135360 | 3135660 | **确定-动态** |  |

## 三、行集对象列形态（FV-1）

### SYS_ALL_SESSIONS（6 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| NODEID | INTEGER | 1 |  |
| SESSION_ID | INTEGER | 2891 |  |
| USER_ID | INTEGER | 1 |  |
| USER_NAME | CHAR | SYSDBA |  |
| CURR_USER_ID | INTEGER | 1 |  |
| CURR_USER_NAME | CHAR | SYSDBA |  |
| SCHEMA_ID | INTEGER | 1 |  |
| SCHEMA | CHAR | SYSDBA |  |
| DB_ID | INTEGER | 1 |  |
| DB_NAME | CHAR | SYSTEM |  |
| IP | CHAR | 127.0.0.1 |  |
| START_T | DATETIME | 2026-07-09 15:14:38 |  |
| VISIT_T | DATETIME | 2026-07-09 15:26:06 |  |
| STATUS | INTEGER | 112 |  |
| CURR_TID | BIGINT |  | 是 |
| CURR_CID | INTEGER | 0 |  |
| AUTO_COMMIT | BOOLEAN | true |  |
| ISO_LEVEL | INTEGER | 1 |  |
| TRANS_START_T | DATETIME |  | 是 |
| CMD_START_T | DATETIME |  | 是 |
| CURSOR_NUM | INTEGER | 0 |  |
| MEM_SIZE | BIGINT | 262144 |  |
| CHAR_SET | CHAR | UTF8 |  |
| TIME_ZONE | CHAR | GMT+08:00 |  |
| TIME_FORMAT | CHAR | YYYY-MM-DD HH24:MI:SS |  |
| LOCK_TIMEOUT | INTEGER | 0 |  |
| STRICT_COMMIT | BOOLEAN | false |  |
| RESULT | CHAR | DEFAULT |  |
| LANGUAGE | CHAR | PL/SQL |  |
| RETURN_ROWID | BOOLEAN | false |  |
| RETURN_SCHEMA | BOOLEAN | false |  |
| RETURN_CURSOR_ID | BOOLEAN | false |  |
| LOB_RET | BOOLEAN | false |  |
| EMPTY_STR_AS_NULL | BOOLEAN | false |  |
| OPTIMIZER_MODE | CHAR | ALL_ROWS |  |
| COMPATIBLE_MODE | CHAR | NONE |  |
| FILTER_POLICY | INTEGER | 0 |  |
| TRANS_RDLY | BOOLEAN | false |  |
| DISABLE_BINLOG | BOOLEAN | false |  |
| IDENTITY_MODE | CHAR | DEFAULT |  |
| APP_NAME | CHAR |  |  |
| KEYWORD_FILTER | CHAR |  | 是 |
| SQL | CHAR |  | 是 |

### SYS_ALL_THD_SESSION（1 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| NODEID | INTEGER | 1 |  |
| THD_ID | INTEGER | 29588 |  |
| STATE | INTEGER | 19 |  |
| CURR_TID | BIGINT | 3134389 |  |
| SESSION_ID | INTEGER | 2895 |  |
| DATABASE | INTEGER | 1 |  |
| USER_NAME | CHAR | SYSDBA |  |
| VISIT_T | DATETIME | 2026-07-09 15:26:10 |  |
| SQL | CHAR | SELECT * FROM SYS_ALL_THD_SESSION LIMIT … |  |

### SYS_ALL_THD_STATUS（55 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| NODEID | INTEGER | 1 |  |
| ID | INTEGER | 23272 |  |
| TYPE | INTEGER | 20 |  |
| STATE | INTEGER | 0 |  |
| CURR_TID | BIGINT | 0 |  |
| WAIT_TYPE | INTEGER | 0 |  |
| WAIT_OBJ | BIGINT | 0 |  |
| DATABASE | INTEGER | 0 |  |
| USER_NAME | CHAR |  |  |
| LOOP_NUM | BIGINT | 0 |  |
| MEM_SIZE | BIGINT | 0 |  |
| SCHED_GRP | INTEGER | 0 |  |
| SCHED_ID | INTEGER | 0 |  |
| NUMA_ID | INTEGER | 0 |  |

### SYS_ALL_TRANS（1 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| NODEID | INTEGER | 1 |  |
| TRANID | BIGINT | 3134397 |  |
| START_T | DATETIME | 2026-07-09 15:26:10 |  |
| RSTUBS | CHAR |  |  |
| IS_PROXY | BOOLEAN | false |  |
| R_NODE | INTEGER | 1 |  |
| R_TRANSID | BIGINT | 3134397 |  |
| WANT_SYNC | INTEGER | 0 |  |
| DONE_SYNC | INTEGER | 0 |  |
| DONE_DEL_IDX | INTEGER | 0 |  |
| MODIFY_COUNT | INTEGER | 0 |  |
| CURR_CID | INTEGER | 1 |  |

### SYS_ALL_MONITORS（42 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| NODEID | INTEGER | 1 |  |
| TARG_NAME | CHAR | REQUEST_NUM |  |
| TARG_VALUE | CHAR | 0 |  |

### SYS_ALL_LOCKS（219 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| NODEID | INTEGER | 1 |  |
| LOCK_TYPE | INTEGER | 9 |  |
| LOCK_ID | BIGINT | 576460765188328703 |  |
| REF | CHAR | [S]0,[X]0,[IS]0,[IX]0,[SIX]0 |  |
| NODE_OWN | CHAR | S |  |
| NODE_REQ | CHAR |  |  |
| WAIT_REVOKE | CHAR |  |  |

### SYS_ALL_LOWNERS（1 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| NODEID | INTEGER | 1 |  |
| LOCK_TYPE | INTEGER | 2 |  |
| LOCK_ID | BIGINT | 576460756598390943 |  |
| OWNER_TID | BIGINT | 3134409 |  |
| LOCK_LEVEL | CHAR | IS |  |
| OWNER_SID | INTEGER | 2895 |  |

### SYS_ALL_LWAITERS（0 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| NODEID | INTEGER |  |  |
| LOCK_TYPE | INTEGER |  |  |
| LOCK_ID | BIGINT |  |  |
| WAIT_TID | BIGINT |  |  |
| WAIT_THD | INTEGER |  |  |
| WAIT_LEVEL | CHAR |  |  |

### SYS_ALL_GLOCKS（219 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| NODEID | INTEGER | 1 |  |
| LOCK_TYPE | INTEGER | 9 |  |
| LOCK_ID | BIGINT | 576460765188328703 |  |
| REF | CHAR | [S]1,[X]0,[IS]0,[IX]0,[SIX]0 |  |

### SYS_ALL_GOWNERS（219 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| NODEID | INTEGER | 1 |  |
| LOCK_TYPE | INTEGER | 9 |  |
| LOCK_ID | BIGINT | 576460765188328703 |  |
| OWNER_NID | INTEGER | 1 |  |
| OWN_LKS | CHAR | S |  |

### SYS_ALL_GWAITERS（0 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| NODEID | INTEGER |  |  |
| LOCK_TYPE | INTEGER |  |  |
| LOCK_ID | BIGINT |  |  |
| WAIT_NID | INTEGER |  |  |
| WAIT_LKS | CHAR |  |  |

### SYS_ALL_TABLESPACES（11 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| NODEID | INTEGER | 1 |  |
| SPACE_ID | INTEGER | 1 |  |
| SPACE_NAME | CHAR | GSYS |  |
| DATAFILE_NUM | INTEGER | 1 |  |
| SPACE_TYPE | CHAR | GSYS_SPACE |  |
| MEDIA_ERROR | BOOLEAN | false |  |
| TOTAL_CHUNK_NUM | BIGINT | 1 |  |
| FREE_CHUNK_NUM | BIGINT | 0 |  |

### SYS_ALL_DATAFILES（11 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| NODEID | INTEGER | 1 |  |
| SPACE_ID | INTEGER | 1 |  |
| PATH | CHAR | /CATA/GSYS1.SYS |  |
| FILE_NO | INTEGER | 1 |  |
| MAX_SIZE | BIGINT | -1 |  |
| STEP_SIZE | INTEGER | 8 |  |
| CURR_SIZE | BIGINT | 8 |  |
| RESERVED1 | CHAR |  | 是 |

### SYS_ALL_SLOWSQL_LOG（15489 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| NODEID | INTEGER | 1 |  |
| DB_ID | INTEGER | 6 |  |
| USER_NAME | CHAR | SYSDBA |  |
| SESSION_ID | INTEGER | 48 |  |
| CLIENT_IP | CHAR | x.x.x.x |  |
| EX_TIME | DATETIME | 2026-06-11 14:16:45 |  |
| ELAPSE_TIME | INTEGER | 612 |  |
| SQL_STR | CHAR | SELECT COUNT(*) AS C FROM (SELECT ID FRO… |  |
| SQL_PARAS | CHAR |  | 是 |

### SYS_ALL_ERROR_LOG（136122 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| NODEID | INTEGER | 1 |  |
| EX_LEVEL | CHAR | ERROR |  |
| ERR_NO | INTEGER | 90 |  |
| ERR_CODE | INTEGER | 19132 |  |
| EX_TIME | DATETIME | 2026-04-01 14:46:29 |  |
| CLIENT_IP | CHAR | x.x.x.x |  |
| USER | CHAR | SYSDBA |  |
| DB_ID | INTEGER | 4 |  |
| ERR_STR | CHAR | 语法错误 |  |
| SQL_STR | CHAR | INSERT INTO IspInfoSubnet(IspId, Ip, Mas… |  |

### SYS_ALL_EVENT_LOG（1286 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| NODEID | INTEGER | 1 |  |
| EVENT_TYPE | CHAR | SYS_START |  |
| EVENT_TIME | DATETIME | 2026-03-12 15:08:46 |  |
| DB_NAME | CHAR | SYSTEM |  |
| OBJ_NAME | CHAR |  |  |
| EVENT_STR | CHAR | Open file cluster.ini failed,start in si… |  |

### SYS_ALL_TRACE_LOG（11543 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| NODEID | INTEGER | 1 |  |
| DB_ID | INTEGER | 0 |  |
| TRACE_TYPE | CHAR | UndoMaint |  |
| TRACE_TIME | DATETIME | 2026-03-12 15:08:48 |  |
| TRACE_STR | CHAR | old_delay_num:79,new_delay_num:79, drop_… | 是 |

### SYS_ALL_COMMAND_LOG（0 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| NODEID | INTEGER |  |  |
| DB_ID | INTEGER |  |  |
| USER | CHAR |  |  |
| SESSION_ID | INTEGER |  |  |
| CLIENT_IP | CHAR |  |  |
| EX_TIME | DATETIME |  |  |
| SQL_STR | CHAR |  |  |
| SQL_PARAS | CHAR |  |  |

### SYS_GSTORES（2303 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| GSTO_NO | INTEGER | 2 |  |
| HEAD_NO | INTEGER | 2 |  |
| TAIL_NO | INTEGER | 2 |  |
| NEXT_NO | INTEGER | 0 |  |
| SPLIT_NUM | INTEGER | 0 |  |
| STORE_STA | INTEGER | 1 |  |
| STORE_NUM | INTEGER | 1 |  |
| NODE_ID1 | INTEGER | 1 |  |
| NODE_ID2 | INTEGER | 0 |  |
| NODE_ID3 | INTEGER | 0 |  |
| STORE_NO1 | INTEGER | 35 |  |
| STORE_NO2 | INTEGER | 0 |  |
| STORE_NO3 | INTEGER | 0 |  |
| LSN | BIGINT | 1 |  |
| DB_ID | INTEGER | 1 |  |
| OBJ_ID | INTEGER | 1 |  |
| ENCRY_ID | INTEGER | 0 |  |
| ZONE_ID | INTEGER | 0 |  |
| NODEID | INTEGER | 1 |  |

### SYS_VARS（237 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| NODEID | INTEGER | 1 |  |
| VAR_NAME | CHAR | listen_port |  |
| VAR_VALUE | CHAR | 5138 |  |
| ACCESS | CHAR | R/W |  |
| IS_GLOBAL | BOOLEAN | true |  |
| EFFECT | INTEGER | 5 |  |
| RANGE | CHAR | [1024,65535] |  |
| POSITION | INTEGER | 1 |  |
| DESCRI | CHAR | 侦听端口 |  |

### SYS_DATABASES（6 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| DB_ID | INTEGER | 1 |  |
| DB_NAME | CHAR | SYSTEM |  |
| USER_ID | INTEGER | -1 |  |
| CHAR_SET | CHAR | UTF8.UTF8_GENERAL_CI |  |
| TIME_ZONE | CHAR | GMT+08:00 |  |
| MAX_USER_NUM | INTEGER | -1 |  |
| MAX_DBC_NUM | INTEGER | -1 |  |
| MAX_SIZE | INTEGER | -1 |  |
| MAX_TAB_NUM | INTEGER | -1 |  |
| MAX_VIEW_NUM | INTEGER | -1 |  |
| MAX_SEQ_NUM | INTEGER | -1 |  |
| MAX_TRIG_NUM | INTEGER | -1 |  |
| MAX_PROC_NUM | INTEGER | -1 |  |
| MAX_PACK_NUM | INTEGER | -1 |  |
| MAX_UDT_NUM | INTEGER | -1 |  |
| MAX_JOB_NUM | INTEGER | -1 |  |
| ENCRYPTOR | BINARY |  | 是 |
| ENABLE_ENCRY | BOOLEAN | false |  |
| ENABLE_POLICY | BOOLEAN | true |  |
| ENABLE_AUDIT | BOOLEAN | true |  |
| MAX_PACK_ID | INTEGER | 8211 |  |
| MAX_OBJ_ID | INTEGER | 1048670 |  |
| MAX_USER_ID | INTEGER | 106 |  |
| COMMENTS | CHAR |  | 是 |
| CREATE_TIME | DATETIME | 2026-03-12 15:08:47 |  |
| MODIFY_TIME | DATETIME | 2026-03-12 15:08:47 |  |
| REG_MODIFY | BOOLEAN |  | 是 |
| ONLINE | BOOLEAN | true |  |
| DROPED | BOOLEAN | false |  |
| ENCRY_ID | INTEGER | 0 |  |
| STO_ZONE | INTEGER | 0 |  |
| RESERVED3 | CHAR |  | 是 |

### SYS_USERS（62 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| DB_ID | INTEGER | 1 |  |
| USER_ID | INTEGER | 1 |  |
| USER_NAME | CHAR | SYSDBA |  |
| IS_ROLE | BOOLEAN | false |  |
| PASSWORD | BINARY | H�,����:�6@�M�� |  |
| START_TIME | DATETIME | 2026-03-12 15:08:47 |  |
| UNTIL_TIME | DATETIME | 2126-02-16 15:08:47 |  |
| LOCKED | BOOLEAN | false |  |
| EXPIRED | BOOLEAN | false |  |
| PASS_SET_TIME | DATETIME |  | 是 |
| PASS_SET_PERIOD | INTEGER |  | 是 |
| ALIAS | CHAR | SYSDBA |  |
| IS_SYS | BOOLEAN | true |  |
| TRUST_IP | CHAR |  | 是 |
| XLS_PID | INTEGER |  | 是 |
| XLS_LID | INTEGER |  | 是 |
| XLS_CIDS | BIGINT |  | 是 |
| PRIORITY | INTEGER | 1 |  |
| TEMP_SPACE_QUOTA | INTEGER | -1 |  |
| CURSOR_QUOTA | INTEGER | -1 |  |
| SESSION_QUOTA | INTEGER | -1 |  |
| IO_QUOTA | INTEGER | -1 |  |
| CREATE_TIME | DATETIME | 2026-03-12 15:08:47 |  |
| LAST_MODI_TIME | DATETIME | 2026-03-12 15:08:47 |  |
| ENCRY_ID | INTEGER | 0 |  |
| STO_ZONE | INTEGER | 0 |  |
| RESERVED3 | CHAR |  | 是 |

### SYS_JOBS（0 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| DB_ID | INTEGER |  |  |
| USER_ID | INTEGER |  |  |
| JOB_ID | INTEGER |  |  |
| JOB_NAME | CHAR |  |  |
| JOB_GRP_ID | INTEGER |  |  |
| JOB_NO | INTEGER |  |  |
| JOB_TYPE | CHAR |  |  |
| JOB_PARAM_NUM | INTEGER |  |  |
| JOB_PARAM | BINARY |  |  |
| JOB_ACTION | CLOB |  |  |
| BEGIN_T | DATETIME |  |  |
| END_T | DATETIME |  |  |
| REPET_INTERVAL | CHAR |  |  |
| TRIG_EVENTS | CHAR |  |  |
| LAST_RUN_T | DATETIME |  |  |
| STATE | CHAR |  |  |
| ENABLE | BOOLEAN |  |  |
| AUTO_DROP | BOOLEAN |  |  |
| IS_SYS | BOOLEAN |  |  |
| COMMENTS | CHAR |  |  |
| RESERVED1 | CHAR |  |  |
| RESERVED2 | CHAR |  |  |

### SYS_BACKUP_PLANS（0 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| DB_ID | INTEGER |  |  |
| PLAN_NAME | CHAR |  |  |
| PTYPE | CHAR |  |  |
| START_T | DATETIME |  |  |
| PERIOD | INTERVAL DAY TO MINUTE |  |  |
| ENABLE | BOOLEAN |  |  |
| PATH | CHAR |  |  |
| CURR_ITEM | INTEGER |  |  |

### SYS_BACKUP_ITEMS（0 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| DB_ID | INTEGER |  |  |
| PLAN_NAME | CHAR |  |  |
| ITEM_NO | INTEGER |  |  |
| OBJ_NAME | CHAR |  |  |
| OBJ_TYPE | CHAR |  |  |
| OP_TYPE | CHAR |  |  |
| FILE_NAME | CHAR |  |  |
| FILE_OP | CHAR |  |  |
| FILE_KEEP_CNT | INTEGER |  |  |
| FILE_MOVE_PATH | CHAR |  |  |
| TIME_OFF | INTERVAL DAY TO MINUTE |  |  |
| NEXT_RUN_T | DATETIME |  |  |
| IPERIOD | INTERVAL DAY TO MINUTE |  |  |
| ISTART_T | DATETIME |  |  |

### SYS_RECYCLEBIN（65 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| DB_ID | INTEGER | 7 |  |
| USER_ID | INTEGER | 1 |  |
| OBJECT_ID | INTEGER | 1048578 |  |
| RELATEDOBJ_ID | INTEGER | 1048578 |  |
| OBJECT_TYPE | INTEGER | 5 |  |
| OBJECT_TYPE_NAME | CHAR | Table |  |
| SCHEMA_ID | INTEGER | 1 |  |
| OBJECT_NAME | CHAR | T_INT_TYPES |  |
| RECYCLE_NAME | CHAR | BIN$08002A0012 |  |
| DROPED_TIME | DATETIME | 2026-06-15 10:29:26 |  |
| CAN_UNDROP | CHAR | YES |  |
| CAN_PURGE | CHAR | YES |  |
| RESERVED1 | CHAR |  | 是 |

### SYS_ALL_FORBIDDEN_IPS（0 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| NODEID | INTEGER |  |  |
| FORBIDDEN_IP | CHAR |  |  |
| CURR_FAILED_CNT | INTEGER |  |  |
| MAX_FAILED_CNT | INTEGER |  |  |
| CURR_T | DATETIME |  |  |
| LAST_T | DATETIME |  |  |
| FORBIDDEN_TIME | INTEGER |  |  |
| IS_FORBIDDEN | BOOLEAN |  |  |

### SYS_BLACK_WHITE_LIST（1 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| NODEID | INTEGER | 1 |  |
| LIST_TYPE | CHAR | whitelist |  |
| DB_NAME | CHAR | everydb |  |
| USER_NAME | CHAR | everyone |  |
| IP_RANGE | CHAR | anywhere |  |

### SYS_AUDIT_DEFS（0 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| DB_ID | INTEGER |  |  |
| USER_ID | INTEGER |  |  |
| OBJ_ID | INTEGER |  |  |
| OBJ_TYPE | INTEGER |  |  |
| AUDIT_MASK | BIGINT |  |  |
| RESERVED1 | CHAR |  |  |
| RESERVED2 | CHAR |  |  |

### SYS_AUDIT_RULES（0 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| DB_ID | INTEGER |  |  |
| SCHEMA_ID | INTEGER |  |  |
| RULE_ID | INTEGER |  |  |
| USER_ID | INTEGER |  |  |
| OBJ_ID | INTEGER |  |  |
| OBJ_TYPE | INTEGER |  |  |
| SUCC_FLAG | CHAR |  |  |
| TIME_SEGS | CHAR |  |  |
| IP_SEGS | CHAR |  |  |
| TYPE | INTEGER |  |  |
| WHENEVER | INTEGER |  |  |
| PERIOD | INTEGER |  |  |
| OP_SEQ | INTEGER |  |  |
| RESERVED1 | CHAR |  |  |
| RESERVED2 | CHAR |  |  |

### SYS_PROFILES（0 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| DB_ID | INTEGER |  |  |
| PROFILE | CHAR |  |  |
| RES_NAME | CHAR |  |  |
| RES_TYPE | CHAR |  |  |
| LIMIT | CHAR |  |  |
| RESERVED1 | CHAR |  |  |
| RESERVED2 | CHAR |  |  |
| RESERVED3 | CHAR |  |  |

### SYS_STO_ZONES（0 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| DB_ID | INTEGER |  |  |
| USER_ID | INTEGER |  |  |
| ZONE_ID | INTEGER |  |  |
| ZONE_NAME | CHAR |  |  |
| SRV_NUM | INTEGER |  |  |
| STO_NODES | BINARY |  |  |
| CREATE_TIME | DATETIME |  |  |
| ENABLE | BOOLEAN |  |  |
| IS_SYS | BOOLEAN |  |  |
| IS_LOCAL | BOOLEAN |  |  |
| COMMENTS | CHAR |  |  |
| RESERVED1 | CHAR |  |  |
| RESERVED2 | CHAR |  |  |
| RESERVED3 | CHAR |  |  |
| RESERVED4 | CHAR |  |  |
| RESERVED5 | CHAR |  |  |

### SYS_ALL_RESTORES（0 行）

| 列 | 类型 | 样例 | 见NULL |
|---|---|---|---|
| NODEID | INTEGER |  |  |
| TYPE | INTEGER |  |  |
| MODEL | INTEGER |  |  |
| PATH | CHAR |  |  |
| ALL | BIGINT |  |  |
| DONE | BIGINT |  |  |
| START_TIME | DATETIME |  |  |

