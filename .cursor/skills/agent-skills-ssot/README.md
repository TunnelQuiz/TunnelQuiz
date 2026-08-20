# Skills — zentraler SSOT-Ordner (Agent)

> **Ein Ort, alle KI-Tools.** Inhalt in `agent-skills-ssot/` — Projekte: `.cursor/skills/agent-skills-symlink` (via `install.sh`).

## Zwei Skill-Typen

| Typ | Form | Beispiel | Wie Cursor es findet |
|-----|------|----------|----------------------|
| **Leicht** | eine `.md`-Datei | `backup-postgres.md` | SSOT-Rules + `brain/index-skills.md` |
| **Paket** | Ordner mit `SKILL.md` + Skripten | `ui-ux-pro-max/` | `.cursor/skills/agent-skills-symlink/` |

## Pfad (SSOT)

```
/opt/Azubuilder/.cursor/skills/agent-skills-ssot/
```

Index aller Skills: `../../brain/index-skills.md`

## Cursor-Anbindung

```
/opt/Azubuilder/.cursor/skills/agent-skills-ssot/     ← echter Inhalt (-ssot)
Projekt/.cursor/skills/agent-skills-symlink          →  derselbe SSOT-Ordner
```

Neuer Paket-Skill: Ordner nach `agent-skills-ssot/<name>/` legen — kein extra Symlink nötig.

## Neuen Skill hinzufügen

Vollständiger Workflow: **`create-skill.md`** in diesem Ordner.

Kurz Paket-Skill:

1. Skill-Ordner nach `agent-skills-ssot/<name>/` legen (mit `SKILL.md`)
2. Eintrag in `../../brain/index-skills.md`
3. Fertig — sichtbar via `agent-skills-symlink`-Kette

**Nicht** `uipro init --ai all` — das legt Kopien in viele Tool-Ordner.

## Paket-Skill aktivieren / deaktivieren

| Aktion | So geht's |
|--------|-----------|
| **Deaktivieren** | Ordner nach `_archive/` verschieben oder `disable-model-invocation: true` in `SKILL.md` |
| **Reaktivieren** | Ordner zurück nach `agent-skills-ssot/<name>/` |

## Obsidian Skills updaten (kepano)

Quelle: https://github.com/kepano/obsidian-skills

```bash
cd /tmp && rm -rf obsidian-skills
git clone --depth 1 https://github.com/kepano/obsidian-skills.git
SSOT=/opt/Azubuilder/.cursor/skills/agent-skills-ssot
for skill in defuddle json-canvas obsidian-bases obsidian-cli obsidian-markdown; do
  cp -a obsidian-skills/skills/$skill/* "$SSOT/$skill/"
done
```

Voraussetzung für `obsidian-cli`: Obsidian **1.12+** lokal, CLI in Settings aktivieren.

## shadcn/ui Skill updaten

Quelle: https://github.com/shadcn-ui/ui/tree/main/skills/shadcn · Doku: https://ui.shadcn.com/docs/skills

```bash
cd /tmp && rm -rf shadcn-ui-skill
git clone --depth 1 --filter=blob:none --sparse https://github.com/shadcn-ui/ui.git shadcn-ui-skill
cd shadcn-ui-skill && git sparse-checkout set skills/shadcn
cp -a skills/shadcn/* /opt/Azubuilder/.cursor/skills/agent-skills-ssot/shadcn/
```

Alternativ (mit Node/npm): `npx skills add shadcn/ui` im Projektroot.

## frontend-design Skill updaten (Anthropic)

Quelle: https://github.com/anthropics/claude-code · Registry: https://explainx.ai/skills/anthropics/claude-code/frontend-design

```bash
cd /tmp && rm -rf claude-code-skill-src
git clone --depth 1 https://github.com/anthropics/claude-code.git claude-code-skill-src
cp claude-code-skill-src/plugins/frontend-design/skills/frontend-design/SKILL.md \
  /opt/Azubuilder/.cursor/skills/agent-skills-ssot/frontend-design/
```

## stop-slop Skill updaten (Hardik Pandya)

Quelle: https://github.com/hardikpandya/stop-slop

```bash
cd /tmp && rm -rf stop-slop
git clone --depth 1 https://github.com/hardikpandya/stop-slop.git
cp -a stop-slop/SKILL.md stop-slop/references stop-slop/LICENSE \
  /opt/Azubuilder/.cursor/skills/agent-skills-ssot/stop-slop/
```

## UI UX Pro Max updaten

Quelle: https://github.com/nextlevelbuilder/ui-ux-pro-max-skill

```bash
cd /tmp && rm -rf ui-ux-pro-max-skill
git clone --depth 1 https://github.com/nextlevelbuilder/ui-ux-pro-max-skill.git
cp -a ui-ux-pro-max-skill/.claude/skills/ui-ux-pro-max/* \
  /opt/Azubuilder/.cursor/skills/agent-skills-ssot/ui-ux-pro-max/
```

## Design-System-Skript (UI UX Pro Max)

```bash
python3 /opt/Azubuilder/.cursor/skills/agent-skills-ssot/ui-ux-pro-max/scripts/search.py \
  "SaaS dashboard" --design-system -p "MeinProjekt"
```
