# MAL 2026-05 月次締め baseline（2026-09-25）

読み取りのみ。金額・個情・秘密は記載しない。

## 環境

- Core branch: `cursor/finance-tax-remediation-2026-09`
- `ORGOS_TENANT=mal`
- 会社 `fiscal_year_end_month=1` → FY 開始月は 2 月（2026-05 の先行ロックは 2026-02→03→04）

## period-locks

- `2026-01`: 最終状態 **unlocked**（locked の後に unlocked 行あり）
- `2026-02`〜`2026-05`: ロック行なし

## validate（finance path error）

`npm run orgos -- validate --warnings` より finance 関連:

| 種別 | 内容（識別子のみ） |
|---|---|
| bs_class | 1100, 1200, 1210, 1290, 2100, 2120, 2130, 2140 |
| statutory remittance | withholding / social_insurance past deadline（as-of=実行日） |

非 finance: `steward/core/agents/agent-capability-manifest.yaml` skills drift（月次締めゲートの path フィルタ外）

## 月次ゲート実測

| month | locked | can_lock | error ids |
|---|---|---|---|
| 2026-01 | false | false | depreciation-posted, payroll-posted, monthly-pl-posted, prior-month-locked(2025-12), validate |
| 2026-02 | false | false | depreciation-posted, payroll-posted, monthly-pl-posted, validate（prior なし＝FY 初月） |
| 2026-03 | false | false | depreciation-posted, payroll-posted, monthly-pl-posted, prior-month-locked, validate |
| 2026-04 | false | false | depreciation-posted, payroll-posted, monthly-pl-posted, prior-month-locked, validate |
| 2026-05 | false | false | depreciation-posted, payroll-posted, prior-month-locked(2026-04), balance-sheet(bs_class 1150/2110/2160/2170), consumption-tax(JE-MPL-…/5900), validate |

試算表 2026-05-31: balanced=true。月次突合は warning 扱いのため can_lock 非阻害。

## handoff との差分

- handoff「validate 5件」→ 実測 **11 finance errors**（bs_class 8 + remittance 3）
- 追加ブロッカー: **depreciation**（historical snapshot 欠落で error）、**payroll-posted**、02–04 の **monthly-pl-posted**
- 消費税: May の MPL 費用行に `tax_amount_yen` / `purchase_use` / `invoice_status` 欠落（投稿経路が未伝播）

## 次アクション向けメモ

1. 製品: MPL 費用行へ税証憑フィールド伝播、証憑不足の明示、close 投稿前 fail-closed、締め validate の remittance を月次 as-of に限定、historical dep を skip 可能に
2. MAL: CoA 全 BS 科目に bs_class、既存 May MPL 行の証憑補完、必要なら payroll/MPL 計上
3. ロック連鎖: 2026-02 → 03 → 04 → 05
