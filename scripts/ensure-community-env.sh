#!/usr/bin/env bash
# Ensure Community/.env exists for local development.
# Idempotent: only creates the file when absent; never overwrites user secrets.
# Called from both install and the community-web terminal so the terminal does
# not depend on install having run first.
set -euo pipefail

ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
ENV_FILE="$ROOT/Community/.env"

if [ -f "$ENV_FILE" ]; then
  exit 0
fi

echo "==> Writing Community/.env for local dev"
SECRET="$(openssl rand -base64 32)"
cat > "$ENV_FILE" <<EOF
DATABASE_URL=postgresql://oscommunity:oscommunity@localhost:5432/oscommunity
AUTH_SECRET=$SECRET
AUTH_URL=http://localhost:3000
NEXT_PUBLIC_SITE_URL=http://localhost:3000
EOF
