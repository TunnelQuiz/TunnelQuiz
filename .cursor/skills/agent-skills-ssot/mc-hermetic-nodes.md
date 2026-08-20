# Skill: Hermetische Routinen-Knoten

> Ein Knoten = eine `.py`-Datei. Zwischen Knoten nur **Postgres** (Fakten).

## Trigger

- Neue Routine oder Knoten anlegen
- Knoten-Logik ändern (`data/files/routinen/`)
- Frage: „Wie schreibe ich einen hermetischen Knoten?“

## Voraussetzungen

- myRoutines-domain-api läuft (`cockpit-todos.md`)
- Graph-Definition in Postgres Schema `myroutines`
- Knoten-Dateien unter `Domains/myRoutinesDomain/<env>/data/files/routinen/{routine_id}/{node_id}.py`

| Host | Daten |
|------|-------|
| **Hetzner** `development/` · `staging/` | Dummy-`data/` — zum Schreiben/Testen |
| **Netcup** `production/` | Live-Knoten |

## Schritte

### 1. Regeln (verbindlich)

1. **Ein Knoten, eine Datei** — z. B. `data/files/routinen/due-notify/n2.py`
2. **Alles in der Datei** — API, SQL, Telegram, Shell
3. **Hermetisch** — Knoten tauschen nur Fakten über Postgres (oder Graph-`branch`)
4. **Orchestrator** — startet Knoten nacheinander (myRoutines-domain-api)

### 2. Architektur (Kurz)

```text
myUI-app-web  ↔  myUI-app-api  ↔  myRoutines-domain-api
myroutines.routines   ← Graph-JSON in Postgres
data/files/routinen/  ← Knoten-.py (myRoutinesDomain)
```

| Schicht | SSOT |
|---------|------|
| Graph-Struktur | Postgres `myroutines` |
| Knoten-Logik | `Domains/myRoutinesDomain/…/data/files/routinen/{routine_id}/{node_id}.py` |
| Lauf-Historie | Postgres `runs` / `run_steps` |

### 3. Neuen Knoten anlegen

1. Graph in Cockpit oder DB erweitern (`routine_id`, `node_id`)
2. Datei unter myRoutinesDomain `data/files/routinen/{routine_id}/{node_id}.py` anlegen (Hetzner Dummy; Live = Netcup production)
3. Health: `curl -sS http://127.0.0.1:8815/api/health`

### 4. Pfad-Auflösung

Projekt-Pfad-Helfer löst `project_id` → `data/files/routinen/{routine_id}/`.

## Erfolgskriterium

- Knoten läuft isoliert über Routine-Run oder UI-Trigger
- Kein Import/geteilter Code zwischen Knoten-Dateien
- Lauf in `runs`/`run_steps` sichtbar

## Rollback

| Problem | Lösung |
|---------|--------|
| Knoten wirft Fehler | Datei zurücksetzen; letzten erfolgreichen Run in DB prüfen |
| Graph kaputt | Routine-JSON in Postgres aus Backup oder UI korrigieren |
| Cron feuert nicht | Cron-Datei unter myRoutinesDomain-`data/` prüfen |

## Verwandt

- `cockpit-todos.md` · `brain/index-workspace.md`
