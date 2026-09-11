# OOO full resync — 2026-09-07

## Purpose

Consolidate latest content under `/Users/kk/OOO` for daily work.  
Legacy trees (`/Users/kk/OS_Steward`, `/Users/kk/OS_Community`, Documents/Codex) were **copy/rsync only** — never deleted, moved, or reset.  
No `git push`. No `git reset --hard`.

## Pre-state (noted)

| Tree | Branch / HEAD | Notes |
|------|---------------|-------|
| `/Users/kk/OOO/Core` | `ooo/migration-ooo-root` @ `4c14df6e` | OOO-only typecheck fixes in `src/commands/contracts.ts`, `src/lib/analytics/snapshot-history.ts` |
| `/Users/kk/OS_Steward` | `fix/community-homepage-stats` @ `2fe19415` | Dirty worktree left untouched |
| `/Users/kk/OOO/Community` | `main` @ `ef412a4` (ahead 1) | — |
| `/Users/kk/OS_Community` | `main` @ `ef412a4` (ahead 1) | Dirty worktree left untouched |

## Excludes (all rsync)

`node_modules`, `dist`, `.next`, `tmp`, `scratch`, `test-results`, `.env`, `.env.*`, `*.pem`, `*.key`, `.DS_Store`

## Actions

### 1. Core

- `rsync -a` **without `--delete`**, exclude `.git` + excludes above  
  `/Users/kk/OS_Steward/` → `/Users/kk/OOO/Core/`
- Re-applied typecheck fixes after sync:
  - `opts?.json` in `src/commands/contracts.ts`
  - `notes: []` in `src/lib/analytics/snapshot-history.ts`
- `.git` preserved → branch remains `ooo/migration-ooo-root` @ `4c14df6e`

### 2. Community

- `rsync -a` **without `--delete`**, exclude `.git` + excludes  
  `/Users/kk/OS_Community/` → `/Users/kk/OOO/Community/`
- `.git` preserved → `ef412a4`

### 3. Web (CANONICAL)

- `rsync -a --delete` **only inside** `/Users/kk/OOO/Web/`  
  from `/Users/kk/OOO/Community/sites/coming-soon/`
- Preserved `_provisional-canvas-web/`
- Wrote/restored OOO overlays:
  - `package.json` (canonical scripts + `sync-to-community`)
  - `README.OOO.md` (edit `/Users/kk/OOO/Web`; do not prefer Community coming-soon)

**Policy going forward:** developers edit `/Users/kk/OOO/Web`. Optional publish path: sync Web → `Community/sites/coming-soon` then Vercel, or deploy from Web directly.

### 4. Console

Re-rsync from Core into `/Users/kk/OOO/Console/`:

- `apps/wire-console` → `wire-console/` and `apps/wire-console/`
- `src/lib/wire-console` → `wire-console-lib/`
- `src/lib/operator-console` → `operator-console-lib/`
- `deploy/operator-console` → `deploy/operator-console/`
- `e2e/wire-console*` → `e2e/`
- `apps/shared` → `shared/` and `apps/shared/`

### 5. Auth

Curated refresh from Core + Community into `/Users/kk/OOO/Auth/` (wire-console, steward-chat, community auth trees + scripts).

### 6. tenants

- `rsync -a` **without `--delete`** from `/Users/kk/OOO/Core/tenants/` → `/Users/kk/OOO/tenants/`
- Extra excludes: `**/secrets/**`, `**/*secret*` (+ standard secret file excludes)

### 7. operations

Refresh from Core:

- `deploy/` → `/Users/kk/OOO/operations/deploy/`
- `services/` → `/Users/kk/OOO/operations/services/`
- `scripts/` → `/Users/kk/OOO/operations/scripts/`

### 8. Docs

- Updated `PROJECT-MAP.yaml` — Web destination `/Users/kk/OOO/Web` is **CANONICAL** edit path; removed “prefer Community/sites/coming-soon”
- Updated `README.md` — same Web policy

## Verify

| Check | Result |
|-------|--------|
| Core `npm run typecheck` | **PASS** (exit 0); log: `artifacts/reports/core-typecheck-resync-2026-09-07.txt` |
| Web `package.json` | present |
| Web `index.html` / `vercel.json` | present |
| Legacy OS_Steward / OS_Community | still present; not reset/pushed |
| OOO top-level | Auth, Community, Console, Core, Web, artifacts, operations, tenants, runtime-private, PROJECT-MAP.yaml, README.md, … |

## OOO top-level (post-resync)

```
Auth
Community
Console
Core
MIGRATION-REPORT.md
PROJECT-MAP.yaml
README.md
Web
artifacts
copy-exclusions.log
dev-env.sh
legacy-codex-status-reference.txt
legacy-community-status.txt
legacy-core-status.txt
operations
runtime-private
tenants
```

## Not done (by design)

- No git push
- No git reset --hard
- No deletion of legacy trees
- No `--delete` on Core / Community / tenants wholesale
