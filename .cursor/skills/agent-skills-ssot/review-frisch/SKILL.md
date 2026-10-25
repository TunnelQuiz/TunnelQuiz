---
name: review-frisch
description: >-
  Prüft eine Änderung mit zwei frischen Agents parallel: einer nur gegen
  die Spezifikation, einer nur gegen die Regeln des Repos. Die Funde
  bleiben getrennt und sind nach Dringlichkeit sortiert. Nutzen nach dem
  Bauen, vor einer Freigabe, oder wenn der Captain eine unabhängige
  Prüfung will.
---

# Prüfung durch frische Agents

Inspiration: Ideen aus https://github.com/mattpocock/skills (MIT), Commit `5beb35b`. Text eigen, keine Laufzeit-Abhängigkeit. Eigene Kopie dieser Org, kein Symlink.

## Wann

Nach einer Änderung mit Spec, vor einer riskanten Freigabe (mehrere Dienste, Daten, Netcup), oder wenn der Captain „prüf das“ sagt. Nicht bei einem Tippfehler.

Die prüfenden Agents haben die Änderung nicht selbst gebaut. Ihre Funde nicht mit der eigenen Meinung glätten.

## Ablauf

1. Vergleichspunkt festnageln. Ohne Angabe: die Merge-Base mit `main`. Diff: `git diff <punkt>...HEAD` (drei Punkte). Leerer Diff oder unbekannter Punkt: stoppen und den Captain fragen.
2. Spec suchen: Issue-Nummer in den Commits, ein Pfad vom Captain, sonst die Spec aus diesem Auftrag. Fehlt sie: die Spec-Achse auslassen und das sagen. Keine Spec im Review erfinden. Hinweis auf `spec-klaeren`.
3. Zwei Sub-Agenten parallel, gleicher Diff, getrennte Aufträge (`execution.mdc`). Jeder bekommt den Diff-Befehl, die Pfade und das Fertig-Kriterium, nicht die Bewertung des anderen.

**Spec-Agent:** nur die Spec. Melden: (a) ein Kriterium fehlt oder ist halb, (b) der Diff enthält etwas, das die Spec nicht verlangt, (c) ein Kriterium sieht erfüllt aus und ist falsch. Je Fund die Spec-Zeile zitieren.

**Regeln-Agent:** nur die geschriebenen Regeln. Lesen: `brain/principles.md` §2 und §8, `rules/agent-rules-ssot/`. Hart ist ein Verstoß dagegen, ein Secret im Text, oder eine Änderung an Netcup (Produktion) ohne ausdrückliche Freigabe. Was ein Linter schon erzwingt, nicht noch einmal als Fund. Bauchgefühl ist kein Fund.

4. Beide Berichte gegen den Diff lesen. Einen Fund streichen nur, wenn er sachlich falsch ist, und das dazuschreiben.
5. Nichts am Code ändern. Der Captain sagt, was gefixt wird.

## Sortierung

Innerhalb jeder Achse sortieren. Die beiden Listen nicht zu einer Note vermischen.

| Stufe | Bedeutung |
|---|---|
| Blocker | Spec verfehlt, oder harte Regel (Secret, Netcup, §2, §8) |
| Vor der Freigabe | sollte weg, ist kein harter Bruch |
| Später | Hinweis, nicht dieser PR |

## Ausgabe

```markdown
## Gegen die Spec
1. **Blocker** — …

## Gegen die Regeln
1. **Blocker** — …

## Kurz
Spec: <Anzahl>, schlimmster Fund: …
Regeln: <Anzahl>, schlimmster Fund: …
```

Fehlt die Spec, steht das unter „Gegen die Spec“.
