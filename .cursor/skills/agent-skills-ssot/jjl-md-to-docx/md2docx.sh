#!/usr/bin/env bash
# Markdown → Word (.docx) mit WM-Formatvorlagen
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULTS="$SCRIPT_DIR/defaults.yaml"
OK=0
FAIL=0

rot()  { printf '\033[0;31m%s\033[0m\n' "$*"; }
grün() { printf '\033[0;32m%s\033[0m\n' "$*"; }
gelb() { printf '\033[0;33m%s\033[0m\n' "$*"; }

fehlt() {
  rot "Fehlt: $1"
  echo "  → Installiere z. B. mit: brew install $2"
  exit 1
}

command -v pandoc >/dev/null 2>&1 || fehlt "pandoc" "pandoc"

[[ -f "$DEFAULTS" ]] || { rot "Konfiguration nicht gefunden: $DEFAULTS"; exit 1; }
[[ -f "$SCRIPT_DIR/reference.docx" ]] || { rot "Referenzvorlage nicht gefunden: $SCRIPT_DIR/reference.docx"; exit 1; }

konvertieren() {
  local datei="$1"
  local ziel="${datei%.md}.docx"

  if [[ ! -f "$datei" ]]; then
    rot "  ✗ Datei nicht gefunden: $datei"
    ((FAIL++)) || true
    return
  fi

  if [[ "${datei##*.}" != "md" && "${datei##*.}" != "MD" ]]; then
    gelb "  ⊘ Übersprungen (keine .md-Datei): $datei"
    return
  fi

  echo ""
  echo "  → $datei"
  if pandoc "$datei" -o "$ziel" --defaults "$DEFAULTS" --reference-doc="$SCRIPT_DIR/reference.docx" 2>&1; then
    grün "  ✓ Word-Datei erstellt: $ziel"
    ((OK++)) || true
  else
    rot "  ✗ Fehler bei: $datei"
    ((FAIL++)) || true
  fi
}

verarbeiten() {
  local pfad="$1"

  if [[ -d "$pfad" ]]; then
    shopt -s nullglob
    local gefunden=0
    for datei in "$pfad"/*.md "$pfad"/*.MD; do
      [[ -f "$datei" ]] || continue
      gefunden=1
      konvertieren "$datei"
    done
    shopt -u nullglob
    if [[ $gefunden -eq 0 ]]; then
      gelb "  ⊘ Keine Markdown-Dateien in: $pfad"
    fi
  else
    konvertieren "$pfad"
  fi
}

echo ""
echo "═══════════════════════════════════════"
echo "  Markdown → Word  (WM-Formatvorlagen)"
echo "═══════════════════════════════════════"

if [[ $# -eq 0 ]]; then
  echo ""
  rot "Keine Datei angegeben."
  echo ""
  echo "  So geht's:"
  echo "    • Datei(en) auf „Word machen.command“ ziehen"
  echo "    • oder:  md2docx.sh mein-text.md"
  echo ""
  exit 1
fi

for arg in "$@"; do
  verarbeiten "$arg"
done

echo ""
echo "───────────────────────────────────────"
if [[ $OK -gt 0 ]]; then
  grün "Fertig: $OK Word-Datei(en) erstellt."
fi
if [[ $FAIL -gt 0 ]]; then
  rot "Fehler: $FAIL Datei(en) konnten nicht konvertiert werden."
  exit 1
fi
echo "───────────────────────────────────────"
echo ""
