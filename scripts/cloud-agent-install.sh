#!/usr/bin/env bash
# Cloud Agent install: prepare the OOO umbrella workspace (Core, Community, Web).
# Idempotent and non-interactive. Safe to re-run.
set -euo pipefail

ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
cd "$ROOT"
# shellcheck source=scripts/lib/postgres.sh
source "$ROOT/scripts/lib/postgres.sh"

echo "==> OOO Cloud Agent install (root: $ROOT)"

# 1) Submodules (Core = OpenOrgOS, Community = OS_Community).
echo "==> Syncing git submodules"
git submodule update --init --recursive

# 2) System dependencies: PostgreSQL (Community DB) + netcat (readiness probe).
require_sudo
if ! command -v psql >/dev/null 2>&1; then
  echo "==> Installing PostgreSQL + netcat"
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    postgresql postgresql-contrib netcat-openbsd
fi
# netcat may be missing even when psql is already present (e.g. custom images).
command -v nc >/dev/null 2>&1 || sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq netcat-openbsd

# 3) Bring PostgreSQL up and ensure the role/database exist. A running DB is a
#    build-time necessity here for the Prisma schema push and seed below; the
#    per-boot equivalent lives in scripts/cloud-agent-start.sh.
pg_start
pg_wait
ensure_role_db

# 4) Node dependencies (npm ci for reproducibility; fall back to install when
#    the lockfile is out of sync). Web has no dependencies, so it is skipped.
install_node_deps() {
  local dir="$1"
  echo "==> Installing $dir dependencies"
  (cd "$dir" && { npm ci --no-audit --no-fund || npm install --no-audit --no-fund; })
}
install_node_deps Core
install_node_deps Community

# 5) Community local dev .env (delegated; only created when absent).
bash "$ROOT/scripts/ensure-community-env.sh"

# 6) Community: Prisma client, schema, seed, and i18n bundles.
echo "==> Community: Prisma generate + db push"
(cd Community && npm run db:generate && npm run db:push)
echo "==> Community: seeding dev data (best-effort)"
if (cd Community && npm run db:seed); then
  # Sanity check: surface a silently empty seed instead of hiding it.
  USER_COUNT="$(PGPASSWORD="$OOO_PG_PASSWORD" psql -h localhost -U "$OOO_PG_ROLE" \
    -d "$OOO_PG_DB" -tAc 'SELECT count(*) FROM "User";' 2>/dev/null || echo 0)"
  echo "==> Seed sanity check: User rows = ${USER_COUNT}"
  [ "${USER_COUNT:-0}" -gt 0 ] 2>/dev/null || echo "   WARNING: seed produced 0 User rows — check seed inputs (non-fatal)."
else
  echo "   WARNING: seed step failed — continuing without seed data (non-fatal for dev)."
fi
echo "==> Community: building i18n bundles"
(cd Community && npm run i18n:build)

# 7) Web: regenerate the static overview assets into the Web tree so they are
#    not stale. The generator lives in Community/packages/shared.
echo "==> Web: generating overview assets"
(cd Web && COMMUNITY_ROOT=../Community npm run build)

echo "==> Install complete."
