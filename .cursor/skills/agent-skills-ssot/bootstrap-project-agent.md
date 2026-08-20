# Skill: Neues Projekt — Agent-Anbindung

> Symlinks `agent-*-symlink` → SSOT `agent-*-ssot`. Mechanik: `brain/index-agents.md`.

## Trigger

- Neues Projekt unter `/opt/` soll Agent-Rules, Skills, Hooks und MCP nutzen
- User: „Projekt an Agent-SSOT anbinden“, „Symlinks installieren“

## Voraussetzungen

- Projektordner existiert, z. B. `/opt/Azubuilder/Apps/NeuesProjekt/` oder `/opt/Azubuilder/Domains/…`
- Skript: `/opt/Azubuilder/.cursor/scripts/install-project-agent-link.sh`

## Schritte

```bash
bash /opt/Azubuilder/.cursor/scripts/install-project-agent-link.sh \
  /opt/Azubuilder/Apps/NeuesProjekt "NeuesProjekt" "Kurzbeschreibung"
# bzw. /opt/Azubuilder/Domains/…
```

Erzeugt nur Symlinks:

| Symlink im Projekt | Ziel (SSOT) |
|--------------------|-------------|
| `.cursor/rules/agent-rules-symlink` | `/opt/Azubuilder/.cursor/rules/agent-rules-ssot/` |
| `.cursor/skills/agent-skills-symlink` | `/opt/Azubuilder/.cursor/skills/agent-skills-ssot/` |
| `.cursor/hooks/agent-hooks-symlink` | `/opt/Azubuilder/.cursor/hooks/agent-hooks-ssot/` |
| `.cursor/mcp/agent-mcp-symlink` | `/opt/Azubuilder/.cursor/mcp/agent-mcp-ssot/` |

Turn-Logging (VPS-Cron): `scripts/turn-log/` — nicht in `hooks/agent-hooks-ssot/`.

**Keine `AGENTS.md`.**

### Projekt-eigenes (optional)

Neben jedem `*-symlink` z. B. `.cursor/rules/kiezquiz-layout.mdc`.

Projekt-eigene `.cursor/hooks.json` nur bei Bedarf (nicht für Agent Turn-Logging).

### Verifizieren

```bash
bash /opt/Azubuilder/.cursor/scripts/cursor-ssot-verify.sh
```

## Erfolgskriterium

- Alle vier `agent-*-symlink` im Projekt zeigen auf SSOT
- Neuer Cursor-Chat im Projekt-Workspace lädt Rules/Skills

## Rollback

Symlinks im Projekt löschen — SSOT bleibt unberührt:

```bash
rm -rf /opt/Azubuilder/Apps/NeuesProjekt/.cursor/rules/agent-rules-symlink \
       /opt/Azubuilder/Apps/NeuesProjekt/.cursor/skills/agent-skills-symlink \
       /opt/Azubuilder/Apps/NeuesProjekt/.cursor/hooks/agent-hooks-symlink \
       /opt/Azubuilder/Apps/NeuesProjekt/.cursor/mcp/agent-mcp-symlink
```

## Verwandt

- `brain/index-agents.md`
