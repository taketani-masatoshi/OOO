# OOO 開発の入口

対象リポジトリの AGENTS.md と `PROJECT-MAP.yaml` も読む。Core の承認・機密情報・台帳保全ルールを弱めない。

パスはリポジトリ相対（`git rev-parse --show-toplevel`）。`kind: product` かつ `edit: true` は `Core/` `Community/` `Web/` だけ。傘ルートは `kind: workspace` で、`edit_paths` に書いたファイル以外は直さない。`extract` / `archive` / `private` は見本またはローカル専用。迷ったら直さない。

## 正本

| 領域 | kind | 編集する | 編集しない |
|------|------|----------|------------|
| 傘 | workspace | `edit_paths`（AGENTS、PROJECT-MAP、README、dev-env、`.cursor/rules`、scripts 等） | extract 全体をルート扱いで触ること |
| Core | product | `Core/`（独立 Git） | レガシー `OS_Steward`、`extracts/` |
| Community | product | `Community/`（独立 Git） | レガシー `OS_Community` |
| Web / oorgos.org | product | `Web/` | `Community/sites/coming-soon`（generated ミラー） |
| Console 実装 | product in Core | `Core/apps/wire-console` 等 | `extracts/console/` |
| Auth 実装 | product in Core/Community | 各リポ内の認証コード | `extracts/auth/` |
| テナント運用データ | product in Core | `Core/tenants`（cwd 検出） | 傘 `tenants/`（方針文書以外） |
| operations | extract | （正本は `Core/deploy` 等） | `extracts/operations/`（無い checkout あり） |
| artifacts | generated | レポート追記のみ | 製品ソースの代わりにしない |
| archive | archive | しない | `archive/`（移行記録） |
| runtime-private | private | しない（GitHub にも載せない） | 秘密のコミット |

業務用 AIA の dispatch と開発用 worktree は別。commit / push / 公開・実テナント変更は、この規約を読むだけでは許可されない。
