---
name: spec-klaeren
description: >-
  Klärt vor dem Bauen Sonderfälle und unklare Wörter mit wenigen Fragen
  in Alltagssprache und schreibt danach eine kurze Spezifikation als
  GitHub-Issue oder Markdown-Datei (Ziel, Grenzen, Akzeptanzkriterien,
  kleine Arbeitspakete). Nutzen, wenn der Auftrag unscharf ist, der
  Captain vor dem Bau nachfragen will, oder ein Wort mehrdeutig ist.
---

# Rückfragen und Spezifikation

Inspiration: Ideen aus https://github.com/mattpocock/skills (MIT), Commit `5beb35b`. Text eigen, keine Laufzeit-Abhängigkeit. Eigene Kopie dieser Org, kein Symlink.

Captain = Jeremiah, der Auftraggeber. Fragen an ihn in Alltagssprache. Ein Fachwort nur mit Klammerzusatz (ein Halbsatz).

## Wann

Vor dem Bauen, wenn Ziel, Grenze oder ein Wort unklar ist. Nicht bei einem Tippfehler oder einer schon festgelegten Ein-Satz-Änderung. Nicht bauen, bevor der Captain die Spezifikation frei gibt (`execution.mdc`).

Nachbau („bau das nach“, „rebuild this“, „clone this feature“, oder die Frage, wie eine bestehende App, eine Binary, eine API oder eine Website etwas macht): zuerst die REA-Regel in `workflow.mdc` und `brain/principles.md`. Dieser Skill ersetzt diese Prüfung nicht.

## Rückfragen

Höchstens drei Fragen pro Runde. Nur Entscheidungen, die der Captain treffen muss. Was im Repo, in `brain/principles.md` oder in den Rules steht, selbst nachsehen.

Jede Frage in einem Satz. Darunter die Zeile `Vorschlag:` — das gilt, wenn er nichts anderes sagt. Dann warten.

Die nächste Runde erst nach seinen Antworten. Aufhören, wenn er „reicht“ oder „schreib die Spec“ sagt, oder wenn kein Sonderfall mehr offen ist.

## Spezifikation

Danach die Spec schreiben, nicht nur in den Chat.

- GitHub-Issue im Repo, zu dem die Änderung gehört (Org laut `brain/index-agents.md`, Abschnitt GitHub).
- Markdown nur, wenn der Captain eine Datei will oder kein Issue angelegt werden kann. Den Pfad in einem Satz nennen und genau dort anlegen. Nicht unter `logs/`. Keine Todo-Liste als Markdown (`workflow.mdc` §Todos).

Keine Secrets, keine `.env`-Werte, keine Tokens (`principles.md` 4.3). Keine langen Code-Blöcke.

```markdown
# Ziel
Ein Satz: was danach anders ist, aus Sicht des Captains.

# Grenzen
Was ausdrücklich nicht dazu gehört.

# Akzeptanzkriterien
- [ ] prüfbar, ohne den Code zu lesen

# Arbeitspakete
### 1. Name
- Danach gilt: …
- Prüfen: …
- Wartet auf: keines
```

Ein Arbeitspaket ist ein schmaler Weg durch alle betroffenen Teile, den man für sich prüfen kann. Klein genug für einen frischen Agenten in einem Durchgang. Nicht „erst nur die Datenbank, dann nur die Oberfläche“.

Hängt ein Paket von einem anderen ab, unter `Wartet auf` den Namen setzen. Eine Umbenennung quer durch viele Dateien nicht in ein Paket zwingen: erst das Neue daneben, dann umstellen, dann das Alte entfernen.

Spec vorlegen und stoppen. Bauen erst nach Freigabe.
