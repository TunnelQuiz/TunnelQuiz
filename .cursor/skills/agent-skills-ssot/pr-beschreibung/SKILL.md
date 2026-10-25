---
name: pr-beschreibung
description: >-
  Schreibt die Beschreibung einer Pull Request: was sich geändert hat,
  wie man es testet, und den Abschnitt Merge-Risiko (Stufe, betroffene
  Dienste, ob Netcup berührt ist, Rollback, was vor dem Merge zu prüfen
  ist). Bei grünen Checks mergen, außer Netcup ist berührt — dann nur
  mit ausdrücklicher Freigabe des Captains. Nutzen beim Öffnen oder
  Nachziehen einer Pull Request.
---

# PR-Beschreibung mit Merge-Risiko

Inspiration: Ideen aus https://github.com/mattpocock/skills (MIT), Commit `5beb35b`. Text eigen, keine Laufzeit-Abhängigkeit. Eigene Kopie dieser Org, kein Symlink.

## Wann

Beim Öffnen oder Aktualisieren einer Pull Request. Der Text ersetzt keine Spec (`spec-klaeren`).

Gearbeitet wird auf Hetzner, nicht auf dem MacBook (`brain/index-workspace.md` §Entwicklungsumgebung).

## Text

Kurz. Alltagssprache. Ein Diagramm oder ein kurzer Baum nur, wenn er den Kern zeigt. Keine Secrets, keine `.env`-Werte, keine Tokens (`principles.md` 4.3).

```markdown
## Was sich geändert hat

## So testet man es
Schritte, die der Captain ohne Code-Lesen nachvollziehen kann. Einen Befehl nur, wenn es einen fertigen Prüflauf gibt.

## Merge-Risiko
- **Stufe:** niedrig | mittel | hoch
- **Dienste:** …
- **Netcup (Produktion):** ja | nein
- **Rollback:** …
- **Vor dem Merge prüfen:**
  - …
```

| Stufe | Wann |
|---|---|
| niedrig | Doku oder Regeln, kein Dienst, Netcup nein, Zurücknehmen per Git reicht |
| mittel | ein Dienst nur auf Hetzner (`development` oder `staging`), zurücknehmbar per Git oder vorherigem Image-SHA |
| hoch | Netcup, Daten löschen, Migration, mehrere Dienste, oder nicht zurücknehmbar |

Netcup ja: dort nichts ändern und nichts deployen, bis der Captain ausdrücklich frei gibt (`principles.md` 3.0 und 3.3). Ein grüner Check ist dann keine Freigabe für Produktion.

Rollback in einem Satz: Git zurücknehmen; ein laufender Dienst holt den vorherigen Image-SHA (`principles.md` 3.5 und 0.6). Kein Quelltext auf Netcup anfassen.

## Merge

Den PR nicht als Entwurf zurückhalten. Checks grün und Netcup nein: mergen (`workflow.mdc` Git-Punkt 3, `principles.md` 5.6).

Netcup ja: nicht mergen und nichts auf Netcup ändern, bis der Captain ausdrücklich frei gibt.

Direkt auf `main` zu committen bleibt erlaubt, wenn gar kein PR entsteht (`workflow.mdc` Git-Punkt 1). Sobald ein PR entsteht, gilt dieser Skill.
