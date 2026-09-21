# Console build notes (OOO)

**Not canonical. Do not edit this extract.** Path: `extracts/console/`. 正本とビルドは Core。案内: [EXTRACT-NOT-CANONICAL.md](./EXTRACT-NOT-CANONICAL.md)。

## Official completion path (PASS) — instruction §7 Console gate

Build **from the Core monorepo** so workspace deps and shared theme resolve:

```bash
cd Core
npm run wire-console:build      # Wire Console → apps/wire-console/dist/
npm run operator-console:build  # Operator Console (= steward-chat:build) → apps/steward-chat/dist/
```

These two Core scripts are the **authoritative** Console completion criteria under Definition A.
Standalone extract under `extracts/console/` is a review copy only — **not** a completion gate.

Verified 2026-09-07 (reverify): both builds EXIT 0. Logs: `artifacts/reports/console-wire-build-core-reverify.txt`, `console-operator-build-core.txt`.

## Standalone extract (non-goal / FAIL expected)

`extracts/console/apps/wire-console` has theme copies under `apps/shared/`, but Vite still fails resolving workspace packages (e.g. `@simplewebauthn/browser`). **Do not treat extract-only `vite build` as a migration blocker.** Prefer Core workspace builds above.

## Layout of Console extract

Paths mirror Core so each entry diffs against one canonical path.

| Path | From Core |
|------|-----------|
| `apps/wire-console/` | `apps/wire-console` |
| `apps/shared/` | `apps/shared` (theme + shell) |
| `wire-console-lib/` | `src/lib/wire-console` |
| `operator-console-lib/` | `src/lib/operator-console` |
| `deploy/operator-console/` | `deploy/operator-console` |
| `e2e/` | `e2e/wire-console*` |

Drift from Core: `./scripts/check-extract-drift.sh`.

## Core dependency

Console UI depends on Core schemas, BFF, and Auth contracts — not a fully self-contained package.
See `PROJECT-MAP.yaml` → `Console` and `Auth/contracts/README.md`.
