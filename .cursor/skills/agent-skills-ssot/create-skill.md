# Skill: Neuen Skill anlegen (leicht oder Paket)

> 🤖 AI-assisted — SSOT: `skills/agent-skills-ssot/` · Index: `brain/index-skills.md` · Technik: `README.md` (dieser Ordner)

## Trigger

- User: „Neuen Skill anlegen“, „Skill erstellen“, „Paket-Skill installieren“
- Wiederholbare Aufgabe soll festgehalten werden
- Externen Agent-Skill (z. B. von GitHub) ins Agent-SSOT holen

## Voraussetzungen

- Schreibzugriff auf `/opt/Azubuilder/.cursor/skills/agent-skills-ssot/`
- Für **Paket-Skills:** Ordner unter `agent-skills-ssot/<name>/` — sichtbar via `agent-skills-symlink` (siehe `README.md`)
- Index: `brain/index-skills.md` aktualisieren

## Schritt 0 — Welcher Typ?

| Frage | → Typ |
|-------|-------|
| Reicht eine Anleitung in Markdown? | **Leicht** — eine `.md`-Datei |
| Braucht `SKILL.md`, Skripte, Datenbank? | **Paket** — Ordner unter `agent-skills-ssot/<name>/` |

**Merksatz:** Leicht = Text. Paket = Werkzeugkasten.

---

## Workflow A — Leichter Skill

1. **Dateiname:** `agent-skills-ssot/<kebab-case>.md` (z. B. `renew-ssl.md`)
2. **Inhalt** — diese Abschnitte (Pflicht):

   ```markdown
   # Skill: [Name]

   ## Trigger
   Wann gilt dieser Skill?

   ## Voraussetzungen
   - …

   ## Schritte
   1. …

   ## Erfolgskriterium
   Woran erkennt man Erfolg?

   ## Rollback
   Was tun bei Fehler?
   ```

3. **Index:** Zeile in `brain/index-skills.md`
4. **Fertig** — kein Symlink nötig (Zugriff über SSOT-Rules + `brain/index-skills.md`)

---

## Workflow B — Paket-Skill

1. **Ordner:** `agent-skills-ssot/<name>/` mit mindestens `SKILL.md` (YAML-Frontmatter: `name`, `description`)
2. **Zentral installieren** — **nicht** `uipro init --ai all`
   - GitHub: Repo klonen, Inhalt nach `agent-skills-ssot/<name>/` kopieren
   - Details/Update: `README.md` § „UI UX Pro Max updaten“
3. **Fertig** — Cursor findet es über `.cursor/skills/agent-skills-symlink/`
4. **Index:** Zeile in `brain/index-skills.md` → Abschnitt „Paket-Skills“
5. **Optional:** `disable-model-invocation: true` in `SKILL.md`
6. **Test:** `ls -la …/agent-skills-ssot/<name>/SKILL.md` · Cursor-Chat neu öffnen

---

## Workflow C — Paket-Skill deaktivieren

1. Ordner nach `agent-skills-ssot/_archive/<name>/` verschieben **oder** `disable-model-invocation: true` in `SKILL.md`
2. In `index-skills.md` Status auf ⏸ pausiert setzen

---

## Checkliste (Agent)

```
- [ ] Typ gewählt (leicht vs. Paket)
- [ ] Datei/Ordner unter agent-skills-ssot/ angelegt
- [ ] index-skills.md aktualisiert
- [ ] Bei Paket: via agent-skills-symlink erreichbar
- [ ] User informiert: Cursor-Chat neu öffnen bei Paket-Skills
```

## Erfolgskriterium

- Skill liegt unter `skills/agent-skills-ssot/` (SSOT)
- Paket-Skill: erreichbar via `.cursor/skills/agent-skills-symlink`

## Rollback

- Leicht: Datei löschen, Zeile aus `index-skills.md` entfernen
- Paket: optional Ordner nach `agent-skills-ssot/_archive/` verschieben

## Verwandte Dateien

- Technik & Symlinks: `README.md` (dieser Ordner)
- Index: `brain/index-skills.md`
- Navigation: `brain/index-workspace.md`
