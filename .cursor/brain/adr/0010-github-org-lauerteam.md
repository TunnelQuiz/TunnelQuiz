# ADR 0010 — GitHub-Org und Org-Root-Repo: `TunnelQuiz`

**Status:** angenommen  
**Datum:** 2026-08-20  
**SSOT der Regel:** `index-agents.md` §GitHub · `principles.md` §3.5 (GHCR)

## Kontext

VPS-Org-Root ist `/opt/TunnelQuiz`. Der File-Hub wurde von LauerTeam rsync't; ADR 0010 beschrieb dort `Lauer-Team` → `LauerTeam` und Repo `file-hub`. Das gilt **nicht** für TunnelQuiz. GitHub-Org folgt dem VPS-Pfad `/opt/TunnelQuiz`.

## Entscheidung

| Fläche | Wert |
|---|---|
| GitHub-Org | `TunnelQuiz` |
| Org-Root-Repo | `TunnelQuiz/TunnelQuiz` (Working-Tree `/opt/TunnelQuiz`, nur `.cursor/` + `.claude/` + README) |
| GHCR | `ghcr.io/tunnelquiz/<repo-lowercase>:<git-sha>` |

GHCR-Pfade anderer Orgs (`ghcr.io/lauerteam`, …) **nicht** nutzen — Compose auf Staging/Production muss diesen Namespace haben.

## Begründung

GitHub-Org ist die Heimat dieser VPS-Org (`index-agents.md`). Ein Repo gleichen Namens wie der VPS-Ordner ist die Org-Wurzel, kein Monorepo: `Apps/` und `Domains/` bleiben eigene Repos (gitignore).

## Verworfen

| Alternative | Warum nicht |
|---|---|
| GitHub-Org `LauerTeam` / GHCR `ghcr.io/lauerteam` | andere Organisation |
| Repo `file-hub` | klingt nach Dateispeicher, nicht nach Org-Root |
| Images unter einem fremden GHCR-Namespace | 403 / falsche Org, kein Redirect |
