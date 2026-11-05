#!/usr/bin/env bash
# 有 pueue daemon 時把指令排進 pueue 等它跑完（Orca 工作站的 build 都要排隊），沒有時直接執行；成功時回傳 0
#
# 用法：run-queued.sh <指令字串>
set -euo pipefail

if command -v pueue >/dev/null 2>&1 && pueue status >/dev/null 2>&1; then
    jobid="$(pueue add -p -- "$1")"
    echo "run-queued: 已排入 pueue（task ${jobid}），等待執行…"
    pueue follow --lines 100000 "$jobid" || true
    pueue log "$jobid" --json --full | grep -q '"result":"Success"'
else
    bash -c "$1"
fi
