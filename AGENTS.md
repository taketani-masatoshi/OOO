# OOO 開発規約（IDE 横断の入口）

**正本:** 本書（ツール非依存）。Core のセキュリティ・承認ルールは弱めない。  
業務用 AIA（テナント操作）と、開発用 Agent（ソース編集）は別物である。

起動時: このファイルを読み、対象リポジトリの `AGENTS.md` があれば続ける。Cursor 以外の IDE が自動読込するとは限らない。

| 対象 | ファイル |
|------|----------|
| 業務オペレータ境界 | `Core/AGENTS.md`（正本 `Core/steward/rules/operator-policy.md`） |
| エンジニアリング憲章 | `Core/steward/rules/engineering/` |
| 正本マップ | `PROJECT-MAP.yaml` |
| パスヘルパー | `dev-env.sh` |

## 正本

| 領域 | 編集する | 編集しない |
|------|----------|------------|
| Core | `Core/`（独立 Git） | レガシー `OS_Steward`、抽出物 `Console/` `Auth/` トップ `tenants/` |
| Community | `Community/`（独立 Git） | レガシー `OS_Community` |
| Web / oorgos.org | `Web/` | `Community/sites/coming-soon` を優先編集しない |
| Console 実装 | `Core/apps/wire-console` 等 | `Console/` 抽出 |
| Auth 実装 | 各リポ内の認証コード | `Auth/` 抽出（共通パッケージへ昇格しない） |
| テナント運用データ | `Core/tenants`（cwd 検出） | トップ `tenants/` 比較コピー、実運用イベントの検証改変 |

## 作業隔離（開発用 Agent）

1 作業 = 1 ブランチ = 1 worktree。手順: `scripts/dev-task.sh start`。  
業務用 `agent dispatch`（`Core/src/lib/agent-dispatch.ts`）はテナント cwd で動く。Git worktree には切り替えない。

worktree はアクセス権のサンドボックスではない。別ツリーへの書込みは OS では禁止できない。制御は規約と `scripts/dev-task.sh inspect` による検査である。

## 共有資源（統合担当が所有）

package.json / lockfile、schema、DB migrations、認証契約、生成 registry、CI。  
各 Agent は提案差分のみ。同時に直接統合しない。

## 検証

```bash
# Web: 生成は Web 自身。Community は変わらないこと
cd Web && npm run build
cd Web && npm run sync-to-community   # dry-run。未反映変更があれば停止

# Core（対象リポの worktree で）
cd Core && npx vitest run tests/fixture-restore-lock.test.ts
```

人間が判断・最終承認する。commit / push / 公開 / デプロイはこのファイルだけでは許可されない。
