#!/usr/bin/env bash
# Markdown Redline → PDF (technischer Vergleich zweier .md, ohne LLM)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULTS_TEX="$SCRIPT_DIR/defaults-tex.yaml"

rot()  { printf '\033[0;31m%s\033[0m\n' "$*"; }
grün() { printf '\033[0;32m%s\033[0m\n' "$*"; }
gelb() { printf '\033[0;33m%s\033[0m\n' "$*"; }

fehlt() {
  rot "Fehlt: $1"
  echo "  → Installiere z. B. mit: brew install $2"
  exit 1
}

command -v pandoc >/dev/null 2>&1 || fehlt "pandoc" "pandoc"
command -v xelatex >/dev/null 2>&1 || fehlt "xelatex (LaTeX)" "basictex"
command -v latexdiff >/dev/null 2>&1 || fehlt "latexdiff" "latexdiff"

[[ -f "$DEFAULTS_TEX" ]] || { rot "Konfiguration nicht gefunden: $DEFAULTS_TEX"; exit 1; }

usage() {
  echo ""
  rot "Aufruf: md2redline.sh <alt.md> <neu.md> [ausgabe.pdf]"
  echo ""
  echo "  alt.md  = Basisversion (wird als gelöscht markiert, was fehlt)"
  echo "  neu.md  = Überarbeitung (Neues wird hervorgehoben)"
  echo ""
  echo "  Ausgabe standardmäßig neben neu.md:"
  echo "    alt-vs-neu-redline.pdf"
  echo ""
  exit 1
}

[[ $# -lt 2 || $# -gt 3 ]] && usage

ALT="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
NEU="$(cd "$(dirname "$2")" && pwd)/$(basename "$2")"

[[ -f "$ALT" ]] || { rot "Datei nicht gefunden: $ALT"; exit 1; }
[[ -f "$NEU" ]] || { rot "Datei nicht gefunden: $NEU"; exit 1; }

ALT_BASE="$(basename "${ALT%.*}")"
NEU_BASE="$(basename "${NEU%.*}")"
NEU_DIR="$(dirname "$NEU")"

if [[ $# -eq 3 ]]; then
  if [[ "$3" = /* ]]; then
    ZIEL="$3"
  else
    ZIEL="$(cd "$(dirname "$3")" && pwd)/$(basename "$3")"
  fi
else
  ZIEL="$NEU_DIR/${ALT_BASE}-vs-${NEU_BASE}-redline.pdf"
fi

WORKDIR="$(mktemp -d)"
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

echo ""
echo "═══════════════════════════════════════"
echo "  Markdown Redline → PDF  (technisch)"
echo "═══════════════════════════════════════"
echo ""
echo "  Alt:  $ALT"
echo "  Neu:  $NEU"
echo ""

echo "  → Markdown → LaTeX …"
pandoc "$ALT" -o "$WORKDIR/alt.tex" --defaults "$DEFAULTS_TEX"
pandoc "$NEU" -o "$WORKDIR/neu.tex" --defaults "$DEFAULTS_TEX"

echo "  → latexdiff …"
latexdiff --type=UNDERLINE "$WORKDIR/alt.tex" "$WORKDIR/neu.tex" > "$WORKDIR/diff.tex"

echo "  → PDF kompilieren …"
pushd "$WORKDIR" >/dev/null
xelatex -interaction=nonstopmode diff.tex >/dev/null 2>&1 || {
  rot "  ✗ LaTeX-Kompilierung fehlgeschlagen."
  echo "  Log: $WORKDIR/diff.log"
  echo ""
  gelb "  Tipp: Bei Tabellen/Fußnoten kann latexdiff scheitern."
  gelb "  Terminal-Diff: git diff --no-index \"$ALT\" \"$NEU\""
  exit 1
}
popd >/dev/null

mv "$WORKDIR/diff.pdf" "$ZIEL"
grün "  ✓ Redline-PDF erstellt: $ZIEL"
echo ""
echo "───────────────────────────────────────"
echo ""
