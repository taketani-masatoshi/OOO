#!/usr/bin/env bash
# Copy Web (canonical) → Community/sites/coming-soon (publish mirror).
# Default is dry-run. Use --apply to write. Never runs from npm run build.
set -euo pipefail

WEB_DIR="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
APPLY=0
FORCE_DIRTY=0
for arg in "$@"; do
  case "$arg" in
    --apply) APPLY=1 ;;
    --force-dirty) FORCE_DIRTY=1 ;;
    --dry-run) APPLY=0 ;;
    *) echo "Unknown argument: $arg" >&2; exit 2 ;;
  esac
done

if [[ -n "${COMMUNITY_ROOT:-}" ]]; then
  COMMUNITY_ROOT="$(CDPATH= cd -- "$COMMUNITY_ROOT" && pwd)"
else
  COMMUNITY_ROOT="$(CDPATH= cd -- "$WEB_DIR/../Community" && pwd)"
fi

MIRROR="$COMMUNITY_ROOT/sites/coming-soon"
if [[ ! -d "$MIRROR" ]]; then
  echo "Mirror directory missing: $MIRROR" >&2
  exit 1
fi

EXCLUDE_FILE="$WEB_DIR/sync-excludes.txt"
RSYNC_EXCLUDES=()
while IFS= read -r pattern || [[ -n "$pattern" ]]; do
  [[ -z "$pattern" || "$pattern" == \#* ]] && continue
  RSYNC_EXCLUDES+=(--exclude "$pattern")
done < "$EXCLUDE_FILE"

if git -C "$COMMUNITY_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  dirty="$(git -C "$COMMUNITY_ROOT" status --porcelain -- sites/coming-soon || true)"
  if [[ -n "$dirty" && "$FORCE_DIRTY" -ne 1 ]]; then
    echo "Mirror has uncommitted changes; refusing to overwrite." >&2
    echo "$dirty"
    echo "Commit or stash them, or pass --force-dirty after review." >&2
    exit 1
  fi
fi

echo "Source: $WEB_DIR"
echo "Mirror: $MIRROR"
echo "Mode: $([[ "$APPLY" -eq 1 ]] && echo apply || echo dry-run)"
echo "--- planned itemized changes (rsync -i) ---"
rsync -a -i --delete --dry-run "${RSYNC_EXCLUDES[@]}" "$WEB_DIR/" "$MIRROR/"
if [[ "$APPLY" -ne 1 ]]; then
  echo "--- dry-run only; re-run with --apply to write ---"
  exit 0
fi

rsync -a -i --delete "${RSYNC_EXCLUDES[@]}" "$WEB_DIR/" "$MIRROR/"
echo "Mirror updated."
