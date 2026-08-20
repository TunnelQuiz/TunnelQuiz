#!/usr/bin/env bash
# Installiert Agent-Symlinks in allen TunnelQuiz-Projekten (Org-Root = SSOT).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL="${SCRIPT_DIR}/install-project-agent-link.sh"
SSOT_CLAUDE="/opt/TunnelQuiz/.claude"
SETTINGS_EXAMPLE="${SSOT_CLAUDE}/hooks/agent-hooks-ssot/settings.json.example"

declare -a PROJECTS=(
  "/opt/TunnelQuiz|TunnelQuiz|Organisation — Apps + Domains (IST die SSOT, keine Symlinks)"
  "/opt/TunnelQuiz/Domains/tunnelQuizDomain|tunnelQuizDomain|TunnelQuiz Domain"
  "/opt/TunnelQuiz/Apps/tunnelQuizApp|tunnelQuizApp|TunnelQuiz App — BFF + Web"
)

link_claude_hooks() {
  local base="$1"
  mkdir -p "$base/.claude/hooks"
  local linkpath="$base/.claude/hooks/agent-hooks-symlink"
  local target="$SSOT_CLAUDE/hooks/agent-hooks-ssot"
  if [[ -L "$linkpath" ]]; then
    [[ "$(readlink "$linkpath")" == "$target" ]] || { rm "$linkpath"; ln -s "$target" "$linkpath"; }
  elif [[ ! -e "$linkpath" ]]; then
    ln -s "$target" "$linkpath"
  fi
  if [[ -f "$SETTINGS_EXAMPLE" && ! -f "$base/.claude/settings.json" ]]; then
    cp "$SETTINGS_EXAMPLE" "$base/.claude/settings.json"
  fi
}

for entry in "${PROJECTS[@]}"; do
  IFS='|' read -r path name desc <<<"$entry"
  if [[ "$path" == "/opt/TunnelQuiz" ]]; then
    echo "==> Org-Root IST die SSOT — keine Cursor-Symlinks."
    continue
  fi
  [[ -d "$path" ]] || { echo "SKIP (fehlt): $path"; continue; }
  bash "$INSTALL" "$path" "$name" "$desc"
  link_claude_hooks "$path"
done
echo "Fertig: TunnelQuiz Agent-Links."
