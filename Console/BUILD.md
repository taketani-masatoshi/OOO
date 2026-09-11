# Console build notes (OOO)

## Official completion path (PASS) — instruction §7 Console gate

Build **from the Core monorepo** so workspace deps and shared theme resolve:

```bash
cd /Users/kk/OOO/Core
npm run wire-console:build      # Wire Console → apps/wire-console/dist/
npm run operator-console:build  # Operator Console (= steward-chat:build) → apps/steward-chat/dist/
```

These two Core scripts are the **authoritative** Console completion criteria under Definition A.
Standalone extract under `/Users/kk/OOO/Console` is a review copy only — **not** a completion gate.

Verified 2026-09-07 (reverify): both builds EXIT 0. Logs: `artifacts/reports/console-wire-build-core-reverify.txt`, `console-operator-build-core.txt`.

## Standalone extract (non-goal / FAIL expected)

`/Users/kk/OOO/Console/wire-console` has theme copies under `shared/` / `apps/shared/`, but Vite still fails resolving workspace packages (e.g. `@simplewebauthn/browser`). **Do not treat extract-only `vite build` as a migration blocker.** Prefer Core workspace builds above.

## Layout of Console extract

| Path | Role |
|------|------|
| `wire-console/` | App extract (review) |
| `apps/wire-console/` | Duplicate layout for path parity |
| `wire-console-lib/` | From Core `src/lib/wire-console` |
| `operator-console-lib/` | From Core `src/lib/operator-console` |
| `deploy/operator-console/` | Deploy notes |
| `e2e/` | Playwright smoke specs (run from Core) |
| `shared/`, `apps/shared/` | Theme CSS copies |

## Core dependency

Console UI depends on Core schemas, BFF, and Auth contracts — not a fully self-contained package.
See `/Users/kk/OOO/PROJECT-MAP.yaml` → `Console` and `/Users/kk/OOO/Auth/contracts/README.md`.
