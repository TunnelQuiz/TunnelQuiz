---
name: rueckblick
description: >-
  Schlägt am Ende einer Aufgabe konkrete Verbesserungen an Regeln, Lint
  oder Doku vor und setzt keine davon um. Der Captain wählt die Punkte.
  Nutzen, wenn eine nicht triviale Aufgabe abgeschlossen ist oder der
  Captain einen Rückblick will.
---

# Rückblick

Inspiration: Ideen aus https://github.com/mattpocock/skills (MIT), Commit `5beb35b`. Text eigen, keine Laufzeit-Abhängigkeit. Eigene Kopie dieser Org, kein Symlink.

## Wann

Am Ende einer abgeschlossenen Aufgabe, die mehr war als ein Tippfehler. Nicht mitten im Bauen. Nichts davon selbst einbauen, auch nicht die kleine naheliegende Zeile.

## Suchen

Nur Lücken, die in dieser Aufgabe wirklich aufgetreten sind. Höchstens fünf. Nichts erfunden, um die Liste zu füllen. Leer ist erlaubt: dann „keine“.

Reihenfolge: was den Fehler am ehesten verhindert hätte, zuerst.

| Art | Wann vorschlagen |
|---|---|
| Lint | Ein festes Muster (verbotene Stelle, Datei am falschen Ort). Lieber ein Check als ein neuer Satz in den Regeln (`principles.md` 5.7). Vorher schauen, ob Lint oder CI das schon können und nur nicht laufen. |
| Regel | Eine Ermessensfrage, die kein Check fassen kann. Die bestehende Datei unter `rules/agent-rules-ssot/` oder `brain/principles.md` nennen. Keine neue `AGENTS.md` (`agent-global.mdc`). |
| Doku | Ein Hinweis, der gefehlt hat. Die bestehende Datei nennen, keine zweite Kopie derselben Information (`agent-global.mdc`, Meta-Regel). |

Andere Orgs nicht anfassen. Übernehmen nur, wenn der Captain es will (`workflow.mdc` §Org-File-Hub).

## Ausgabe

```markdown
## Vorschläge
Nichts davon ist umgesetzt.

1. **Lint | Regel | Doku** — was, in welcher Datei, ein Satz warum.
```

Der Captain nennt die Nummern. Ohne Nummer keine Änderung.
