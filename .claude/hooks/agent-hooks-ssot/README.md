# Claude-Hooks SSOT

Symlink-Ziel für `.claude/hooks/agent-hooks-symlink` in Projekt-Repos.
Pendant zu `.cursor/hooks/agent-hooks-ssot/` — eigener Namespace, weil Claude Code und
Cursor unterschiedliche Hook-Events/Formate haben und die Skripte nicht austauschbar sind.

| Inhalt | Zweck |
|--------|--------|
| `load-agent-rules.sh` | SessionStart-Hook: liest `.cursor/rules/*.mdc` (Agent-SSOT + projekteigen) des Projekts und gibt sie als Kontext aus — Pendant zu Cursors nativer Rule-Ladung |
| `settings.json.example` | Vorlage für projekt-eigene `.claude/settings.json` |
