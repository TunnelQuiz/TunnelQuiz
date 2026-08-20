#!/usr/bin/env bash
# Agent Turn-Logging — manueller Aufruf (rules/workflow.mdc §Turn-Logging).
# Cron nutzt turn-log-sync.sh → turn-log.py --sync direkt.
# Index: logs/agent-turns/JJJJ-MM-TT.jsonl · Archiv: logs/agent-turns/_archive/<session>/<turn>.json
# Aufruf: turn-log.sh [agent-name]   (optional JSON-Payload über stdin)
# Exit immer 0 — blockiert nie.

LOG_DIR="${AGENT_TURNLOG_DIR:-/opt/TunnelQuiz/.cursor/logs/agent-turns}"
AGENT="${1:-${AGENT_NAME:-unknown}}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ERROR_LOG="$LOG_DIR/debug/hook-errors.log"

mkdir -p "$LOG_DIR/debug" 2>/dev/null || true

PAYLOAD="$(cat 2>/dev/null || true)"
export AGENT_HOOK_PAYLOAD="$PAYLOAD"

if ! python3 "$SCRIPT_DIR/turn-log.py" "$AGENT" "$LOG_DIR" 2>>"$ERROR_LOG"; then
  printf '%s hook failed agent=%s\n' "$(date -Is)" "$AGENT" >>"$ERROR_LOG"
fi

exit 0
