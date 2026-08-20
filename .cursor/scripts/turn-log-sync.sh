#!/usr/bin/env bash
# Transcript-Sync: archiviert neue Turns aus Cursor agent-transcripts (VPS-Cron).
set -euo pipefail

SCRIPT="/opt/TunnelQuiz/.cursor/scripts/turn-log/turn-log.py"
export AGENT_TURNLOG_DIR="/opt/TunnelQuiz/.cursor/logs/agent-turns"
export AGENT_TRANSCRIPT_ROOTS="/home/jjl/.cursor/projects/opt-LauerTeam/agent-transcripts,/home/jjl/.cursor/projects/opt-LauerTeam-Domains-myAgentsDomain/agent-transcripts,/home/jjl/.cursor/projects/opt/agent-transcripts"
export AGENT_WORKSPACE="/opt/TunnelQuiz"

exec /usr/bin/python3 "$SCRIPT" --sync
