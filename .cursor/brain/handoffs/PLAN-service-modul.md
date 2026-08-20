# Plan: Service-Modul prüfen und korrigieren

> Freigegeben 2026-08-20. SSOT: `brain/principles.md` §8.
> Referenz: Company `cProjects-api` (Domain), `cUI-api` (BFF).
> Prüfskript: `/opt/TunnelQuiz/.cursor/scripts/architecture-check.sh`

**Nicht-Ziele:** keine Features, kein Company-Umbau, kein postgres-shared, kein zweites Prinzipien-Dokument, keine GUI-Repos, kein Deploy nach Netcup in diesem Auftrag.

---

## 0. Master-Agent

Ein Master-Agent führt den Auftrag. Sub-Agenten schreiben Code; der Master entscheidet, ob das Ergebnis zählt. An Jeremiah erst bei grünen Qualitätstoren.

**Qualitätstore:** `architecture-check.sh` Exit 0 · `openapi.yaml` vorhanden · `routes/` importiert nicht `db/` · `src/` weg/leer · Dockerfile kopiert `routes/logic/db/openapi.yaml` · Entry `uvicorn routes.app:app` · Cross-Repo nur HTTP · Review unabhängig vom Migrator grün.

**HITL:** OpenAPI-Freigabe pro Welle als Paket (SwaggerUI). Commits/Pushes automatisch (`workflow.mdc`).

---

## 1. Wellen

| Welle | Inhalt |
|-------|--------|
| 0 | Prüfskript File-Hub |
| 1 | Rezept: azubuilder-domain-api → azubuilder-app-api → myUser-domain-api → myDownloads-domain-api |
| 2 | myBrain, myAgents-domain, 3× KiezQuiz-Domain |
| 3 | myProjects, myOps, myGuns-domain, myRoutines |
| 4 | App-APIs/BFFs (nach Domain) |
| 5 | myAgents-app-api (Sven) zuletzt |

21 Service-Repos. Nur `myDisplay-app-api` hatte bereits `openapi.yaml` (Stand vor Umsetzung).

---

## 2. Prüfskript

`architecture-check.sh <repo>` oder `--all` — nur `*-domain-api` / `*-app-api` unter LauerTeam, TunnelQuiz, KiezQuiz.

Prüft: openapi.yaml · routes/logic/db · Einbahnstraße · Cross-Repo · src/Legacy · Dockerfile COPY · Secrets · .gitignore.

---

## 3. Korrektur-Rezept

1. Bestehende Endpunkte → schlanke `openapi.yaml` (Company-Stil)
2. HITL-Freigabe
3. Code nach `routes/` → `logic/` → `db/` (Einbahnstraße)
4. Dockerfile/Start: `uvicorn routes.app:app`; `src/` entfernen
5. Smoke: Health + ein GET
6. Commit im Service-Repo: `refactor(api): routes/logic/db + openapi`

---

## 4. Aufwand (grob)

Welle 0 Stunden · 1: 1 Tag · 2: 2–3 Tage · 3: 3–4 Tage · 4: 2 Tage · 5: 2–3 Tage.
