#!/usr/bin/env bash
# Generate overview assets into this Web tree. Does not write Community.
# Requires a Community checkout only as the generator (packages/shared).
set -euo pipefail

WEB_DIR="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
if [[ -n "${COMMUNITY_ROOT:-}" ]]; then
  COMMUNITY_ROOT="$(CDPATH= cd -- "$COMMUNITY_ROOT" && pwd)"
else
  COMMUNITY_ROOT="$(CDPATH= cd -- "$WEB_DIR/../Community" && pwd)"
fi

GENERATOR="$COMMUNITY_ROOT/packages/shared/scripts/generate-overview-links.ts"
if [[ ! -f "$GENERATOR" ]]; then
  echo "Missing generator: $GENERATOR" >&2
  echo "Set COMMUNITY_ROOT to an OS_Community checkout (relative path or env)." >&2
  exit 1
fi

OVERVIEW_DIR="${OVERVIEW_DIR:-$WEB_DIR}"
export OVERVIEW_DIR
echo "Generating overview assets into $OVERVIEW_DIR (generator from $COMMUNITY_ROOT)"
npm run overview:links --prefix "$COMMUNITY_ROOT" -- --dir "$OVERVIEW_DIR"
