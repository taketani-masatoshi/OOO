# OOO — OpenOrgOS 日常開発ルート（3B）

**OOO (`/Users/kk/OOO`) が日常開発の正本（development canonical）です。**  
決定: **3B**（2026-09-07）。レガシーパスは比較用に残置 — **削除しない**。GitHub への push は別途承認があるまで **しない**。

EN: `/Users/kk/OOO` is the daily development canonical root (decision **3B**). Legacy trees stay for comparison; do not delete. Do not push to GitHub until separately approved.

---

## 作業のしかた / How to work

| 領域 | 開発ルート | メモ |
|------|------------|------|
| **Core** | `/Users/kk/OOO/Core` | OpenOrgOS monorepo。CLI / tenants / Console ビルドもここ |
| **Community** | `/Users/kk/OOO/Community` | `community.oorgos.org`（Next.js + Docker） |
| **Web** | `/Users/kk/OOO/Web` | **正本編集パス** — oorgos.org coming-soon 全文。ここを編集する |
| **Console** | Core monorepo 経由 | `cd /Users/kk/OOO/Core && npm run wire-console:build`（＋ `operator-console:build`） |

### Web（oorgos.org）

- **編集は `/Users/kk/OOO/Web` のみ**（`Community/sites/coming-soon` を優先編集しない）
- 公開時は Web から直接 Vercel、または `npm run sync-to-community` で Community に戻してからデプロイ

任意の環境ヘルパー:

```bash
source /Users/kk/OOO/dev-env.sh   # OOO_ROOT / ORGOS_HOME を設定（任意）
cd "$ORGOS_HOME"                 # = /Users/kk/OOO/Core
```

Core は通常、cwd から `tenants/` を自動検出します（`ORGOS_HOME` / `ORGOS_WORKSPACE` は任意上書き）。

---

## レガシーパス（非正本）

次は **まだディスク上に残っています**が、**日常開発の正本ではありません**:

- `/Users/kk/OS_Steward`（旧 Core）
- `/Users/kk/OS_Community`（旧 Community）
- `/Users/kk/Documents/Codex`（Core 候補・未採用）

**今は削除しないでください。** 人間の差分レビューと削除サインオフが済むまで保持します。

---

## Git 構成

| パス | Git? | Remote |
|------|------|--------|
| `/Users/kk/OOO`（トップ） | Yes（傘リポジトリ） | [taketani-masatoshi/OOO](https://github.com/taketani-masatoshi/OOO) |
| `/Users/kk/OOO/Core` | Yes（submodule） | [taketani-masatoshi/OpenOrgOS](https://github.com/taketani-masatoshi/OpenOrgOS) |
| `/Users/kk/OOO/Community` | Yes（submodule） | [taketani-masatoshi/OS_Community](https://github.com/taketani-masatoshi/OS_Community) |

クローン:

```bash
git clone --recurse-submodules https://github.com/taketani-masatoshi/OOO.git
```

`tenants/` の実データ、`operations/` 抽出、`runtime-private/` は公開しません。Core / Community の未コミット作業ツリーもこの傘リポには含めません。

---

## 関連ドキュメント

- フル再同期レポート: [`artifacts/reports/ooo-full-resync-2026-09-07.md`](artifacts/reports/ooo-full-resync-2026-09-07.md)
- 完了チェックリスト: [`artifacts/reports/completion-checklist-2026-09-07.md`](artifacts/reports/completion-checklist-2026-09-07.md)
- GitHub push 候補（**push 承認待ち**）: [`artifacts/reports/github-push-candidates-2026-09-07.md`](artifacts/reports/github-push-candidates-2026-09-07.md)
- 正本切替記録（1A / 2B / 3B）: [`artifacts/reports/canonical-switch-3B-2026-09-07.md`](artifacts/reports/canonical-switch-3B-2026-09-07.md)
- 移行レポート: [`MIGRATION-REPORT.md`](MIGRATION-REPORT.md)
- プロジェクトマップ: [`PROJECT-MAP.yaml`](PROJECT-MAP.yaml)
- Web スロット: [`Web/README.OOO.md`](Web/README.OOO.md)

---

## 現状ステータス

- **verification_gates_green** — §7 主要ゲートは OOO 上で PASS
- **development_canonical_ooo** — 3B により日常開発正本を宣言済み
- **web_canonical** — `/Users/kk/OOO/Web` が coming-soon の正本編集パス
- **github_push** — 未実施（人間承認待ち）
- **legacy_deletion** — 未実施（人間サインオフ待ち）
