# ADR 0002 — Nomenklatur ohne Alias

> Nützliche Regeln aus der LauerTeam-Kopie; myOS/myUI-Listen entfernt. Gilt nur für TunnelQuiz.

**Status:** angenommen  
**Datum:** 2026-08-20  
**SSOT:** diese Datei (`/opt/TunnelQuiz/.cursor/brain/adr/0002-nomenklatur-ohne-myos.md`)

## Kontext

Soll: `principles.md` §7.4 überall. Ein Produktstamm, keine Aliase. Production und Dev/Staging teilen denselben Kurznamen, unterschiedliche Prefixe. TunnelQuiz hat **keine** myOS/myUI-Hostnamen.

## Entscheidung

1. **Öffentliche Hostnamen (beide VPS, Tailnet):** `https://tunnelquiz.lauer.team`

   | Environment | URL |
   |---|---|
   | Production (Netcup) | `https://tunnelquiz.lauer.team` |
   | Development (Hetzner) | `https://dev.tunnelquiz.lauer.team` |
   | Staging (Hetzner) | `https://staging.tunnelquiz.lauer.team` |

   Production-A-Records → Netcup `100.92.81.26`. Hetzner nur `dev.*` / `staging.*`. Keine parallelen Aliase. Domain-API ist **nicht** öffentlich (nur Docker-DNS).

2. **Docker-DNS und Compose-Services** heißen wie das Produkt in Kleinbuchstaben. Keine Aliase (`sven-api`, `lauer-*` als Dauername, …).

   | Rolle | Compose-Service | GitHub-Repo |
   |---|---|---|
   | GUI (Dev-Vite) | `tunnelquiz-app-dev` | `tunnelQuiz-app-web` |
   | App-API (BFF) | `tunnelquiz-app-api` | `tunnelQuiz-app-api` |
   | Domain-API | `tunnelquiz-domain-api` | `tunnelQuiz-domain-api` |
   | Postgres | `tunnelquiz-domain-db` | — |

3. **Env-Präfixe** = Produkt, App vs. Domain getrennt: `TUNNELQUIZ_APP_`, `TUNNELQUIZ_DOMAIN_`, `TUNNELQUIZ_DB_`.

4. **`tunnelQuiz-app-api` ist BFF.** GUI spricht nur diese App-API; Fachdaten per HTTP von `tunnelQuiz-domain-api`.

5. **Domain besitzt** `data/files/` + Postgres. App = `tunnelQuiz-app-web` + `tunnelQuiz-app-api`.

6. **Caddy:** Site `tunnelquiz` (prod) · `dev.tunnelquiz` · `staging.tunnelquiz`.

## Verworfen

| Alternative | Warum nicht |
|---|---|
| Aliase neben dem Produktnamen | zweite Wahrheit |
| Domain-API öffentlich | GUI → App-API → Domain |
| Production-Namen abweichend von Dev | zwei Systeme |
| myUI/myOS-Hostnamen aus der LauerTeam-Kopie | gehören nicht zu TunnelQuiz |

## Folgen

- Ein öffentlicher Hostname-Stamm: `tunnelquiz.lauer.team`.
- Netcup-Caddy/DNS-Liste = Hetzner-Liste (prod vs. `dev.`/`staging.`-Prefix).
