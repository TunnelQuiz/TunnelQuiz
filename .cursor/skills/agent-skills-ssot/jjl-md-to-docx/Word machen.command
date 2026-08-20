#!/bin/bash
# Doppelklick oder Markdown-Dateien hierher ziehen → Word
cd "$(dirname "$0")"
chmod +x "./md2docx.sh" 2>/dev/null

clear
echo ""
echo "  ┌─────────────────────────────────────────┐"
echo "  │   Markdown → Word                       │"
echo "  │   WM-Formatvorlagen                     │"
echo "  └─────────────────────────────────────────┘"
echo ""

if [[ $# -eq 0 ]]; then
  echo "  Markdown-Datei(en) auf dieses Icon ziehen"
  echo "  und loslassen — die .docx erscheint neben der .md-Datei."
  echo ""
  echo "  Beispiel:"
  echo "    mein-aufsatz.md  →  mein-aufsatz.docx"
  echo ""
else
  "./md2docx.sh" "$@"
fi

echo ""
read -r -p "Enter drücken zum Schließen … " _
