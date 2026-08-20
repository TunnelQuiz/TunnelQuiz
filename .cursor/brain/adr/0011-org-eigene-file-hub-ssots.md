# ADR 0011 — Org-eigene File-Hub-SSOTs (kein Cross-Org-Link)

Jede Organisation unter `/opt/` hat eine eigenständige SSOT:

| Org | File-Hub |
|-----|----------|
| LauerTeam | `/opt/LauerTeam/.cursor/` |
| Company | `/opt/Company/.cursor/` |
| Azubuilder | `/opt/Azubuilder/.cursor/` |
| KiezQuiz | `/opt/KiezQuiz/.cursor/` |
| BottleBuddy | `/opt/BottleBuddy/.cursor/` |
| TunnelQuiz | `/opt/TunnelQuiz/.cursor/` |
| UniversalView | `/opt/UniversalView/.cursor/` |
| Volea | `/opt/Volea/.cursor/` |

Projekt-Symlinks zeigen nur auf die eigene Org-SSOT.
