---
name: md-to-redline-jura
description: >-
  Erstellt technische Redline-PDFs durch Vergleich zweier Markdown-Dateien
  (latexdiff + Pandoc/XeLaTeX, ohne LLM). Verwenden wenn der Nutzer zwei .md
  vergleichen, Redline, Änderungsvergleich, Diff-PDF oder md-to-redline-jura
  erwähnt.
---

# Markdown Redline → PDF (technisch)

## Skill-Basis (SSOT)

```
/Users/jjl/Documents/Menschen/Lauer, Jeremiah Joel/KI = Künstliche Intelligenz/Skills/md-to-redline-jura/
```

| Datei | Zweck |
|---|---|
| `md2redline.sh` | Redline-Konvertierung |
| `defaults-tex.yaml` | LaTeX-Layout (gleich wie md-to-pdf-jura) |
| `ANLEITUNG.md` | Nutzer-Anleitung |

Verwandter Skill: `md-to-pdf-jura` (Einzel-PDF ohne Vergleich).

## Grundregel

**Niemals LLM für den Vergleich.** Rein technisch: `latexdiff` auf zwei Pandoc-LaTeX-Exporte.

```bash
"/Users/jjl/Documents/Menschen/Lauer, Jeremiah Joel/KI = Künstliche Intelligenz/Skills/md-to-redline-jura/md2redline.sh" "/pfad/alt.md" "/pfad/neu.md"
```

**Ausgabe:** `{alt}-vs-{neu}-redline.pdf` neben `neu.md` (oder dritter Parameter als Zielpfad).

## Workflow für den Agenten

1. Zwei `.md`-Pfade klären: **alt** (Basis), **neu** (Überarbeitung).
2. Abhängigkeiten prüfen:
   ```bash
   command -v pandoc xelatex latexdiff
   ```
3. Redline ausführen:
   ```bash
   SKILL="/Users/jjl/Documents/Menschen/Lauer, Jeremiah Joel/KI = Künstliche Intelligenz/Skills/md-to-redline-jura/md2redline.sh"
   "$SKILL" "/pfad/alt.md" "/pfad/neu.md"
   ```
4. Optional mit festem Ausgabepfad:
   ```bash
   "$SKILL" "/pfad/alt.md" "/pfad/neu.md" "/pfad/vergleich-redline.pdf"
   ```
5. PDF existiert und ist lesbar → Nutzer informieren.

## Was die Redline zeigt

| Markierung | Bedeutung |
|---|---|
| Durchgestrichen | In alt.md, nicht (so) in neu.md |
| Unterstrichen | Neu oder geändert in neu.md |

Kein inhaltliches Urteil — nur Zeichen-/Zeilen-Diff.

## Fehlerbehebung

| Fehler | Lösung |
|---|---|
| `latexdiff` fehlt | `brew install latexdiff` |
| LaTeX-Kompilierung scheitert | Oft Tabellen/Fußnoten — Terminal-Diff: `git diff --no-index alt.md neu.md` |
| `pandoc` / `xelatex` fehlt | wie md-to-pdf-jura: `brew install pandoc basictex` |

## Einschränkungen

- Große strukturelle Umbauten (verschobene Abschnitte) → unübersichtliche Redline
- Tabellen und Fußnoten können latexdiff brechen
- Kein Word-Track-Changes-Import — nur zwei `.md`-Dateien

## Was der Agent NICHT tun soll

- Kein LLM zum Vergleichen oder Zusammenfassen der Änderungen
- Kein manuelles Markieren von Änderungen in Markdown
- Kein md-to-pdf-jura für Redline-Aufgaben verwenden
- Bei latexdiff-Fehler nicht halluzinieren — Fehler melden und `git diff` anbieten

## Nutzer-Anweisung (einfach)

> Ich vergleiche die beiden Markdown-Dateien technisch und erstelle eine Redline-PDF.

Dann `md2redline.sh` ausführen.
