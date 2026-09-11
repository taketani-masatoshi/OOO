#!/usr/bin/env bash
# Optional helpers for daily work under /Users/kk/OOO (decision 3B).
# Usage: source /Users/kk/OOO/dev-env.sh
#
# Core auto-detects install/workspace from cwd when run inside Core.
# ORGOS_HOME / ORGOS_WORKSPACE are optional overrides (see Core/src/lib/orgos-paths.ts).
# This script does not change git remotes, push, or delete legacy paths.

export OOO_ROOT="/Users/kk/OOO"
export ORGOS_HOME="${ORGOS_HOME:-/Users/kk/OOO/Core}"
# Leave ORGOS_WORKSPACE unset by default so cwd (e.g. Core) wins for tenants/.
# Uncomment only if you intentionally pin workspace away from cwd:
# export ORGOS_WORKSPACE="/Users/kk/OOO/Core"

export OOO_CORE="/Users/kk/OOO/Core"
export OOO_COMMUNITY="/Users/kk/OOO/Community"
export OOO_WEB="/Users/kk/OOO/Web"

echo "OOO_ROOT=$OOO_ROOT"
echo "ORGOS_HOME=$ORGOS_HOME (Core development root)"
echo "Community: $OOO_COMMUNITY | Web: $OOO_WEB"
echo "Legacy /Users/kk/OS_Steward and /Users/kk/OS_Community are NOT development canonical."
