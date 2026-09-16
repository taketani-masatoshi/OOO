# OOO 開発の入口

対象リポジトリの AGENTS.md と `PROJECT-MAP.yaml` も読む。Core の承認・機密情報・台帳保全ルールを弱めない。

`PROJECT-MAP.yaml` の `kind` が `product` かつ `edit: true` のパスだけを編集する。`extract` / `archive` / `private` は見本またはローカル専用。迷ったら直さない。

## 正本

編集してよい製品は次の3つだけ。Auth・Console・operations・傘の `tenants/` 実データは extract。

| 領域 | kind | 編集する | 編集しない |
|------|------|----------|------------|
| Core | product | `Core/`（独立 Git） | レガシー `OS_Steward`、抽出物 `Console/` `Auth/` トップ `tenants/` |
| Community | product | `Community/`（独立 Git） | レガシー `OS_Community` |
| Web / oorgos.org | product | `Web/` | `Community/sites/coming-soon`（generated ミラー） |
| Console 実装 | product in Core | `Core/apps/wire-console` 等 | `Console/` extract |
| Auth 実装 | product in Core/Community | 各リポ内の認証コード | `Auth/` extract |
| テナント運用データ | product in Core | `Core/tenants`（cwd 検出） | トップ `tenants/` 比較コピー |
| operations | extract | （正本は `Core/deploy` 等） | `operations/` |
| artifacts | generated | レポート追記のみ | 製品ソースの代わりにしない |
| runtime-private | private | しない（GitHub にも載せない） | 秘密のコミット |

業務用 AIA の dispatch と開発用 worktree は別。commit / push / 公開・実テナント変更は、この規約を読むだけでは許可されない。
