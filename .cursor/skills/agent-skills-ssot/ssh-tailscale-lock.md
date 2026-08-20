# Skill: SSH hinter Tailscale

> Port 22 nur im Tailnet — SSH nicht öffentlich.

## Trigger

- „SSH absichern“, „nur Tailscale“, nach Tailscale-Setup

## Voraussetzungen

- Tailscale auf VPS aktiv
- SSH-Zugang aktuell funktioniert

## Schritte

```bash
ssh jjl@jjl-server-prod-01.tailbbda14.ts.net
bash /opt/_server/production/repos/Server/scripts/lock-ssh-tailscale.sh
```

Danach: SSH nur noch über Tailscale-Hostname/IP.

## Erfolgskriterium

Öffentliche IP: Port 22 zu. Tailnet: SSH funktioniert.

## Rollback

| Problem | Lösung |
|---------|--------|
| Ausgesperrt (Tailscale down) | Hetzner-Web-Konsole → Tailscale wiederherstellen, dann SSH |
| Port 22 öffentlich wieder nötig | UFW-Regel manuell anpassen (nur in Notfall; Security-Risiko) |

## Verwandt

- `tailscale-authkey.md` — VPS muss im Tailnet bleiben
