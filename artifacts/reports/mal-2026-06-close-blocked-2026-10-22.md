# MAL 2026-06 月次締め — ブロック記録（2026-10-22）

## 実施内容

1. 月次 YAML を修正（未コミット・ローカルのみ）
   - 減価償却: `category: other` → `depreciation`
   - 運営費・通信費: `purchase_use` / `invoice_status` を付与
   - 通信費: 会社経費のため `counterparty_id: VENDOR-COMMS` を付与
   - 給与行: 月次損益へ載せない前提のまま（JE-PAYROLL 担当）
2. `closeAccountingMonth(2026-06, postDepreciation=false, postPayroll=false)` を実行

## 結果

| 項目 | 値 |
|------|-----|
| locked | false |
| ok | false |
| journal delta | 0（投稿後にロールバック） |
| period-locks | 変更なし |
| rolled_back_entry_ids | REV-RENT, REV-HOTEL-REVENUE, EXP-OTHER-PROPERTY, EXP-COMMUNICATION |

残ゲート: `payroll-posted: monthly salary rows 300000 yen have no payroll journal`

## 理由

`tenants/mal/data/finance/payroll-rates-2026.yaml` が存在しない。料率を推測で作成すると税務計算を捏造することになるため、作成していない。

## 次に必要な入力（人間）

1. 検証済みの `payroll-rates-2026.yaml`（有効期間・健保/年金の標準報酬を含む）
2. または税理士確定の源泉・社保額を明示したうえで JE-PAYROLL-2026-06 を計上

その後、同じ close を再実行すれば月次損益＋ロックまで進む想定（原子性は本日の製品修正で担保済み）。
