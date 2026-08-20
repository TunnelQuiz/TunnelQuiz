# Workspace Index — LauerTeam / File-Hub

> Reine Karte: Wo liegt was? Wie hängt das System zusammen?
> **File-Hub** = `/opt/TunnelQuiz/.cursor/` (brain, Rules, Skills, Logs, Scripts) + `/opt/TunnelQuiz/.claude/` (Claude-Hooks).

---

## System in einem Satz

**File-over-AI:** Identität, Navigation und Prozesse in Markdown. Jedes KI-Tool liest dieselben Maps. Strukturierte Fakten leben in der **Postgres der jeweiligen Domain** — nicht in duplizierten md-Indizes. God-Domain abgelöst (ADR `brain/adr/0001-lauerteam-domain-split.md`).

```
Tools (Cursor, Claude, Sven, …)
        │ liest Org-Root .cursor/rules + .cursor/brain/
        ▼
brain/  — Maps (me, workspace, agents, skills, principles)
        │
Domain-Dateien — documents (myBrain) · todos (myProjects) · routinen (myRoutines)
        │
Postgres je Domain — Todos, Routinen, Register, Telemetrie
```

---

## Zwei VPS (Host-Rollen)

Bindend: `principles.md` §3.0.

| Host | Anbieter | Projekt-Envs | Rolle |
|------|----------|--------------|-------|
| **Dieser Cursor-/SSH-Host** | **Hetzner** | nur `development/` · `staging/` | Arbeit, Agent-SSOT, On-Demand-Stacks |
| **Separater Prod-Host** | **Netcup** | `production/` | Live 24/7 |

Kein Projekt-`production/` auf Hetzner. Deploy auf Netcup = Image pullen + `docker-compose.yml` + `.env` + `data/` (kein Source-Tree). Staging auf Hetzner ebenso Image-only; nur `development/` hat `repos/`. Staging/Prod-Images: `ghcr.io/tunnelquiz/<repo>:<git-sha>` (ADR `brain/adr/0009-ghcr-sha-images.md` · `0010-github-org-lauerteam.md`).

**Hostnamen-Cutover:** beide VPS nutzen `myui` / `myagents` / `mywidgets` / `mydisplay` / `mydownloads.lauer.team` (ADR `brain/adr/0002-nomenklatur-ohne-myos.md`). Production-A-Records → Netcup private Tailscale-IP `100.92.81.26`. Hetzner nur `dev.*` / `staging.*`.

---

## VPS-Root `/opt/` (gleicher Baum auf beiden Hosts; Envs je Host)

```
/opt/
├── _server/production/     ← Ops-Stack (Caddy/Compose); Hetzner: Slim via docker-compose.hetzner.yml
├── _dotfiles/              ← User jjl (SSH, Git, Shell)
├── Company/                ← Domains/ + Apps/ (siehe Company/README.md)
├── LauerTeam/              ← Org-Root (.cursor/ File-Hub, .obsidian/ — Vault)
│   ├── _TEMP/              ← leer (README); Cutover-Kopien entfernt 2026-08-18
│   ├── Apps/<App>/{development,staging}/     ← Hetzner (data/files = Dummy)
│   │                 {production}/           ← nur Netcup
│   └── Domains/<Domain>/…
├── KiezQuiz/<Projekt>/…
├── TunnelQuiz/
└── _backups/
```

Layout: `principles.md` 7.3 · Org: `/opt/TunnelQuiz/README.md`.

**`_TEMP`:** nach Cutover geleert (nur README). Live-Dateien: Netcup `production/data/files/`. Langzeit: Restic + `/opt/_backups/netcup-cutover-2026-08-18/`.

---

## LauerTeam — Ziel-Schnitt (kein God-Domain)

ADRs: `brain/adr/0001-lauerteam-domain-split.md` · `0007-agent-ssot-org-root.md` · `0008-hetzner-dev-clone-staging-image.md` · `0009-ghcr-sha-images.md` · `0010-github-org-lauerteam.md`. Soft Facts: `brain/adr/0006-soft-facts-ownership.md` + `principles.md` §1.6.

**File-Hub-SSOT:** `/opt/TunnelQuiz/.cursor/` (+ `.claude/`). Git: `LauerTeam/LauerTeam` (Working-Tree = Org-Root, nur diese Pfade).

GUI spricht nur die eigene App-API; erst die App-API ruft Domain- oder andere App-APIs.

| Domain | API | Besitz |
|--------|-----|--------|
| myProjectsDomain | myProjects-domain-api | Todos, Projekt-Register |
| myAgentsDomain | myAgents-domain-api | Agent-Rechte, Runtime-API (kein File-Hub) |
| myBrainDomain | myBrain-domain-api | Dokumente / Wissen |
| myUserDomain | myUser-domain-api | Identität, app-übergreifende Prefs |
| myOpsDomain | myOps-domain-api | KPI, Quota, Health-Snapshots |
| myRoutinesDomain | myRoutines-domain-api | Ablauf-Graphen, Läufe |
| myGunsDomain | myGuns-domain-api | Waffenwissen |
| myDownloadsDomain | myDownloads-domain-api | Binärdateien (Downloads) |

| App | GUI | App-API |
|-----|-----|---------|
| myUIApp | ja (Cockpit, `myUI-app-web`) | myUI-app-api |
| myAgentsApp | nein | myAgents-app-api (Sven) |
| myGunsApp | ja (`myGuns-app-web`) | myGuns-app-api |
| myDisplayApp | ja (`myDisplay-app-web` / `-pi`) | myDisplay-app-api |
| myWidgetsApp | nein (`-scriptables`) | myWidgets-app-api |
| myDownloadsApp | ja (`myDownloads-app-web`) | myDownloads-app-api |

**Wissens-Trennung:**
- Agent-übergreifend → `/opt/TunnelQuiz/.cursor/` (brain, skills, logs, scripts)
- Dokumente → myBrainDomain `data/files/documents/` (Hetzner: Dummy; Live: Netcup)
- Todo-Notizen → myProjectsDomain `data/files/todos/` (Hetzner: Dummy; Live: Netcup)
- Routinen-Knoten → myRoutinesDomain `data/files/routinen/` (Hetzner: Dummy; Live: Netcup)
- Projekt-spezifisch → im jeweiligen `repos/` + `.cursor/rules`

---

## Dateien je Domain (einzige Definition)

| Ort | Inhalt |
|-----|--------|
| **Org-Root** `.cursor/brain/` | Maps + Prinzipien |
| **Org-Root** `.cursor/rules|skills|hooks|mcp/` | Rules, Skills, Hooks, MCP |
| **Org-Root** `.cursor/scripts/` | Symlink-Install, Turn-Log, Verify |
| **Org-Root** `.cursor/logs/` | Turn-Logs (System schreibt) |
| **Org-Root** `.claude/hooks/` | Claude-Code-Hooks |
| **myBrainDomain** `data/files/documents/` | Passives Wissen (Live: Netcup `production/`) |
| **myProjectsDomain** `data/files/todos/` | Zusatzinfos zu Postgres-Todos (`detail_path`) |
| **myRoutinesDomain** `data/files/routinen/` | Hermetische `.py`-Knoten |

**Entfernt:** `uploads/`, `atlas/` als Dateiordner (Inhalt → `documents/`); `system/` (→ `documents/`).

**Nicht verwechseln:** MC-Tab „Atlas" (UI/JSON) ≠ Dateiordner.

---

## Projekte unter `/opt/` (Stand 2026-08-18)

### LauerTeam — Apps

| Pfad | Rolle |
|------|-------|
| `LauerTeam/Apps/myUIApp/` | myUI-app-web + myUI-app-api — `https://myui.lauer.team` |
| `LauerTeam/Apps/myAgentsApp/` | myAgents-app-api (kein GUI), Telegram, Agent-Runner — `https://myagents.lauer.team` |
| `LauerTeam/Apps/myGunsApp/` | myGuns-app-web + myGuns-app-api — `https://myguns.lauer.team` |
| `LauerTeam/Apps/myDisplayApp/` | Pi-Dashboard — `https://mydisplay.lauer.team` |
| `LauerTeam/Apps/myWidgetsApp/` | Scriptable-Vorlagen + App-API · `https://mywidgets.lauer.team` |
| `LauerTeam/Apps/myDownloadsApp/` | myDownloads-app-web + myDownloads-app-api — `https://mydownloads.lauer.team` |
| `LauerTeam/Apps/tempui/` | UI-Sandbox — `https://tempui.lauer.team` |

### LauerTeam — Domains

| Pfad | Rolle |
|------|-------|
| `LauerTeam/Domains/myProjectsDomain/` | Todos, Projekt-Register |
| `LauerTeam/Domains/myAgentsDomain/` | Agent-Rechte, Runtime-API |
| `LauerTeam/Domains/myBrainDomain/` | Dokumente / Wissen |
| `LauerTeam/Domains/myUserDomain/` | Identität, app-übergreifende Prefs |
| `LauerTeam/Domains/myOpsDomain/` | KPI, Quota, Health |
| `LauerTeam/Domains/myRoutinesDomain/` | Ablauf-Graphen |
| `LauerTeam/Domains/myGunsDomain/` | myGuns-domain-api (intern, Docker-DNS) |
| `LauerTeam/Domains/myDownloadsDomain/` | Binärdateien (Downloads) |

### Weitere Orgs

| Pfad | Rolle |
|------|-------|
| `_server/production/` | Caddy, Plattform |
| `TunnelQuiz/` | Lern-App Bauzeichner-Azubis — `https://azubuilder.de` (Apps/ + Domains/) |
| `KiezQuiz/Apps/` | Spieler-SPA + BFF, Kalle-Bot/Ops |
| `KiezQuiz/Domains/` | User, Game, Ops, Assets (Brand Guidelines `https://kiezquizdesign.lauer.team`) |
| `Company/Apps/*` · `Company/Domains/*` | siehe `Company/README.md` |

Eigenständigkeit und API-only: `principles.md` 1.5 · Org-README: `LauerTeam/README.md`.

---

## Entwicklungsumgebung

**Standard:** Remote-SSH auf **Hetzner** (`cursor-hetzner`) — Workspace `/opt/…` = `development`/`staging`. Production = **Netcup** (separat; → §Zwei VPS, `principles.md` 3.0). Deploy-Tor: `principles.md` 3.3.

| Erkennung | Bedeutung |
|-----------|-----------|
| Linux + `/opt/…` + nur `development`/`staging` unter Projekten | **Hetzner** — Arbeit |
| Netcup-Host + `production/` unter Projekten | **Production** — Live |
| macOS + `/Users/…` | **Optional** — Cursor-Client per SSH; kein Datenort |

**Kein automatischer Sync** Mac↔Hetzner↔Netcup. Commit/Push = Git-Backup; Prod-Deploy = GHCR-Image-Pull auf Netcup.

**Merksatz:** Arbeit auf Hetzner. Production auf Netcup. Mac ist Werkzeug.

---

## Pflege (alle 2–4 Wochen)

- [ ] `index-workspace.md` — neue Projekte/Ordner?
- [ ] `index-skills.md` — Skills aktuell, Veraltetes archiviert?
- [ ] `me.md` — noch passend?
- [ ] Pfade in Skills stimmen mit `/opt/` überein?
- [ ] Redundanz-Check: keine Information doppelt (`rules/agent-global.mdc` §Meta-Regel)?
