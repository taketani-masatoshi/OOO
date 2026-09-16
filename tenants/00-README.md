# tenants/ — umbrella policy only

This umbrella path is **not** the live tenant workspace.

| Path | Role |
|------|------|
| `Core/tenants/` | Day-to-day tenant data (CLI cwd detection) |
| `tenants/GIT-POLICY.md` | GitHub post ban + tip isolation policy |
| `tenants/00-README.md` | This file |

Do not put real tenant `data/` / `docs/` / `records/` here for GitHub. Local leftovers may be parked under `runtime-private/` (private, untracked).
