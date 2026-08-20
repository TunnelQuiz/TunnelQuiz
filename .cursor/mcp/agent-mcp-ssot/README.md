# MCP SSOT (Agent)

Symlink-Ziel für `.cursor/mcp/agent-mcp-symlink` in LauerTeam-Projekten.

**Keine Secrets hier** — weder Cursor-OAuth noch `CLOUDFLARE_API_TOKEN`.

| Datei | Inhalt |
|-------|--------|
| `cloudflare.cursor.mcp.json` | Kanonische Cloudflare-MCP-URLs (HTTP, ohne Auth-Header) |

## Runtime vs. SSOT

| Schicht | Ort | Rolle |
|---------|-----|--------|
| **Runtime (primär)** | Cursor-Plugin `cloudflare` | Liefert die vier MCP-Server systemweit |
| **SSOT (diese Dateien)** | `agent-mcp-ssot/` | Quelle der Wahrheit für URLs + Doku |
| **OAuth** | Cursor intern (`mcp_auth`) | Bindings / Builds / Observability — nicht dateibasiert |
| **DNS-API-Token** | `/opt/_server/production/repos/Server/.env` | `CLOUDFLARE_API_TOKEN` für Shell-Scripts |

Docs-MCP braucht keine Auth. Die anderen drei: in Cursor `mcp_auth` für den jeweiligen Server auslösen.

## Optional: Projekt-`mcp.json` aktivieren

Nur wenn das Cloudflare-Plugin **aus** ist — sonst doppelte Server:

```bash
ln -sfn \
  /opt/TunnelQuiz/.cursor/mcp/agent-mcp-ssot/cloudflare.cursor.mcp.json \
  /pfad/zum/projekt/.cursor/mcp.json
```

Nach Symlink-Änderung: `rm` + neu `ln -s`, dann MCP neu laden (Watcher hängt oft an Symlink-mtime).

## Verwandt

- Skill: `skills/agent-skills-ssot/domain-cloudflare.md` — DNS für `*.lauer.team`
- Plugin-Spiegel (Cache): `~/.cursor/plugins/cache/cursor-public/cloudflare/`
- Company-Pendant (mit Bearer): `cAgents/.../cAgent-mcp-ssot/` — anderes Modell, nicht kopieren
