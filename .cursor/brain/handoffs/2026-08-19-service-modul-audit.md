# Handoff: Plan — Service-Modul prüfen & korrigieren

> **Auftrag an einen neuen Agenten.** Nur **planen**, nicht umbauen — bis Jeremiah den Plan freigibt.
> Stand: 2026-08-19 · File-Hub `e9d69d0` · SSOT: `brain/principles.md` **§8**.

---

## 1. Auftrag

Schreibe einen **konkreten Plan**, wie `routes/logic/db` + `openapi.yaml` in **allen** Service-Repos unter LauerTeam, TunnelQuiz und KiezQuiz **geprüft** und **gegebenenfalls korrigiert** werden.

Kein Code-Refactor in diesem Auftrag. Deliverable = Plan (Datei), den Jeremiah abnimmt.

---

## 2. Bindende Regel (nicht neu erfinden)

| Lesen | Warum |
|-------|--------|
| `/opt/TunnelQuiz/.cursor/brain/principles.md` **§8** | SSOT, gewinnt bei Widerspruch |
| Company `index/principles.md` §6 + `index/architektur.md` TEIL 2–3 + 7 | Vorbild (bereits umgesetzt) |
| `/opt/Company/Domains/cAgents/development/repos/cAgents-api/scripts/architecture-check.sh` | Prüfskript-Vorlage |
| `rules/praeferenzen.mdc` · `workflow.mdc` | Antwortformat, Git |

**Kurz:** Service = Vertrag zuerst (`openapi.yaml`, User-Freigabe) + Einbahnstraße `routes → logic → db`. Clients (GUI) haben beides **nicht**.

---

## 3. Scope

| In | Out |
|----|-----|
| `*-domain-api` und `*-app-api` unter `/opt/TunnelQuiz/`, `/opt/TunnelQuiz/`, `/opt/KiezQuiz/` | `*-app-web`, iOS, Scriptable, Pi-GUI, nginx-Brand (`kiezQuizAssetsDomain`) |
| Neuer Check (Skript) + Korrektur-Reihenfolge | Company (ist schon konform) |
| Bestand `src/` überführen, nicht vergrößern | Feature-Arbeit, Deploy nach Netcup ohne Plan-Freigabe |

Hetzner = Arbeit (`development/repos/`). Staging/Prod = Images — Korrektur nur im Git-Repo, dann CI/GHCR.

---

## 4. Ist-Stand 2026-08-19 (Startpunkt, bitte verifizieren)

Spalten: `openapi.yaml` · `routes/` · `logic/` · `db/` · `src/` (oder anderes Innenleben).

| Repo | oa | r | l | db | src/alt |
|------|----|---|---|----|---------|
| myProjects-domain-api | n | n | n | n | `src/` |
| myAgents-domain-api | n | n | n | n | `src/` |
| myBrain-domain-api | n | n | n | n | `src/` |
| myUser-domain-api | n | n | n | n | `src/` |
| myOps-domain-api | n | n | n | n | `src/` |
| myRoutines-domain-api | n | n | n | n | `src/` |
| myGuns-domain-api | n | n | n | n | `src/` |
| myDownloads-domain-api | n | n | n | n | `src/` |
| myUI-app-api | n | n | n | n | `src/` |
| myGuns-app-api | n | n | n | n | `src/` |
| myDisplay-app-api | **Y** | n | n | n | `src/` |
| myWidgets-app-api | n | n | n | n | `src/` |
| myDownloads-app-api | n | n | n | n | `src/` |
| myAgents-app-api (Sven) | n | n | n | n | `myagents_api/` + `myagents_lib/` + `adapters/` — Sonderfall |
| azubuilder-domain-api | n | n | n | n | `src/` |
| azubuilder-app-api | n | n | n | n | `src/` |
| kiezQuiz-user-domain-api | n | n | n | n | `src/` |
| kiezQuiz-game-domain-api | n | n | n | n | `src/` |
| kiezQuizOps-domain-api | n | n | n | n | `src/` |
| kiezQuiz-app-api | n | n | n | n | `src/` |
| kiezQuizOps-app-api | n | n | n | n | `src/` |

**Fazit Startpunkt:** fast alle Services verletzen §8. Company-Services (`c*-api`, `cUI-api`) sind die Referenz-Implementierung.

---

## 5. Was der Plan enthalten muss

1. **Prüfmethode** — ein Skript (Vorbild `architecture-check.sh`), das für jedes Service-Repo meldet: fehlt Vertrag? fehlt `routes/logic/db`? `routes/` importiert `db/`? Cross-Repo-Import? `src/` noch da?
2. **Inventur** — Tabelle aller Repos mit Ampel; Sonderfälle benennen (Sven, BFFs die nur proxyn, Repos ohne SQL → `db/` trotzdem als einziger I/O-Ort).
3. **Korrektur-Rezept je Repo** — immer: bestehende Endpunkte → `openapi.yaml` (User-Freigabe) → Code in `routes/logic/db` schieben → Tests → Image. Kein stilles Mitwachsen von `src/`.
4. **Reihenfolge** — klein/isoliert zuerst (z. B. eine Domain-API), BFFs danach, Sven zuletzt. Begründung je Stufe (Risiko, Abhängigkeiten).
5. **Aufwand & Risiko** — grob je Welle; was parallel geht; was HITL braucht (OpenAPI-Freigabe).
6. **Nicht-Ziele** — keine Features, kein postgres-shared wie Company, kein zweites Prinzipien-Dokument.

---

## 6. Constraints

- Jeremiah ist kein Entwickler — Plan in Schachteln, Tabellen, wenig Prosa (`praeferenzen.mdc`).
- Contract-first: Agent schreibt `openapi.yaml` **vor** Implementation; wartet auf Freigabe.
- Rip-out / API-only bleibt (`principles.md` §1.5).
- Git: Conventional Commits, File-Hub vs. Service-Repos getrennt.
- `tempui` / Brand-nginx sind keine Service-Vorlage.

---

## 7. Erster Schritt für dich

1. `principles.md` §8 + ein konformes Company-Repo lesen (`cProjects-api` oder `cUI-api`).
2. Inventur gegen §4 verifizieren (Ordner können sich seit diesem Handoff geändert haben).
3. Plan-Datei schreiben, z. B. `/opt/TunnelQuiz/.cursor/brain/handoffs/PLAN-service-modul.md` — **nicht** implementieren.
4. Jeremiah den Plan vorlegen (Schachtel 1 = Wellen, Schachtel 2 = Prüfskript, Schachtel 3 = erstes Pilot-Repo).
