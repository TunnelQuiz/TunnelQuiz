# Skill: Domain Cloudflare (lauer.team)

> DNS für `*.lauer.team` — VPS-IP, Caddy unter `/opt/_server/production/`.

## Trigger

- Neue Subdomain, DNS-Fix, Option A (`server.lauer.team`, `myui.lauer.team`, …)

## Voraussetzungen

- Cloudflare-Zugang für `lauer.team`
- VPS-IP oder Tailscale-Setup (siehe `tailnet-lauer-domains.md`)
- DNS-Scripts: `CLOUDFLARE_API_TOKEN` in `/opt/_server/production/repos/Server/.env` (nicht im Cursor-SSOT)
- Agent-MCP (Docs/Bindings/…): SSOT `/.cursor/mcp/agent-mcp-ssot/` — Runtime über Cursor-Plugin; Auth via `mcp_auth`, nicht per Datei

## Schritte

1. Cloudflare DNS: A-Record → VPS-IP (oder CNAME für Tailnet-Split-DNS)
2. Caddy-Snippet in `/opt/_server/production/repos/Server/caddy/sites.d/`
3. `docker compose restart caddy` im Server-Stack
4. Test: `curl -sI https://myui.lauer.team`

## Erfolgskriterium

HTTPS gültig, Ziel-App antwortet.

## Rollback

| Problem | Lösung |
|---------|--------|
| Falsche IP in DNS | A-Record in Cloudflare korrigieren |
| Caddy-Fehler | Snippet in `sites.d/` prüfen; `docker compose logs caddy` |
| HTTPS-Zertifikat | Caddy neu starten; Tailnet-Domains: siehe `tailnet-lauer-domains.md` |

## Verwandt

- `tailnet-lauer-domains.md` — Tailscale-spezifische DNS
- `.cursor/mcp/agent-mcp-ssot/README.md` — Cloudflare-MCP-URLs & Auth-Grenze
