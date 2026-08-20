#!/bin/bash
# Doppelklick oder Markdown-Dateien hierher ziehen → PDF
cd "$(dirname "$0")"
chmod +x "./md2pdf.sh" 2>/dev/null

clear
echo ""
echo "  ┌─────────────────────────────────────────┐"
echo "  │   Markdown → PDF                        │"
echo "  │   juristisch-akademisches Layout        │"
echo "  └─────────────────────────────────────────┘"
echo ""

if [[ $# -eq 0 ]]; then
  echo "  Markdown-Datei(en) auf dieses Icon ziehen"
  echo "  und loslassen — die PDF erscheint neben der .md-Datei."
  echo ""
  echo "  Beispiel:"
  echo "    mein-aufsatz.md  →  mein-aufsatz.pdf"
  echo ""
else
  "./md2pdf.sh" "$@"
fi

echo ""
read -r -p "Enter drücken zum Schließen … " _
