#!/usr/bin/env bash
# Point this repository (and its product submodules) at the tracked .githooks
# directory. Without this, .githooks/pre-commit and pre-push never run.
#
# Every product git root gets a status line whether or not it could be wired up.
# A submodule without .githooks is an unprotected repository, and saying nothing
# about it reads exactly like success.
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
cd "$root"

git config core.hooksPath .githooks
echo "✓ core.hooksPath=.githooks ($root)"

# Product git roots and their expected hook state, from PROJECT-MAP
# layout.git_roots (minus the umbrella itself). macOS ships bash 3.2, which has
# no associative arrays, hence the case statement.
submodules=(Core Community)
unprotected=()

expected_hooks() {
  case "$1" in
    Community) echo exempt ;;
    *) echo required ;;
  esac
}

for sub in "${submodules[@]}"; do
  if [[ ! -e "$sub/.git" ]]; then
    echo "· $sub — not checked out (git submodule update --init $sub)"
    continue
  fi
  if [[ ! -d "$sub/.githooks" ]]; then
    if [[ "$(expected_hooks "$sub")" == "exempt" ]]; then
      echo "· $sub — no .githooks, exempt by PROJECT-MAP (no tenants/ tree)"
    else
      echo "! $sub — no .githooks directory, so nothing enforces the tenant rule there"
      unprotected+=("$sub")
    fi
    continue
  fi
  git -C "$sub" config core.hooksPath .githooks
  echo "✓ core.hooksPath=.githooks ($sub)"
done

echo "Verify: git config --get core.hooksPath"

if [[ ${#unprotected[@]} -gt 0 ]]; then
  echo
  echo "Unprotected product repositories: ${unprotected[*]}" >&2
  echo "Add .githooks/pre-commit and .githooks/pre-push there, or record the" >&2
  echo "exemption under layout.git_roots[].hooks in PROJECT-MAP.yaml so the gap" >&2
  echo "is a decision rather than an oversight." >&2
fi
