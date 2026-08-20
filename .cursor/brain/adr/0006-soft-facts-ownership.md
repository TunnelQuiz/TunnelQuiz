# ADR 0006 — Soft Facts: Eigentum nach Lebensdauer

**Status:** angenommen  
**Datum:** 2026-08-11  
**SSOT der Tabelle:** `principles.md` §1.6 (diese Datei = Entscheidung + Begründung)

## Kontext

Unklar war, ob Soft Facts (Favoriten, Layouts, Theme) in eine User-Domain oder in App-Daten gehören.

## Entscheidung

Speichern nach **Eigentum & Lebensdauer**, nicht nach „hart vs. weich“. Keine God-User-Domain als Default. Normativ: `principles.md` §1.6.

## Begründung

- Präsentations-Layouts gehören zum GUI und sterben mit der App (Rip-out → §1.5).
- Favoriten auf Entities sind Domänen-Beziehungen und überleben GUI-Redesign.
- Zentrale Soft-Facts-Domain koppelt Layout-Evolution an fremde Deploy-Zyklen (YAGNI → 0.1).

## Verworfen

| Alternative | Warum nicht |
|---|---|
| Alle Soft Facts in `myUserDomain` | God-Domain; GUI-Kopplung |
| Alle Soft Facts nur in App-`data/` | Entity-Favoriten gehen bei App-Rip-out verloren |
| Nur Browser-localStorage | kein Sync, keine Server-SSOT |

## Folgen

Neue Soft-Fact-Features: zuerst §1.6-Tabelle. Schema erst beim ersten Feature, nicht vorab.
