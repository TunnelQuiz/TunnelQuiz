# ADR 0002 — Nomenklatur ohne myOS, ohne Alias

**Status:** angenommen  
**Datum:** 2026-08-18  
**SSOT:** diese Datei (`/opt/TunnelQuiz/.cursor/brain/adr/0002-nomenklatur-ohne-myos.md`)

## Kontext

Nach ADR 0001 lebten Aliase (`sven-api`, `gunsdb-api`, `myos-web`), öffentliche Hostnamen (`myos.lauer.team`) und Env-Präfixe (`GUNSDB_*`). Soll: `principles.md` §7.4 überall. Der **Netcup-Cutover übernimmt dieselben Hostnamen** — kein Dauer-Zustand „Hetzner neu, Production alt“.

## Entscheidung

1. **Öffentliche Hostnamen (beide VPS, Tailnet):** `https://<kurz>.lauer.team` mit Kurz = Kleinbuchstaben des Produktstamms.

   | Alt | Soll |
   |---|---|
   | myos.lauer.team | myui.lauer.team |
   | sven.lauer.team | myagents.lauer.team |
   | widgets.lauer.team | mywidgets.lauer.team |
   | display.lauer.team | mydisplay.lauer.team |
   | gunsdb.lauer.team | entfällt (Domain-API nur Docker-DNS) |
   | downloads.lauer.team | mydownloads.lauer.team |
   | myguns.lauer.team | bleibt |
   | tempui.lauer.team | bleibt (Sandbox) |

   Dev: `dev.<kurz>.lauer.team`. Staging: `staging.<kurz>.lauer.team` wo nötig.

   **Cutover:** Hetzner und Netcup nutzen dieselben Production-Namen. Production-A-Records → Netcup `100.92.81.26`. Hetzner nur `dev.*` / `staging.*`. Keine parallelen Aliase.

2. **Docker-DNS und Compose-Services** heißen wie das Repo (`myui-app-api`, `myguns-domain-api`, …). Keine Aliase.

3. **Env-Präfixe** = Produkt, App vs. Domain getrennt: `MYUI_`, `MYGUNS_DOMAIN_`, `MYGUNS_APP_`, `MYDISPLAY_`, `MYDOWNLOADS_`, `MYAGENTS_APP_`, `MYAGENTS_DOMAIN_`, `MYWIDGETS_`, `MYPROJECTS_`, `MYBRAIN_`, `MYUSER_`, `MYOPS_`, `MYROUTINES_`. Telegram-Adapter-Secrets bleiben `TELEGRAM_*`.

4. **myGuns-app-api** ist BFF. GUI spricht nur diese App-API; Katalog per HTTP von myGuns-domain-api.

5. **myDownloads vollständig:** Domain besitzt `data/files/`; App = `myDownloads-app-web` + `myDownloads-app-api`.

6. **Caddy Hetzner** (`sites.d/private/`): `myui` · `myagents` · `mywidgets` · `mydisplay` · `mydownloads` · `myguns` · `tempui`. Alte Dateinamen (`myos.caddy`, `sven.caddy`, …) auf Hetzner weg.

## Verworfen

| Alternative | Warum nicht |
|---|---|
| Aliase neben neuen Namen | zweite Wahrheit |
| Domain-APIs öffentlich | GUI → App-API → Domain |
| Production dauerhaft bei alten Namen | zwei Systeme, Cutover nie fertig |
| Prod-DNS myos→Hetzner vor Netcup-Cutover | würde Live umbiegen |

## Folgen

- Scriptable-URLs: `mywidgets.lauer.team`.
- Netcup-Caddy/DNS-Liste = Hetzner-Liste, sobald Production umgestellt ist.
