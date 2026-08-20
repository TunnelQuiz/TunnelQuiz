#!/usr/bin/env bash
# Prüft: 0 % globaler Kontext, SSOT-Symlinks korrekt.
set -euo pipefail

SSOT="/opt/TunnelQuiz/.cursor"
ERRORS=0
WARNINGS=0

ok()   { echo "  ✓ $*"; }
warn() { echo "  ⚠ $*"; WARNINGS=$((WARNINGS + 1)); }
fail() { echo "  ✗ $*"; ERRORS=$((ERRORS + 1)); }

echo "═══════════════════════════════════════════"
echo " Cursor SSOT Verify"
echo "═══════════════════════════════════════════"

echo ""
echo "1. Globale Artefakte (sollten fehlen)"
echo "─────────────────────────────────────"

for dir in "$HOME/.cursor/skills" "$HOME/.claude/skills" "$HOME/.cursor/rules"; do
  if [[ -d "$dir" ]] && [[ -n "$(ls -A "$dir" 2>/dev/null)" ]]; then
    fail "$dir ist nicht leer"
  else
    ok "$(basename "$(dirname "$dir")")/$(basename "$dir") leer oder fehlt"
  fi
done

if find "$HOME" -maxdepth 3 -name 'mcp.json' \
    ! -path '*/.cursor/plugins/*' \
    ! -path '*/.cursor/projects/*' 2>/dev/null | grep -q .; then
  fail "User-level mcp.json gefunden"
else
  ok "Kein User-level mcp.json"
fi

echo ""
echo "2. SSOT-Struktur"
echo "─────────────────────────────────────"

for item in \
  "rules/agent-rules-ssot" \
  "hooks/agent-hooks-ssot" \
  "mcp/agent-mcp-ssot" \
  "skills/agent-skills-ssot" \
  "brain" \
  "scripts"; do
  if [[ -e "$SSOT/$item" ]]; then
    ok "$item"
  else
    fail "$item fehlt"
  fi
done

if [[ -e "$SSOT/rules/myOS-rules-ssot" ]] || [[ -f "$SSOT/rules/agent-rules-ssot/myos-global.mdc" ]]; then
  fail "alte myOS-Rules-SSOT / myos-global.mdc existiert noch"
else
  ok "keine alten myOS-Rules-Namen"
fi

if [[ -d "$SSOT/skills/agent-skills-ssot" && ! -L "$SSOT/skills/agent-skills-ssot" ]]; then
  ok "skills/agent-skills-ssot ist echter Inhalt (kein Symlink)"
else
  fail "skills/agent-skills-ssot fehlt oder ist Symlink"
fi
if [[ -L "$SSOT/skills/agent-skills-symlink" || -e "$SSOT/skills/agent-skills-symlink" ]]; then
  fail "Org-Root hat noch agent-skills-symlink — würde Rules/Skills doppelt laden"
else
  ok "Org-Root ohne agent-*-symlink"
fi

rule_count="$(find "$SSOT/rules/agent-rules-ssot" -name '*.mdc' 2>/dev/null | wc -l)"
ok "$rule_count Rules in agent-rules-ssot"

if [[ -f "$SSOT/mcp/agent-mcp-ssot/README.md" ]] \
  && [[ -f "$SSOT/mcp/agent-mcp-ssot/cloudflare.cursor.mcp.json" ]]; then
  ok "mcp/agent-mcp-ssot: README + cloudflare.cursor.mcp.json"
else
  fail "mcp/agent-mcp-ssot unvollständig (README.md / cloudflare.cursor.mcp.json)"
fi

if grep -qE '"(Authorization|api[_-]?token|CLOUDFLARE_API)' \
  "$SSOT/mcp/agent-mcp-ssot/"*.json 2>/dev/null; then
  fail "mcp/agent-mcp-ssot enthält Secrets — gehört nicht hierher"
else
  ok "mcp/agent-mcp-ssot ohne Secrets in JSON"
fi

echo ""
echo "3. Projekt-Symlinks"
echo "─────────────────────────────────────"

PROJECTS=(
  "/opt/TunnelQuiz"
  "/opt/TunnelQuiz/Domains/azubuilderDomain"
  "/opt/TunnelQuiz/Apps/azubuilderApp"
)

check_project() {
  local proj="$1" name
  name="$(basename "$proj")"
  if [[ "$proj" == "/opt/TunnelQuiz" ]]; then
    name="TunnelQuiz (root)"
  fi
  if [[ ! -d "$proj/.cursor" ]]; then
    if [[ "$proj" == "/opt/TunnelQuiz" ]]; then
      fail "$name: kein .cursor/"
    else
      warn "$name: kein .cursor/ (evtl. absichtlich)"
    fi
    return
  fi
  if [[ "$proj" == "/opt/TunnelQuiz" ]]; then
    local missing=0
    for item in rules/agent-rules-ssot skills/agent-skills-ssot \
                hooks/agent-hooks-ssot mcp/agent-mcp-ssot; do
      if [[ ! -d "$proj/.cursor/$item" ]]; then
        fail "$name: $item fehlt"
        missing=1
      fi
    done
    for link in rules/agent-rules-symlink skills/agent-skills-symlink \
                hooks/agent-hooks-symlink mcp/agent-mcp-symlink; do
      if [[ -e "$proj/.cursor/$link" || -L "$proj/.cursor/$link" ]]; then
        fail "$name: $link am Org-Root (SSOT darf keine Selbst-Symlinks haben)"
        missing=1
      fi
    done
    [[ $missing -eq 0 ]] && ok "$name: SSOT (echte *-ssot, keine Symlinks)"
    return
  fi
  local missing=0
  for link in rules/agent-rules-symlink skills/agent-skills-symlink \
              hooks/agent-hooks-symlink mcp/agent-mcp-symlink; do
    local p="$proj/.cursor/$link"
    if [[ ! -L "$p" ]]; then
      fail "$name: $link fehlt oder kein Symlink"
      missing=1
    fi
  done
  for old in rules/myOS-rules-symlink skills/myOS-skills-symlink \
             hooks/myOS-hooks-symlink mcp/myOS-mcp-symlink; do
    if [[ -e "$proj/.cursor/$old" || -L "$proj/.cursor/$old" ]]; then
      fail "$name: alter $old noch vorhanden"
      missing=1
    fi
  done
  [[ $missing -eq 0 ]] && ok "$name: alle 4 Symlinks"
}

for p in "${PROJECTS[@]}"; do
  check_project "$p"
done

ok "Org-Scope: nur /opt/TunnelQuiz (kein Cross-Org-Scan)"

echo ""
echo "4. Cursor-eigen (nicht SSOT, dokumentiert)"
echo "─────────────────────────────────────"

if [[ -d "$HOME/.cursor/skills-cursor" ]]; then
  n="$(find "$HOME/.cursor/skills-cursor" -name 'SKILL.md' 2>/dev/null | wc -l)"
  warn "skills-cursor: $n Cursor-eigene Skills (nicht löschbar)"
fi

if [[ -d "$HOME/.cursor/plugins/cache/cursor-public" ]]; then
  plugins="$(ls "$HOME/.cursor/plugins/cache/cursor-public" 2>/dev/null | tr '\n' ', ' | sed 's/,$//')"
  if [[ "$plugins" == *cloudflare* ]]; then
    ok "Plugin-Cache enthält cloudflare (Runtime; SSOT: mcp/agent-mcp-ssot/)"
  fi
  other="$(echo "$plugins" | tr ',' '\n' | grep -v '^cloudflare$' | tr '\n' ', ' | sed 's/,$//')"
  if [[ -n "$other" ]]; then
    warn "Weitere Plugins: $other — ggf. in Settings prüfen"
  fi
fi

echo ""
echo "5. Install-Template"
echo "─────────────────────────────────────"
INSTALL="/opt/TunnelQuiz/.cursor/scripts/install-project-agent-link.sh"
INSTALL_ALL="/opt/TunnelQuiz/.cursor/scripts/install-all-agent-links.sh"
if [[ -x "$INSTALL" ]]; then
  ok "install-project-agent-link.sh vorhanden und ausführbar"
else
  fail "install-project-agent-link.sh fehlt oder nicht ausführbar: $INSTALL"
fi
if [[ -x "$INSTALL_ALL" ]]; then
  ok "install-all-agent-links.sh vorhanden und ausführbar"
else
  fail "install-all-agent-links.sh fehlt oder nicht ausführbar: $INSTALL_ALL"
fi
if [[ -e /opt/TunnelQuiz/.cursor/scripts/install-all-myos-links.sh ]]; then
  fail "altes install-all-myos-links.sh existiert noch"
else
  ok "kein install-all-myos-links.sh"
fi

echo ""
echo "6. Turn-Logging (VPS-Cron)"
echo "─────────────────────────────────────"

TURN_LOG_PY="/opt/TunnelQuiz/.cursor/scripts/turn-log/turn-log.py"
TURN_SYNC="/opt/TunnelQuiz/.cursor/scripts/turn-log-sync.sh"
if [[ -x "$TURN_LOG_PY" ]]; then
  ok "scripts/turn-log/turn-log.py vorhanden und ausführbar"
else
  fail "turn-log.py fehlt oder nicht ausführbar: $TURN_LOG_PY"
fi
if [[ -x "$TURN_SYNC" ]]; then
  ok "scripts/turn-log-sync.sh vorhanden und ausführbar"
else
  fail "turn-log-sync.sh fehlt oder nicht ausführbar: $TURN_SYNC"
fi
if crontab -l 2>/dev/null | grep -qF 'turn-log-sync.sh'; then
  ok "Cron: turn-log-sync.sh eingetragen"
else
  warn "Cron: turn-log-sync.sh nicht in crontab (install-cron.sh ausführen)"
fi

echo ""
echo "═══════════════════════════════════════════"
if [[ $ERRORS -eq 0 ]]; then
  echo " Ergebnis: OK ($WARNINGS Hinweise)"
  exit 0
else
  echo " Ergebnis: $ERRORS Fehler, $WARNINGS Hinweise"
  exit 1
fi
