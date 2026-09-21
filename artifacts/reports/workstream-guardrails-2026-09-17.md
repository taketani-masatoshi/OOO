# 作業面ガード（1目的1ブランチ）

正本宣言の詳細: [parallel-workstream-consolidation-2026-09-17.md](./parallel-workstream-consolidation-2026-09-17.md)

## ルール

1. **OpenOrgOS の ready 正本候補 PR は同時に1つ**（現在: #40 `cursor/mal-operations-dashboard`）。
2. エージェント開始時は各 git ルートで `git status`。dirty なら **新規 worktree**。正本 tip 上で別作業を混ぜない。
3. `tenants/mal/**` のローカル差分は **push しない**。退避は `wip/local-tenant-mal-*`（ローカル専用）。
4. 従属 PR（#43 workflow-canvas）は正本 merge 後に rebase。正本と同時 merge しない。
5. 傘の Web/React Flow 実験は Core 側 PR（#46/#43）へ。傘は #12 を継続。

## 残してよい worktree（目安）

- `/Users/kk/OOO/Core` — 正本 checkout
- `Core-worktrees/mal-ops-publish` — #40 CI / publish 作業
- （必要時のみ）tip-guard / fixture 用 1 本

それ以外の旧 `OS_Steward-*` は閉鎖済み（差分は `wip/quarantine-*` ローカルブランチに退避、**push 禁止**）。
