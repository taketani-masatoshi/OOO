# OOO Migration Report

## Summary
- Date: 2026-09-07 (Asia/Tokyo)
- Core source: `/Users/kk/OS_Steward` (OpenOrgOS origin; preferred Codex existed but had no remotes / different HEAD)
- Community source: `/Users/kk/OS_Community`
- Web official: `/Users/kk/OOO/Community/sites/coming-soon` (oorgos.org); `/OOO/Web` = rsync mirror + `overview:links` proxy
- Definition: **A** (gates green under OOO)
- Decision: **1A + 2B + 3B** — daily development canonical root = `/Users/kk/OOO` (legacy retained, not deleted)
- Status: **DEVELOPMENT_CANONICAL_OOO** (was VERIFICATION_GATES_GREEN) — GitHub push + legacy deletion remain **BLOCKED_HUMAN**
- Checklist: `artifacts/reports/completion-checklist-2026-09-07.md`
- Canonical switch record: `artifacts/reports/canonical-switch-3B-2026-09-07.md`
- Day-to-day roots: Core=`/Users/kk/OOO/Core`, Community=`/Users/kk/OOO/Community`, Web=`/Users/kk/OOO/Web`

## Sources
| Target | Source path | Exists | Notes |
|--------|-------------|--------|-------|
| Core (preferred) | `/Users/kk/Documents/Codex` | yes | Git present, **no remotes**; HEAD `8e5e9de…`; not selected |
| Core (actual) | `/Users/kk/OS_Steward` | yes | origin `OpenOrgOS.git`; HEAD `2fe1941…`; dirty work left untouched |
| Community | `/Users/kk/OS_Community` | yes | origin `OS_Community.git`; ahead of origin/main |
| Web (official) | `/Users/kk/OS_Community/sites/coming-soon` | yes | Production overview → `Community/sites/coming-soon` + `/OOO/Web` mirror |
| Web (provisional) | `/Users/kk/OS_Steward/apps/canvas-web` | yes | Retained under `Web/_provisional-canvas-web` |
| Console wire-console | `/Users/kk/OS_Steward/apps/wire-console` | yes | Copied; build via Core |
| Console wire-console-lib | `/Users/kk/OS_Steward/src/lib/wire-console` | yes | No `packages/wire-console-lib`; used `src/lib/wire-console` |
| Console operator-console | `/Users/kk/OS_Steward/deploy/operator-console` | yes | Copied |
| Console e2e | `/Users/kk/OS_Steward/e2e/wire-console*` | yes | Copied |
| Auth (Core) | wire-console + steward-chat auth paths | yes | Extracted under `Auth/` + `Auth/contracts/` |
| Auth (Community) | NextAuth / OAuth files | yes | Extracted under `Auth/community/` |
| tenants | `/Users/kk/OS_Steward/tenants` | yes | Secret-ish dirs excluded |
| operations | `deploy/`, `services/`, `scripts/` | yes | From Core |

## Copy operations
| From | To | Method | .git included | Exclusions applied |
|------|-----|--------|---------------|--------------------|
| `/Users/kk/OS_Steward/` | `/Users/kk/OOO/Core/` | rsync -a | yes | standard* |
| `/Users/kk/OS_Community/` | `/Users/kk/OOO/Community/` | rsync -a | yes | standard* |
| `.../sites/coming-soon/` | `/Users/kk/OOO/Web/` | rsync -a (+ package.json overlay) | no | standard* |
| `.../apps/canvas-web/` | `/Users/kk/OOO/Web/_provisional-canvas-web/` | move/retain | no | standard* |
| `.../apps/wire-console/` | `/Users/kk/OOO/Console/wire-console/` (+ `Console/apps/wire-console/`) | rsync -a | no | standard* |
| `.../src/lib/wire-console/` | `/Users/kk/OOO/Console/wire-console-lib/` | rsync -a | no | standard* |
| `.../src/lib/operator-console/` | `/Users/kk/OOO/Console/operator-console-lib/` | rsync -a | no | standard* |
| `.../deploy/operator-console/` | `/Users/kk/OOO/Console/deploy/operator-console/` | rsync -a | no | standard* |
| `.../e2e/wire-console*` | `/Users/kk/OOO/Console/e2e/` | rsync -a | no | standard* |
| Auth curated files | `/Users/kk/OOO/Auth/{wire-console,steward-chat,community}/` | rsync file/dir | no | standard* |
| `.../tenants/` | `/Users/kk/OOO/tenants/` | rsync -a | no | standard* + secrets/credentials/private-keys/.secrets/*.secret/*.env |
| `.../deploy|services|scripts/` | `/Users/kk/OOO/operations/{deploy,services,scripts}/` | rsync -a | no | standard* |

\*standard excludes: `node_modules`, `dist`, `.next`, `tmp`, `scratch`, `test-results`, `.env`, `.env.*`, `*.pem`, `*.key`

## Verification (reverify 2026-09-07)
| Check | Result | Notes |
|-------|--------|-------|
| Secret scan (.env / *.pem / *.key in OOO) | PASS | count=0 |
| Core `npm run typecheck` | **PASS** | Fixed earlier in OOO/Core only |
| Core vitest `chat-rbac` + `static-cli-digests` + `pipeline-static-digests` | **PASS** | 14/14 |
| Core `orgos validate` demo | **PASS** | Valid; 3 non-fatal warnings |
| Core `orgos validate` mal | **PASS** | Valid; many ISO/placeholder warnings — **non-blocking** |
| Web official (`overview:links` via `/OOO/Web`) | **PASS** | Proxies Community; static site |
| Community `prisma generate` / `db:generate` | **PASS** | Dummy DATABASE_URL |
| Community `next build` | **PASS** | SSG may log unreachable DB (non-fatal) |
| Console via Core `wire-console:build` | **PASS** | Official §7 path — `Console/BUILD.md` |
| Console via Core `operator-console:build` | **PASS** | steward-chat vite build |
| Console extract-only `vite build` | FAIL (non-goal) | Documented; not a completion blocker |
| Legacy retained / no push | **PASS** | Sources unmodified by this pass; no GitHub push |
| Sources unmodified (legacy) | PASS | Typecheck fixes only under `/Users/kk/OOO/Core` (prior); this pass docs/Web/Auth only in OOO |

See also: `artifacts/reports/verification-2026-09-07.md`, `completion-checklist-2026-09-07.md`

## Exclusions
See copy-exclusions.log

## Git policy
- Core: `.git` copied into `/Users/kk/OOO/Core`; source `/Users/kk/OS_Steward` not modified; **no push**
- Community: `.git` copied into `/Users/kk/OOO/Community`; history/remote preserved; **no push**
- tenants: subtree copy **without** `.git`; see `tenants/GIT-POLICY.md`
- Secrets: no `.env` / `.pem` / `.key` copied
- Artifacts / runtime-private: stubs only; not for secrets

## Remaining BLOCKED_HUMAN
1. **GitHub push target file list review** — no push until operator reviews publish boundary (see `github-push-candidates-2026-09-07.md`)
2. ~~**Sustained development on new root**~~ — **STARTED / canonical declared (3B)** — daily work uses `/Users/kk/OOO`; “一定期間の実開発” continues under this root
3. **Legacy vs OOO diff / gap sign-off** — human confirms no migration misses
4. **Human migration-complete confirmation / legacy deletion** — required before any legacy delete (legacy kept for comparison)

## Issues / Follow-ups (non-blocking)
- Console extract still fails standalone (workspace deps); use Core builds
- Community `next build` without live DB: runtime needs real `DATABASE_URL`
- Core typecheck fixes exist in OOO copy only — upstream OS_Steward may still have the same bugs
- `dist` exclude means prebuilt CLI JS not present; use `tsx` for orgos
- Time Machine noise during tests (host environment)
- Auth is curated extract + contracts README — not a runnable unified package
- Do not push GitHub from migration outputs without explicit operator review
- Do not delete legacy until BLOCKED_HUMAN items clear (3B keeps legacy for comparison)
- Day-to-day development: use `/Users/kk/OOO/{Core,Community,Web}` — not legacy trees
