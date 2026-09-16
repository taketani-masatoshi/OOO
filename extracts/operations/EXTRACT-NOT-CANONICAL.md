# EXTRACT — not canonical

This directory (when present) is a **comparison extract** of Core deploy/services/scripts.

Canonical operations code lives under `Core/deploy`, `Core/services`, and `Core/scripts`.
Do not edit copies here as product source. Development Agents must not treat this as a standard write target.

`deploy/`, `scripts/`, and `services/` are gitignored local payload — they are not part of the umbrella repository, so a fresh clone has only this notice. `services/` alone is ~242 MB of build output; delete it locally when you are not comparing.

Measure drift before trusting the copies:

```bash
./scripts/check-extract-drift.sh
```

Baseline 2026-09-16, measured against Core `b4ae815d7882ea8b90fee1ebd01dff67c7d5a343`
(the commit the umbrella pinned for `Core` at the time — `git ls-tree HEAD Core`):
`deploy` 2 entries · `scripts` 0 entries.

These counts only mean anything on a checkout that still has the gitignored payload.
