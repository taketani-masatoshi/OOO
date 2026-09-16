# EXTRACT — not canonical

**Do not edit this tree.** Path: `extracts/auth/`. Review copy only.

| 直す場所 | ここ |
|----------|------|
| `Core/` と `Community/` の認証実装 | `extracts/auth/` |

## Drift from the canonical implementations

This snapshot is frozen and has fallen a long way behind. Measure before trusting it:

```bash
./scripts/check-extract-drift.sh
```

Baseline 2026-09-16, measured against the commits the umbrella pinned at the time
(`git ls-tree HEAD Core Community`):

- Core `b4ae815d7882ea8b90fee1ebd01dff67c7d5a343`
- Community `8e1d503b5b8f8361881a18806e86c7a329a93454`

`community/apps/web/src` vs `Community/apps/web/src` — **198 entries**. Read this tree
as history, not as the current auth design.

See `PROJECT-MAP.yaml` (`kind: extract`, `edit: false`) and `AGENTS.md`.
