#!/usr/bin/env python3
"""Generate image-only staging docker-compose.yml from development repo compose files."""
from __future__ import annotations

import re
from pathlib import Path

import yaml

ROOT = Path("/opt/Azubuilder")

# GitHub-Repos (exakt) → GHCR-Name = lowercase.
GITHUB_REPOS = (
    "myAgents-app-api",
    "myDisplay-app-api",
    "myDisplay-app-web",
    "myDownloads-app-api",
    "myDownloads-app-web",
    "myGuns-app-api",
    "myGuns-app-web",
    "myUI-app-api",
    "myUI-app-web",
    "myWidgets-app-api",
    "temp-ui-web",
    "myAgents-domain-api",
    "myBrain-domain-api",
    "myDownloads-domain-api",
    "myGuns-domain-api",
    "myOps-domain-api",
    "myProjects-domain-api",
    "myRoutines-domain-api",
    "myUser-domain-api",
)

GHCR_REPOS = {r.lower(): r.lower() for r in GITHUB_REPOS}

# Compose-Lokalname → GHCR-Repo (nur Abweichungen vom lowercase-Strip).
LOCAL_TO_GHCR = {
    "tempui-web": "temp-ui-web",
}

FOREIGN_IMAGE_PREFIXES = ("postgres:", "nginx:")

PROJECTS: dict[str, list[str]] = {
    "Apps/myAgentsApp": ["myAgents-app-api"],
    "Apps/myDisplayApp": ["myDisplay-app-api", "myDisplay-app-web"],
    "Apps/myDownloadsApp": ["myDownloads-app-api", "myDownloads-app-web"],
    "Apps/myGunsApp": ["myGuns-app-api", "myGuns-app-web"],
    "Apps/myUIApp": ["myUI-app-api", "myUI-app-web"],
    "Apps/myWidgetsApp": ["myWidgets-app-api"],
    "Apps/tempui": ["temp-ui-web"],
    "Domains/myAgentsDomain": ["myAgents-domain-api"],
    "Domains/myBrainDomain": ["myBrain-domain-api"],
    "Domains/myDownloadsDomain": ["myDownloads-domain-api"],
    "Domains/myGunsDomain": ["myGuns-domain-api"],
    "Domains/myOpsDomain": ["myOps-domain-api"],
    "Domains/myProjectsDomain": ["myProjects-domain-api"],
    "Domains/myRoutinesDomain": ["myRoutines-domain-api"],
    "Domains/myUserDomain": ["myUser-domain-api"],
}


def ghcr_image(repo: str, tag_var: str) -> str:
    if repo not in GHCR_REPOS:
        raise SystemExit(f"unknown GHCR repo: {repo}")
    return f"ghcr.io/azubuilder/{repo}:${{{tag_var}:?{tag_var} fehlt}}"


WEB_IMAGES = {
    "mydisplay-app-web": ghcr_image("mydisplay-app-web", "MYDISPLAY_WEB_IMAGE_TAG"),
    "myui-app-web": ghcr_image("myui-app-web", "MYUI_WEB_IMAGE_TAG"),
    "mydownloads-app-web": ghcr_image("mydownloads-app-web", "MYDOWNLOADS_WEB_IMAGE_TAG"),
    "myguns-app-web": ghcr_image("myguns-app-web", "MYGUNS_WEB_IMAGE_TAG"),
    "tempui-web": ghcr_image("temp-ui-web", "TEMPUI_IMAGE_TAG"),
}

_IMAGE_RE = re.compile(
    r"^(?:ghcr\.io/lauerteam/|ghcr\.io/lauer-team/|lauer-)([^:]+):\$\{([A-Z0-9_]+)(?::[-?][^}]*)?\}$"
)
_DEV_ENV_PATH = re.compile(r"(/opt/Azubuilder/(?:Apps|Domains)/[^/]+)/development\b")


def to_staging_host_path(value: str) -> str:
    return _DEV_ENV_PATH.sub(r"\1/staging", value)


def rewrite_image(image: str) -> str:
    if image.startswith(FOREIGN_IMAGE_PREFIXES):
        return image
    m = _IMAGE_RE.match(image)
    if not m:
        raise SystemExit(f"unrecognized app image (need GHCR+SHA): {image}")
    local, tag_var = m.group(1), m.group(2)
    repo = LOCAL_TO_GHCR.get(local, local)
    return ghcr_image(repo, tag_var)

KEEP_SRC_PREFIXES = ("/opt", "/home", "/host", "/")


def rewrite_path(src: str) -> str | None:
    if src.startswith("../../data"):
        return "./data" + src[len("../../data") :]
    if src == "../../.env":
        return "./.env"
    if src.startswith("/opt") or src.startswith("/home") or src in ("/", "/host"):
        return src
    if src.startswith("../myDisplay-app-pi"):
        return "./data/files/pi-scripts"
    return None


def rewrite_volume(item: str | dict) -> str | dict | None:
    if isinstance(item, dict):
        src = str(item.get("source") or item.get("src") or "")
        new = rewrite_path(src)
        if new is None:
            return None
        item = dict(item)
        if "source" in item:
            item["source"] = new
        if "src" in item:
            item["src"] = new
        dest = str(item.get("target") or "")
        if dest:
            item["target"] = to_staging_host_path(dest)
        return item
    parts = item.split(":")
    src = parts[0]
    new = rewrite_path(src)
    if new is None:
        return None
    parts[0] = new
    if len(parts) >= 2:
        parts[1] = to_staging_host_path(parts[1])
    return ":".join(parts)


def transform_service(name: str, svc: dict) -> dict:
    svc = dict(svc)
    svc.pop("build", None)
    if name in WEB_IMAGES:
        svc["image"] = WEB_IMAGES[name]
        svc.pop("volumes", None)
    else:
        if "image" in svc:
            svc["image"] = rewrite_image(str(svc["image"]))
        vols = svc.get("volumes")
        if vols:
            kept = [v for v in (rewrite_volume(x) for x in vols) if v is not None]
            if kept:
                svc["volumes"] = kept
            else:
                svc.pop("volumes", None)
        env_files = svc.get("env_file")
        if isinstance(env_files, str):
            env_files = [env_files]
        if env_files:
            svc["env_file"] = [
                ".env" if f in ("../../.env", "./.env") else f for f in env_files
            ]
        env = svc.get("environment")
        if isinstance(env, dict):
            for k, val in list(env.items()):
                if isinstance(val, str):
                    env[k] = to_staging_host_path(val)
            env.pop("MYAGENTS_APP_CONFIG_FILE", None)
        nets = svc.get("networks")
        if isinstance(nets, dict) and all(v is None for v in nets.values()):
            svc["networks"] = list(nets.keys())
    if name in WEB_IMAGES and "image" in svc and "${" in str(svc["image"]):
        pass
    elif "image" not in svc:
        raise SystemExit(f"service {name} has no image after transform")
    return svc


def load_compose(path: Path) -> dict:
    data = yaml.safe_load(path.read_text()) or {}
    if not isinstance(data, dict):
        raise SystemExit(f"not a mapping: {path}")
    return data


def project_name(rel: str) -> str:
    if rel == "Apps/myAgentsApp":
        return "myagents-app-api"  # already running
    slug = rel.split("/")[-1].lower()
    return f"{slug}-staging"


def quoted_str(dumper, data: str):
    if any(ch in data for ch in "${}?:") or data in ("no", "yes", "true", "false"):
        return dumper.represent_scalar("tag:yaml.org,2002:str", data, style='"')
    return dumper.represent_scalar("tag:yaml.org,2002:str", data)


yaml.SafeDumper.add_representer(str, quoted_str)

HEADER = """# Image-only staging — GHCR (kein Source-Tree).
# Tag = Git-SHA aus .env (*_IMAGE_TAG). On-Demand: nicht parallel zu development (gleiche Ports).
# Start: docker compose --env-file .env pull && docker compose --env-file .env up -d --no-build
"""


def main() -> None:
    for rel, repos in PROJECTS.items():
        services: dict = {}
        networks: dict = {}
        for repo in repos:
            src = ROOT / rel / "development" / "repos" / repo / "docker-compose.yml"
            if not src.is_file():
                raise SystemExit(f"missing {src}")
            data = load_compose(src)
            for n, svc in (data.get("services") or {}).items():
                services[n] = transform_service(n, svc)
            for n, net in (data.get("networks") or {}).items():
                networks[n] = net
        out = {
            "name": project_name(rel),
            "services": services,
        }
        if networks:
            out["networks"] = networks
        dest = ROOT / rel / "staging" / "docker-compose.yml"
        dest.parent.mkdir(parents=True, exist_ok=True)
        dumped = yaml.safe_dump(
            out,
            sort_keys=False,
            default_flow_style=False,
            allow_unicode=True,
            width=1000,
        )
        dest.write_text(HEADER + dumped)
        print(f"wrote {dest.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
