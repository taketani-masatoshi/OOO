# MAL validate warning triage — 2026-09-16

## Scope

- Command: `cd /Users/kk/OOO/Core && npm run orgos -- --tenant mal validate`
- Exit code: **0** (schema / integrity gate PASS)
- Banner: `✓ All data files are valid.`
- Warning count: **143** (これらの警告は「解消済み」ではない)
- Environment noise outside the 143-count: Time Machine / `backupd` mount failure line on stdout (not a validate issue)

**Policy for this triage:** no real tenant data was modified. Empty ISO templates were not created. Dates, amounts, facility facts, and audit evidence were not invented.

## Classification summary

| Category | Count | Owner next action |
|----------|------:|-------------------|
| 実データ・人間の判断が必要 | 5 | CEO / ops: decide payroll links, org-chart roster, REPLACE_ME secrets, backup stamp |
| 既存データの整合性確認が必要 | 19 | Ops / finance / CS: reconcile stays vs open date, customer health, catalogs, guest register |
| ISO様式・証跡の不足 | 57 | Compliance: place real evidence or disable unused ISO modules; fix date formats |
| 機能成熟度の目標との差 | 62 | Compliance / module owners: lower targets or raise control levels intentionally |
| 検証器の誤検知 | 0 | None proven safe to change in Core alone |
| 実行環境のノイズ | 1* | Local: Time Machine destination not mounted (*outside warning count) |

\* `Failed to mount backup destination ... backupd` appears before the warning list; ignore for product health.

## Category detail

### 1. 実データ・人間の判断が必要 (5)

| Representative | Meaning | Ask human to |
|----------------|---------|--------------|
| `payroll.yaml`: EMP-001 / EMP-002 missing from `employee_ids` | Officers are active in roster but not linked as payroll/withholding subjects | Confirm unpaid officers stay out of `employee_ids`, or link them if they should be on payroll |
| `org-chart.yaml`: linked employee_id count 2 vs active employees 4 | Chart does not cover all active people | Add chart nodes or mark roles intentionally uncovered |
| `kamezawa-secrets.yaml`: 4× REPLACE_ME / TBD | Facility secrets placeholders | Fill local-only secrets or document N/A; do not commit L2 |
| `scratch/executive-backup-last.txt` missing stamp | Weekly backup procedure not recorded | Run backup procedure and stamp the scratch file |

### 2. 既存データの整合性確認が必要 (19)

| Representative | Meaning | Ask human to |
|----------------|---------|--------------|
| `stays.yaml` / `lodging-tax.yaml`: stay in 2026-08 before PROP-002 `opened_date` 2026-09-18 | Ops timeline contradicts property open date | Correct stay dates, open date, or void demo stays |
| `宿泊者名簿.csv` missing for 2026-09 | Guest register artifact absent | Create real register when operating, or accept gap until open |
| `invoice-registration-catalog.yaml` incomplete source metadata | Catalog provenance incomplete | Fill `source_checked_at` / official source fields after real check |
| `customers/accounts.yaml` health mismatches (declared vs computed) | CS health labels drift from score | Reconcile declared health or accept computed recommendation |
| Medical-device ledgers empty (“空の台帳は証拠ではない”) | Empty ledgers are honest gaps, not evidence | Either record real events or keep modules off / acknowledge gap |

### 3. ISO様式・証跡の不足 (57)

| Representative | Meaning | Ask human to |
|----------------|---------|--------------|
| Many `docs/compliance/iso/ISO-*/… がありません` (~45) | Required evidence files missing for enabled ISO set | Run templates only when adopting that ISO; then replace placeholders with real content |
| ISO-21401 placeholders still `{FACILITY_NAME}` etc. (6) | Template not tenant-filled | Fill facility facts from verified ops data |
| Empty ISO registers / KPI logs (5) | No measurements recorded | Record real aspects / KPIs or defer ISO claim |
| ISO-27001 `risk-register.csv` `review_date` = `2026-08` (3) | Needs `YYYY-MM-DD` | Change to a real review day (e.g. last day of month) after human confirmation — **do not invent** |

**Do not** treat `orgos iso templates … --write` alone as closing evidence.

### 4. 機能成熟度の目標との差 (62)

All are `data/compliance/controls.yaml` rows of the form `CTL-…: 現在 Ln · 目標 Lm`.

- Representative: `CTL-CORE-operation` L0→L2; many ISO-13485 / 14001 / 20000 / 21401 / … controls at L0 vs target L2/L3.
- These are **maturity debt signals**, not schema failures.
- Ask owners to either raise control level with real evidence, or lower `target` when a module is aspirational only.

### 5. 検証器の誤検知 (0)

No warning was proven to be a Core validator bug that is safe to patch without weakening checks. No Core validator change in this pass.

### 6. 実行環境のノイズ

- macOS Time Machine / `backupd` mount error on the machine running validate.
- Not counted in 143; ignore for product triage.

## Suggested follow-ups (data — not applied)

1. CEO: payroll officer link policy for EMP-001 / EMP-002.
2. Ops: PROP-002 open date vs STAY-2026-001 / lodging-tax August periods.
3. Compliance: ISO-27001 `review_date` format on three risk-register rows (after confirming real review dates).
4. Compliance: decide which ISO families stay enabled; disable or evidence the rest.
5. Local operator: stamp executive backup scratch file after a real backup.

## What this triage does *not* claim

- Warnings are not “cleared.”
- Empty templates would not make validate “green enough.”
- Authenticated production MAL console behavior is out of scope here.

## Remediation applied — 2026-09-16

### Result

| Metric | Before | After |
|--------|-------:|------:|
| `orgos validate` warnings | 143 | **31** |
| Applicable ISO standards | 11 | **2** (`ISO-21401`, `ISO-37000`) |
| In-scope controls | 71 | **35** |
| Control gaps | 83 | **28** |

`orgos validate` remains exit code 0 with `All data files are valid`. The reduction did not create empty evidence or replace unknown business facts with invented values.

### Fixed

1. Corrected `standards.yaml` applicability. All 12 packs remain available, while standards not pursued by MAL are explicitly `excluded` with reasons. This now agrees with disabled REG-009/011/013/015 and the existing ISO-13485 non-certification note.
2. Reinitialized `controls.yaml` from the two applicable standards. ISO 37000 P-01..P-11 were raised to L2 only after `orgos governance principles status` returned 11/11 and `ready_for_self_declaration=true`.
3. Added honest ISO 37000 evidence indexes for the existing internal-audit plan, pending management review, and governance ledgers. The files explicitly preserve `未実施` where no decision exists.
4. Corrected maturity states: Core operation and hospitality hygiene are L2 based on REG-012 and the FY2026 audit record; drafted ISO 21401 areas are L1; operational evidence gaps remain below target.
5. Removed validator false positives:
   - unpaid officers linked through `payroll.officers` count as explicit payroll coverage;
   - joint representatives can be linked through an org unit's `employee_ids`;
   - demo accounts and sales prospects no longer produce real-customer health drift;
   - a guest-register file is required only for a month containing a non-cancelled stay.
6. Synced the MAL org-chart fixture so Vitest no longer restores the old two-person coverage state.
7. Added the empty invoice-registration catalog with actual source-check metadata from the National Tax Agency public site. No registration number was invented.

### Remaining 31 warnings — intentionally not fabricated

| Category | Count | Required evidence / decision |
|----------|------:|------------------------------|
| ISO 21401 maturity below target | 14 | approved policies, measurements, internal-audit/MR results |
| ISO 21401 empty or placeholder records | 11 | real environmental, KPI, stakeholder, procurement and facility survey records |
| Open-date vs stay/tax conflict | 3 | decide whether August was a real pre-opening stay, demo data, or whether `opened_date` is wrong |
| Facility secrets placeholders | 1 | fill the local L2 secret store; do not commit values |
| Customer health drift | 1 | operator must accept or reject `critical` recommendation for CUST-2026-101 |
| Executive backup stamp | 1 | perform the backup, then record the date |

### Verification

- Focused remediation tests: **24 PASS**
- Control / ISO / integrity regression tests: **60 PASS**
- TypeScript typecheck: **PASS**
- MAL validate: **PASS**, 31 warnings
- Time Machine XPC mount output remains execution-environment noise outside the warning count.

## Stabilization follow-up — 2026-09-17

MAL の実データについて CEO が `STAY-2026-001` を「開業前試泊」、`CUST-2026-101` の health を `critical` に更新することを確認した。前者は stay の `purpose: pre_opening_trial` として明示し、開業日との単純な前後比較のみ除外した。後者は算定結果に合わせて記録した。

ISO 21401 の空の様式6件を MAL 固有の未承認ドラフトへ改め、既存の根拠から確認できる記録4件を記入した。地域雇用・調達の実績は確認できず、`local-economy-log.csv` は空のまま残した。デモ専用 payroll の欠落で Today/RBAC テストが不安定だったため、合成テスト fixture を追加した。

| Gate | Result |
|------|--------|
| MAL `orgos validate` | データ検査 PASS、警告 **31 → 18** |
| ISO 21401 records check | 12件、未充足1件（地域経済実績） |
| 関連テスト（隔離コピー） | 14ファイル・141テスト PASS |
| TypeScript typecheck | PASS |
| 変更ファイルの ESLint | 0 warnings |
| `git diff --check` / tenant tip | PASS |
| Core 全体 ESLint | 0 errors、既存 **204 warnings** |
| 全593テストファイル | 完走確認なし。初回は sandbox の `listen EPERM`、再実行は途中で終了。合格とは判定しない |

残る18件は、統制成熟度未達14件、L2施設秘密情報の実値未入力1件、実バックアップ未記録1件、地域経済実績未記録1件、開業前試泊の宿泊税算定に関する時系列確認1件。試泊の事実確認だけで宿泊税処理まで確定とはみなさず、税の警告を1件残した。成熟度を期限前として警告から外す案は ISO 監査の不適合判定まで隠すため採用しなかった。レベルを実証なしに引き上げず、秘密値・バックアップ日付・地域実績を捏造しない。

安定性上の別課題: 現行 Vitest setup は fixture 復元時に tenant ディレクトリを削除・再作成する。このため `npm test` 起動時・global setup・worker setup に使い捨て checkout ガードを追加し、通常の Core checkout では fixture 復元前に拒否する。GitHub Actions の一時 checkout は許可し、ローカル Docker test は使い捨て checkout の明示を必須にした。ガード単体3テストは隔離コピーで PASS、通常 checkout での拒否も確認した。全体 ESLint 204件は別途、所有範囲ごとに修正が必要。

注意: ガード追加前に通常の Core checkout で関連テストと中断した全テストを実行しており、既存の fixture restore が Git 非追跡の runtime ファイルに触れた可能性がある。事前スナップショットが無く、元の値との一致は立証できない。追跡ファイルの差分は保全されているが、MAL の mail-triage queue、生成 agent missions、demo fixture、プロトコル実行時ファイルなどは別途運用バックアップとの照合が必要。
