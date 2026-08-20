# Turn-Logging — Transcript-Sync (VPS-Cron)

Pro abgeschlossenem Agent-Turn:

| Ausgabe | Ort | Inhalt |
|---------|-----|--------|
| **Index** | `logs/agent-turns/JJJJ-MM-TT.jsonl` | Metadaten + `_archive`-Pfad |
| **Archiv** | `logs/agent-turns/_archive/<YYYY>/<MM month>/<DD weekday>/<session>/<turn>.json` | User-Nachricht, Assistant-Antwort, Tool-Calls, Metadaten |

**Hauptweg:** VPS-Cron liest Cursor-Transcripts direkt — unabhängig von IDE-Hooks.

Skripte: `scripts/turn-log-sync.sh` → `scripts/turn-log/turn-log.py --sync` (kein LLM, Exit immer 0).

## Cron (jjl, jede Minute)

```bash
* * * * * /opt/TunnelQuiz/.cursor/scripts/turn-log-sync.sh
```

Cron zeigt auf `/opt/TunnelQuiz/.cursor/scripts/turn-log-sync.sh` (File-Hub).

Liest Transcript-Roots unter `~/.cursor/projects/*/agent-transcripts/` (Default: `opt-LauerTeam`, `opt-LauerTeam-Domains-myAgentsDomain`, `opt`). Konfiguration: `AGENT_TRANSCRIPT_ROOTS` (kommagetrennt) in `turn-log-sync.sh`.
Index-Einträge haben `"agent": "cursor-sync"`, `"event": "sync"`.

Spätestens **1 Minute** nach Turn-Ende erscheint ein neues Archiv.

## Benennung

| Ebene | Format | Beispiel |
|-------|--------|----------|
| Monat | `YYYY/MM month/` | `2026/07 july/` |
| Tag | `DD weekday/` | `03 friday/` |
| Session-Ordner | `YYYY-MM-DD-HH-MM-SS-<keyword>-<session-id>` | `2026-07-02-23-15-23-moin-4404b347-…` |
| Turn-Datei | `YYYY-MM-DD-HH-MM-SS-<keyword>-<generation-id>.json` | `2026-07-02-23-15-23-moin-sync-turn-0001.json` |

**Keyword** = erste Zeile der User-Nachricht aus `<user_query>`, slugified (max. 40 Zeichen).

## Manuell

```bash
/opt/TunnelQuiz/.cursor/scripts/turn-log-sync.sh
ls logs/agent-turns/_archive/
```

Migration bestehender UUID-Ordner:

```bash
python3 scripts/turn-log/turn-log.py --rename-archive-dirs
python3 scripts/turn-log/turn-log.py --rename-archives
python3 scripts/turn-log/turn-log.py --migrate-date-buckets
```

## Hooks (archiviert)

IDE-Hooks entfernt. Turn-Logs schreibt der VPS-Cron (`scripts/turn-log/`).
Geplant: agentenübergreifende Hooks ohne Cron (Todo in Postgres).
