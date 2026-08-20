# Skill: SSL / HTTPS Troubleshooting (Caddy)

> 🤖 AI-assisted — HTTPS-Fehler für `*.lauer.team` debuggen. Caddy = einziger Einstieg von außen.

## Trigger

- Browser: Zertifikatswarnung, `NET::ERR_CERT_*`, „Verbindung nicht privat“
- `curl` schlägt bei HTTPS fehl
- Neue Domain / Caddy-Snippet — Zertifikat kommt nicht
- Nach Änderung an `sites.d/*.caddy` oder `.env`

## Voraussetzungen

- SSH auf den betroffenen Host (Hetzner = dieser Cursor-Host · Netcup = Production; nicht denselben Tailscale-Namen als „prod“ für beide verwenden)
- Server-Stack: `/opt/_server/production/repos/Server/`
- Secrets in `/opt/_server/production/.env` (nie in Git)

## Schritte

### 1. Symptom eingrenzen

| Symptom | Wahrscheinliche Ursache |
|---------|-------------------------|
| Nur **ohne** Tailscale | Normal bei Tailnet-only-Domains — Tailscale muss an sein |
| `connection refused` | Caddy down oder falscher DNS-IP |
| `certificate invalid` / abgelaufen | ACME-Renewal fehlgeschlagen |
| `502` / `503` | Caddy ok, **Backend** down (`myui-app-api` etc.) |
| DNS löst nicht auf | Cloudflare A-Record — siehe `tailnet-lauer-domains.md` |

```bash
curl -svI https://myui.lauer.team/api/health 2>&1 | head -30
dig +short myui.lauer.team @1.1.1.1
```

### 2. Caddy-Container & Config

```bash
cd /opt/_server/production/repos/Server
docker compose ps
docker compose logs caddy --tail 80
docker compose exec -T caddy caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile
```

**Caddyfile-Kette:** `caddy/Caddyfile` → `sites.d/*.caddy` + `tailnet.Caddyfile`

SSOT Hetzner: `caddy/sites.d/private/myui.caddy` — TLS via **Cloudflare DNS-01**:

```caddy
tls {
    dns cloudflare {env.CLOUDFLARE_API_TOKEN}
}
```

### 3. Cloudflare-Token prüfen

In `/opt/_server/production/.env`:

- `CLOUDFLARE_API_TOKEN` gesetzt und gültig
- Token braucht **Zone:DNS:Edit** für `lauer.team`

Nach Token-Änderung:

```bash
cd /opt/_server/production/repos/Server
docker compose up -d caddy
```

### 4. DNS (Cloudflare)

Für Tailnet-Domains (`myui.lauer.team`):

| Check | Erwartung |
|-------|-----------|
| A-Record `myui` | Tailscale-IP des VPS (`tailscale ip -4`) |
| Proxy | **Aus** (graue Wolke) |
| Kein CNAME auf öffentliche VPS-IP | Nur `100.x.x.x` |

Details: `tailnet-lauer-domains.md` · `domain-cloudflare.md`

### 5. Zertifikat erneuern / ACME-Daten

ACME-State liegt in `data/files/caddy-data/` (Volume-Mount).

```bash
cd /opt/_server/production/repos/Server
docker compose restart caddy
docker compose logs caddy --tail 50 | grep -iE 'certificate|acme|tls|error'
```

Bei hartnäckigem Fehler (selten): betroffene ACME-Datei in `caddy-data` sichern und Caddy neu starten lassen (erneute Ausstellung).

Custom-Zertifikate (Tailscale-Host): `data/files/caddy-certs/` (`tailscale.crt`, `tailscale.key`).

### 6. Backend vs. TLS trennen

TLS ok, aber App antwortet nicht:

```bash
docker ps | grep myui
curl -s http://127.0.0.1:8820/api/health
cd /opt/Azubuilder/Apps/myUIApp/development/repos/myUI-app-api && docker compose --env-file ../../.env up -d
```

### 7. Nach Snippet-Änderung deployen

```bash
cd /opt/_server/production/repos/Server
# sites.d/<projekt>.caddy bearbeitet
docker compose restart caddy
curl -s https://myui.lauer.team/api/health
```

Siehe auch `vps-deploy.md`.

## Erfolgskriterium

- `docker compose exec -T caddy caddy validate …` → exit 0
- `curl -s https://myui.lauer.team/api/health` → ok (mit Tailscale an)
- Caddy-Logs ohne wiederholte ACME-Fehler
- Browser zeigt gültiges Zertifikat für die Domain

## Rollback

| Problem | Lösung |
|---------|--------|
| Kaputtes Caddy-Snippet | Letzte Version aus Git: `git checkout -- caddy/sites.d/` → `docker compose restart caddy` |
| Token ungültig | Neuen Token in Cloudflare, `.env` aktualisieren, Caddy neu starten |
| Falsche DNS | A-Record korrigieren, 1–5 Min warten, erneut testen |
| Gesamter Stack kaputt | `post-reboot-check.sh` · ggf. Hetzner-Snapshot — siehe `incident-response.md` |

## Verwandt

- `domain-cloudflare.md` · `tailnet-lauer-domains.md` · `vps-deploy.md`
- `_server/production/repos/Server/docs/PROGRAMME.md` — Caddy-Architektur
