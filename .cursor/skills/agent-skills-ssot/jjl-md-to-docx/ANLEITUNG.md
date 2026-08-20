# Markdown → Word (WM-Formatvorlagen)

Immer gleiche Formatvorlagen. Kein KI, kein Internet.

**SSOT-Ordner:**
`Documents/Menschen/Lauer, Jeremiah Joel/KI = Künstliche Intelligenz/Skills/md-to-docx-jura/`

**Projekt-Vorlage:**
`Desktop/- Todo - WM-Aufsatz/- KI/Word-Vorlage/reference.docx`

---

## So benutzt du es (empfohlen)

Im Terminal:

```bash
"/Users/jjl/Documents/Menschen/Lauer, Jeremiah Joel/KI = Künstliche Intelligenz/Skills/md-to-docx-jura/md2docx.sh" "/Pfad/zur/datei.md"
```

Die **Word-Datei liegt im selben Ordner** wie die Markdown-Datei.

Ganzen Ordner konvertieren (alle `.md` darin):

```bash
"/Users/jjl/Documents/Menschen/Lauer, Jeremiah Joel/KI = Künstliche Intelligenz/Skills/md-to-docx-jura/md2docx.sh" "/Pfad/zum/ordner/"
```

In Cursor einfach sagen: *„Wandle diese .md in Word um“* — der Agent nutzt den Skill `md-to-docx-jura`.

---

## Was du bekommst

- WM-Formatvorlagen aus deiner Entwurfs-Word-Datei
- Echte Word-Fußnoten aus `[^1]`-Syntax
- Überschriften, Kursiv, Fett, Tabellen
- Weiterbearbeitung in Word (Track Changes, Co-Autoren)

---

## Vorlage aktualisieren

1. Formatvorlagen in Word anpassen (Datei `reference.docx` in `Word-Vorlage/` öffnen).
2. Kopie ins Skill-Verzeichnis:

```bash
cp "/Users/jjl/Desktop/- Todo - WM-Aufsatz/- KI/Word-Vorlage/reference.docx" \
   "/Users/jjl/Documents/Menschen/Lauer, Jeremiah Joel/KI = Künstliche Intelligenz/Skills/md-to-docx-jura/reference.docx"
```

---

## Wenn etwas nicht klappt

| Problem | Lösung |
|---|---|
| `pandoc` fehlt | `brew install pandoc` |
| Falsche Formatierung | `reference.docx` prüfen/aktualisieren |
| TOC-Links im Text | In der `.md` entfernen, in Word TOC neu erzeugen |

---

## Ordnerinhalt

| Datei | Zweck |
|---|---|
| `SKILL.md` | Cursor-Agent-Skill |
| `md2docx.sh` | Konvertierungsskript |
| `defaults.yaml` | Pandoc-Einstellungen |
| `reference.docx` | Word-Formatvorlagen |
| `Word machen.command` | Optional (Drag & Drop) |
| `ANLEITUNG.md` | Diese Anleitung |
