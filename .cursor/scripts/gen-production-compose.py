#!/usr/bin/env python3
"""Copy Hetzner staging compose → production compose (paths + no host ports)."""
from __future__ import annotations

from pathlib import Path

import yaml

ROOT = Path("/opt/Azubuilder")
PROJECTS = [
    "Apps/myAgentsApp",
    "Apps/myDisplayApp",
    "Apps/myDownloadsApp",
    "Apps/myGunsApp",
    "Apps/myUIApp",
    "Apps/myWidgetsApp",
    "Apps/tempui",
    "Domains/myAgentsDomain",
    "Domains/myBrainDomain",
    "Domains/myDownloadsDomain",
    "Domains/myGunsDomain",
    "Domains/myOpsDomain",
    "Domains/myProjectsDomain",
    "Domains/myRoutinesDomain",
    "Domains/myUserDomain",
]

HEADER = """# Image-only production — GHCR (kein Source-Tree). Netcup only.
# Tag = Git-SHA aus .env (*_IMAGE_TAG).
# Start: docker compose --env-file .env pull && docker compose --env-file .env up -d --no-build
# Host-ports stripped: Caddy uses Docker DNS on lauer_web; myOS stays up during strangler.
"""


def rewrite_str(s: str) -> str:
    return s.replace("/staging", "/production").replace("staging", "production")


def strip_ports(svc: dict) -> dict:
    svc = dict(svc)
    svc.pop("ports", None)
    env = svc.get("environment")
    if isinstance(env, dict):
        for k, val in list(env.items()):
            if isinstance(val, str):
                env[k] = rewrite_str(val)
    vols = svc.get("volumes")
    if isinstance(vols, list):
        new = []
        for v in vols:
            if isinstance(v, str):
                new.append(rewrite_str(v))
            elif isinstance(v, dict):
                nv = dict(v)
                for key in ("source", "src", "target"):
                    if key in nv and isinstance(nv[key], str):
                        nv[key] = rewrite_str(nv[key])
                new.append(nv)
            else:
                new.append(v)
        svc["volumes"] = new
    return svc


def quoted_str(dumper, data: str):
    if any(ch in data for ch in "${}?:") or data in ("no", "yes", "true", "false"):
        return dumper.represent_scalar("tag:yaml.org,2002:str", data, style='"')
    return dumper.represent_scalar("tag:yaml.org,2002:str", data)


yaml.SafeDumper.add_representer(str, quoted_str)


def main() -> None:
    out_root = Path("/tmp/lt-prod-compose")
    for rel in PROJECTS:
        src = ROOT / rel / "staging" / "docker-compose.yml"
        data = yaml.safe_load(src.read_text())
        name = str(data.get("name") or rel.split("/")[-1].lower() + "-staging")
        data["name"] = name.replace("-staging", "-production").replace("staging", "production")
        services = data.get("services") or {}
        data["services"] = {n: strip_ports(svc) for n, svc in services.items()}
        dest_dir = out_root / rel / "production"
        dest_dir.mkdir(parents=True, exist_ok=True)
        dumped = yaml.safe_dump(
            data,
            sort_keys=False,
            default_flow_style=False,
            allow_unicode=True,
            width=1000,
        )
        (dest_dir / "docker-compose.yml").write_text(HEADER + dumped)
        print(f"wrote {rel}/production/docker-compose.yml")


if __name__ == "__main__":
    main()
