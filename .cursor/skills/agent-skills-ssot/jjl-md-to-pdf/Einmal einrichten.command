#!/bin/bash
# Einmal ausführen, wenn du bessere Typografie-Pakete nachinstallieren willst.
# Nicht nötig — PDF machen funktioniert auch ohne diesen Schritt.

cd "$(dirname "$0")"

clear
echo ""
echo "  ┌─────────────────────────────────────────┐"
echo "  │   LaTeX-Pakete nachinstallieren         │"
echo "  │   (optional, einmalig)                  │"
echo "  └─────────────────────────────────────────┘"
echo ""
echo "  Dieser Schritt ist optional."
echo "  „PDF machen.command“ funktioniert auch ohne ihn."
echo ""
echo "  Es wird dein Mac-Passwort abgefragt."
echo ""

if ! command -v tlmgr >/dev/null 2>&1; then
  echo "  tlmgr nicht gefunden."
  echo "  LaTeX scheint nicht installiert zu sein."
  echo "  Installiere mit:  brew install basictex"
  echo ""
  read -r -p "Enter drücken … " _
  exit 1
fi

sudo tlmgr update --self
sudo tlmgr install csquotes enumitem xetex xunicode fontspec

echo ""
echo "  Fertig. Du kannst dieses Programm schließen."
echo ""
read -r -p "Enter drücken … " _
