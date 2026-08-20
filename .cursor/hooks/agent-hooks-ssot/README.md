# Hooks SSOT

Symlink-Ziel für `.cursor/hooks/agent-hooks-symlink` in Projekt-Repos.

| Inhalt | Zweck |
|--------|--------|
| `hooks.json.example` | Vorlage für projekt-eigene `.cursor/hooks.json` |

**Turn-Logging** läuft über VPS-Cron — Skripte: `scripts/turn-log/`, Doku: `scripts/turn-log/README.md`.

Turn-Logging läuft über VPS-Cron (`scripts/turn-log/`), nicht über IDE-Hooks.
