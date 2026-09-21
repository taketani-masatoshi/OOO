#!/usr/bin/env bash
# Cloud Agent install: prepare the OOO umbrella workspace (Core, Community, Web).
# Idempotent and non-interactive. Safe to re-run.
set -euo pipefail

ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
cd "$ROOT"

echo "==> OOO Cloud Agent install (root: $ROOT)"

# 1) Submodules (Core = OpenOrgOS, Community = OS_Community).
echo "==> Syncing git submodules"
git submodule update --init --recursive

# 2) System dependencies: PostgreSQL (Community DB) + netcat (readiness probe).
if ! command -v psql >/dev/null 2>&1; then
  echo "==> Installing PostgreSQL + netcat"
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    postgresql postgresql-contrib netcat-openbsd
fi

# 3) Ensure the PostgreSQL cluster is running (needed for schema push / seed below).
sudo pg_ctlcluster 16 main start 2>/dev/null || true
for _ in $(seq 1 30); do
  nc -z localhost 5432 2>/dev/null && break
  sleep 1
done

# 4) Create the oscommunity role + database (idempotent).
echo "==> Ensuring PostgreSQL role/database 'oscommunity'"
sudo -u postgres psql -v ON_ERROR_STOP=1 <<'SQL'
DO $$ BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname='oscommunity') THEN
    CREATE ROLE oscommunity LOGIN PASSWORD 'oscommunity' CREATEDB;
  END IF;
END $$;
SQL
sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='oscommunity'" \
  | grep -q 1 || sudo -u postgres createdb -O oscommunity oscommunity

# 5) Node dependencies for each project (npm; lockfiles present).
echo "==> Installing Web dependencies"
(cd Web && npm install --no-audit --no-fund)
echo "==> Installing Core dependencies"
(cd Core && npm install --no-audit --no-fund)
echo "==> Installing Community dependencies"
(cd Community && npm install --no-audit --no-fund)

# 6) Community local dev .env (only when absent; never overwrite user secrets).
if [ ! -f Community/.env ]; then
  echo "==> Writing Community/.env for local dev"
  SECRET="$(openssl rand -base64 32)"
  cat > Community/.env <<EOF
DATABASE_URL=postgresql://oscommunity:oscommunity@localhost:5432/oscommunity
AUTH_SECRET=$SECRET
AUTH_URL=http://localhost:3000
NEXT_PUBLIC_SITE_URL=http://localhost:3000
EOF
fi

# 7) Community: Prisma client, schema, seed, and i18n bundles.
echo "==> Community: Prisma generate + db push"
(cd Community && npm run db:generate && npm run db:push)
echo "==> Community: seeding dev data (best-effort)"
(cd Community && npm run db:seed) || echo "   (seed skipped/failed — non-fatal for dev)"
echo "==> Community: building i18n bundles"
(cd Community && npm run i18n:build)

echo "==> Install complete."
