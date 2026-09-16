# EXTRACT — not canonical

**Do not edit this tree.** Path: `extracts/console/`. Review copy only.

Paths mirror Core so a reviewer can compare side by side:

| ここ | 正本 |
|------|------|
| `apps/wire-console/` | `Core/apps/wire-console` |
| `apps/shared/` | `Core/apps/shared` |
| `wire-console-lib/` | `Core/src/lib/wire-console` |
| `operator-console-lib/` | `Core/src/lib/operator-console` |
| `deploy/operator-console/` | `Core/deploy/operator-console` |
| `e2e/` | `Core/e2e` |

直すのは Core 側。ビルドは Core の `npm run wire-console:build`。

## Drift from Core

This snapshot is frozen, so it falls behind. Measure before trusting it:

```bash
./scripts/check-extract-drift.sh
```

Baseline 2026-09-16, measured against Core `b4ae815d7882ea8b90fee1ebd01dff67c7d5a343`
(the commit the umbrella pinned for `Core` at the time — `git ls-tree HEAD Core`):
`apps/wire-console/src` 3 entries · `apps/shared` 2 entries · `e2e` 24 entries.

Re-measuring against a different Core commit gives different numbers, so compare
the SHA above with today's pointer before reading the counts as current.

See `BUILD.md`, `PROJECT-MAP.yaml` (`kind: extract`, `edit: false`), and `AGENTS.md`.
