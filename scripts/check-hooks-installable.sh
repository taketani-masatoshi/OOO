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

# Every product git root declares its expected hook state in PROJECT-MAP. Keep
# install-hooks.sh's list in step with it, so a root cannot quietly drop out of
# scope by being deleted from the script.
declared="$(
  python3 - <<'PY'
import sys
import yaml

with open("PROJECT-MAP.yaml") as handle:
    doc = yaml.safe_load(handle)

roots = (doc.get("layout") or {}).get("git_roots") or []
allowed = {"required", "exempt"}
bad = []
for root in roots:
    path = root.get("path")
    hooks = root.get("hooks")
    if hooks not in allowed:
        bad.append(f"{path}: hooks={hooks!r} (expected one of {sorted(allowed)})")
    if path != "/":
        print(f"{path}\t{hooks}")

if bad:
    print("\n".join(bad), file=sys.stderr)
    sys.exit(1)
PY
)" || {
  echo "✗ PROJECT-MAP.yaml layout.git_roots[].hooks is missing or invalid" >&2
  errors=1
}

while IFS=$'\t' read -r path hooks; do
  [[ -z "$path" ]] && continue
  if ! grep -q "\b$path\b" scripts/install-hooks.sh; then
    echo "✗ $path is a declared git root but scripts/install-hooks.sh never mentions it" >&2
    errors=1
  fi
  if [[ "$hooks" == "required" && -e "$path/.git" && ! -d "$path/.githooks" ]]; then
    echo "! $path declares hooks: required but has no .githooks — it is unprotected locally" >&2
  fi
done <<<"$declared"

if [[ "$errors" -ne 0 ]]; then
  exit 1
fi

echo "✓ hooks are installable (run scripts/install-hooks.sh once per clone)"
