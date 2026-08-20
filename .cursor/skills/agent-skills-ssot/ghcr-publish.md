# Skill: GHCR publishen (SHA-Tags)

> SSOT der Regel: ADR `.cursor/brain/adr/0009-ghcr-sha-images.md` · `principles.md` §3.5

## Trigger

| Situation | Dann |
|-----------|------|
| Image publishen / nach GHCR bringen | dieser Skill |
| CI für App-/Domain-Image | liegt in jedem Image-Repo: `.github/workflows/ghcr.yml` |
| Netcup kann nicht pullen | Auth + Tag in Host-`.env` prüfen |

## Name-Schema

`ghcr.io/azubuilder/<repo-lowercase>:${GIT_SHA}` — `<repo>` = GitHub-Repo (`myUI-app-api` → `myui-app-api`, `temp-ui-web` bleibt `temp-ui-web`).

| Verboten | Erlaubt |
|----------|---------|
| `:latest`, `:local`, `lauer-*` ohne Registry | SHA-Tag in `*_IMAGE_TAG`; Basis `postgres:16`, `nginx:1.27-alpine` |

## Dev lokal (Hetzner `development/`)

```bash
SHA=$(git rev-parse HEAD)
# im Repo, Compose mit image: ghcr.io/azubuilder/<repo>:${FOO_IMAGE_TAG:?…}
FOO_IMAGE_TAG=$SHA docker compose --env-file ../../.env up -d --build
# optional Registry:
docker push ghcr.io/azubuilder/<repo>:$SHA
```

## CI (liegt in jedem Image-Repo)

`.github/workflows/ghcr.yml` — Push auf `main`/`master` (oder `workflow_dispatch`) pusht `ghcr.io/azubuilder/<repo-lowercase>:${{ github.sha }}`. `permissions.packages: write` ist Pflicht.

## Staging / Production

Tag nur in Host-`.env` (`FOO_IMAGE_TAG=<sha>`). Dann:

```bash
docker compose --env-file .env pull
docker compose --env-file .env up -d --no-build
```

## Auth Netcup (read)

Token in **Host-`.env`**, nie in Git:

```bash
echo "$GHCR_TOKEN" | docker login ghcr.io -u USER --password-stdin
```

## Erfolgskriterium

`docker compose pull` holt `ghcr.io/azubuilder/<repo>:<sha>`; Container starten ohne `--build`.

## Rollback

Vorherigen SHA in `.env` setzen, erneut `pull && up -d --no-build`.
