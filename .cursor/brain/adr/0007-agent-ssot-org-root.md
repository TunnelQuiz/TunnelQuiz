# ADR 0007 — Agent-SSOT am Org-Root

## Kontext

Agent-Rules, Skills, brain-Maps und Turn-Logs lagen unter `Domains/myAgentsDomain/{development,staging}/data/files/`. Das vermischte Dev-Time-Kontext (Cursor/Claude) mit Domain-Laufzeitdaten. Hetzner `development/`/`staging/` soll nur Dummy-Daten halten; echte Nutzdaten gehören nach Netcup `production/`.

## Entscheidung

File-Hub lebt auf Hetzner am Org-Root:

- `/opt/TunnelQuiz/.cursor/` — brain, rules, skills, hooks, mcp, scripts, logs
- `/opt/TunnelQuiz/.claude/` — Claude-Hooks

myAgentsDomain bleibt Runtime-API (Rechte, strukturierte Daten). Projekte symlinken auf den Org-Root; der Org-Root selbst hat keine Selbst-Symlinks.

Nutzdaten aus Hetzner-`data/files/` liegen als Backup unter `/opt/TunnelQuiz/_TEMP/` (gleiche relative Pfade), Ziel: Netcup production. `_TEMP/`-Kopien des File-Hubs sind nicht Live-SSOT (SSOT = Org-Root). Domain-Schnitt: ADR `0001-lauerteam-domain-split.md`.

## Begründung

`principles.md` §1.5: Agent-Symlinks sind Dev-Time, keine Laufzeit-Kopplung. Der SSOT gehört deshalb an den Workspace-Root, nicht in eine Domain-`data/`-Ebene.

## Verworfene Alternativen

- SSOT in myAgentsDomain `data/files/` belassen
- File-Hub nach `~/` / Cursor User Rules
- Getrennte Kopien in development und staging
