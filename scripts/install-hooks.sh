#!/usr/bin/env bash
# Point this repository (and its submodules) at the tracked .githooks directory.
# Without this, .githooks/pre-commit and pre-push never run.
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
cd "$root"

git config core.hooksPath .githooks
echo "✓ core.hooksPath=.githooks ($root)"

for sub in Core Community; do
  if [[ -e "$sub/.git" ]] && [[ -d "$sub/.githooks" ]]; then
    git -C "$sub" config core.hooksPath .githooks
    echo "✓ core.hooksPath=.githooks ($sub)"
  fi
done

echo "Verify: git config --get core.hooksPath"
