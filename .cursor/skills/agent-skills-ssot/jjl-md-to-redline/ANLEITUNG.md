# Markdown Redline → PDF (technisch)

Zwei `.md`-Dateien vergleichen — **ohne KI**, nur `latexdiff`.

**SSOT-Ordner:**
`Documents/Menschen/Lauer, Jeremiah Joel/KI = Künstliche Intelligenz/Skills/md-to-redline-jura/`

---

## So benutzt du es

```bash
"/Users/jjl/Documents/Menschen/Lauer, Jeremiah Joel/KI = Künstliche Intelligenz/Skills/md-to-redline-jura/md2redline.sh" \
  "/Pfad/zur/alt.md" \
  "/Pfad/zur/neu.md"
```

**Ergebnis:** `alt-vs-neu-redline.pdf` (neben `neu.md`)

Eigener Ausgabename (optional):

```bash
md2redline.sh alt.md neu.md "/Pfad/vergleich-redline.pdf"
```

In Cursor: *„Redline zwischen diesen zwei .md-Dateien“* — Skill `md-to-redline-jura`.

---

## Was du siehst

- **Durchgestrichen** = war in alt, fehlt/geändert in neu
- **Unterstrichen** = neu oder geändert in neu

Gleiche Schrift/Ränder wie beim normalen PDF-Export (`md-to-pdf-jura`).

---

## Einmalige Installation

```bash
brew install pandoc basictex latexdiff
```

Terminal danach neu starten.

---

## Wenn es nicht klappt

Terminal-Diff (immer verfügbar):

```bash
git diff --no-index "/Pfad/alt.md" "/Pfad/neu.md"
```

Bei Tabellen/Fußnoten scheitert `latexdiff` manchmal — dann Terminal-Diff nutzen.

---

## Ordnerinhalt

| Datei | Zweck |
|---|---|
| `SKILL.md` | Cursor-Agent-Skill |
| `md2redline.sh` | Redline-Skript |
| `defaults-tex.yaml` | LaTeX-Layout |
| `ANLEITUNG.md` | Diese Anleitung |
