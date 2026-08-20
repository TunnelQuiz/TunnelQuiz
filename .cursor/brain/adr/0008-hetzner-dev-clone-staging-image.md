# ADR 0008 — Hetzner: development = Klone, staging = Image

## Kontext

`principles.md` §3.0 legt Arbeit auf Hetzner (`development/` + `staging/`) und Live auf Netcup (`production/`). Staging auf diesem Host soll Image-only sein, kein zweiter Git-Klon. Gilt für TunnelQuiz (`Apps/tunnelQuizApp/` + `Domains/tunnelQuizDomain/`) wie für jede andere Org.

## Entscheidung

| Environment | Host | Inhalt |
|---|---|---|
| `development/` | Hetzner | `repos/` + `.env` + Dummy-`data/` |
| `staging/` | Hetzner | `docker-compose.yml` + `.env` + Dummy-`data/` — Image pullen, **kein** Source-Tree; On-Demand, nicht parallel zu development |
| `production/` | Netcup | dasselbe Schema wie Staging, Live-`data/` |

Vite-Dev-Server: `docker-compose.dev.yml` im GUI-Repo, nicht auf der Env-Ebene.

## Begründung

Staging ist das Probe-Image vor Production, nicht eine zweite Klon-Umgebung. Unterschied zu Development ist der Code-Pfad (Klon vs. Image), nicht der Host.

## Verworfene Alternativen

- Staging ebenfalls mit `repos/` (wie Development)
- Staging nach Netcup legen
- Env-Ebene-Compose für Vite-Bind-Mount

Verwandt: ADR `0001-lauerteam-domain-split.md` · Images: ADR `0009-ghcr-sha-images.md`.
