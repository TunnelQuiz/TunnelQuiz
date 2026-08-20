# PRINZIPIEN

> SSOT für Arbeitsprinzipien aller Projekte unter `/opt/TunnelQuiz/`.
> Gelesen von Mensch und allen KI-Agenten. Bei Widersprüchen **gewinnt dieses Dokument**.
> Stand: 2026-08-20 (Org-eigene File-Hub-SSOT `/opt/TunnelQuiz/.cursor/` · Service-Modul `routes/logic/db` + `openapi.yaml`).

**File-Hub:** Nur `/opt/TunnelQuiz/.cursor/`. Andere Orgs haben eigene SSOTs — keine Cross-Org-Symlinks. Änderungen hier: Agent fragt vor Sync in andere Orgs (`workflow.mdc` §Org-File-Hub).

---

## 0. Meta-Prinzipien

**0.1 Das kleinste System, das funktioniert.** YAGNI — Komplexität nur bei realem Schmerz.

**0.2 Minimize scope** — simplest correct diff; no unrelated changes

**0.3 Mach es möglich, aber nicht jetzt.** Architektur andockbar legen; bauen bei Bedarf.

**0.4 Übersichtlichkeit vor Effizienz.** Was ich nicht verstehe, kann ich nicht steuern.

**0.5 Schachteldenken.** Organisation → Projekt → Environment → Code / Config / Daten.

**0.6 Reproduzierbarkeit ist der Lackmustest.** ~20 Min. Wiederherstellung aus Git + Backups.

**0.7 Avoid over-engineering** — no premature abstraction or excessive error handling

**0.8 Use existing conventions** — match surrounding code; reuse and extend existing functions

**0.9 Comments** — only for non-obvious business logic

**0.10 Useful tests only** — add tests if requested or they cover real behavior

**0.11 Avoid backticks** — do not overuse bolding or backticks for decoration

---



## 1. SSOT & Trennung

**1.1 Eine maßgebliche Quelle pro Information.**

- Code → **GitHub**
- Strukturierte Daten → **Postgres** des jeweiligen Projekts/Environments
- Config / Secrets → `.env` pro Environment (nie in Git)
- Kopien erlaubt — nie zwei konkurrierende Wahrheiten

**1.2 Vier Kategorien.**

1. **Code** — Git, wegwerfbar
2. **Config & Secrets** — `.env` auf dem Server
3. **Strukturierte Daten** — Postgres (Todos, Fakten, Beziehungen)
4. **Passive Dateien** — `data/files/` (Ordnerlogik: `index-workspace.md`)

**1.3 Codebase ≠ Image ≠ Daten.** Code in GitHub; Laufzeit als gepinntes Image; persistente Daten nur in `data/` / Postgres — nichts Wichtiges nur im flüchtigen Container-Filesystem.

**1.4 Ein SSOT für Mensch UND KI.** Dieselben Daten; Aufgaben mit und ohne KI möglich.

**1.5 Projekte sind eigenständig — API-only, eisern.**

Jedes Projekt ist eine abgeschlossene Einheit mit eigener API und `data/`. Unter LauerTeam und Company gilt zusätzlich die **Apps-/Domains-Trennung** (Org-README):

| Zone | Verantwortung |
|------|----------------|
| **Domain** | Daten + Domain-API (DB je nach Komplexität: Postgres oder SQLite) |
| **App** | Statisches GUI + ggf. App-API/BFF — konsumiert Domains nur per HTTP |

Laufzeit-Kommunikation **ausschließlich** App-API → Domain-API (Health-Check, dokumentierte Endpunkte). Keine App spricht direkt eine fremde DB an.

- **Rip-out-Test (Prüfkriterium):** Jedes Projekt muss sich jederzeit komplett entfernen lassen, ohne dass ein anderes Projekt mehr als einen fehlgeschlagenen HTTP-Call bemerkt. Jede Integration, die diesen Test nicht besteht, ist ein Verstoß.
- **Verboten:** gemeinsame DB-User oder DB-Zugriff über Projektgrenzen; Lesen/Schreiben fremder `data/files/`; Imports aus fremden `repos/`; gemeinsame Docker-Volumes zwischen Projekten.
- **Ausnahme 1 — Dev-Time-Kontext:** Die `agent-*-symlink`s (siehe `index-agents.md`) kreuzen Projektgrenzen im Dateisystem. Das ist erlaubt, weil sie ausschließlich Agenten-Kontext zur Entwicklungszeit liefern; zur Laufzeit hängt kein Projekt von ihnen ab. Ein gelöschter Symlink darf nie einen Service brechen.
- **Ausnahme 2 — Agent-Orchestrierung (myAgentsApp):** myAgentsApp (Sven) startet als digitaler Assistent Coding-Agenten (Cursor CLI) in den Workspaces anderer Projekte (Registry: `Apps/myAgentsApp/…/config/agent-permissions.json`). Das ist Dev-Time-Arbeit im Auftrag des Nutzers, keine Laufzeit-Kopplung: Fehlt ein Ziel-Projekt, schlägt nur der jeweilige Agent-Start fehl — myAgentsApp selbst läuft weiter. Alles andere bleibt verboten: zur Laufzeit keine fremden Daten/Configs lesen/schreiben und keinen fremden Code importieren — Datenaustausch nur über HTTP-APIs (z. B. Agent-Kontext via myAgentsDomain).
- **Prüfskript:** `scripts/verify-rip-out.sh` — scannt alle `repos/` (Code/Config; `.md`-Prosa ausgenommen) auf fremde Projekt-Pfade; für Ausnahme 2 gilt eine Allowlist aus der Workspace-Registry.

**1.6 Soft Facts — Eigentum nach Lebensdauer, nicht nach „hart/weich“.**

Nutzerbezogene Soft Facts (Favoriten, Custom-Layouts, Theme, …) speichern Profis **nicht** pauschal in einer User-Domain und auch nicht pauschal in App-Daten. Maßstab ist **Eigentum & Lebensdauer** (ADR: `brain/adr/0006-soft-facts-ownership.md`):

| Art | Beispiele | Speichern in |
|-----|-----------|--------------|
| **Identität** | Account, Login | Auth-/Account-Quelle |
| **Domänen-Beziehung** | Favorit auf einer Entity (z. B. Waffe X) | **dieselbe Domain** wie die Entity |
| **Präsentation** | Spaltenlayout, Panel-Größen, Widget-Reihenfolge | **App-Daten** (App-API / App-`data/`) |
| **Geräte-ephemer** | Scroll-Position, offenes Modal, Draft | Browser (localStorage/State) — kein Server |

- **Verboten als Default:** eine zentrale User-/Preferences-Domain für *alle* Soft Facts (God-Domain; koppelt GUI-Evolution an fremde Domains; verletzt YAGNI → 0.1 und Rip-out → 1.5).
- **App-übergreifende Prefs** (Theme, Locale): **myUserDomain** (Identität + Prefs) — keine Layouts, keine Entity-Favoriten (die bleiben in der Entity-Domain).
- **Merksatz:** Soft ≠ User-Domain. Soft + Entity → Domain; Soft + GUI → App.

---



## 2. Twelve-Factor — verbindliche Regeln

> **Diese Regeln sind bindend für jeden Agenten, der Code schreibt oder ändert.**
> Verstößt eine Anforderung des Nutzers gegen eine Regel, weist der Agent
> darauf hin, bevor er implementiert. **Kein stillschweigendes Abweichen!**



### **2.1 Codebase**

*Ein Repo pro Projekt, deploybar in alle Environments.*
**Verboten:** Copy-Paste-Forks, environment-spezifische Branches (kein „staging-branch" mit eigenem Code).

### **2.2 Dependencies**

*Alle Abhängigkeiten explizit deklariert und gepinnt*
*(package.json/requirements.txt mit Versionen, Lockfile im Git).*
**Verboten:** implizite System-Pakete voraussetzen, ungepinnte Versionen, `:latest` bei Images (→ 3.5).

### **2.3 Config**

*Alles, was zwischen Environments variiert, kommt aus Umgebungsvariablen (→ 1.1, 3.2).*
**Verboten:** Hardcoded URLs, Ports, Credentials oder `if (env === "production")` im Code.

### **2.4 Backing Services**

*Postgres, Redis, externe APIs werden nur über Config angebunden (Connection-String in .env).*
Ein Austausch der Ressource darf **keine Codeänderung** erfordern.

### **2.5 Build / Release / Run**

*Strikt getrennt (→ 3.3).*
**Verboten:** Builds zur Laufzeit; Änderungen am laufenden System außerhalb des Git-Flows (→ 3.3).

### **2.6 Stateless Processes**

*Kein Zustand im Prozess oder Container, der einen Restart überleben muss.*
**Sessions, Uploads, Fakten → Postgres oder data/files/** (→ 1.3).
**Verboten:** lokale Dateien oder In-Memory-State als einzige Wahrheit.

### **2.7 Port Binding**

*Jeder Service exportiert sich selbst über einen Port aus .env.*
Nach außen routet ausschließlich **Caddy** (→ 4.1).

### **2.8 Concurrency**

*Skalierung über weitere stateless Prozesse, nie über „größer machen" eines stateful Prozesses (→ 3.6).*

### **2.9 Disposability**

*Jeder Prozess muss jederzeit gekillt und neu gestartet werden können, ohne Datenverlust und ohne manuelle Aufräumarbeit.*
**Graceful Shutdown; Start ohne Handarbeit.**

### **2.10 Dev/Prod Parity**

*Gleiche Dienste und Versionen in allen Environments (→ 3.1, 3.5).*
**Verboten:** SQLite in dev, Postgres in prod.

### **2.11 Logs als Stream**

*Prozesse schreiben nach stdout/stderr (→ 6.1).*
**Verboten:** eigene Logdateien im Container, eigenes Log-Routing im Code.

### **2.12 Admin-Prozesse**

*Migrationen und einmalige Tasks laufen als eigene, versionierte Prozesse aus derselben Codebase (→ 3.7).*
**Verboten:** manuelle SQL-Statements direkt auf der DB.

**Prüfpflicht:**
*Vor jedem Commit gleicht der Agent seine Änderung gegen 2.1–2.12 ab.*
**Bei Verstoß:** nicht committen! Stattdessen Konflikt benennen und Alternative vorschlagen.

---



## 3. Environments & Deployment

**3.0 Zwei VPS — verbindlich.**

| Rolle | Anbieter | Projekt-Environments unter `/opt/…` |
|-------|----------|-------------------------------------|
| **Dev/Staging-Host** | **Hetzner** | nur `development/` und `staging/` — **kein** Projekt-`production/` |
| **Production-Host** | **Netcup** | nur `production/` — Live-Dienste, 24/7 |

- Code-SSOT: **GitHub**. Dieselbe Codebasis für alle Environments.
- Getrennte `.env` + `data/` je Host/Environment — Secrets und Nutzdaten **nie** in Git.
- **Verboten auf Hetzner:** Projektordner `…/<Projekt>/production/` anlegen oder als Deploy-Ziel behandeln.
- **Verboten auf Netcup:** development/staging als Ersatz für Hetzner-Arbeit nutzen (Arbeit = Hetzner).
- Plattform-Stack `_server/production/` ist der **Ops-Ordnername** (Caddy/Compose) und darf auf beiden Hosts existieren — das ist **kein** Projekt-Environment. Hetzner: Slim-Stack (`docker-compose.hetzner.yml`); Netcup: Prod-Stack. Source der Plattform: Git-Klon `repos/Server` (Ausnahme zu Image-only, weil Routing-Config das Produkt ist). Details: `index-workspace.md`, Server-ADR `0004-vps-provider-netcup.md`.

**3.1** Environments: `development` · `staging` · `production` — Unterschied = Config + Daten + Host (→ 3.0) + wer editiert; **nicht** anderer Code.

**3.2** Eine Codebasis, getrennte `.env` — kein environment-spezifischer Code. Höchstens `.env.example` ohne Secrets im Repo.

**3.3 Deploy-Modell (verbindlich).**

1. **GitHub** hält die gesamte Codebase.
2. Daraus wird ein **Image** gebaut (CI) und nach **GHCR** gepusht — Tag = Git-SHA (ADR `brain/adr/0009-ghcr-sha-images.md`, → 3.5).
3. **Hetzner `development/`:** `repos/` (Git-Klone) + `.env` + `data/` (nur Dummy/Testdaten). Entwickeln/bauen: `docker compose` **aus dem Repo** (`--env-file ../../.env`, bei Bedarf `--build`). Frontend-Vite: `docker-compose.dev.yml` im GUI-Repo.
4. **Hetzner `staging/`:** wie Production — **`docker-compose.yml` + `.env` + `data/`**, Image pullen, **kein** Quellcode-Baum. Daten: nur Dummy.
5. **Netcup `production/`:** **`docker-compose.yml` + `.env` + `data/`** — **kein** App-Quellcode, **kein** `repos/`-Source-Tree. Deploy = Image pullen (`docker compose pull`) + `up -d --no-build`. Die Compose-Datei nennt Image-Tag, Netzwerk, und die Pfade zu `.env` und `data/`.

- **Arbeit:** Remote-SSH auf **Hetzner** `/opt/…` (`development` / `staging`). Jede Änderung über Commit (`rules/workflow.mdc`); ohne Commit gilt der Stand als nicht existent.
- **Production-Deploy:** nur auf **Netcup**, nur per Image — nie „nebenbei“ Source auf Netcup editieren oder bauen.
- Schutz = Git-Rollback (→ 0.6), nicht HITL am Commit-Tor (→ 5.6).

**3.4** Portability: Production in Minuten wiederherstellbar aus Image-Tag + `.env` + `data/`-Backup; Staging ebenso (Dummy-`data/`); Development aus Git + `.env` + Dummy-`data/`.

**3.5** App-Images: `ghcr.io/tunnelquiz/<repo-lowercase>:<git-sha>` (ADR 0009 · ADR 0010). **Verboten:** `:latest`, `:local`. Basis-Images weiter pinnen (`postgres:16`, `nginx:1.27-alpine`).

**3.6** Stateless skalieren; DB bleibt eine Instanz pro Environment **und Host**.

**3.7** DB-Struktur nur per nummerierte Migrationen.

---



## 4. Sicherheit

**4.1** Default: alles zu. Nach außen nur **Caddy**. DB nie aus dem Internet.

**4.2** Admin-Zugang über **Tailscale**.

**4.3** Secrets nur in `.env`.

**4.4** Least Privilege — Coding-Agent ≠ operativer Agent; getrennte Blast-Radius.

**4.5** Alle API-Endpunkte rate-limiten.

**4.6** Captcha auf allen Auth-Routen und Sign-up-Seiten.

**4.7 Exposure-Policy: Default alles Tailnet-only, öffentlich nur per Opt-in.** Kein Dienst ist ohne bewusste, dokumentierte Entscheidung aus dem Internet erreichbar. Technische Durchsetzung in Caddy (nicht nur DNS!): Jede Site in `Server/caddy/sites.d/` importiert genau eines von `tailnet_only` (remote_ip-Guard, Default) oder `public_site` (Opt-in, im Site-Header begründet). Prüfskript: `Server/scripts/verify-exposure.sh`. Split-DNS/verstecktes DNS gilt **nicht** als Schutz.

---



## 5. KI & Agenten (File-over-AI)

**5.1 Anweisungen in Dateien (Git).** Rollen, Grenzen, Maps in `brain/`, Rules in `.cursor/rules/agent-rules-ssot/` (File-Hub: Org-Root `/opt/TunnelQuiz/.cursor/`). Deterministischer Wrapper lädt sie — Agent kann nicht „vergessen", wer er ist. Mechanik: `index-agents.md`.

**5.2 Gedächtnis in Postgres.** Todos, Fakten, Verlauf — abfragbar, nicht als wachsende md-Halde. **Todos-SSOT = Postgres der myProjectsDomain**, kein Markdown-Snapshot. Abruf: `rules/workflow.mdc` §Todos.

**5.3** So viel Kontext wie nötig, so wenig wie möglich.

**5.4** Kein Handoff — Was überleben soll, muss geschrieben werden (DB oder Datei).

**5.5** Coding-Agent ändert Code; operativer Agent nur Daten — nie fremde Projekte direkt.

**5.6** HITL an definierten Toren technisch erzwungen — dort, wo Schaden nicht per Git-Rollback heilbar wäre (destruktive DB-Operationen, Löschen von `data/`, Kommunikation nach außen). Der Git-Flow selbst ist **kein** HITL-Tor: Commits, Pushes und Merges laufen automatisch (`rules/workflow.mdc`); Schutz = Rollback (→ 3.3).

**5.7 Skript vor Manager.** Wenn die Regel in einem Satz formulierbar ist → deterministisches Skript/Cron, kein LLM-Manager. KI-Manager nur für echte Urteils-Aufgaben (Texte, Pläne, Bewertungen). Ausarbeitung (Loop, Rollen, Bau-Reihenfolge): `Domains/myProjectsDomain/staging/data/files/todos/agents/2026-06-29 - KI-MANAGEMENT-PLAN.md`.

---



## 6. Nachvollziehbarkeit

**6.1** Logs als Ereignis-Strom.

**6.2** Proof-of-Action; System meldet Auffälligkeiten aktiv.

---



## 7. Projekt-Organisation

**7.1** Eigenständige Repos; Schnittstellen nur über APIs (→ 1.5).

**7.2** Docker wo Nutzen — nicht dogmatisch.

**7.3** Feste Konvention — **gleiches Org-Layout auf beiden VPS; Env-Inhalt nach Rolle** (Dev = Klone, Staging/Prod = Image):

Organisationen (gleiche Top-Level-Struktur auf beiden VPS):

```
/opt/
├── LauerTeam/{Apps,Domains}/…
├── Company/{Apps,Domains,infra}/…
├── KiezQuiz/…
├── TunnelQuiz/…
├── _server/production/     ← Plattform (Ops; → 3.0)
├── _backups/
└── _dotfiles/
```

Pro Projekt (App oder Domain), Environment-Ebene:

**Hetzner `development/`:**

```
…/<Projekt>/development/
├── repos/              ← Git-Klone (Code-SSOT = GitHub)
├── .env                ← Dev-Secrets (nie in Git)
└── data/               ← nur Dummy/Testdaten
    ├── database/
    ├── files/
    └── cache/          ← optional
```

Vite-Dev-Server: `docker-compose.dev.yml` + `Dockerfile.dev` **im GUI-Repo**, Start aus dem Repo mit `--env-file ../../.env`.

**Hetzner `staging/` und Netcup `production/`:**

```
…/<Projekt>/<environment>/
├── docker-compose.yml  ← Image, Netzwerk, Mounts von .env + data/
├── .env
└── data/               ← Staging: Dummy · Production: Live
```

**Kein** `repos/`-Source-Tree auf Staging oder Production (→ 3.3). Ausnahme Plattform: `/opt/_server/production/repos/Server` (Git-Klon).

**Welches `<environment>` auf welchem Host:** → 3.0  
(Hetzner: `development`/`staging` · Netcup: `production`)

**7.4 Nomenklatur (Blicklesbarkeit).** `<Kurz>` = Produktstamm (`myUI`, `myProjects`, …). Ordner: `Apps/<Kurz>App/`, `Domains/<Kurz>Domain/`. GitHub- und `repos/`-Name:

| Fläche | Name |
|--------|------|
| Domain-API | `<Kurz>-domain-api` (genau eins) |
| App-API | `<Kurz>-app-api` |
| GUI Web | `<Kurz>-app-web` |
| GUI iOS | `<Kurz>-app-ios` (ggf. Suffix `-quota` / `-kpi`) |
| GUI Pi | `<Kurz>-app-pi` |

Kein GUI-Repo unter `Domains/`. Ausnahme: `Apps/tempui/`. Docker-DNS = Repo-Name, keine Aliase. Env-Präfixe = Produkt (`MYUI_`, `MYGUNS_DOMAIN_`, `MYGUNS_APP_`, `MYDISPLAY_`, `MYDOWNLOADS_`, `MYAGENTS_APP_`, `MYAGENTS_DOMAIN_`). Hostnamen: ADR `brain/adr/0002-nomenklatur-ohne-myos.md`. Ein `.env` je Environment des Projekts, nicht je Repo.

**Merksatz:** Code-SSOT = GitHub · Hetzner-Dev = `repos/` + `.env` + Dummy-`data/` · Hetzner-Staging + Netcup-Prod = GHCR-Image (`ghcr.io/tunnelquiz/<repo>:<git-sha>`) + Compose + `.env` + `data/` · Domänen-Fakten in Domain-`data/database/` · Dateien in `data/files/` · GUI in Apps · Production-Live nur auf Netcup · Service-Innenleben → §8.

---



## 8. Service-Architektur (bindend)

> **Gilt ohne Ausnahme** für jedes Service-Repo unter `/opt/TunnelQuiz/`.
> Andere Orgs pflegen denselben Standard in eigener SSOT. **Kein stillschweigendes Abweichen.**

**8.1 Clients vs. Services.**

| Typ | Beispiele | `openapi.yaml`? | Läuft wo? |
|-----|-----------|-----------------|-----------|
| **Service** (bietet an) | `*-domain-api`, `*-app-api` | **ja** | VPS (Container) |
| **Client** (konsumiert) | `*-app-web`, iOS, Scriptable, Pi-GUI | nein | Browser / Gerät — **nie** als API-Service |

**8.2 Modul-Vorlage — jedes Service-Repo identisch.**

```
<service-repo>/
├── openapi.yaml     ← Vertrag (zuerst, User-Freigabe)
├── routes/          ← HTTP-Eingang
├── logic/           ← Business-Regeln
├── db/              ← einziger DB-Zugriff
├── Dockerfile · docker-compose.yml · .env.example · .gitignore
└── migrations/      ← nur wo SQL (→ 3.7)
```

**Einbahnstraße:** `Anfrage → routes/ → logic/ → db/` — `routes/` importiert **nie** aus `db/`. Ein Teil ruft ein anderes *nur* über dessen Vertrag (HTTP) — nie in dessen `logic/` oder `db/`.

**8.3 Contract-first.** Agent schreibt zuerst `openapi.yaml` → User-Freigabe → dann `routes/logic/db`. Kein neuer Endpunkt ohne Eintrag im Vertrag. SwaggerUI: `/opt/_server/production/repos/Server/scripts/swagger-ui.sh <repo>/openapi.yaml`.

**8.4 Bestand.** Kein neues `src/`-Layout. Bestehendes `src/` nicht vergrößern; bei Arbeit an einem Modul in die Vorlage überführen. Clients (GUI) haben kein `routes/logic/db` und kein `openapi.yaml`.

**8.5 Vier Ebenen (Merksatz).**

1. Zwischen Teilen: Verträge (`openapi.yaml`), nur HTTP.
2. Innerhalb Teils: Einbahnstraße `routes → logic → db`.
3. Über Environments: ein Code, drei Configs (`.env`) (→ 3.1).
4. Production/Staging: fertige Images, kein App-Quellcode (→ 3.3).

**Prüfpflicht:** Vor jedem Commit gegen 8.1–8.5 abgleichen (zusätzlich zu §2). Bei Verstoß: nicht committen — Konflikt benennen, Alternative vorschlagen.
