# DEVLOG — File-Hub / Agent-SSOT

## 2026-10-25 – Vier Agent-Skills (Spec, Review, PR, Rückblick)

Eigene Kopie unter `skills/agent-skills-ssot/` (kein Symlink zu einer anderen Org). Angepasst: Merge bei grünen Checks (`workflow.mdc` Punkt 3, `principles.md` 5.6), Netcup nur mit ausdrücklicher Freigabe, kein fremdes Live-Skript. Pointer in `workflow.mdc`, Katalog in `index-skills.md`.

## 2026-10-21 – myDisplay: Limit pro Client-IP, Server-HEAD auf origin/master

API `2cda3e91c4d4acf8c678d7c6b5d15e202e740c3a` → `4075682ef4bda69cbabf0cd32c5194f6483600dd` (PR #2 per Fast-Forward auf master, GHCR grün). Nur `mydisplay-app-api`. Verify: 401 / 401 / 200 (Datum 2026-10-21) / 404 / 404 / 404, Tailnet 200. Rate-Limit: eine Test-IP 30×200 dann 429, andere IP 200; der eigene öffentliche Abruf bleibt 200.

Server-HEAD `04ea6c19` → `69668c3` (origin/master). Arbeitsbaum bytegleich, Caddy-adapt identisch, kein Reload. Lokaler Commit bleibt als `backup/netcup-server-04ea6c1-20261021`. Backup: `/home/jjl/.config/server-repo-backup-20261021/`.

## 2026-08-21 – Ausführung: Sub-Agenten + 100%-Done

Always-on-Rule `rules/agent-rules-ssot/execution.mdc` von LauerTeam übernommen: parallele Sub-Agenten; nach Freigabe bis Prüfung + Doku/Git. Pointer in `agent-global.mdc` und `workflow.mdc`.

> Einträge **vor 2026-08-20** stammen aus der LauerTeam-Kopie (rsync). Sie beschreiben **nicht** TunnelQuiz (kein myWidgets/myOS-Cutover dieser Org).

## 2026-08-20 – File-Hub von LauerTeam-Kopie auf TunnelQuiz umgeschrieben

ADR 0001/0002 org-spezifisch (1 App `tunnelQuizApp` + 1 Domain `tunnelQuizDomain`). GHCR `ghcr.io/tunnelquiz`, GitHub `TunnelQuiz`. Public URL `https://tunnelquiz.lauer.team`. Hetzner = development/staging, Netcup = production. Skills nicht gelöscht.

## 2026-08-19 – (LauerTeam-Kopie, nicht diese Org) Widgets live: Quota + KPI Hetzner/Netcup

Production-myWidgets auf Netcup liest KPI Hetzner von 24/7-myOps-Sammler `staging.myops.lauer.team` (Hetzner, kein Projekt-`production/`). Cursor-Token auf Netcup-myOps gesetzt. Dev/Staging bleiben aus.

## 2026-08-19 – Handoff: Plan Service-Modul-Audit

Auftrag für nächsten Agenten: nur Plan (Prüfen + Korrigieren von `routes/logic/db` + `openapi.yaml` in LauerTeam/TunnelQuiz/KiezQuiz). Datei: `brain/handoffs/2026-08-19-service-modul-audit.md`.

## 2026-08-19 – Service-Modul routes/logic/db + openapi.yaml bindend

`principles.md` §8 (Vorbild Company `index/principles.md` §6): jedes Service-Repo unter LauerTeam/TunnelQuiz/KiezQuiz hat Vertrag `openapi.yaml` und Einbahnstraße `routes → logic → db`. Pointer in `agent-global.mdc` + Commit-Check `workflow.mdc`. Bestand `src/` nicht vergrößern.

## 2026-08-19 – Hetzner: leeren Altordner `/opt/Lauer-Team` gelöscht

Nur Sven-Gerüst (0-Byte `.env`/`config.json`, leeres `data/files/`). Kein Mount, keine Nutzdaten. Live bleibt `/opt/TunnelQuiz/`. Altdaten weiter in `_backups/hetzner-production-20260805/`.

## 2026-08-19 – (LauerTeam-Kopie) GitHub-Org — für TunnelQuiz gilt `TunnelQuiz` / `ghcr.io/tunnelquiz` (ADR 0010, 2026-08-20)

Org `Lauer-Team` → `LauerTeam`; Repo `file-hub` → `LauerTeam`. GHCR: `ghcr.io/tunnelquiz/<repo>:<sha>` (kein Redirect vom alten Namespace). ADR 0010. Compose auf Hetzner-Staging und Netcup-Production nachgezogen.

## 2026-08-18 – (LauerTeam-Kopie, nicht diese Org) Netcup-Cutover Apps/Domains

Live auf Netcup: `/opt/TunnelQuiz/{Apps,Domains}/*/production/` (GHCR-SHA, image-only). myOS-Fakten per ETL in Domain-DBs; Guns/Display/Sven dump-restore. DNS/Caddy auf `myui`/`myagents`/… → `100.92.81.26`. Alter Baum: `/opt/_backups/netcup-myos-quarantine-2026-08-18/` plus `/opt/_backups/netcup-cutover-2026-08-18/`. GitHub `myOS-backend` archiviert. TunnelQuiz unter `/opt/Lauer-Team/TunnelQuiz` unangetastet.

## 2026-08-18 – GHCR-CI, File-Hub in Git, Sven nur .env

CI `.github/workflows/ghcr.yml` in allen Image-Repos. File-Hub: GitHub `Lauer-Team/file-hub`. Sven: keine `config.json`, Settings in `.env`. Offen: Netcup-Cutover.

## 2026-08-18 – File-Hub: ADR-SSOT, GHCR/SHA, Skills image-only

ADR 0001/0002/0006/0009 nach `brain/adr/` (kanonisch); `_TEMP/`-Kopien nur Stubs. Deploy-Skills ohne `git pull` auf Staging/Prod; Images `ghcr.io/lauer-team/<repo>:<git-sha>` (ADR 0009). Verworfen: lokale `lauer-*:local`. Stale `documents/_archive`-Zeiger in Hooks/Turn-Log entfernt. Offen: Netcup-Cutover, GHCR-CI in den Repos, Staging-Rauchtest.

## 2026-08-18 – Staging image-only + config.json unter data/

`config.json` → `data/config.json` (Sven). Jedes Staging hat `docker-compose.yml` (Image, kein Source). Generator: `scripts/gen-staging-compose.py`. On-Demand, nicht parallel zu development.

## 2026-08-18 – Staging ohne Source-Tree

Sven läuft image-only aus `Apps/myAgentsApp/staging/` (`docker-compose.yml` + `.env` + `config.json` + `data/`). Alle `staging/repos/` entfernt (uncommitted Pi-Scripts + ein Screenshot nach `_TEMP`). temp-ui `origin` → GitHub. `config.json` bleibt Sven-Ausnahme, Ziel `.env`.

## 2026-08-18 – Hetzner-Daten leer, Schema Dev≠Staging

Postgres-Cluster (uid 999) nach `_TEMP/…/data/database`; laufende Container auf leere Stubs neu gemountet. Dummy-`.gitkeep` weg. myDisplay-Dev-URL `dev.mydisplay.lauer.team`; `MC_BASE_URL` → `myui.lauer.team`; Mail in myAgents `config.json` Dummy, SMTP-Env leer. Vite-Compose ins GUI-Repo; Env-`.cursor` nur myDisplay entfernt. Prinzipien 3.3/7.3 + ADR `0008`.

Offen: `_TEMP` → Netcup; Staging-`repos/` noch vorhanden (Sven läuft von `myAgentsApp/staging/repos`).

## 2026-08-18 – Schema-Müll entfernt

Gelöscht: `.DS_Store`/`._*`, `.staging-scaffold`, leere `data/files/{cache,runtime}`, Domain-Root-READMEs, doppelte `repos/*/.env`. Cursor-Plan myGuns → `_TEMP/Apps/myGunsApp/.cursor/plans/`. Prinzipien 7.3: optionales Env-Compose für Vite-Bind-Mount. File-Hub-Hinweis in myAgents-domain-api README korrigiert.

Offen: `_TEMP` → Netcup; `data/database/` mode 700 (docker/nobody) unlesbar, nicht verschoben.

## 2026-08-18 – Nutzdaten nach `_TEMP`, Agent-SSOT an Org-Root

Prod-ähnliche `data/files/` aus Hetzner development/staging nach `/opt/TunnelQuiz/_TEMP/` (Projektbaum erhalten). File-Hub von myAgentsDomain nach `/opt/TunnelQuiz/.cursor/` + `.claude/`. Dummy-`.gitkeep` an den alten Mount-Punkten. ADR: `brain/adr/0007-agent-ssot-org-root.md`.

Offen: `_TEMP` nach Netcup `production/` spiegeln; development-Postgres (docker/nobody, ~47 MB typische initdb) nur prüfen wenn Stacks echte Rows enthalten.
