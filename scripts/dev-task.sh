#!/usr/bin/env bash
# Development-agent worktree helpers. Not used by business agent dispatch.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  scripts/dev-task.sh start --repo <Core|Community> --task <slug> [--base <branch>]
  scripts/dev-task.sh inspect [--repo-dir <path>] [--allow <prefix>]...
  scripts/dev-task.sh integrate-check [--repo-dir <path>] [--allow <prefix>]...

start:    1 task = 1 branch = 1 worktree. Writes artifacts/dev-tasks/<slug>.yaml
inspect:  reports staged/unstaged/untracked; fails on paths outside --allow
integrate-check: inspect + refuse dirty files outside allowed prefixes (no restore/delete)

Worktrees are not an OS sandbox. Another process can still write other trees.
EOF
}

OOO_ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
CMD="${1:-}"
shift || true

REPO=""
TASK=""
BASE=""
REPO_DIR=""
ALLOW=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) REPO="${2:-}"; shift 2 ;;
    --task) TASK="${2:-}"; shift 2 ;;
    --base) BASE="${2:-}"; shift 2 ;;
    --repo-dir) REPO_DIR="${2:-}"; shift 2 ;;
    --allow) ALLOW+=("${2:-}"); shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 2 ;;
  esac
done

task_file_for() {
  local slug="$1"
  echo "$OOO_ROOT/artifacts/dev-tasks/${slug}.yaml"
}

case "$CMD" in
  start)
    [[ -n "$REPO" && -n "$TASK" ]] || { usage; exit 2; }
    SRC="$OOO_ROOT/$REPO"
    [[ -d "$SRC/.git" || -f "$SRC/.git" ]] || { echo "Not a git checkout: $SRC" >&2; exit 1; }
    BRANCH="dev/${TASK}"
    DEST="$(CDPATH= cd -- "$OOO_ROOT/.." && pwd)/${REPO}-${TASK}"
    if [[ -e "$DEST" ]]; then
      echo "Destination exists: $DEST" >&2
      exit 1
    fi
    BASE="${BASE:-$(git -C "$SRC" rev-parse --abbrev-ref HEAD)}"
    START_COMMIT="$(git -C "$SRC" rev-parse HEAD)"
    git -C "$SRC" worktree add -b "$BRANCH" "$DEST"
    mkdir -p "$OOO_ROOT/artifacts/dev-tasks"
    cat > "$(task_file_for "$TASK")" <<EOF
schema: ooo.dev-task.v1
task: ${TASK}
kind: development-agent
not: business-aia-dispatch
repo: ${REPO}
source_checkout: ${SRC}
worktree: ${DEST}
branch: ${BRANCH}
base: ${BASE}
start_commit: ${START_COMMIT}
paths:
  read: ["${REPO}/"]
  write: ["${REPO}/"]
  generated: []
  denied:
    - Console/
    - Auth/
    - tenants/
    - operations/
    - runtime-private/
shared_resources:
  - lockfiles
  - schemas
  - db-migrations
  - auth-contracts
  - ci
completion: inspect clean of denied paths; no commit/push unless separately approved
isolation: convention-and-inspect
sandbox: none
EOF
    echo "Worktree: $DEST"
    echo "Task file: $(task_file_for "$TASK")"
    echo "Open the same directory in any IDE."
    ;;
  inspect|integrate-check)
    REPO_DIR="${REPO_DIR:-$(pwd)}"
    git -C "$REPO_DIR" rev-parse --is-inside-work-tree >/dev/null
    echo "HEAD: $(git -C "$REPO_DIR" rev-parse --short HEAD) $(git -C "$REPO_DIR" rev-parse --abbrev-ref HEAD)"
    echo "worktree: $REPO_DIR"
    echo "git-common-dir: $(git -C "$REPO_DIR" rev-parse --git-common-dir)"
    echo "--- status (staged/unstaged/untracked) ---"
    git -C "$REPO_DIR" status --short --untracked-files=all
    if [[ ${#ALLOW[@]} -eq 0 ]]; then
      echo "No --allow prefixes; listing only."
      exit 0
    fi
    outside=0
    while IFS= read -r line; do
      path="${line#???}"
      [[ -z "$path" ]] && continue
      ok=0
      for prefix in "${ALLOW[@]}"; do
        case "$path" in
          "$prefix"*) ok=1; break ;;
        esac
      done
      if [[ "$ok" -eq 0 ]]; then
        echo "OUT OF SCOPE: $path"
        outside=1
      fi
    done <<EOF
$(git -C "$REPO_DIR" status --porcelain --untracked-files=all)
EOF
    if [[ "$outside" -eq 1 ]]; then
      echo "Integrate refused: out-of-scope paths present. Not restoring or deleting them."
      exit 1
    fi
    echo "Scope OK."
    ;;
  *)
    usage
    exit 2
    ;;
esac
