#!/usr/bin/env bash
# Cloud Agent start: bring up per-boot runtime services (PostgreSQL).
# Idempotent; tolerates an already-running cluster. Returns once ready.
set -euo pipefail

echo "==> Starting PostgreSQL cluster (16/main)"
sudo pg_ctlcluster 16 main start 2>/dev/null || true

for _ in $(seq 1 30); do
  if nc -z localhost 5432 2>/dev/null; then
    echo "==> PostgreSQL is ready on localhost:5432"
    exit 0
  fi
  sleep 1
done

echo "PostgreSQL did not become ready on localhost:5432 in time." >&2
exit 1
