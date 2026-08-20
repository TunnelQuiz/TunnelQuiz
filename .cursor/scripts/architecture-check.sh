#!/usr/bin/env bash
# Service-Architektur-Check (brain/principles.md §8).
# Usage:
#   architecture-check.sh <repo-root>
#   architecture-check.sh --all
# Scope: *-domain-api / *-app-api under /opt/TunnelQuiz only
# Exit 0 = bestanden, Exit 1 = Fehler.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ERRORS=0
WARNINGS=0
STRICT_LEGACY=0  # set when routes+logic+db present → src/legacy = fail

fail() { echo "FEHLER: $1" >&2; ERRORS=$((ERRORS + 1)); }
warn() { echo "WARNUNG: $1" >&2; WARNINGS=$((WARNINGS + 1)); }
ok() { echo "OK: $1"; }

check_repo() {
  local ROOT="$1"
  ERRORS=0
  WARNINGS=0
  STRICT_LEGACY=0

  echo "=== $(basename "$ROOT") ==="
  echo "Pfad: $ROOT"

  if [[ ! -d "$ROOT" ]]; then
    fail "Repo-Pfad existiert nicht"
    echo "--- Ergebnis: $ERRORS Fehler, $WARNINGS Warnungen ---"
    return 1
  fi

  # --- §8 Bestand: openapi + Schichten ---
  if [[ -f "$ROOT/openapi.yaml" ]]; then
    ok "openapi.yaml vorhanden"
  else
    fail "openapi.yaml fehlt"
  fi

  local has_routes=0 has_logic=0 has_db=0
  [[ -d "$ROOT/routes" ]] && has_routes=1
  [[ -d "$ROOT/logic" ]] && has_logic=1
  [[ -d "$ROOT/db" ]] && has_db=1

  if [[ $has_routes -eq 1 ]]; then ok "routes/ vorhanden"; else fail "routes/ fehlt"; fi
  if [[ $has_logic -eq 1 ]]; then ok "logic/ vorhanden"; else fail "logic/ fehlt"; fi
  if [[ $has_db -eq 1 ]]; then ok "db/ vorhanden"; else fail "db/ fehlt"; fi

  if [[ $has_routes -eq 1 && $has_logic -eq 1 && $has_db -eq 1 ]]; then
    STRICT_LEGACY=1
  fi

  # --- Einbahnstraße: routes → db verboten ---
  if [[ $has_routes -eq 1 && $has_db -eq 1 ]]; then
    if rg -l --glob '*.py' -e 'from db\b|import db\b|from db\.|import db\.' "$ROOT/routes" 2>/dev/null | grep -q .; then
      fail "routes/ importiert aus db/ (Einbahnstraße verletzt)"
    else
      ok "routes/ importiert nicht aus db/"
    fi
  fi

  # --- Rückwärts: logic → routes verboten ---
  if [[ $has_logic -eq 1 && $has_routes -eq 1 ]]; then
    if rg -l --glob '*.py' -e 'from routes\b|import routes\b|from routes\.|import routes\.' "$ROOT/logic" 2>/dev/null | grep -q .; then
      fail "logic/ importiert aus routes/ (Rückwärts)"
    else
      ok "logic/ importiert nicht aus routes/"
    fi
  fi

  # --- db → routes verboten ---
  if [[ $has_db -eq 1 && $has_routes -eq 1 ]]; then
    if rg -l --glob '*.py' -e 'from routes\b|import routes\b|from routes\.|import routes\.' "$ROOT/db" 2>/dev/null | grep -q .; then
      fail "db/ importiert aus routes/"
    else
      ok "db/ importiert nicht aus routes/"
    fi
  fi

  # --- Cross-Repo-Imports (Heuristik) ---
  if rg --glob '*.py' -e 'from Domains\.|from Apps\.|/opt/(LauerTeam|TunnelQuiz|KiezQuiz|Company)/(Domains|Apps)/' "$ROOT" 2>/dev/null | grep -q .; then
    fail "Python-Imports aus fremden Repo-Pfaden"
  else
    ok "keine offensichtlichen Cross-Repo-Imports"
  fi

  # --- Legacy / src ---
  local legacy_hit=0
  if [[ -d "$ROOT/src" ]]; then
    # leeres src/ oder nur __pycache__ zählt als Restmüll
    if find "$ROOT/src" -type f ! -name '*.pyc' ! -path '*/__pycache__/*' 2>/dev/null | grep -q .; then
      legacy_hit=1
      if [[ $STRICT_LEGACY -eq 1 ]]; then
        fail "src/ noch vorhanden (nach Migration entfernen)"
      else
        warn "src/ noch vorhanden (Migration ausstehend)"
      fi
    fi
  fi
  for leg in myagents_api myagents_lib adapters; do
    if [[ -d "$ROOT/$leg" ]]; then
      legacy_hit=1
      if [[ $STRICT_LEGACY -eq 1 ]]; then
        fail "Legacy-Ordner $leg/ noch vorhanden"
      else
        warn "Legacy-Ordner $leg/ noch vorhanden (Migration ausstehend)"
      fi
    fi
  done
  if [[ $legacy_hit -eq 0 && $STRICT_LEGACY -eq 1 ]]; then
    ok "kein src/Legacy-Bestand"
  fi

  # --- Dockerfile COPY ---
  if [[ -f "$ROOT/Dockerfile" ]]; then
    local df
    df="$(cat "$ROOT/Dockerfile")"
    if [[ $STRICT_LEGACY -eq 1 ]]; then
      local miss=0
      echo "$df" | grep -qE 'COPY[[:space:]].*routes' || { fail "Dockerfile kopiert routes/ nicht"; miss=1; }
      echo "$df" | grep -qE 'COPY[[:space:]].*logic' || { fail "Dockerfile kopiert logic/ nicht"; miss=1; }
      echo "$df" | grep -qE 'COPY[[:space:]].*db' || { fail "Dockerfile kopiert db/ nicht"; miss=1; }
      if [[ $miss -eq 0 ]]; then
        ok "Dockerfile kopiert routes/logic/db"
      fi
      if echo "$df" | grep -qE 'COPY[[:space:]].*openapi\.yaml|COPY[[:space:]].*openapi'; then
        ok "Dockerfile kopiert openapi.yaml"
      else
        warn "Dockerfile kopiert openapi.yaml nicht (empfohlen)"
      fi
      if echo "$df" | grep -qE 'COPY[[:space:]]+\.[[:space:]]'; then
        fail "Dockerfile nutzt COPY . (zu breit; Sven-Anti-Pattern)"
      fi
    else
      warn "Dockerfile-COPY-Check übersprungen (Schichten fehlen noch)"
    fi
  else
    fail "Dockerfile fehlt"
  fi

  # --- Secrets-Heuristik ---
  if rg -i --glob '*.py' --glob '*.yaml' --glob '!*.example' --glob '!.env*' \
    '(password|secret|api_key)\s*=\s*["\x27][^"\x27]{8,}' "$ROOT" 2>/dev/null | grep -q .; then
    fail "mögliches Secret in committeter Datei"
  else
    ok "keine offensichtlichen hardcoded Secrets"
  fi

  # --- .gitignore ---
  if [[ -f "$ROOT/.gitignore" ]]; then
    local gi_ok=1
    for entry in .env data/ .cursor/ .claude/; do
      if ! grep -qF "$entry" "$ROOT/.gitignore" 2>/dev/null; then
        fail ".gitignore fehlt: $entry"
        gi_ok=0
      fi
    done
    if [[ $gi_ok -eq 1 ]]; then
      ok ".gitignore enthält Pflicht-Einträge"
    fi
  else
    fail ".gitignore fehlt"
  fi

  echo "--- Ergebnis: $ERRORS Fehler, $WARNINGS Warnungen ---"
  [[ $ERRORS -eq 0 ]]
}

discover_repos() {
  local org zone proj repos_dir repo
  org="/opt/TunnelQuiz"
  [[ -d "$org" ]] || return 0
  for zone in Apps Domains; do
    [[ -d "$org/$zone" ]] || continue
    for proj in "$org/$zone"/*/; do
      [[ -d "$proj" ]] || continue
      repos_dir="${proj}development/repos"
      [[ -d "$repos_dir" ]] || continue
      for repo in "$repos_dir"/*/; do
        [[ -d "$repo" ]] || continue
        local name
        name="$(basename "$repo")"
        if [[ "$name" == *-domain-api || "$name" == *-app-api ]]; then
          printf '%s\n' "${repo%/}"
        fi
      done
    done
  done | sort -u
}

ampel_line() {
  local ROOT="$1"
  local name
  name="$(basename "$ROOT")"
  local oa=n r=n l=n db=n src=n
  [[ -f "$ROOT/openapi.yaml" ]] && oa=Y
  [[ -d "$ROOT/routes" ]] && r=Y
  [[ -d "$ROOT/logic" ]] && l=Y
  [[ -d "$ROOT/db" ]] && db=Y
  [[ -d "$ROOT/src" ]] && src=Y
  local status="🔴"
  if [[ "$oa" == Y && "$r" == Y && "$l" == Y && "$db" == Y && "$src" == n ]]; then
    status="🟢"
  elif [[ "$r" == Y || "$l" == Y || "$db" == Y || "$oa" == Y ]]; then
    status="🟡"
  fi
  printf '%s  oa=%s r=%s l=%s db=%s src=%s  %s\n' "$status" "$oa" "$r" "$l" "$db" "$src" "$name"
}

usage() {
  cat <<'EOF'
Usage:
  architecture-check.sh <repo-root>
  architecture-check.sh --all
  architecture-check.sh --ampel
EOF
}

main() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
  fi

  if [[ "${1:-}" == "--all" ]]; then
    local fail_count=0 total=0
    while IFS= read -r repo; do
      total=$((total + 1))
      if ! check_repo "$repo"; then
        fail_count=$((fail_count + 1))
      fi
      echo
    done < <(discover_repos)
    echo "=== Gesamt: $total Repos, $fail_count mit Fehlern ==="
    [[ $fail_count -eq 0 ]]
    return $?
  fi

  if [[ "${1:-}" == "--ampel" ]]; then
    printf 'Ampel  oa  r  l  db src  Repo\n'
    while IFS= read -r repo; do
      ampel_line "$repo"
    done < <(discover_repos)
    return 0
  fi

  local ROOT="${1:-}"
  if [[ -z "$ROOT" ]]; then
    usage >&2
    exit 2
  fi
  check_repo "$ROOT"
}

main "$@"
