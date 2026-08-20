---
name: md-to-pdf-jura
description: >-
  Konvertiert Markdown-Dateien per Pandoc/XeLaTeX in einheitlich formatierte
  PDFs für juristisch-akademische Texte (WM, NJW, ZHR). Nutzt das lokale
  md-to-pdf-jura-Setup ohne LLM. Verwenden wenn der Nutzer .md in PDF umwandeln,
  PDF exportieren, juristisches Paper formatieren oder md-to-pdf-jura erwähnt.
---

# Markdown → PDF (juristisch-akademisch)

## Skill-Basis (SSOT)

Alles liegt hier:

```
/Users/jjl/Documents/Menschen/Lauer, Jeremiah Joel/KI = Künstliche Intelligenz/Skills/md-to-pdf-jura/
```

| Datei | Zweck |
|---|---|
| `md2pdf.sh` | Konvertierungsskript |
| `defaults.yaml` | Layout-Einstellungen |
| `ANLEITUNG.md` | Nutzer-Anleitung |

## Grundregel

**Niemals LLM für die PDF-Erzeugung.** Immer das lokale Skript ausführen:

```bash
"/Users/jjl/Documents/Menschen/Lauer, Jeremiah Joel/KI = Künstliche Intelligenz/Skills/md-to-pdf-jura/md2pdf.sh" "/absoluter/pfad/zur/datei.md"
```

Die PDF liegt im **selben Ordner** wie die `.md`-Datei.

## Workflow für den Agenten

1. Pfad der `.md`-Datei ermitteln (absoluter Pfad, Anführungszeichen bei Leerzeichen).
2. Prüfen ob `pandoc` und `xelatex` verfügbar sind:
   ```bash
   command -v pandoc xelatex
   ```
3. Konvertierung ausführen (Pfad aus Grundregel oben).
4. Erfolg prüfen: PDF existiert, Dateigröße > 0.
5. Nutzer kurz informieren: wo die PDF liegt.

### Mehrere Dateien oder Ordner

```bash
SKILL="/Users/jjl/Documents/Menschen/Lauer, Jeremiah Joel/KI = Künstliche Intelligenz/Skills/md-to-pdf-jura/md2pdf.sh"
"$SKILL" "/ordner/"
"$SKILL" "a.md" "b.md"
```

## Drag & Drop

`PDF machen.command` per Finder-Drag & Drop ist auf macOS unzuverlässig.
**Standardweg:** immer `md2pdf.sh` per Shell aufrufen.

## Layout (fest, nicht ändern ohne Auftrag)

Konfiguration: `defaults.yaml` im Skill-Ordner (SSOT).

| Einstellung | Wert |
|---|---|
| Engine | Pandoc + XeLaTeX |
| Format | A4, 11 pt |
| Schrift | Times New Roman |
| Ränder | 2,5 cm |
| Klasse | scrartcl (KOMA) |
| Sprache | de-DE |
| Pakete | microtype, booktabs |

## Markdown-Konventionen

### Optionaler YAML-Kopf (Titel/Autor)

```markdown
---
title: "Transparenzpflichten nach MiFID II"
author: "Max Mustermann"
date: "Juli 2026"
---

# Einleitung
```

### Fußnoten

```markdown
Text mit Fußnote[^1].

[^1]: ESMA, Q&A on MiFID II, ESMA35-43-344, Rn. 12.
```

### Sonderzeichen

`✓` / `✗` fehlen in Times New Roman → in `.md` durch `[x]` / `[ ]` ersetzen, wenn der Nutzer danach fragt.

## Fehlerbehebung

| Fehler | Lösung |
|---|---|
| `pandoc` fehlt | `brew install pandoc` |
| `xelatex` fehlt | `brew install basictex`, Terminal neu starten |
| LaTeX-Paket fehlt | `Einmal einrichten.command` im Skill-Ordner (optional) |
| Datei nicht gefunden | Absoluten Pfad prüfen, Leerzeichen quoten |

## Was der Agent NICHT tun soll

- Kein LLM für Layout, Formatierung oder PDF-Inhalt
- Kein pandoc-Befehl ohne `defaults.yaml` erfinden
- Keine Eisvogel-/Online-Templates ohne expliziten Auftrag
- Keine PDF manuell schreiben oder generieren

## Nutzer-Anweisung (einfach)

Wenn der Nutzer nur „mach PDF“ sagt:

> Ich konvertiere die Datei jetzt per Pandoc — die PDF erscheint neben der Markdown-Datei.

Dann Skript ausführen und Ergebnis melden.
