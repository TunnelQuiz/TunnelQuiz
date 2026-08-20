#!/usr/bin/env bash
# SessionStart-Hook für Claude Code — Pendant zu Cursors nativer Ladung von .cursor/rules/*.mdc.
# Liest alle .mdc-Regeln (Agent-SSOT + projekteigene) aus .cursor/rules/ des jeweiligen Projekts
# und gibt sie als Klartext auf stdout aus (wird von Claude Code automatisch als Kontext übernommen).
#
# "Immer lesen"-Dateien (agent-global.mdc §Session-Start) werden inhaltlich mitgeliefert, nicht nur
# als Regel-Text verlinkt — ein injizierter Hinweis "lies X" zwingt ein Modell nicht zuverlässig dazu,
# X von sich aus per Tool-Call nachzuladen. Trigger-basierte Dateien (principles.md, index-agents.md,
# index-skills.md) bleiben bewusst reaktiv und werden hier nicht ausgegeben.
set -euo pipefail

ssot_root="/opt/TunnelQuiz/.cursor"
global_rule="$ssot_root/rules/agent-rules-ssot/agent-global.mdc"

# "Immer lesen"-Liste wird aus agent-global.mdc geparst, nicht hart kodiert — neue Einträge dort
# wirken sofort, ohne dieses Script anzufassen (einzige Pflegestelle bleibt die Regel-Datei).
if [[ -f "$global_rule" ]]; then
  always_paths=$(awk '/^Immer lesen:$/{flag=1; next} /^Trigger-basiert lesen:$/{flag=0} flag' "$global_rule" \
    | grep -oE '`[^`]+`' | tr -d '`')
  while IFS= read -r rel; do
    [[ -z "$rel" ]] && continue
    f="$ssot_root/$rel"
    [[ -f "$f" ]] || continue
    echo "--- $f (Immer lesen, agent-global.mdc) ---"
    cat "$f"
    echo
  done <<< "$always_paths"
fi

rules_dir="${CLAUDE_PROJECT_DIR:-.}/.cursor/rules"
[[ -d "$rules_dir" ]] || exit 0

find -L "$rules_dir" -type f -name "*.mdc" | sort | while IFS= read -r f; do
  echo "--- $f ---"
  cat "$f"
  echo
done
