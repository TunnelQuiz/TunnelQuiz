#!/usr/bin/env bash
# Agent File-over-AI — Symlinks für ein Projekt-Repo anlegen.
# Usage: bash install-project-agent-link.sh /opt/TunnelQuiz/NeuesProjekt "Projektname" "Kurzbeschreibung"
# Idempotent — kann jederzeit erneut ausgeführt werden.
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <projekt-pfad> <name> <kurzbeschreibung>" >&2
  echo "Beispiel: $0 /opt/TunnelQuiz/NeuesProjekt NeuesProjekt \"Kurzbeschreibung\"" >&2
  exit 1
fi

PROJECT_DIR="$(cd "$1" && pwd)"
PROJECT_NAME="$2"
PROJECT_DESC="$3"

SSOT_CURSOR="/opt/TunnelQuiz/.cursor"

if [[ "$PROJECT_DIR" == "/opt/TunnelQuiz" ]]; then
  echo "==> Org-Root IST die SSOT ($SSOT_CURSOR) — keine Symlinks."
  exit 0
fi

for d in rules skills hooks mcp; do
  if [[ ! -d "$SSOT_CURSOR/$d" ]]; then
    echo "Fehler: SSOT fehlt: $SSOT_CURSOR/$d" >&2
    exit 1
  fi
done

mkdir -p "$PROJECT_DIR/.cursor"/{rules,skills,hooks,mcp}

link() {
  local target="$1" linkpath="$2"
  if [[ -L "$linkpath" ]]; then
    local current
    current="$(readlink "$linkpath")"
    if [[ "$current" == "$target" ]]; then
      echo "  OK (existiert): $linkpath"
      return
    fi
    rm "$linkpath"
  elif [[ -e "$linkpath" ]]; then
    echo "Fehler: $linkpath ist keine Symlink-Datei — bitte manuell prüfen." >&2
    exit 1
  fi
  ln -s "$target" "$linkpath"
  echo "  → $linkpath"
}

echo "==> Projekt: $PROJECT_DIR ($PROJECT_NAME — $PROJECT_DESC)"
echo "==> SSOT:   $SSOT_CURSOR"
echo ""
echo "Symlinks:"

link "$SSOT_CURSOR/rules/agent-rules-ssot" \
  "$PROJECT_DIR/.cursor/rules/agent-rules-symlink"
link "$SSOT_CURSOR/skills/agent-skills-ssot" \
  "$PROJECT_DIR/.cursor/skills/agent-skills-symlink"
link "$SSOT_CURSOR/hooks/agent-hooks-ssot" \
  "$PROJECT_DIR/.cursor/hooks/agent-hooks-symlink"
link "$SSOT_CURSOR/mcp/agent-mcp-ssot" \
  "$PROJECT_DIR/.cursor/mcp/agent-mcp-symlink"

# Alte myOS-Pointer entfernen (SSOT umbenannt)
for old in rules/myOS-rules-symlink skills/myOS-skills-symlink \
           hooks/myOS-hooks-symlink mcp/myOS-mcp-symlink; do
  oldpath="$PROJECT_DIR/.cursor/$old"
  if [[ -L "$oldpath" || -e "$oldpath" ]]; then
    rm -f "$oldpath"
    echo "  entfernt alt: $oldpath"
  fi
done

echo ""
echo "OK: Agent-Symlinks aktiv. Keine AGENTS.md — Kontext über rules/agent-rules-symlink."
echo "Optional: projekt-eigene .cursor/rules/*.mdc neben dem Symlink."
