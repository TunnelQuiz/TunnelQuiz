# ADR 0001 — TunnelQuiz: ein App+Domain-Paar

> Ersetzt die LauerTeam-Kopie. TunnelQuiz ist nicht LauerTeam: kein myOS, kein myUI, keine acht Domains.

**Status:** angenommen  
**Datum:** 2026-08-20  
**SSOT:** diese Datei (`/opt/TunnelQuiz/.cursor/brain/adr/0001-lauerteam-domain-split.md`)

## Kontext

Dieser File-Hub wurde von LauerTeam rsync't. Dort löste ADR 0001 die God-Domain `myOSDomain` in acht Domain-APIs plus mehrere Apps ab. TunnelQuiz hat diesen Schnitt nicht — Gold-Standard ist **eine App und eine Domain**.

## Entscheidung

1. **Eine App, eine Domain** unter `/opt/TunnelQuiz/`:

   | Zone | Ordner | Repos / Services | Besitz |
   |------|--------|------------------|--------|
   | Domain | `Domains/tunnelQuizDomain/` | `tunnelQuiz-domain-api` (`tunnelquiz-domain-api`) + Postgres (`tunnelquiz-domain-db`) | Fachdaten, Invarianten |
   | App | `Apps/tunnelQuizApp/` | `tunnelQuiz-app-web` (GUI) + `tunnelQuiz-app-api` (`tunnelquiz-app-api`, BFF) | Oberfläche, Aggregation |

2. **GUI spricht nur die eigene App-API** (BFF: routen, aggregieren, Token). Fachregeln bleiben in der Domain-API. Die App-API ruft die Domain-API per HTTP — keine direkte GUI→Domain-Origin, keine fremde DB.

3. **Keine LauerTeam-Services** in dieser Org (kein myUI, myAgents, myGuns, myOS, …).

4. **File-Hub** lebt am Org-Root `/opt/TunnelQuiz/.cursor/` (+ `.claude/`) — ADR `0007`. Domain-Dateien → `tunnelQuizDomain` `data/files/`.

5. **Hosts:** Hetzner = `development/` + `staging/`; Netcup = `production/`. Öffentlich: `https://tunnelquiz.lauer.team` (ADR 0002).

## Begründung

- Rip-out (`principles.md` §1.5): eine Org, ein Produkt, ein Fach.
- Eine GUI mit eigener App-API — Browser föderiert nicht Domain-Origins.
- Agent-Kontext ist Dev-Time, keine Domain-Nutzdaten (ADR 0007).

## Verworfen

| Alternative | Warum nicht |
|---|---|
| LauerTeam-Schnitt (acht Domains) behalten | diese Org hat ein Fach |
| GUI ruft Domain-API direkt | Token/CORS/Aggregation im Browser |
| File-Hub in Domain-`data/` | vermischt Dev-Time und Runtime |
| Fachlogik nur in der App-API, Domain als dummes I/O | Invarianten würden sich verdoppeln, sobald eine zweite App dazukäme |

## Folgen

- Layout: `Apps/tunnelQuizApp/` + `Domains/tunnelQuizDomain/` (Hetzner: development + staging; production nur Netcup).
- Images: `ghcr.io/tunnelquiz/<repo>:<git-sha>` (ADR 0009, 0010).
- Dateiname `0001-lauerteam-domain-split.md` bleibt historisch (rsync); Inhalt gilt nur für TunnelQuiz.
