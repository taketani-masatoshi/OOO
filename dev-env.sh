# Optional helpers for daily work in this repository (decision 3B).
# Usage: source /path/to/dev-env.sh  (from any worktree)
#
# Core auto-detects install/workspace from cwd when run inside Core.
# Existing ORGOS_HOME / ORGOS_WORKSPACE are kept. This script does not
# change git remotes, push, or delete legacy paths.

_OOO_DEV_ENV="${BASH_SOURCE[0]:-$0}"
OOO_ROOT="$(CDPATH= cd -- "$(dirname -- "$_OOO_DEV_ENV")" && pwd)"
unset _OOO_DEV_ENV

export OOO_ROOT
export ORGOS_HOME="${ORGOS_HOME:-$OOO_ROOT/Core}"
export OOO_CORE="$OOO_ROOT/Core"
export OOO_COMMUNITY="$OOO_ROOT/Community"
export OOO_WEB="$OOO_ROOT/Web"

if [ -d "$OOO_ROOT/.githooks" ] && [ "$(git -C "$OOO_ROOT" config --get core.hooksPath 2>/dev/null)" != ".githooks" ]; then
  echo "hooks: core.hooksPath is not .githooks — run $OOO_ROOT/scripts/install-hooks.sh"
fi

echo "OOO_ROOT=$OOO_ROOT"
echo "ORGOS_HOME=$ORGOS_HOME (Core development root)"
echo "Community: $OOO_COMMUNITY | Web: $OOO_WEB"
echo "Legacy OS_Steward and OS_Community are NOT development canonical."
