---
name: md-to-docx-jura
description: >-
  Konvertiert Markdown-Dateien per Pandoc in Word (.docx) mit WM-Formatvorlagen
  und Fußnoten. Nutzt das lokale md-to-docx-jura-Setup ohne LLM. Verwenden wenn
  der Nutzer .md in Word umwandeln, DOCX exportieren, Formatvorlagen einfügen
  oder md-to-docx-jura erwähnt.
---

# Markdown → Word (WM-Formatvorlagen)

## Skill-Basis (SSOT)

Alles liegt hier:

```
/Users/jjl/Documents/Menschen/Lauer, Jeremiah Joel/KI = Künstliche Intelligenz/Skills/md-to-docx-jura/
```

| Datei | Zweck |
|---|---|
| `md2docx.sh` | Konvertierungsskript |
| `defaults.yaml` | Pandoc-Einstellungen |
| `reference.docx` | Word-Formatvorlagen (Kopie) |
| `ANLEITUNG.md` | Nutzer-Anleitung |

**Projekt-Vorlage (Original):**

```
/Users/jjl/Desktop/- Todo - WM-Aufsatz/- KI/Word-Vorlage/reference.docx
```

Abgeleitet aus `2026-05-13 - Entwurf - 2026-07-15 171800.docx`. Inhalt der Vorlage wird von Pandoc ignoriert — nur die Formatvorlagen zählen.

## Grundregel

**Niemals LLM für die Word-Erzeugung.** Immer das lokale Skript ausführen:

```bash
"/Users/jjl/Documents/Menschen/Lauer, Jeremiah Joel/KI = Künstliche Intelligenz/Skills/md-to-docx-jura/md2docx.sh" "/absoluter/pfad/zur/datei.md"
```

Die `.docx` liegt im **selben Ordner** wie die `.md`-Datei.

## Workflow für den Agenten

1. Pfad der `.md`-Datei ermitteln (absoluter Pfad, Anführungszeichen bei Leerzeichen).
2. Prüfen ob `pandoc` verfügbar ist:
   ```bash
   command -v pandoc
   ```
3. Konvertierung ausführen (Pfad aus Grundregel oben).
4. Erfolg prüfen: `.docx` existiert, Dateigröße > 0.
5. Nutzer kurz informieren: wo die Word-Datei liegt.

### Mehrere Dateien oder Ordner

```bash
SKILL="/Users/jjl/Documents/Menschen/Lauer, Jeremiah Joel/KI = Künstliche Intelligenz/Skills/md-to-docx-jura/md2docx.sh"
"$SKILL" "/ordner/"
"$SKILL" "a.md" "b.md"
```

## Pandoc-Zuordnung

| Markdown | Word-Formatvorlage |
|---|---|
| `#` | Überschrift 1 |
| `##` | Überschrift 2 |
| `###` | Überschrift 3 |
| Fließtext | Normal |
| `[^1]` + `[^1]: …` | Fußnoten |
| `*kursiv*` / `**fett**` | Kursiv / Fett |
| Tabellen | Tabellen |

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

### Gliederung (WM)

Überschriften in der `.md` mit Präfix schreiben:

```markdown
# A. Einleitung
## I. Funktionsweise …
```

### Inhaltsverzeichnis-Links

Auto-TOC-Links aus HTML/PDF-Export (`[A. Einleitung [1](#…)]`) vor Konvertierung entfernen oder in Word neu erzeugen.

## Fehlerbehebung

| Fehler | Lösung |
|---|---|
| `pandoc` fehlt | `brew install pandoc` |
| `reference.docx` fehlt | Vorlage in `Word-Vorlage/` prüfen |
| Datei nicht gefunden | Absoluten Pfad prüfen, Leerzeichen quoten |

## Was der Agent NICHT tun soll

- Kein LLM für Layout, Formatierung oder Word-Inhalt
- Kein pandoc-Befehl ohne `defaults.yaml` und `reference.docx` erfinden
- Keine `.docx` manuell schreiben oder generieren

## Nutzer-Anweisung (einfach)

Wenn der Nutzer nur „mach Word“ sagt:

> Ich konvertiere die Datei jetzt per Pandoc — die Word-Datei erscheint neben der Markdown-Datei.

Dann Skript ausführen und Ergebnis melden.
