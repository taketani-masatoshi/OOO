#!/usr/bin/env bash
# Optional helpers for daily work under this OOO tree (decision 3B).
# Usage: source path/to/dev-env.sh
#
# Resolution order (does not override already-set variables):
#   1. Existing OOO_ROOT / ORGOS_HOME / OOO_CORE / OOO_COMMUNITY / OOO_WEB
#   2. Directory containing this script (so a worktree copy follows itself)
#   3. Core workspace detection from cwd remains in Core (orgos-paths.ts)
#
# Core auto-detects install/workspace from cwd when run inside Core.
# This script does not change git remotes, push, or delete legacy paths.

_DEV_ENV_DIR="$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export OOO_ROOT="${OOO_ROOT:-$_DEV_ENV_DIR}"
export ORGOS_HOME="${ORGOS_HOME:-$OOO_ROOT/Core}"
# Leave ORGOS_WORKSPACE unset by default so cwd (e.g. Core worktree) wins for tenants/.
# Uncomment only if you intentionally pin workspace away from cwd:
# export ORGOS_WORKSPACE="$OOO_ROOT/Core"

export OOO_CORE="${OOO_CORE:-$OOO_ROOT/Core}"
export OOO_COMMUNITY="${OOO_COMMUNITY:-$OOO_ROOT/Community}"
export OOO_WEB="${OOO_WEB:-$OOO_ROOT/Web}"

echo "OOO_ROOT=$OOO_ROOT"
echo "ORGOS_HOME=$ORGOS_HOME (Core development root)"
echo "Community: $OOO_COMMUNITY | Web: $OOO_WEB"
echo "Legacy /Users/kk/OS_Steward and /Users/kk/OS_Community are NOT development canonical."
