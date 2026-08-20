# ADR 0001 — myOS ablösen: Apps-/Domain-Schnitt

**Status:** angenommen  
**Datum:** 2026-08-18  
**SSOT:** diese Datei (`/opt/TunnelQuiz/.cursor/brain/adr/0001-lauerteam-domain-split.md`)

## Kontext

`myOSDomain` war Gehirn, Todos, Routinen, Telemetrie, Agent-Kontext und Mission-Control in einer API — eine God-Domain. Ziel: Fach-Schnitt analog Company, ohne myOS.

## Entscheidung

1. **myOSDomain entfällt.** Netcup-Cutover 2026-08-18 abgeschlossen (Live in Domain-/App-`production/`; God-API nur noch Quarantäne/`myOS-backend` archiviert).
2. **Acht Domain-APIs**, je eigene DB sobald das Fach Schema hat:

   | Domain | API | Besitz |
   |---|---|---|
   | myProjectsDomain | myProjects-domain-api | Todos, Projekt-Register |
   | myAgentsDomain | myAgents-domain-api | Agent-Rechte, Runtime-API (**kein** File-Hub) |
   | myBrainDomain | myBrain-domain-api | Dokumente / Wissen |
   | myUserDomain | myUser-domain-api | Identität, app-übergreifende Prefs |
   | myOpsDomain | myOps-domain-api | KPI, Quota, Health-Snapshots |
   | myRoutinesDomain | myRoutines-domain-api | Ablauf-Graphen, Läufe |
   | myGunsDomain | myGuns-domain-api | Waffenwissen |
   | myDownloadsDomain | myDownloads-domain-api | Binärdateien (Downloads) |

3. **GUI spricht nur die eigene App-API** (BFF: routen, aggregieren, Token). Fachregeln bleiben in der Domain-API. Erst die App-API ruft Domain- oder andere App-APIs.

   | App | GUI | App-API | ruft |
   |---|---|---|---|
   | myUIApp | ja (Cockpit) | myUI-app-api | Domain-APIs + myAgents-app-api (Chat) |
   | myAgentsApp | nein | myAgents-app-api | myAgents, myProjects, myBrain, myUser, myRoutines, myOps + fremde Projekt-APIs (HTTP) |
   | myGunsApp | ja | myGuns-app-api | myGuns, myUser |
   | myDisplayApp | ja | myDisplay-app-api | myOps, myUser |
   | myWidgetsApp | nein (Scriptables) | myWidgets-app-api | myOps |
   | myDownloadsApp | ja | myDownloads-app-api | myDownloads |
   | tempui | Sandbox | — | keine feste Bindung |

4. **myAgentsApp hat kein GUI.** Chat-UI lebt in myUIApp. Telegram ist Adapter, keine Produkt-GUI.
5. **myRoutines-domain-api** darf andere Domain-APIs per HTTP anstoßen, nie fremde DBs.
6. **File-Hub** lebt am Org-Root `/opt/TunnelQuiz/.cursor/` (+ `.claude/`) — ADR `0007`. `documents/` → myBrainDomain, `todos/` → myProjectsDomain, `routinen/` → myRoutinesDomain. Hetzner-Ordner `myOSDomain` ist entfernt.

## Begründung

- Rip-out (`principles.md` §1.5): eine God-API koppelt alle Fächer.
- Eine Cockpit-GUI mit eigener App-API — Browser föderiert nicht viele Origins.
- myUser ist nur Identität + app-übergreifende Prefs; Layouts bleiben App-Daten (§1.6).
- Agent-Kontext ist Dev-Time, keine Domain-Nutzdaten (ADR 0007).

## Verworfen

| Alternative | Warum nicht |
|---|---|
| myOS als Hülle behalten | God-Domain unter neuem Namen |
| GUI ruft Domain-APIs direkt | Token/CORS/Aggregation im Browser |
| Eigenes Sven-WebUI | zweite GUI neben myUIApp |
| Dateien in myOS / File-Hub in myAgentsDomain | God-Domain über Dateien; vermischt Dev-Time und Runtime |
| Fachlogik nur in App-APIs, Domains als dummes I/O | Domain-Invarianten würden sich über Apps verdoppeln |

## Folgen

- **Hetzner:** myOS-Runtime weg; Domain-APIs + App-APIs tragen die Fach-Pfade.
- **Netcup-Cutover (erledigt 2026-08-18):** Live unter `/opt/TunnelQuiz/{Apps,Domains}/*/production/`. Alter Baum in `/opt/_backups/netcup-myos-quarantine-2026-08-18/` (kein SSOT). GitHub `myOS-backend` archiviert. Hostnamen ADR 0002.
- Widget-Telemetrie: myWidgets-app-api spricht myOps-domain-api (HTTP); Writer in myOps.
