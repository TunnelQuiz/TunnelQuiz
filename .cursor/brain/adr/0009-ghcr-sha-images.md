# ADR 0009 — App-Images: GHCR, Tag = Git-SHA

**Status:** angenommen  
**Datum:** 2026-08-18  
**SSOT der Regel:** `principles.md` §3.5 (diese Datei = Entscheidung)

## Kontext

Staging/Production sollen Image-only laufen (`principles.md` §3.3). Compose darf keine nur-lokalen Namen (`:local` / `:latest`) als Dauer-SSOT nutzen — Netcup kann die dann nicht pullen.

## Entscheidung

| Teil | Wert |
|---|---|
| Registry | GitHub Container Registry |
| Name | `ghcr.io/tunnelquiz/<repo-lowercase>` — `<repo>` = GitHub-Repo (`tunnelQuiz-app-api` → `tunnelquiz-app-api`); Namespace = Org `TunnelQuiz` (ADR 0010) |
| Tag | **voller Git-Commit-SHA** der gebauten Codebase, in `.env` als `*_IMAGE_TAG` |
| Verboten | `:latest`, `:local`, unversionierte Tags, anderes Registry-Schema für TunnelQuiz-App-Images |
| Basis-Images | weiter pinnen (`postgres:16`, `nginx:1.27-alpine`) |

**Dev (Hetzner `development/`):** `docker compose --build` im Repo. Das Compose-`image:` ist bereits der GHCR-Name + SHA-Tag — lokal bauen taggt denselben Namen (Staging auf demselben Host braucht dann keinen Pull).

**Staging / Production:** kein `build:`. `docker compose pull && docker compose up -d --no-build`. Tag kommt nur aus `.env`.

**Publish:** GitHub Actions auf `main` (Skill `ghcr-publish.md`). Netcup authentifiziert sich an GHCR (read).

**Nicht betroffen:** Vite-Dev-Compose (`docker-compose.dev.yml`) — nur Entwicklung, nie Production.

## Begründung

Gleiche Image-Identität auf beiden Hosts. SHA ist reproduzierbar und rollback-fähig (`principles.md` §0.6, §3.4). `:latest`/`:local` verletzt §2.2 und §3.5.

## Verworfen

| Alternative | Warum nicht |
|---|---|
| nur lokal, `docker save` nach Netcup | kein Registry-SSOT, manuell, bricht §3.3 |
| Tag = SemVer / `v1` | weniger präzise als Commit; SHA bleibt erlaubt als einziges App-Tag |
| `:latest` plus Digest in Doku | Compose würde trotzdem gleiten |
| Images unter `ghcr.io/lauerteam` | das ist LauerTeam, nicht TunnelQuiz |

## Folgen

- Generator `scripts/gen-staging-compose.py` schreibt GHCR-Namen, Default-Tag verboten (`:?TAG fehlt`).
- Deploy-Skill: Image-Pull, kein `git pull` auf Staging/Prod.
- CI-Workflows in den App-/Domain-Repos (Vorlage im Skill); ohne Push nach GHCR startet Netcup nicht.
