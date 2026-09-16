#!/usr/bin/env bash
# Fail if the tracked hooks cannot be installed or would not run.
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
cd "$root"

errors=0

for hook in pre-commit pre-push; do
  path=".githooks/$hook"
  if [[ ! -f "$path" ]]; then
    echo "✗ missing $path" >&2
    errors=1
    continue
  fi
  if [[ ! -x "$path" ]]; then
    echo "✗ $path is not executable (git update-index --chmod=+x $path)" >&2
    errors=1
  fi
  if ! bash -n "$path"; then
    echo "✗ $path has a syntax error" >&2
    errors=1
  fi
done

if [[ ! -x scripts/install-hooks.sh ]]; then
  echo "✗ scripts/install-hooks.sh is not executable" >&2
  errors=1
fi

if [[ "$errors" -ne 0 ]]; then
  exit 1
fi

echo "✓ hooks are installable (run scripts/install-hooks.sh once per clone)"
