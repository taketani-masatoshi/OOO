#!/usr/bin/env bash
# Cloud Agent start: bring up per-boot runtime services (PostgreSQL).
# Idempotent; tolerates an already-running cluster. Returns once ready.
set -euo pipefail

ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
# shellcheck source=scripts/lib/postgres.sh
source "$ROOT/scripts/lib/postgres.sh"

require_sudo
pg_start
pg_wait
# Re-assert role/database so a lost or rebuilt data directory self-heals
# instead of leaving the port up but the database missing.
ensure_role_db
