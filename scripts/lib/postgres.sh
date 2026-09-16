#!/usr/bin/env bash
# Shared PostgreSQL helpers for the OOO Cloud Agent environment.
# Source this file; do not execute it directly.
#
# Provides: require_sudo, detect_pg, pg_start, pg_wait, ensure_role_db.
# The PostgreSQL major version and cluster name are detected at runtime so the
# scripts do not break when the base image ships a different major version.
#
# Dev-only credentials: role/password "oscommunity" is a well-known local
# development value. PostgreSQL listens on localhost only (Debian/Ubuntu
# default), so this credential is never exposed off the VM.

OOO_PG_ROLE="oscommunity"
OOO_PG_PASSWORD="oscommunity"
OOO_PG_DB="oscommunity"

# Fail fast (with a clear message) when passwordless sudo is unavailable, since
# apt install and cluster management below depend on it.
require_sudo() {
  if ! sudo -n true 2>/dev/null; then
    echo "ERROR: passwordless sudo is required (needed for apt install and PostgreSQL cluster management)." >&2
    echo "       Run this environment on a base image where the agent user has passwordless sudo." >&2
    return 1
  fi
}

# Detect the installed PostgreSQL major version + cluster name without
# hardcoding. Sets OOO_PGVER and OOO_PGCLUSTER. Returns non-zero if none found.
detect_pg() {
  OOO_PGVER="$(pg_lsclusters -h 2>/dev/null | awk 'NR==1{print $1}')"
  if [ -z "${OOO_PGVER:-}" ]; then
    OOO_PGVER="$(ls -1 /usr/lib/postgresql 2>/dev/null | sort -V | tail -1)"
  fi
  OOO_PGCLUSTER="$(pg_lsclusters -h 2>/dev/null | awk 'NR==1{print $2}')"
  OOO_PGCLUSTER="${OOO_PGCLUSTER:-main}"
  if [ -z "${OOO_PGVER:-}" ]; then
    echo "ERROR: no PostgreSQL installation found under /usr/lib/postgresql." >&2
    return 1
  fi
}

# Start the detected cluster (idempotent; tolerates an already-running cluster).
pg_start() {
  detect_pg || return 1
  echo "==> Starting PostgreSQL cluster ${OOO_PGVER}/${OOO_PGCLUSTER}"
  sudo pg_ctlcluster "$OOO_PGVER" "$OOO_PGCLUSTER" start 2>/dev/null || true
}

# Wait until PostgreSQL accepts TCP connections on localhost:5432.
pg_wait() {
  for _ in $(seq 1 30); do
    if nc -z localhost 5432 2>/dev/null; then
      echo "==> PostgreSQL is ready on localhost:5432"
      return 0
    fi
    sleep 1
  done
  echo "ERROR: PostgreSQL did not become ready on localhost:5432 in time." >&2
  return 1
}

# Ensure the oscommunity role and database exist (idempotent). Safe to call from
# both install and start, so a lost/rebuilt data directory self-heals.
ensure_role_db() {
  echo "==> Ensuring PostgreSQL role/database '${OOO_PG_ROLE}'"
  sudo -u postgres psql -v ON_ERROR_STOP=1 \
    -v role="$OOO_PG_ROLE" -v pw="$OOO_PG_PASSWORD" <<'SQL'
SELECT format('CREATE ROLE %I LOGIN PASSWORD %L CREATEDB', :'role', :'pw')
WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = :'role')
\gexec
SQL
  if ! sudo -u postgres psql -tAc \
      "SELECT 1 FROM pg_database WHERE datname='${OOO_PG_DB}'" | grep -q 1; then
    sudo -u postgres createdb -O "$OOO_PG_ROLE" "$OOO_PG_DB"
  fi
}
