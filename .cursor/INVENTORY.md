# Cursor SSOT — Inventar

> Pfad: `/opt/LauerTeam/.cursor/`

## Namenskonvention

- **`-symlink`** = Symlink (Pointer im Projekt)
- **`-ssot`** = echter Inhalt (Org-Root)

## SSOT-Struktur

```
.cursor/
├── brain/                       ← Maps + Prinzipien + adr/ (0001, 0002, 0006, 0007, 0008, 0009)
├── logs/                        ← Turn-Logs
├── scripts/                     ← Install, Verify, Turn-Log, gen-staging-compose.py
├── rules/agent-rules-ssot/      ← *.mdc
├── hooks/agent-hooks-ssot/      ← Hook-Vorlagen (Turn-Log: scripts/turn-log/)
├── mcp/agent-mcp-ssot/          ← README + cloudflare.cursor.mcp.json (keine Secrets)
└── skills/agent-skills-ssot/    ← Skill-Pakete
```

MCP-Details: `mcp/agent-mcp-ssot/README.md` — Runtime = Cursor-Plugin; OAuth intern; DNS-Token in Server-`.env`.

Turn-Logging (Cron): `scripts/turn-log/` — nicht in `hooks/agent-hooks-ssot/`.

Skill-Inhalte: `/opt/LauerTeam/.cursor/skills/agent-skills-ssot/`

## Projekt-Symlinks

```
Projekt/.cursor/
├── rules/agent-rules-symlink    →  SSOT/rules/agent-rules-ssot/
├── skills/agent-skills-symlink  →  SSOT/skills/agent-skills-ssot/
├── hooks/agent-hooks-symlink    →  SSOT/hooks/agent-hooks-ssot/
└── mcp/agent-mcp-symlink        →  SSOT/mcp/agent-mcp-ssot/
```

Org-Root selbst hat **keine** `*-symlink` — er hält die `*-ssot`.

Install: `bash /opt/LauerTeam/.cursor/scripts/install-project-agent-link.sh …`

Verify: `bash /opt/LauerTeam/.cursor/scripts/cursor-ssot-verify.sh` · Cleanup: `bash /opt/LauerTeam/.cursor/scripts/cursor-global-cleanup.sh`

## Doku

`brain/index-agents.md` · `brain/adr/` (0001 Domain-Split · 0002 Nomenklatur · 0006 Soft Facts · 0007 Agent-SSOT · 0008 Dev/Staging · 0009 GHCR/SHA · 0010 GitHub-Org LauerTeam)

Git: `https://github.com/LauerTeam/LauerTeam.git` — Working-Tree `/opt/LauerTeam` (`.cursor/` + `.claude/` + README). `logs/` nicht im Git.
