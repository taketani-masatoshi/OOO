#!/usr/bin/env bash
# Cloud Agent verify: optional health/quality gate for the OOO workspace.
# NOT part of install/start (kept out so boot stays fast). Run manually:
#   bash scripts/cloud-agent-verify.sh
#
# Runs each check independently, prints a PASS/FAIL summary, and exits non-zero
# if any check failed. Health checks assume the community-web (:3000) and
# web-overview (:8080) terminals are running.
set -uo pipefail

ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
cd "$ROOT"

FAILURES=0
declare -a RESULTS

record() {
  local name="$1" code="$2"
  if [ "$code" -eq 0 ]; then
    RESULTS+=("PASS  $name")
  else
    RESULTS+=("FAIL  $name (exit $code)")
    FAILURES=$((FAILURES + 1))
  fi
}

run() {
  local name="$1"; shift
  echo "==> $name"
  "$@"
  record "$name" "$?"
}

http_check() {
  local name="$1" url="$2"
  local code
  code="$(curl -s -m 30 -o /dev/null -w '%{http_code}' "$url" 2>/dev/null || echo 000)"
  echo "==> $name -> HTTP $code"
  [ "$code" = "200" ]
  record "$name ($url)" "$?"
}

# --- Static quality gates ---
run "Core typecheck"   bash -c 'cd Core && npm run typecheck'
run "Core lint"        bash -c 'cd Core && npm run lint'
run "Community lint"   bash -c 'cd Community && npm run lint'
run "Community test"   bash -c 'cd Community && npm run test'

# --- Runtime health checks (best-effort; require terminals up) ---
http_check "Community home"    "http://localhost:3000/"
http_check "Community experts" "http://localhost:3000/experts"
http_check "Web overview"      "http://localhost:8080/"

# Community /api/health database + authSecret flags.
echo "==> Community /api/health"
HEALTH="$(curl -s -m 30 http://localhost:3000/api/health 2>/dev/null || echo '{}')"
echo "$HEALTH" | python3 -c 'import sys,json;d=json.load(sys.stdin);c=d.get("checks",{});print("database:",c.get("database"),"authSecret:",c.get("authSecret"));sys.exit(0 if c.get("database") and c.get("authSecret") else 1)'
record "Community /api/health (database+authSecret)" "$?"

# --- Core CLI smoke ---
run "Core CLI version" bash -c 'cd Core && node --import tsx src/cli.ts --version'

echo
echo "================ verify summary ================"
printf '%s\n' "${RESULTS[@]}"
echo "==============================================="
if [ "$FAILURES" -gt 0 ]; then
  echo "$FAILURES check(s) failed." >&2
  exit 1
fi
echo "All checks passed."
