# 系统字典字段有效性矩阵（自动生成）

> 生成: 2026-07-09 11:33:26　工具: tools/verify　依据: docs/test-plan.md
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

