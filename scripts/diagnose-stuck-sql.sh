#!/usr/bin/env bash
# 卡死 SQL 一键诊断（Linux，需与数据库同机执行，需要 pstack/gdb）
#
# 原理：从 exporter /metrics 读取 xugu_active_statement_duration_seconds，
# 找出执行超过阈值的语句及其 OS 线程号，对每个线程执行 pstack 抓取堆栈，
# 用于定位语句卡在哪个内核环节（配合原厂分析）。
#
# 用法: ./diagnose-stuck-sql.sh [阈值秒,默认60] [exporter地址,默认 http://127.0.0.1:9156]
set -e
THRESHOLD="${1:-60}"
EXPORTER="${2:-http://127.0.0.1:9156}"
TS=$(date +%Y%m%d_%H%M%S)
OUT="stuck-sql-diagnose-${TS}.txt"

echo "== 卡死 SQL 诊断 $(date) 阈值=${THRESHOLD}s ==" | tee "$OUT"
curl -s --noproxy '*' "$EXPORTER/metrics" \
 | grep '^xugu_active_statement_duration_seconds' \
 | while read -r line; do
    secs=$(echo "$line" | awk '{print $NF}' | cut -d. -f1)
    [ -z "$secs" ] && continue
    [ "$secs" -lt "$THRESHOLD" ] && continue
    thd=$(echo "$line" | sed -n 's/.*thd_id="\([0-9]*\)".*/\1/p')
    sql=$(echo "$line" | sed -n 's/.*sql="\([^"]*\)".*/\1/p')
    sid=$(echo "$line" | sed -n 's/.*session_id="\([0-9]*\)".*/\1/p')
    {
      echo ""
      echo "---- 会话 $sid 线程 $thd 已执行 ${secs}s ----"
      echo "SQL: $sql"
      if command -v pstack >/dev/null 2>&1; then
        echo "--- pstack $thd ---"
        pstack "$thd" 2>&1 || true
      elif command -v gdb >/dev/null 2>&1; then
        echo "--- gdb 堆栈(线程 $thd) ---"
        gdb -q -p "$thd" -ex "bt" -ex "detach" -ex "quit" 2>&1 || true
      else
        echo "(未安装 pstack/gdb，请手工执行: pstack $thd)"
      fi
    } | tee -a "$OUT"
  done
echo "" | tee -a "$OUT"
echo "诊断结果已保存: $OUT （请连同结果提交原厂分析）" | tee -a "$OUT"
