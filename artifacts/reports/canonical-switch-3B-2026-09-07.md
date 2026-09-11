# Canonical switch record — decision 3B

**Timestamp:** 2026-09-07T07:05:00+09:00 (Asia/Tokyo)  
**Status recorded:** `DEVELOPMENT_CANONICAL_OOO`  
**Actor:** human choice via operator (parent agent task)

---

## Decisions

| Step | Choice | Meaning |
|------|--------|---------|
| **1A** | Done (prior) | Verification / Definition A path — major gates green under `/Users/kk/OOO` |
| **2B** | Done (prior) | GitHub push candidates prepared; **push not executed** (awaiting separate approval) |
| **3B** | **Declared this pass** | Daily development canonical root = **`/Users/kk/OOO`**. Legacy paths **retained** (not deleted). |

Not chosen / not done:

- Legacy delete / `rm` of `/Users/kk/OS_Steward` or `/Users/kk/OS_Community`
- GitHub `git push` to OpenOrgOS or OS_Community
- Treating legacy trees as development canonical

---

## Development roots (post-3B)

| Area | Path |
|------|------|
| OOO umbrella | `/Users/kk/OOO` |
| Core | `/Users/kk/OOO/Core` |
| Community | `/Users/kk/OOO/Community` |
| Web (coming-soon slot) | `/Users/kk/OOO/Web` (edit prefer `Community/sites/coming-soon`) |
| Console | via Core monorepo builds |

## Legacy retention

| Path | Role after 3B |
|------|----------------|
| `/Users/kk/OS_Steward` | Comparison only — **not** development canonical |
| `/Users/kk/OS_Community` | Comparison only — **not** development canonical |
| `/Users/kk/Documents/Codex` | Unselected Core candidate — retained |

**Policy:** keep until human explicitly deletes after gap review + migration-complete sign-off.

---

## Docs updated this pass (OOO only)

- `/Users/kk/OOO/PROJECT-MAP.yaml` — `root.canonical`, `development_canonical`, `legacy_retention`, status flags, Core/Community `actual_source_note`
- `/Users/kk/OOO/README.md` — daily-work guide (JA + brief EN)
- `/Users/kk/OOO/MIGRATION-REPORT.md` — status → `DEVELOPMENT_CANONICAL_OOO`
- `/Users/kk/OOO/artifacts/reports/completion-checklist-2026-09-07.md` — criterion #13 → **STARTED**
- `/Users/kk/OOO/dev-env.sh` — optional `ORGOS_HOME` / `OOO_*` helpers
- This file

**Not modified:** `/Users/kk/OS_Steward`, `/Users/kk/OS_Community` working trees (read-only if referenced).

---

## Still blocked

1. GitHub push — see `github-push-candidates-2026-09-07.md`
2. Human gap/diff sign-off vs legacy
3. Human sign-off for legacy deletion
