# Markdown → PDF (juristisch-akademisch)

Immer gleiches Layout. Kein KI, kein Internet.

**SSOT-Ordner:**
`Documents/Menschen/Lauer, Jeremiah Joel/KI = Künstliche Intelligenz/Skills/md-to-pdf-jura/`

---

## So benutzt du es (empfohlen)

Im Terminal:

```bash
"/Users/jjl/Documents/Menschen/Lauer, Jeremiah Joel/KI = Künstliche Intelligenz/Skills/md-to-pdf-jura/md2pdf.sh" "/Pfad/zur/datei.md"
```

Die **PDF liegt im selben Ordner** wie die Markdown-Datei.

Ganzen Ordner konvertieren (alle `.md` darin):

```bash
"/Users/jjl/Documents/Menschen/Lauer, Jeremiah Joel/KI = Künstliche Intelligenz/Skills/md-to-pdf-jura/md2pdf.sh" "/Pfad/zum/ordner/"
```

In Cursor einfach sagen: *„Wandle diese .md in PDF um“* — der Agent nutzt den Skill `md-to-pdf-jura`.

---

## Was du bekommst

Jede PDF sieht gleich aus:

- A4, 11 pt, Serifenschrift (Times-Stil)
- Deutsche Silbentrennung und Typografie
- Übersichtliche Überschriften
- Saubere Tabellen und Fußnoten
- 2,5 cm Seitenränder

Passt für WM-Aufsätze, Seminararbeiten, Gutachten-Entwürfe, Maßstäbe, Vermerke.

---

## Optional: Titel und Autor in der PDF

Ganz oben in deiner `.md`-Datei:

```markdown
---
title: "Transparenzpflichten nach MiFID II"
author: "Max Mustermann"
date: "Juli 2026"
---

# Einleitung
…
```

Ohne diesen Block wird einfach der Text formatiert — kein Deckblatt.

---

## Fußnoten (für Zitate)

```markdown
Die ESMA hat klargestellt, dass …[^1]

[^1]: ESMA, Q&A on MiFID II, ESMA35-43-344, Rn. 12.
```

---

## Wenn etwas nicht klappt

| Problem | Lösung |
|---|---|
| Fenster schließt sofort mit Fehler | Pandoc/LaTeX fehlt — siehe unten |
| Sonderzeichen fehlen in der PDF | In der `.md`-Datei `[x]` statt ✓ verwenden |
| Drag & Drop auf `.command` klappt nicht | Terminal-Befehl oben nutzen |

**Einmalige Installation** (falls noch nicht vorhanden):

```bash
brew install pandoc basictex
```

Danach Terminal neu starten.

---

## Ordnerinhalt

| Datei | Zweck |
|---|---|
| `SKILL.md` | Cursor-Agent-Skill |
| `md2pdf.sh` | Konvertierungsskript |
| `defaults.yaml` | Layout-Einstellungen |
| `PDF machen.command` | Optional (Drag & Drop — unzuverlässig) |
| `Einmal einrichten.command` | Optional — extra LaTeX-Pakete |
| `ANLEITUNG.md` | Diese Anleitung |
