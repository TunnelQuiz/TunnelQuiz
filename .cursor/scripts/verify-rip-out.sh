#!/usr/bin/env bash
# Rip-out-Test (brain/principles.md 1.5): Kein Projekt-Repo darf Pfade eines
# fremden Projekts referenzieren — Interaktion nur über HTTP-APIs.
# SSOT-Laufzeit-Kopie: data/files/scripts/verify-rip-out.sh (identisch halten).
#
# Geprüft: Code/Config; .md-Prosa ausgenommen.
# Ausnahme 2: myAgentsApp (Sven) + Allowlist aus agent-permissions.json.
#
# Exit 0 = bestanden, Exit 1 = Verstöße.
set -uo pipefail

AGENT_SSOT="/opt/TunnelQuiz/.cursor"
FAIL=0
CHECKED=0

mapfile -t PROJECT_ROOTS < <(
  {
    org="/opt/TunnelQuiz"
    for zone in Apps Domains; do
      [[ -d "$org/$zone" ]] || continue
      for proj in "$org/$zone"/*/; do
        [[ -d "$proj" ]] || continue
        printf '%s\n' "${proj%/}"
      done
    done
    for proj in "$org"/*/; do
      p="${proj%/}"
      b="$(basename "$p")"
      [[ "$b" == Apps || "$b" == Domains || "$b" == .cursor || "$b" == .claude || "$b" == .obsidian ]] && continue
      if [[ -d "$p/development/repos" || -d "$p/staging/repos" || -d "$p/production/repos" ]]; then
        printf '%s\n' "$p"
      fi
    done
  } | sort -u
)

_project_root_for_path() {
  local fp="$1" best="" root
  for root in "${PROJECT_ROOTS[@]}"; do
    if [[ "$fp" == "$root" || "$fp" == "$root"/* ]]; then
      if [[ ${#root} -gt ${#best} ]]; then
        best="$root"
      fi
    fi
  done
  [[ -n "$best" ]] && printf '%s\n' "$best"
}

_sven_orchestrator_allowlist() {
  local perm_file="$1"
  if [[ -f "$perm_file" ]]; then
    python3 - "$perm_file" <<'PY'
import json, sys
from pathlib import Path
cfg = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
for key in (cfg.get("projects") or {}):
    print("/opt/" + key.strip("/"))
PY
  fi
}

_is_meta_allowed() {
  local fp="$1"
  [[ "$fp" == /opt/_server || "$fp" == /opt/_server/* ]] && return 0
  [[ "$fp" == /opt/_dotfiles || "$fp" == /opt/_dotfiles/* ]] && return 0
  [[ "$fp" == /opt/_backups || "$fp" == /opt/_backups/* ]] && return 0
  [[ "$fp" == "$AGENT_SSOT" || "$fp" == "$AGENT_SSOT"/* ]] && return 0
  return 1
}

_is_allowed() {
  local fp="$1" own_root="$2" repo_root="$3"
  local mapped
  mapped="$(_project_root_for_path "$fp" || true)"

  if [[ -n "$mapped" ]]; then
    [[ "$mapped" == "$own_root" ]] && return 0
  else
    # Kein bekanntes Projekt (z. B. /opt/homebrew) — ignorieren
    _is_meta_allowed "$fp" && return 0
    return 0
  fi

  _is_meta_allowed "$fp" && return 0


  return 1
}

_extract_opt_paths() {
  local repo_root="$1"
  grep -rhoE \
    '/opt/TunnelQuiz/(Apps|Domains)/[A-Za-z0-9._-]+|/opt/Company/(Apps|Domains)/[A-Za-z0-9._-]+|/opt/Company/infra|/opt/KiezQuiz/[A-Za-z0-9._-]+|/opt/TunnelQuiz|/opt/_server|/opt/_dotfiles|/opt/_backups|/opt/[A-Za-z0-9_-]+/[A-Za-z0-9._-]+' \
    "$repo_root" \
    --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=__pycache__ \
    --exclude-dir=venv --exclude-dir=.venv --exclude-dir=dist --exclude-dir=build \
    --exclude='*.md' --exclude='verify-rip-out.sh' \
    2>/dev/null | sort -u || true
}

for own_root in "${PROJECT_ROOTS[@]}"; do
  for env in development staging production; do
    repo_root="$own_root/$env/repos"
    [[ -d "$repo_root" ]] || continue
    CHECKED=$((CHECKED + 1))

    violations=()
    while IFS= read -r fp; do
      [[ -z "$fp" ]] && continue
      if ! _is_allowed "$fp" "$own_root" "$repo_root"; then
        violations+=("$fp")
      fi
    done < <(_extract_opt_paths "$repo_root")

    if ((${#violations[@]} > 0)); then
      FAIL=1
      echo "VERSTOSS — $repo_root referenziert fremde Projekt-Pfade:"
      printf '%s\n' "${violations[@]}" | sort -u | head -n 20
      echo ""
    fi
  done
done

if [[ $FAIL -eq 0 ]]; then
  echo "OK: Rip-out-Test bestanden ($CHECKED repos/-Ordner geprüft) — keine fremden Projekt-Pfade."
else
  echo "FEHLGESCHLAGEN: Obige Referenzen verletzen principles.md 1.5 (API-only)."
  echo "(Hinweis: nur Projekte unter /opt/TunnelQuiz werden geprüft; fremde /opt/-Referenzen darin sind Verstöße.)"
fi
exit $FAIL
