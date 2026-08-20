# ADR 0007 — Agent-SSOT am Org-Root

## Kontext

Agent-Rules, Skills, brain-Maps und Turn-Logs gehören nicht in Domain-`data/files/`. Das vermischt Dev-Time-Kontext (Cursor/Claude) mit Domain-Laufzeitdaten. Hetzner `development/`/`staging/` soll nur Dummy-Daten halten; echte Nutzdaten gehören nach Netcup `production/`.

Die LauerTeam-Kopie erwähnte `myAgentsDomain` — TunnelQuiz hat **kein** myAgentsDomain.

## Entscheidung

File-Hub lebt auf Hetzner am Org-Root:

- `/opt/TunnelQuiz/.cursor/` — brain, rules, skills, hooks, mcp, scripts, logs
- `/opt/TunnelQuiz/.claude/` — Claude-Hooks

App `tunnelQuizApp` und Domain `tunnelQuizDomain` symlinken auf den Org-Root; der Org-Root selbst hat keine Selbst-Symlinks. Keine Cross-Org-Symlinks nach LauerTeam (ADR 0011).

Domain-Schnitt: ADR `0001-lauerteam-domain-split.md` (Inhalt = TunnelQuiz, nicht LauerTeam).

## Begründung

`principles.md` §1.5: Agent-Symlinks sind Dev-Time, keine Laufzeit-Kopplung. Der SSOT gehört deshalb an den Workspace-Root, nicht in eine Domain-`data/`-Ebene.

## Verworfene Alternativen

- SSOT in Domain-`data/files/`
- File-Hub nach `~/` / Cursor User Rules
- Getrennte Kopien in development und staging
- Symlinks nach `/opt/LauerTeam/.cursor/`
