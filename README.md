# OOO — OpenOrgOS 日常開発ルート（3B）

この Git リポジトリ（`git rev-parse --show-toplevel`）が日常開発の正本ワークスペースです。  
人向けの要約は本 README、編集規則の正本は [`AGENTS.md`](AGENTS.md) と [`PROJECT-MAP.yaml`](PROJECT-MAP.yaml) です。

レガシーパスは比較用に残置 — **削除しない**。テナント実データは GitHub に載せない。

---

## 作業のしかた

| 領域 | kind | 開発ルート | メモ |
|------|------|------------|------|
| **Core** | product | `Core/` | OpenOrgOS。CLI / テナント / Console ビルドもここ |
| **Community** | product | `Community/` | `community.oorgos.org` |
| **Web** | product | `Web/` | oorgos.org の正本編集パス |
| **Console / Auth / ops** | extract | 編集しない | [`extracts/`](extracts/) — 各 `EXTRACT-NOT-CANONICAL.md`。乖離は `./scripts/check-extract-drift.sh` |

### Web（oorgos.org）

- 編集は `Web/` のみ（`Community/sites/coming-soon` を優先編集しない）
- 公開時は Web から直接 Vercel、または `npm run sync-to-community` で Community に戻してからデプロイ

```bash
./scripts/install-hooks.sh   # clone 直後に1回（テナント保護 hook を有効化）
source ./dev-env.sh          # このファイル位置から OOO_ROOT を解決（既存 env は上書きしない）
cd "$ORGOS_HOME"             # 既定は <repo>/Core
```

`core.hooksPath` を設定しないと `.githooks/pre-commit` と `pre-push` は動きません。

Core は通常、cwd から `tenants/` を自動検出します。

---

## ルートの見え方

```text
Core/ Community/ Web/     # product — ここだけ直す
extracts/                 # 見本（auth, console, provisional-canvas-web, operations）
archive/                  # 移行記録
artifacts/                # generated（レポート追記のみ）
runtime-private/          # ローカル専用（GitHub に載せない）
tenants/                  # GIT-POLICY.md と 00-README.md のみ
```

---

## レガシーパス（非正本）

このリポジトリ外のローカル checkout。移行当時の実パスは [`archive/MIGRATION-REPORT.md`](archive/MIGRATION-REPORT.md) にあります。

- `OS_Steward`（旧 Core）
- `OS_Community`（旧 Community）
- `Codex`（Core 候補・未採用）

**今は削除しないでください。**

---

## Git 構成

| パス | Git? | Remote |
|------|------|--------|
| このリポジトリ（トップ） | Yes（傘） | [taketani-masatoshi/OOO](https://github.com/taketani-masatoshi/OOO) |
| `Core/` | submodule | [taketani-masatoshi/OpenOrgOS](https://github.com/taketani-masatoshi/OpenOrgOS) |
| `Community/` | submodule | [taketani-masatoshi/OS_Community](https://github.com/taketani-masatoshi/OS_Community) |

```bash
git clone --recurse-submodules https://github.com/taketani-masatoshi/OOO.git
```

**ポスト規則:** テナント情報は GitHub に載せない。傘 `tenants/` で載せるのは `GIT-POLICY.md` と `00-README.md` の2つだけ。`extracts/operations/` の payload と `runtime-private/` も公開しません。

`./scripts/install-hooks.sh` を1回実行すれば、この規則を pre-commit / pre-push が止めます（CI は `no-tenant-post`）。

---

## 関連ドキュメント

- 正本マップ: [`PROJECT-MAP.yaml`](PROJECT-MAP.yaml)
- 入口規約: [`AGENTS.md`](AGENTS.md)
- Web: [`Web/README.OOO.md`](Web/README.OOO.md)
- 移行記録: [`archive/`](archive/)

---

## 現状ステータス

- **verification_gates_green** — 主要ゲートは OOO 上で PASS（2026-09-07）
- **development_canonical_ooo** — 3B により日常開発正本を宣言済み
- **web_canonical** — `Web/` が coming-soon の正本編集パス
- **github** — 傘リポジトリあり。テナント実データの push は禁止
- **legacy_deletion** — 未実施（人間サインオフ待ち）
