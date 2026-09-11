#!/usr/bin/env bash
# Fail if tenant workspace data is staged, committed, or about to be pushed.
set -euo pipefail

if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "forbid-tenant-github-post: not a git repository" >&2
  exit 1
fi

allowed='^tenants/GIT-POLICY\.md$'
blocked='(^|/)tenants/'

collect() {
  {
    git ls-files -z
    git diff --cached --name-only -z
    if git rev-parse --abbrev-ref @{upstream} >/dev/null 2>&1; then
      git diff --name-only -z "@{upstream}...HEAD" || true
    fi
  } | tr '\0' '\n' | sed '/^$/d' | sort -u
}

hits="$(collect | grep -E "$blocked" | grep -Ev "$allowed" || true)"

if [[ -n "$hits" ]]; then
  echo "拒否: テナント情報は GitHub にポストしません。" >&2
  echo "$hits" >&2
  echo "許可されるのは tenants/GIT-POLICY.md のみです。" >&2
  exit 1
fi
