#!/usr/bin/env bash
# Report how far each review copy under extracts/ has drifted from its canonical
# home. Extracts are frozen snapshots, so drift is expected — this makes it
# measurable instead of invisible. Exit 1 only with --strict.
set -uo pipefail

root="$(git rev-parse --show-toplevel)"
cd "$root"

strict=0
[[ "${1:-}" == "--strict" ]] && strict=1

# extract path : canonical path
PAIRS=(
  "extracts/console/apps/wire-console/src:Core/apps/wire-console/src"
  "extracts/console/apps/shared:Core/apps/shared"
  "extracts/console/e2e:Core/e2e"
  "extracts/auth/community/apps/web/src:Community/apps/web/src"
  "extracts/operations/deploy:Core/deploy"
  "extracts/operations/scripts:Core/scripts"
)

total_drift=0
missing=0

printf '%-46s %-34s %s\n' "extract" "canonical" "drift"
for pair in "${PAIRS[@]}"; do
  extract="${pair%%:*}"
  canonical="${pair##*:}"

  if [[ ! -d "$extract" ]]; then
    printf '%-46s %-34s %s\n' "$extract" "$canonical" "extract missing"
    continue
  fi
  if [[ ! -d "$canonical" ]]; then
    printf '%-46s %-34s %s\n' "$extract" "$canonical" "canonical not checked out"
    missing=$((missing + 1))
    continue
  fi

  drift="$(diff -rq "$extract" "$canonical" 2>/dev/null \
    | grep -v -e '\.DS_Store' -e 'node_modules' -e '/dist' | wc -l | tr -d ' ')"
  total_drift=$((total_drift + drift))
  printf '%-46s %-34s %s\n' "$extract" "$canonical" "$drift entries"
done

echo
echo "total drift: $total_drift entries ($(date +%Y-%m-%d))"
if [[ "$missing" -gt 0 ]]; then
  echo "note: $missing canonical path(s) not checked out — run git submodule update --init"
fi

if [[ "$strict" -eq 1 && "$total_drift" -gt 0 ]]; then
  echo "--strict: extracts are out of date; re-sync or update the recorded baseline" >&2
  exit 1
fi
