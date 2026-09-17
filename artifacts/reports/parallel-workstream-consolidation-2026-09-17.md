# 作業面の分裂整理 — 正本宣言と棚卸し（2026-09-17）

## 正本宣言（今週）

| 領域 | 正本 | tip SHA | PR |
|------|------|---------|-----|
| OpenOrgOS（製品） | `cursor/mal-operations-dashboard` | `a65569eaf41e04d067827df78784655793b71476` | [#40](https://github.com/taketani-masatoshi/OpenOrgOS/pull/40) |
| 傘 OOO | `cursor/secretary-workbench-tasks` | `b84b8158cdf74e1b4312486b34ce70a91048c0ce` | [#12](https://github.com/taketani-masatoshi/OOO/pull/12) |

ローカル傘 checkout `feat/react-flow-module-map` は tip `b84b815` と同一（別名）。中身の分岐ではない。

**他 PR / worktree は待機。** ready な製品正本候補は #40 のみ。

## 保護 SHA

- OpenOrgOS #40: `a65569ea`（finance 席ゲート / `check:tenant-tip` / tenant provision clean 含む）
- 傘 #12: `b84b815`

## PR 群分類

| 群 | PR | 扱い |
|----|-----|------|
| A 正本 | OpenOrgOS #40, OOO #12 | 唯一の取り込み対象 |
| B CI衛生 | #42 fixture-guard, #39 tip-guard | #40 CI 支援。tip スクリプトは #40 を正 |
| C 従属 | #43 workflow-canvas | #40 merge 後に rebase。並行 merge 禁止 |
| D 直交 | #46 module-flow | 後回し可 |
| E 広域 | #44 commercial-readiness | A/B 完了後 |
| Z 休眠 | OOO #7/#9、旧 OS_Steward worktree | superseded 注記 / 未コミット退避後に閉鎖 |

## 公開候補から除外

- `/Users/kk/OOO/Core` 上の `tenants/mal/**` を含む未コミット（数十件）
- 製品 dirty（hospitality / HR / ledger / PassKey 等）— 正本 tip に混ぜない
- 傘 `?? Core-worktrees/`、artifacts 報告（本レポートは例外として生成物）

## Worktree 棚卸し（開始時）

| path | branch | dirty |
|------|--------|------:|
| `/Users/kk/OOO/Core` | mal-operations-dashboard | 多（テナント含む） |
| `ooo-core-fixture-guard` | fixture-guard | 0 |
| `ooo-core-tip-guard-rebase` | tip-guard | 2 |
| `ooo-core-tipguard` | commercial-readiness | 0 |
| `Core-worktrees/workflow-canvas` | workflow-canvas | 0 |
| `Core-worktrees/react-flow-ui` | detached | ? |
| `wt-sanity-90` | fix/sanity-90pt | ? |
| 多数の `OS_Steward-*` | 旧線 | 0〜43 |

## 固定ルール

- discard / reset --hard しない
- `tenants/mal/**` を GitHub に載せない
- #40 の CI が緑になるまで main merge しない
- #43 と #40 を同時期に main へ入れない

## 実施ログ（同日）

- Phase 0: 本ファイル作成。保護 SHA 記録。
- Phase 1: Core dirty を `wip/local-product-2026-09-17` / `wip/local-tenant-mal-2026-09-17` にローカル退避（未 push）。clean worktree `mal-ops-publish` 作成。傘を `cursor/secretary-workbench-tasks` に揃え。
- Phase 2: #40 に CI 修正を積む（demo 固定、treasury .gitkeep、demo payroll、canonical baseline、payroll optional validate）。smoke は pass に到達。validate 再実行待ち。main merge は CI 緑後のみ。
- Phase 3: #43/#46/#44/#39/#42 に正本整理コメント。#43 は draft 維持。rebase は #40 merge 後。
- Phase 4: 休眠傘 PR #7/#9 close。旧 OS_Steward worktree 多数を `wip/quarantine-*` 退避後に削除（ローカルのみ、push しない）。
- Phase 5: workstream-guardrails-2026-09-17.md を追加。

