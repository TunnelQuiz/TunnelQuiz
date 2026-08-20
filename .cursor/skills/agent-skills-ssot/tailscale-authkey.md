# Skill: Tailscale Auth-Key (VPS + Pi, dauerhaft)

> Auth-Key statt Browser; Geräte melden sich selbst an, auch nach Reboot.

## Trigger

- VPS oder Pi soll **ohne Browser** in Tailscale bleiben
- Nach SSH-Lock: VPS **muss** im Tailnet sein (Port 22 nur auf `tailscale0`)
- Key-Renewal (Ablauf ~90 Tage)

## Voraussetzungen

- Zugang zur Tailscale-Admin-Konsole
- SSH auf den **betroffenen** Host (Hetzner = dieser Cursor-Host · Netcup = Production) oder Web-Konsole als Notfall
- Secrets **nicht** in Git

## Schritte

### 1. Key in Tailscale-Admin erzeugen

https://login.tailscale.com/admin/settings/keys → **Generate auth key**

| Option | VPS | Pi |
|--------|-----|-----|
| Reusable | aus (Einmal) | aus (Einmal) |
| Ephemeral | **aus** | **aus** |
| Pre-approved | **an** | **an** |
| Ablauf | max 90 Tage | gleich |

### 2. VPS

Key in `/opt/_server/production/.secrets/tailscale.env` speichern (je Host eigene Datei).

```bash
# auf dem betroffenen Host
bash /opt/_server/production/repos/Server/scripts/ensure-tailscale-up.sh
tailscale ip -4
```

Live via `ensure-tailscale-up.sh` + `tailscale-ensure.service`.

### 3. Pi-top

Key in `/opt/Azubuilder/Apps/myDisplayApp/staging/…/pi.env` (Pfad je Display-Layout).

```bash
./Display/scripts/pi-tailscale-ssh.sh 'tailscale ip -4'
```

### 4. Erinnerung setzen

Key-Ablauf als Todo (~80 Tage vor Ablauf):

- BFF: `https://myui.lauer.team/api/reminders`
- oder direkt myProjects-domain-api (`:8810`)

Kein `myos.reminders`. Routine-Knoten ggf. unter myRoutinesDomain `data/files/routinen/` (Hetzner Dummy · Live Netcup).

### 5. Verifikation

```bash
tailscale status | head -5
```

## Erfolgskriterium

- `tailscale ip -4` liefert `100.x.x.x` auf VPS (und Pi)
- `tailscale status` zeigt Gerät als connected
- SSH über Tailnet-Hostname des **richtigen** Hosts funktioniert

## Rollback

| Problem | Lösung |
|---------|--------|
| VPS aus Tailnet | Web-Konsole **dieses** Hosts → `bash …/ensure-tailscale-up.sh` mit gültigem Key |
| Falscher Key in `.env` | Vorherigen Key aus Backup/Admin neu generieren und Skript erneut ausführen |
| Pi offline | Key in `pi.env` prüfen, Pi neu booten |

## Dateien

| Ort | Datei | Git? |
|-----|-------|------|
| VPS | `/opt/_server/production/.secrets/tailscale.env` | **Nein** |
| Pi | `/opt/Azubuilder/Apps/myDisplayApp/staging/…/pi.env` | **Nein** |
| Erinnerungen | myProjects-Todos via myUI BFF / myProjects-domain-api | — |
| Skript | `/opt/_server/production/repos/Server/scripts/ensure-tailscale-up.sh` | Ja |

## Verwandt

- `ssh-tailscale-lock.md` · `tailnet-lauer-domains.md` · `cockpit-todos.md`
