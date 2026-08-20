#!/usr/bin/env bash
# Entfernt globale Cursor/Claude Skills — damit nur SSOT-Symlinks Kontext liefern.
# User Rules + Plugins: manuell in Cursor Settings (siehe documents/_archive/cursor-cleanup-checklist.md).
set -euo pipefail

echo "==> Globale Skills entfernen"

removed=0
for dir in "$HOME/.cursor/skills" "$HOME/.claude/skills"; do
  if [[ -d "$dir" ]]; then
    count="$(find "$dir" -mindepth 1 | wc -l)"
    rm -rf "$dir"/*
    rmdir "$dir" 2>/dev/null || true
    echo "  geleert: $dir ($count Einträge)"
    removed=$((removed + count))
  else
    echo "  OK (fehlt): $dir"
  fi
done

echo ""
echo "==> Globale Rules-Verzeichnisse"
for dir in "$HOME/.cursor/rules" "$HOME/.cursor/hooks"; do
  if [[ -d "$dir" ]]; then
    echo "  WARNUNG: $dir existiert — bitte prüfen/entfernen"
  else
    echo "  OK (fehlt): $dir"
  fi
done

echo ""
echo "==> User-level mcp.json / hooks.json"
found=0
while IFS= read -r f; do
  echo "  WARNUNG: $f"
  found=1
done < <(find "$HOME" -maxdepth 3 \( -name 'mcp.json' -o -name 'hooks.json' \) \
  ! -path '*/.cursor/plugins/*' \
  ! -path '*/.cursor/projects/*' \
  ! -path '*/.cursor/skills-cursor/*' 2>/dev/null)
[[ $found -eq 0 ]] && echo "  OK (keine gefunden)"

echo ""
echo "==> Cursor Plugins (Cache)"
if [[ -d "$HOME/.cursor/plugins/cache" ]]; then
  plugins="$(ls "$HOME/.cursor/plugins/cache/cursor-public" 2>/dev/null | tr '\n' ' ')"
  if [[ -n "$plugins" ]]; then
    echo "  HINWEIS: Plugin-Cache aktiv: $plugins"
    echo "  → Cursor Settings → Plugins: nur bewusst behalten"
    echo "  → MCP/Skills aus Plugins sind NICHT SSOT"
  else
    echo "  OK (kein Plugin-Cache)"
  fi
else
  echo "  OK (kein plugins-Verzeichnis)"
fi

echo ""
echo "==> skills-cursor (Cursor-eigen, nicht löschbar)"
if [[ -d "$HOME/.cursor/skills-cursor" ]]; then
  n="$(find "$HOME/.cursor/skills-cursor" -name 'SKILL.md' | wc -l)"
  echo "  $n eingebaute Cursor-Skills — von Cursor verwaltet, kein Agent-SSOT-Leak"
fi

echo ""
if [[ $removed -gt 0 ]]; then
  echo "Fertig: $removed globale Skill-Einträge entfernt."
else
  echo "Fertig: Keine globalen Skills zu entfernen."
fi
echo "Nächster Schritt: bash /opt/TunnelQuiz/.cursor/scripts/cursor-ssot-verify.sh"
