# Skills Index — Agent-SSOT (projektübergreifend)

> Leichte Skills = `.md` in `skills/agent-skills-ssot/` · Paket = Ordner mit `SKILL.md`.
> SSOT: `/opt/TunnelQuiz/.cursor/skills/agent-skills-ssot/`

## Was ist ein Skill?

Wissen für die AI: *„Wenn ich X sage, mach es so."* Portabel — File over AI.

| Typ | Form | Zugriff |
|-----|------|---------|
| **Leicht** | eine `.md` | Rules + dieser Index |
| **Paket** | Ordner + `SKILL.md` | `.cursor/skills/agent-skills-symlink/` |

Neu anlegen: `skills/agent-skills-ssot/create-skill.md`

---

## Skills (aktiv)

| Skill | Datei | Wann nutzen |
|-------|-------|-------------|
| PostgreSQL-Backup | `backup-postgres.md` | DB-Backup, Restore |
| **VPS-Backup-System** | `backup-system.md` | Restic, Cron, /opt/ — Doku: `_server/.../docs/BACKUP.md` |
| **VPS deployen** | `vps-deploy.md` | Dev: build im Repo · Staging/Prod: GHCR-Pull, SHA-Tag |
| **GHCR publishen** | `ghcr-publish.md` | Image nach GHCR, SHA-Tag, CI-Vorlage, Netcup-Pull |
| Post-Reboot-Check | `post-reboot-check.md` | Nach VPS-Neustart |
| SSH hinter Tailscale | `ssh-tailscale-lock.md` | UFW / Port 22 |
| Tailnet-URLs | `tailnet-lauer-domains.md` | DNS → Tailscale + Caddy |
| Tailscale Auth-Key | `tailscale-authkey.md` | VPS/Pi Dauer-Anmeldung |
| Domain Cloudflare | `domain-cloudflare.md` | `*.lauer.team` DNS |
| Cockpit @ Web & Todos | `cockpit-todos.md` | API, Routinen, Web-UI |
| Hermetische Knoten | `mc-hermetic-nodes.md` | `.py` in `routinen/` |
| Sven Agent Setup | `sven-agent-setup.md` | Bot Sven Compose (kein systemd-Default) |
| VPS-Anbieter wechseln | `vps-provider-migration.md` | Server-Umzug |
| **Projekt Agent anbinden** | `bootstrap-project-agent.md` | Symlinks installieren |
| **Neuen Skill anlegen** | `create-skill.md` | Leicht oder Paket |
| SSL / HTTPS (Caddy) | `ssl-troubleshooting-caddy.md` | Zertifikat, ACME, 502 |
| Incident Response | `incident-response.md` | Production down, Notfall |

## Paket-Skills

| Skill | Ort |
|-------|-----|
| **UI/UX Pro Max** | `ui-ux-pro-max/SKILL.md` |
| **Obsidian** (offiziell, kepano) | Quelle: [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) |
| ↳ `obsidian-markdown` | `obsidian-markdown/SKILL.md` — OFM, Wikilinks, Callouts, Properties |
| ↳ `obsidian-bases` | `obsidian-bases/SKILL.md` — `.base`-Dateien |
| ↳ `json-canvas` | `json-canvas/SKILL.md` — `.canvas`-Dateien |
| ↳ `obsidian-cli` | `obsidian-cli/SKILL.md` — Vault-Ops per CLI |
| ↳ `defuddle` | `defuddle/SKILL.md` — Web → sauberes Markdown |
| **shadcn/ui** (offiziell) | Quelle: [shadcn-ui/ui](https://github.com/shadcn-ui/ui/tree/main/skills/shadcn) |
| ↳ `shadcn` | `shadcn/SKILL.md` — Komponenten, CLI, Theming, Registry, MCP |
| **frontend-design** (Anthropic) | Quelle: [anthropics/claude-code](https://github.com/anthropics/claude-code) |
| ↳ `frontend-design` | `frontend-design/SKILL.md` — Distinctive UI, Typografie, Motion, Anti-AI-Slop |
| **stop-slop** (Hardik Pandya) | Quelle: [hardikpandya/stop-slop](https://github.com/hardikpandya/stop-slop) |
| ↳ `stop-slop` | `stop-slop/SKILL.md` — AI-Tells aus Prosa entfernen, Schreib-Review |

---

## Archiviert / entfernt

| Skill | Grund |
|-------|-------|
| n8n deployen | n8n abgeschaltet — Cockpit @ Web |
| projects-sync / docs-sync | Mac↔VPS-Sync entfällt — siehe `vps-deploy.md` |
| Mac-Cursor-Start | Mac kein Systembestandteil mehr |
| `mission-control.md` | umbenannt → `cockpit-todos.md` |
| `jackal-obsidian-cli` | ersetzt durch kepano/obsidian-skills |
| `bootstrap-project-myos.md` | umbenannt → `bootstrap-project-agent.md` |

Veraltete Dateien nach `skills/agent-skills-ssot/_archive/`.

---

## Pflege

Alle 2–4 Wochen: Pfade `/opt/…` prüfen, Index aktuell, `index-workspace.md` stimmig.
