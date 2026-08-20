# Agents Index — Symlink- & SSOT-Mechanik

SSOT (Hetzner): `/opt/TunnelQuiz/.cursor/`
Claude-Hooks: `/opt/TunnelQuiz/.claude/`
> Production-Live: Netcup `…/production/` — siehe `principles.md` §3.0.
> Gilt für **KI-Agenten in TunnelQuiz-Projekten**.
> **Andere Orgs** haben eigene File-Hubs — keine Cross-Org-Symlinks.

## Namenskonvention

| Suffix     | Bedeutung                                             |
| ---------- | ----------------------------------------------------- |
| `-symlink` | Symlink im Projekt (Pointer — nicht direkt editieren) |
| `-ssot`    | Echter Inhalt im Org-Root `.cursor/` / `.claude/`     |

## Projekt-Symlinks

```
Projekt/.cursor/
├── rules/agent-rules-symlink    →  /opt/TunnelQuiz/.cursor/rules/agent-rules-ssot/
├── skills/agent-skills-symlink  →  /opt/TunnelQuiz/.cursor/skills/agent-skills-ssot/
├── hooks/agent-hooks-symlink    →  /opt/TunnelQuiz/.cursor/hooks/agent-hooks-ssot/
└── mcp/agent-mcp-symlink        →  /opt/TunnelQuiz/.cursor/mcp/agent-mcp-ssot/
```

Install:

```bash
bash /opt/TunnelQuiz/.cursor/scripts/install-all-agent-links.sh
```

## GitHub

**Regel:** GitHub-Org folgt dem VPS-Pfad.

| VPS-Pfad-Präfix | GitHub-Org |
| --------------- | ---------- |
| `/opt/TunnelQuiz/…` | `TunnelQuiz` |

| Regel | Wert |
| ----- | ---- |
| Org | `TunnelQuiz` |
| Remote | `https://github.com/TunnelQuiz/<repo>.git` |
| Org-Root-Repo | `https://github.com/TunnelQuiz/TunnelQuiz.git` |
| Images | `ghcr.io/tunnelquiz/<repo>:<git-sha>` |
