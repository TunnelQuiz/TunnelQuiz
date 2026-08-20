# TunnelQuiz — Organisation

Hamburg U/S-Bahn lernen auf der Karte.

## Layout

```
/opt/TunnelQuiz/
├── Apps/
│   └── tunnelQuizApp/     ← tunnelQuiz-app-web + tunnelQuiz-app-api (BFF)
└── Domains/
    └── tunnelQuizDomain/  ← tunnelQuiz-domain-api + Postgres
```

## Regel

| Zone | Inhalt |
|------|--------|
| **Domains/** | Daten + Domain-API. Kein GUI. |
| **Apps/** | GUI + App-API (BFF). GUI spricht nur die eigene App-API. |

Kommunikation: **GUI → App-API → Domain-API**.

## Hosting

| Host | Environments |
|------|----------------|
| **Hetzner** | `development/` · `staging/` |
| **Netcup** | `production/` — Live (noch nicht angelegt) |

## URLs (vorgesehen)

| URL | Environment |
|-----|-------------|
| `tunnelquiz.lauer.team` | Production |
| `dev.tunnelquiz.lauer.team` | Development |
| `staging.tunnelquiz.lauer.team` | Staging |

## GitHub

| Repo | Inhalt |
|------|--------|
| `TunnelQuiz/tunnelQuiz-domain-api` | FastAPI + Postgres |
| `TunnelQuiz/tunnelQuiz-app-api` | BFF-Proxy |
| `TunnelQuiz/tunnelQuiz-app-web` | GUI |
| `TunnelQuiz/TunnelQuiz` | File-Hub (Org-Root) |

Images: `ghcr.io/tunnelquiz/<repo>:<git-sha>`. Staging/Prod: image-only.
