# アーキテクチャ是正 — 実施記録（2026-09-11）

作業ツリー: `/Users/kk/ooo-arch-remediation`（OOO / Core / Community 各 `chore/arch-remediation-2026-09-11`）。  
元の `/Users/kk/OOO`・`Core`・`Community` の dirty/untracked には未接触。commit / push / 公開 / デプロイは未実施。

開始時点（元ツリー、秘密・テナント本文は出さない）:

| リポ | HEAD / branch | status |
|------|----------------|--------|
| OOO 傘 | `17e2c71` `main` | `M Community` `M Core`、未追跡: 本指示レポート |
| Core | `4c14df6e` `ooo/migration-ooo-root` | テナント・製品ファイルの多数 modified/deleted/untracked |
| Community | `ef412a4` `main` (origin より 1 commit 先行) | i18n・compose・approve ほか多数 dirty |
| 親 submodule 記録 | Community `d77188e` / Core `fe6fd6b`（いずれも現 HEAD と不一致） | |

今回の差分は上記 dirty とは別（worktree 上の規約・生成・検査）。

---

## 問題ごとの判定（コード再確認後）

### P1-A Web 正本・生成先・公開元 — 修正済み（Git 方針は未決定）

**開始時:** 不足。`Web/package.json` の `build` が `../Community` の `overview:links` を呼び、生成先は `Community/packages/shared/scripts/generate-overview-links.ts` で `sites/coming-soon` 固定。公開 WF は `Community/.github/workflows/deploy-oorgos-org.yml` が同ディレクトリ。`sync-to-community` は無条件 `rsync --delete`。

**修正:**

- 生成先を `OVERVIEW_DIR` / `--dir` で明示（既定は従来どおり Community ミラー）: `Community/packages/shared/scripts/generate-overview-links.ts` 16–34 行付近
- Web `build` / `overview:links` は `Web/scripts/generate-overview.sh` 経由で **Web 自身**へ書く。`COMMUNITY_ROOT` でジェネレータ位置を指定（個人ホームの絶対パス固定なし）
- 同期は別コマンド。既定 dry-run。`--apply` のみ書込。ミラーの `git status` が dirty なら停止: `Web/scripts/sync-to-community.sh`
- 除外: `Web/sync-excludes.txt`

**検証:** 一時ディレクトリへ生成成功。Web 生成前後で worktree の `Community/sites/coming-soon` チェックサム同一。dry-run で itemized 差分表示。ミラーに未コミットを足すと `--apply` が拒否（その後 checkout でプローブのみ戻した）。

**残:** Web の Git 管理は承認待ち（下記案）。公開 WF は引き続き Community ミラー。`npm run overview:links` を Community 単体で走らせると従来どおりミラーへ書く（意図した既定）。

### P1-B 開発用 Agent の worktree — 部分実装（業務 dispatch は未変更）

**開始時:** 確認済みの経路あり。`Core/src/lib/agent-dispatch.ts` 349 行 `local: { cwd: ROOT_DIR }` は **業務 AIA**（Work Order / テナント）。呼出: `buildDispatchManifest` → `runCursorTask`。`runWithFsGuardAgentAsync` はポリシーALSであり OS サンドボックスではない。

**修正:** 業務経路は worktree 化していない（コメントのみ 349 行付近）。開発用は `scripts/dev-task.sh`（1作業=1ブランチ=1worktree、task YAML、inspect が staged/unstaged/untracked を見、範囲外は削除せず拒否）。`AGENTS.md` に「規約・検査であり隔離保証ではない」と明記。

**検証:** 一時 git で `denied.txt` 変更を `--allow allowed.txt` が拒否。2作業の同時実行実測（2つの Core worktree で未コミットが混ざらないこと）は未実施。

**残:** Cursor SDK 外部の隔離は未検証。サンドボックスは無し。

### P1-C テスト共有テナント — 部分実装

**開始時:** 確認済み。`Core/tests/setup-restore-protocol.ts` 242–251 行は警告のみ。`FIXTURE_PATHS` は `ROOT_DIR`（`orgos-paths` / cwd）の committed テナント。復元ロックは直列、本体は共有。

**修正:** 既定で第二 vitest を拒否（`ORGOS_TEST_ALLOW_CONCURRENT=1` のみ警告）。`tests/helpers/fixture-restore-lock.ts` の `concurrentVitestPolicy`。`tests/fixture-restore-lock.test.ts` 4 件 PASS。

**残:** 作業ごとの一時テナント/DB/ポート/Docker 分離は未実装。共有 fixture は残る。2プロセス実走の待機は未検証（拒否ロジックのみ）。実運用テナントを触るテストの全列挙は未了。

### P1-D worktree 登録 — 調査済み、修復は未実施（承認待ち）

いずれもディレクトリは存在し `.git` 参照は解決する。**壊れていると即断しない。**

Core `git worktree list`（`/Users/kk/OOO/Core`）には `OS_Steward-*` と `Documents/Codex/.worktrees/*` が載る。各ツリーの `git-common-dir` は **`/Users/kk/OS_Steward/.git`**。一方 OOO Core 本体は `.git` がディレクトリで `git-common-dir` は自分自身。移行時に `.git/worktrees` メタデータがコピーされたため、**一覧上の二重登録**がある。実作業はレガシー git オブジェクト側。

Community も同様: `OS_Community-*` の common-dir は `/Users/kk/OS_Community/.git`。OOO Community 本体は独立 `.git`。

今回追加: `/Users/kk/ooo-arch-remediation/{Core,Community}` はそれぞれ OOO 側 `.git/worktrees` に正常登録。

**修復案（承認後のみ）:** レガシー削除サインオフと一体で、(1) 不要 worktree を **その common-dir のリポ**から `git worktree remove`、(2) OOO 側に残ったコピー登録だけなら当該リポで `git worktree prune`。`.git` 直接編集はしない。正常な進行中 worktree は残す。

### P2-A 比較用コピー — 規約で分離（削除せず）

**開始時:** 確認済み。Console に二重配置、Auth/tenants/operations は抽出。

**修正:** `PROJECT-MAP.yaml` に `role`（canonical / extract / mirror / runtime）。`Console/EXTRACT-NOT-CANONICAL.md`、`Auth/EXTRACT-NOT-CANONICAL.md`、`operations/EXTRACT-NOT-CANONICAL.md`、`tenants/GIT-POLICY.md`。Auth を共通パッケージへは昇格していない。

### P2-B IDE 横断入口 — 実装済み（自動読込は仮定しない）

`AGENTS.md`（OOO）、`Community/AGENTS.md`、`.cursor/rules/ooo-root.mdc`（ポインタのみ）。Core `AGENTS.md` は未改変。管理規約の Git 先は Web と同じく **OOO 傘リポ**を推奨（下記）。

### P2-C 開発パス — 修正済み

`dev-env.sh`: 既存 env 保全。未設定時は **スクリプト位置**を `OOO_ROOT` にする。cwd は Core の `orgos-paths.ts` に任せる。

**検証:** 一時ディレクトリへスクリプトをコピーして source → そのディレクトリが `OOO_ROOT`。`ORGOS_HOME=/explicit/core` は保持。

### P2-D CLI/Web 共有 — 一部実装済み、網羅は未検証

設計: `Core/steward/rules/engineering/01-architecture.md` 79–80 行「GUI and API must execute the same Application commands」。

標本: `org approval approve` は `src/commands/org.ts` → `src/lib/org/approval/`。MCP は承認ツールを持たず CLI/UI へ誘導（`src/lib/mcp/tools.ts`）。業務 dispatch の cwd はテナント。**今回、根拠のないパッケージ分割はしていない。** 全経路一致の検査 CI は未追加。

### P2-E 共有資源・CI — 一部修正

列挙を `PROJECT-MAP.yaml` `shared_resources_integrator_owned` と `AGENTS.md` に追加。Community CI の `npm install` を **`npm ci`** に変更（`.github/workflows/ci.yml` build / e2e）。`i18n:sync` と `audit:web-stability:write` は生成書込のまま（意図しない差分検出は未追加）。Core 既存 CI の作り直しはしていない。SSO 契約の自動一致テストは未追加。

---

## 最終判定（保証できる範囲）

| モード | 保証できる | 保証できない |
|--------|------------|--------------|
| 単独開発 | Web build がこの worktree の Community を書き換えない。同期 dry-run と dirty 停止。dev-env がスクリプト位置に追従。同一 worktree の第二 vitest は既定拒否 | ジェネレータに Community checkout + tsx が必要。公開はまだ Community WF |
| 複数 IDE の分離開発 | 同じ worktree パスを開ける。inspect が範囲外を拒否 | worktree は権限隔離ではない。別 IDE が別パスを開けば書ける |
| 複数 AIA の自動並行開発 | 業務 dispatch を壊す変更はしていない | 自動で 1作業1worktree を強制しない。テスト資源の完全分離なし。並行統合は不可 |

---

## 承認が必要な具体案

### 1. Web と OOO 規約の Git（推奨: 案A）

| 案 | 内容 | 推奨 |
|----|------|------|
| **A** | 現状どおり Web・AGENTS.md・PROJECT-MAP を **OOO 傘リポ**で追跡。公開は同期後に Community `sites/coming-soon` | **推奨**。追加リモート不要。正本とミラーがリポで分かれる |
| B | Web を独立 GitHub リポにし Vercel をそこへ向ける | 公開と編集は単純。サブモジュールが増える |
| C | Web 正本を Community 内へ戻す | 今回の「Web が正本」と逆。非推奨 |

リポジトリ再編・正本移動は未実施。

### 2. P1-D worktree メタデータ

上記修復案。レガシー `OS_Steward` / `OS_Community` 削除と同時が安全。単独 prune は進行中 Codex/OS_Steward worktree を巻き込みうる。

### 3. テスト完全隔離

一時テナント + 専用 DB/ポートまでやるか。今回は拒否のみ。全面分離は工数が大きく、運用テナント dirty と干渉しやすい。

### 4. 本 worktree の取り込み

マージ・commit は未実施。取り込まない場合は worktree 削除前にこのレポートを残すか指示が必要。

---

## 質問（判断が必要な再編）

1. Web/規約の Git は案Aでよいか。
2. レガシー worktree 登録の prune を、レガシー削除サインオフまで待つか。
3. テスト隔離を「拒否で十分」とするか、一時 fixture まで進めるか。
4. この worktree を元へマージするか（commit 承認が別途必要）。
