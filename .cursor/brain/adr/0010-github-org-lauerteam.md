# ADR 0010 — GitHub-Org und Org-Root-Repo: `LauerTeam`

**Status:** angenommen  
**Datum:** 2026-08-19  
**SSOT der Regel:** `index-agents.md` §GitHub · `principles.md` §3.5 (GHCR)

## Kontext

VPS-Org-Root ist `/opt/TunnelQuiz` (ohne Bindestrich). Die GitHub-Org hieß `Lauer-Team`; das Org-Root-Repo hieß `file-hub`. Zwei Namen für dieselbe Organisation, plus ein Repo-Name, der den Inhalt (Agent-SSOT) nicht als Org-Wurzel lesbar macht.

## Entscheidung

| Fläche | Wert |
|---|---|
| GitHub-Org | `TunnelQuiz` |
| Org-Root-Repo | `TunnelQuiz/TunnelQuiz` (optional) (Working-Tree `/opt/TunnelQuiz`, nur `.cursor/` + `.claude/` + README) |
| GHCR | `ghcr.io/tunnelquiz/<repo-lowercase>:<git-sha>` |

Git-URLs unter dem alten Org-Namen redirecten. GHCR-Pfade redirecten **nicht** — Compose auf Staging/Production muss den neuen Namespace nutzen.

## Begründung

GitHub-Org folgt dem VPS-Pfad (`index-agents.md`). Ein Repo gleichen Namens ist die Org-Wurzel, kein Monorepo: `Apps/` und `Domains/` bleiben eigene Repos (gitignore).

## Verworfen

| Alternative | Warum nicht |
|---|---|
| Org `Lauer-Team` belassen | weicht vom VPS-Ordner ab |
| Repo `file-hub` / `LauerTeam-shared` | klingt nach Dateispeicher bzw. Library, nicht nach Org-Root |
| GHCR `ghcr.io/lauer-team` weiter hartcodieren | nach Org-Rename 403, kein Redirect |
