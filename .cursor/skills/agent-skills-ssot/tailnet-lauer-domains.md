# Skill: Tailnet-URLs (Hetzner)

> Nur im Tailnet erreichbar; schöne Namen statt langer `*.ts.net`-URLs. Hostnamen: ADR `brain/adr/0002-nomenklatur-ohne-myos.md`.

## Trigger

- `myui.lauer.team` (oder andere Hetzner-Kurz-Hosts) lässt sich nicht auflösen oder nicht erreichen
- Neue Tailnet-Domain einrichten (DNS + Caddy)
- Split-DNS für `*.lauer.team` konfigurieren

## Voraussetzungen

- Tailscale auf VPS aktiv (`tailscale ip -4`)
- Cloudflare-Zugang für `lauer.team`
- Caddy unter `/opt/_server/production/repos/Server/`

## Schritte

### 1. Verstehen (Kurz)

Ein **Tailnet-Client** fragt „Wohin zeigt myui.lauer.team?“ — Cloudflare antwortet mit der **Tailscale-IP** des VPS (`100.x.x.x`). Nur Geräte **mit laufendem Tailscale** erreichen diese IP. **Caddy** liefert HTTPS.

**Hetzner-Arbeit vs. Netcup-Live:** dieser Host dient `development`/`staging`. Hetzner-Nomenklatur gilt; Netcup übernimmt dieselben Namen im Production-Cutover (ADR 0002).

### 2. DNS-Einträge (Cloudflare, Hetzner)

| Typ | Name | Inhalt | Proxy |
|-----|------|--------|-------|
| **A** | **`myui`** | Tailscale-IP (`tailscale ip -4` auf **diesem** VPS) | Aus (grau) |
| A | `myagents` · `mywidgets` · `mydisplay` · `mydownloads` · `myguns` | dieselbe IP | Aus (grau) |

Kein CNAME — nur A-Records auf die Tailscale-IP.

| Domain | Rolle |
|--------|--------|
| **`myui.lauer.team`** | Cockpit (myUI-app-web + myUI-app-api) |
| `myagents.lauer.team` | myAgents-app-api |
| `mywidgets.lauer.team` | myWidgets-app-api |
| `mydisplay.lauer.team` | myDisplay |
| `mydownloads.lauer.team` | myDownloads |
| `myguns.lauer.team` | myGuns-app-web |

### 3. Split DNS (empfohlen)

```bash
bash /opt/_server/production/repos/Server/scripts/setup-lauer-team-split-dns.sh
```

### 4. Testen (Tailscale **an**)

```bash
dig +short myui.lauer.team @1.1.1.1
curl -s https://myui.lauer.team/api/health
```

### 5. Client-DNS-Troubleshooting

```bash
dig +short myui.lauer.team @1.1.1.1
```

**macOS (optionaler Client):** DNS-Cache leeren:

```bash
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

**HTTPS ohne lokales DNS testen:**

```bash
curl -sk --resolve myui.lauer.team:443:$(tailscale ip -4) https://myui.lauer.team/api/health
```

## Erfolgskriterium

- `dig +short myui.lauer.team @1.1.1.1` → `100.x.x.x`
- `https://myui.lauer.team/api/health` → ok (mit Tailscale an)

## Rollback

| Problem | Lösung |
|---------|--------|
| Falsche DNS-IP | A-Record in Cloudflare auf aktuelle `tailscale ip -4` korrigieren |
| Caddy antwortet nicht | `docker compose restart caddy` im Server-Stack |
| Split-DNS kaputt | Skript erneut ausführen oder manuell in Tailscale-Admin prüfen |

## Verwandte Dateien

| Datei | Rolle |
|-------|--------|
| `/opt/_server/production/repos/Server/caddy/sites.d/private/myui.caddy` | Caddy für `myui.lauer.team` |
| `domain-cloudflare.md` | Allgemeine DNS-Schritte |
