# OOO 開発計画（2026-10-22）

前版: `ooo-development-plan-2026-10-19.md`

## 本日の追加要件

PHP2Shell（CVE-2026-109618 / 109619）を把握し、自社開発内容を点検する。  
結果: **製品コードは影響なし**。運用 WordPress（malkk.com）はオペレーター対応。詳細は `php2shell-assessment-2026-10-22.md`。

## 実行順（承認済み方針を継承）

| 順 | 作業 | 状態 |
|----|------|------|
| 0 | PHP2Shell 影響評価 | 完了（製品影響なし） |
| 1 | 月次締め原子性・年次締め修正・給与/償却の誤計上拒否（製品） | 実装済・未コミット |
| 2 | MAL 2026-06 締め | データ修正→実行（給与料率が無ければロック不可を明示） |
| 3 | Core / Community / 傘を目的別にコミット → push → PR（`tenants/**` 除外） | 次 |
| 4 | 残存財務テスト失敗 27 件を原因別に修正 | その次 |

## MAL 2026-06 の前提

- 減価償却行が `category: other` になっている → `depreciation` に直す（JE-DEP 担当）。
- 課税仕入行に `purchase_use` / `invoice_status` が無い → May と同じ証憑タグを付ける（ダミー行の運用継続）。
- 給与行は JE-PAYROLL 必須。`payroll-rates-2026.yaml` が無いため、料率を捏造せず、締めが給与ゲートで止まる場合はそれを正とする。

## コミット分割方針

1. **Core: monthly-close safety** — 原子性、給与/償却の誤計上拒否、関連テスト
2. **Core: license GPL-2.0** — LICENSE / TERMS / package.json license
3. **Community: license + footer** — 同上 + フッター注記
4. **傘: license + Web footer + PROJECT-MAP** — 同上
5. artifacts レポートは傘に含める（テナントデータは含めない）

## 進捗更新（2026-10-22 夜）

- 財務テスト一式（`/tmp/files.txt` 81 files / 454 tests）: **全件パス**
- 修正要点:
  - 請求書 JE / invoice-generate: `counterparty_id` 欠落時は `property_id` にフォールバック
  - 会計 acceptance: bank e2e 後の stub 明細と reconciliation-events を整合（lite 読取可）
  - bonus 下書きテスト: 従業員・税社保・証憑を明示
  - external reconciliation: 小数は minor_unit>0 通貨で検証
  - agent-capability-manifest: tax skills drift を同期解消
  - HTTP/fixture: `setTenantEnv` + fixture payroll rates
- MAL 2026-06 月次ロック: 給与料率未整備のため引き続きブロック（別証跡）
- PHP2Shell: 製品コードに PHP なし。運用側 WordPress(malkk.com) はオペレータ対応

