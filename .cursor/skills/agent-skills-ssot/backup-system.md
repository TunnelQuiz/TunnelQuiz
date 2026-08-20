# Skill: VPS-Backup-System

> 🤖 AI-assisted — Vier-Ebenen-Backup für `/opt/`. Doku: `_server/production/repos/Server/docs/BACKUP.md`

## Trigger

- User: „Backup einrichten“, „Backup prüfen“, „Restic“, „/opt sichern“, „Was hat sich geändert?“
- Vor größeren Migrationen oder Server-Updates
- Nach Einrichtung neuer Postgres-Instanz

## Voraussetzungen

- SSH auf den betroffenen Host (Hetzner = dieser Cursor-Host · Netcup = Production)
- Einmalig: `bash _server/production/repos/Server/scripts/backup/install-backup-cron.sh`

## Die vier Ebenen (Kurz)

1. **Code** → GitHub (`git push`)
2. **DB** → `pg_dump` nach `/opt/_backups/db-dumps/`
3. **/opt/** → Restic nach `/opt/_backups/restic-repo/`
4. **Offsite** → Hetzner VPS-Snapshots + iCloud (`setup-icloud-offsite.sh`)

**iCloud:** rclone auf dem Mac einrichten (normales Apple-Passwort + 2FA), Config auf VPS kopieren. Trust-Token ~30 Tage → `BACKUP.md` + `todos/vps-icloud-trust-token-refresh.md`

## Skripte (SSOT)

| Skript | Aufgabe |
|--------|---------|
| `install-backup-cron.sh` | Einmal-Setup + Cron 02:30 |
| `run-nightly-backup.sh` | DB + Restic |
| `backup-databases.sh` | Alle DBs aus `config/backup-databases.json` |
| `backup-opt-restic.sh` | Restic-Snapshot + Retention + Offsite-Copy |
| `setup-icloud-offsite.sh` | Einmalig: rclone iCloud + Restic-Offsite |

Pfad: `/opt/_server/production/repos/Server/scripts/backup/`

## Manuell

```bash
bash /opt/_server/production/repos/Server/scripts/backup/run-nightly-backup.sh
source /opt/_backups/.restic-env && restic snapshots
```

## Neue DB

Eintrag in `config/backup-databases.json` — nur wenn Container läuft.

## Restore

- **Datei:** `restic restore <id> --target /tmp/r --include /pfad/zur/datei`
- **DB:** Dump aus `db-dumps/` → `psql` (siehe `_server/production/repos/Server/docs/BACKUP.md`)

## Erfolgskriterium

- `db-dumps/myprojects-<datum>.sql.gz` (bzw. registriertes Prefix) vorhanden
- `restic snapshots` zeigt aktuelles `nightly`-Snapshot
- `logs/nightly.log` ohne Fehler

## Rollback

| Problem | Lösung |
|---------|--------|
| Datei wiederherstellen | `restic restore <snapshot-id> --target /tmp/r --include /pfad` |
| DB wiederherstellen | Dump aus `db-dumps/` — siehe `backup-postgres.md` |
| Backup läuft nicht | `crontab -l`; `logs/nightly.log`; `install-backup-cron.sh` erneut |

## Verwandt

- `backup-postgres.md` — DB-Kurzreferenz
- `vps-provider-migration.md` — Server-Umzug
- `_server/production/repos/Server/docs/BACKUP.md` — vollständige Doku
