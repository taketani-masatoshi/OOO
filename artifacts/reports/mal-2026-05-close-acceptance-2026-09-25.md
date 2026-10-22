# MAL 2026-05 月次締め受入（2026-09-25）

## 受入結果

| 区分 | 結果 |
|---|---|
| MAL 2026-05 `locked` | **true** |
| MAL 2026-05 `can_lock`（default `evaluateMonthlyCloseGates`） | **true**（errors=[]） |
| 先行月 2026-02〜04 | いずれも `locked=true` / `can_lock=true` |
| 合成 `tests/monthly-close-acceptance.test.ts` | **19/19 PASS**（`ORGOS_TEST_DISPOSABLE_ROOT` 指定） |
| 法定申告 / e-Tax | **未対応**（対象外） |
| tenants/mal の commit / push | **未実施** |

Baseline: [mal-2026-05-close-baseline-2026-09-25.md](mal-2026-05-close-baseline-2026-09-25.md)

## 実施した製品変更（Core）

| 内容 | 主なパス |
|---|---|
| MPL 課税費用へ `tax_amount_yen` / `purchase_use` / `invoice_status` 伝播。欠落は投稿前に拒否 | `src/lib/finance/journal-sources.ts`, `schemas/finance/monthly-loans.ts` |
| 消費税証憑不足メッセージに不足フィールドを明示 | `src/lib/finance/consumption-tax.ts` |
| 歴史月の減価償却スナップショット欠落は skip | `src/lib/finance/monthly-close.ts` |
| 給与料率/標準報酬未整備は skip（推定計算しない） | 同上 |
| 締め validate の remittance を月次 as-of 以降の期限で除外 | 同上 |
| 投稿前の hard gate 失敗で仕訳を書かない | 同上 |
| 証憑不足・hard gate の acceptance 失敗ケース | `tests/monthly-close-acceptance.test.ts`, `tests/helpers/finance-fixture.ts` |

## MAL ローカル入力（未コミット）

| 内容 | 根拠 |
|---|---|
| CoA に `bs_class` / `cf_role` | fixture と同型の会社法区分 |
| 2026-01〜05 monthly 費用に `purchase_use=taxable_only`, `invoice_status=qualified` | 課税売上が主の事業費用としての運用者宣言（推測控除エンジンではない） |
| 既存 `JE-MPL-2026-05-EXP-*` に税額・用途・インボイス区分 | 同一仕訳の 2170 借方を `tax_amount_yen` に転記 |
| 2026-02→05 を `finances close --no-depreciation --no-payroll` で順ロック | 資産スナップショット as_of=2027-01、給与料率未登録のため |

## 残リスク

1. **給与**: 料率 YAML と標準報酬が無いため payroll ゲートは skip。通年の給与計上・納付は別作業。
2. **減価償却**: 2026 月は historical snapshot 欠落で skip。スナップショット整備後に再評価が必要。
3. **締め原子性**: 投稿前 fail-closed のみ。仕訳+証跡+ロックの一体ロールバックは未実装。
4. **銀行**: MAL に bank-statements なし（ゲート skip）。
5. **電帳法・申告**: 未検証 / 未提出。
6. **Time Machine ノイズ**: ローカルで backupd mount 失敗メッセージが出るがゲート結果とは無関係。

## 再現コマンド

```bash
cd Core
export ORGOS_TENANT=mal
# ゲート確認（秘密を出さない）
node --import tsx -e 'import {evaluateMonthlyCloseGates} from "./src/lib/finance/monthly-close.ts"; import {isMonthLocked} from "./src/lib/finance/period-lock.ts"; const m="2026-05"; const e=evaluateMonthlyCloseGates(m); console.log({locked:isMonthLocked(m), can_lock:e.can_lock, errors:e.errors});'

ORGOS_TEST_DISPOSABLE_ROOT="$PWD" npx vitest run tests/monthly-close-acceptance.test.ts
```
