# Skill: PostgreSQL-Backup

> 🤖 AI-assisted — Teil des VPS-Backup-Systems. Vollständig: `backup-system.md` · Doku: `_server/production/repos/Server/docs/BACKUP.md`

## Trigger

- User sagt: „Backup einrichten“, „Backup prüfen“, „PostgreSQL sichern“
- Vor größeren DB-Migrationen oder Server-Updates

## Voraussetzungen

- SSH auf den betroffenen Host (Hetzner = dieser Cursor-Host · Netcup = Production)
- Docker-Compose je Projekt mit DB-Service
- Backup-Cron installiert (`install-backup-cron.sh`)

## Automatisch (täglich 02:30)

Alle registrierten DBs → `/opt/_backups/db-dumps/<prefix>-YYYY-MM-DD.sql.gz`

Registry: `_server/production/repos/Server/config/backup-databases.json`

## Manuell

```bash
# Alle registrierten DBs
bash /opt/_server/production/repos/Server/scripts/backup/backup-databases.sh
```

## Restore

```bash
gunzip -c /opt/_backups/db-dumps/myprojects-YYYY-MM-DD.sql.gz | \
  docker compose exec -T postgres psql -U myprojects -d myprojects
```

Oder: Restore über das jeweilige Domain-Compose (`docker compose exec -T postgres psql …`).

## Neue Projekt-DB

Eintrag in `backup-databases.json` — nur wenn Container läuft.

## Hetzner Snapshot (ergänzend)

Vollständige Platten-Sicherung über Hetzner Cloud Console — nicht Ersatz für SQL-Dumps.

## Erfolgskriterium

Dump-Datei unter `db-dumps/`, Eintrag in `logs/db-backup.log`

## Rollback

| Problem | Lösung |
|---------|--------|
| Restore nötig | Dump aus `db-dumps/` → `restore-db.sh` oder `psql` (siehe oben) |
| Backup schlägt fehl | Container läuft? `docker compose ps`; Log: `logs/db-backup.log` |
| Falsche DB gesichert | `backup-databases.json` prüfen, nur registrierte Container |

## Verwandt

- `backup-system.md` — Restic + Cron
