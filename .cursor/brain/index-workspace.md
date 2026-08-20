# Workspace Index — TunnelQuiz / File-Hub

> Reine Karte: Wo liegt was? Wie hängt das System zusammen?
> **File-Hub** = `/opt/TunnelQuiz/.cursor/` (brain, Rules, Skills, Logs, Scripts) + `/opt/TunnelQuiz/.claude/` (Claude-Hooks).
> Diese Org ist **nicht** LauerTeam: **1 App + 1 Domain** (Gold-Standard).

---

## System in einem Satz

**TunnelQuiz:** Hamburg U/S-Bahn lernen auf der Karte. File-over-AI am Org-Root. Fakten in der **Postgres der Domain**. GUI spricht nur die App-API (ADR `brain/adr/0001-lauerteam-domain-split.md`).

```
Tools (Cursor, Claude, …)
        │ liest Org-Root .cursor/rules + .cursor/brain/
        ▼
brain/  — Maps (me, workspace, agents, skills, principles)
        │
tunnelQuizDomain data/files/ + Postgres
```

---

## Zwei VPS (Host-Rollen)

Bindend: `principles.md` §3.0.

| Host | Anbieter | Projekt-Envs | Rolle |
|------|----------|--------------|-------|
| **Dieser Cursor-/SSH-Host** | **Hetzner** | nur `development/` · `staging/` | Arbeit, Agent-SSOT, On-Demand-Stacks |
| **Separater Prod-Host** | **Netcup** | `production/` | Live 24/7 |

Kein Projekt-`production/` auf Hetzner. Deploy auf Netcup = Image pullen + `docker-compose.yml` + `.env` + `data/` (kein Source-Tree). Staging auf Hetzner ebenso Image-only; nur `development/` hat `repos/`. Staging/Prod-Images: `ghcr.io/tunnelquiz/<repo>:<git-sha>` (ADR `brain/adr/0009-ghcr-sha-images.md` · `0010-github-org-lauerteam.md`).

**Hostnamen:** Production `https://tunnelquiz.lauer.team`. Dev `https://dev.tunnelquiz.lauer.team`. Staging `https://staging.tunnelquiz.lauer.team`. Production-A-Records → Netcup private Tailscale-IP `100.92.81.26`. Hetzner nur `dev.*` / `staging.*` (ADR `brain/adr/0002-nomenklatur-ohne-myos.md`).

---

## VPS-Root `/opt/` (gleicher Baum auf beiden Hosts; Envs je Host)

```
/opt/
├── _server/production/     ← Ops-Stack (Caddy/Compose); Hetzner: Slim via docker-compose.hetzner.yml
├── _dotfiles/              ← User jjl (SSH, Git, Shell)
├── TunnelQuiz/                    ← diese Org (File-Hub + 1 App + 1 Domain)
│   ├── Apps/tunnelQuizApp/{development,staging}/   ← Hetzner (data/ = Dummy)
│   │              {production}/            ← nur Netcup
│   └── Domains/tunnelQuizDomain/…
├── LauerTeam/ · Company/ · Azubuilder/ · KiezQuiz/
├── BottleBuddy/ · TunnelQuiz/ · UniversalView/ · Volea/
└── _backups/
```

Layout: `principles.md` 7.3 · Org: `/opt/TunnelQuiz/README.md`.

---

## TunnelQuiz — ein App+Domain-Paar

ADRs: `brain/adr/0001-lauerteam-domain-split.md` · `0007-agent-ssot-org-root.md` · `0008-hetzner-dev-clone-staging-image.md` · `0009-ghcr-sha-images.md` · `0010-github-org-lauerteam.md`. Soft Facts: `brain/adr/0006-soft-facts-ownership.md` + `principles.md` §1.6.

**File-Hub-SSOT:** `/opt/TunnelQuiz/.cursor/` (+ `.claude/`). Git: `TunnelQuiz/TunnelQuiz` (Working-Tree = Org-Root, nur `.cursor/` + `.claude/` + README).

GUI spricht nur die eigene App-API; die App-API ruft die Domain-API.

| Zone | Pfad | Services | Besitz |
|------|------|----------|--------|
| Domain | `Domains/tunnelQuizDomain/` | `tunnelQuiz-domain-api` + Postgres (`tunnelquiz-domain-db`) | Fachdaten, Invarianten |
| App | `Apps/tunnelQuizApp/` | `tunnelQuiz-app-web` (GUI) + `tunnelQuiz-app-api` (BFF) | Oberfläche, Aggregation |

**Öffentlich:** `https://tunnelquiz.lauer.team`

**Wissens-Trennung:**
- Agent-übergreifend → `/opt/TunnelQuiz/.cursor/` (brain, skills, logs, scripts)
- Domain-Dateien → `tunnelQuizDomain` `data/files/` (Hetzner: Dummy; Live: Netcup)
- Projekt-spezifisch → im jeweiligen `repos/` + `.cursor/rules`

---

## Dateien (einzige Definition)

| Ort | Inhalt |
|-----|--------|
| **Org-Root** `.cursor/brain/` | Maps + Prinzipien |
| **Org-Root** `.cursor/rules|skills|hooks|mcp/` | Rules, Skills, Hooks, MCP |
| **Org-Root** `.cursor/scripts/` | Symlink-Install, Turn-Log, Verify |
| **Org-Root** `.cursor/logs/` | Turn-Logs (System schreibt) |
| **Org-Root** `.claude/hooks/` | Claude-Code-Hooks |
| **tunnelQuizDomain** `data/files/` | Domain-Dateien (Live: Netcup `production/`) |
| **tunnelQuizDomain** `data/database/` | Postgres-Volume |

---

## Projekte unter `/opt/TunnelQuiz/`

### App

| Pfad | Rolle |
|------|-------|
| `TunnelQuiz/Apps/tunnelQuizApp/` | `tunnelQuiz-app-web` + `tunnelQuiz-app-api` — `https://tunnelquiz.lauer.team` |

### Domain

| Pfad | Rolle |
|------|-------|
| `TunnelQuiz/Domains/tunnelQuizDomain/` | `tunnelQuiz-domain-api` + Postgres (intern, Docker-DNS `tunnelquiz-domain-api`) |

Eigenständigkeit und API-only: `principles.md` 1.5 · Org-README: `TunnelQuiz/README.md`.

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

- [ ] `index-workspace.md` — App/Domain/Repos aktuell?
- [ ] `index-skills.md` — Skills aktuell, Veraltetes archiviert?
- [ ] `me.md` — noch passend?
- [ ] Pfade in Skills stimmen mit `/opt/` überein?
- [ ] Redundanz-Check: keine Information doppelt (`rules/agent-global.mdc` §Meta-Regel)?
