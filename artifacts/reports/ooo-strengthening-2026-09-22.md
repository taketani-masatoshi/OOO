# OOO 強化・整理の検証記録 — 2026-09-22

## 結果

銀行消込の承認後も月次締めが未消込扱いになる経路を修正した。顧客業務の HTTP 統合検証、商用判定、テスト隔離、公開前ゲート、効果測定を強化した。Core 全体の型検査は成功。これは合成データでの検証であり、本番稼働や実顧客の効果を証明するものではない。

## 実装済み

- `Core/src/lib/finance/bank-statements-lite.ts` は消込イベントが存在する場合、その再生結果を参照する。部分消込・取消・無効化・月末時点を反映し、イベント不整合を古いスナップショットで隠さない。元の銀行明細は書き換えない。
- 消込一覧は部分消込の残額を表示し、月次締めは未消込・部分消込を拒否する。
- 顧客経路は会社登録、CSV dry-run/取込、重複防止、部分/残額消込、提案/承認、権限拒否、月次ロック、CSV出力まで検証する。合成の売掛残高を開始データとして投入する。
- 専用テストランナーは一時 workspace を用い、業務用環境変数を除外する。失敗・中断・空・スキップを合格にせず、実行結果とソース識別情報を保存する。
- Stripe 商用準備判定は live key と webhook secret を要求する。test key を本番課金準備済みとは扱わない。外部課金疎通は未検証。
- Core Release 作成は release-check 後。Community コンテナ公開は build/Docker/E2E と Core commit 指定を要求する。protocol 同期は必須ファイルの欠落・空・コピー失敗を拒否する。
- 顧客効果の集計コマンドと入力テンプレートを追加した。実データと synthetic を分離し、欠測は null、観測ゼロは 0 とする。比較データなしで改善率を作らない。
- Core 型エラー4箇所を修正した。PayPal 通貨桁情報の付与、日本間接税アダプターの戻り値整合、到達不能な条件2箇所の整理。税率・控除要件は変更していない。
- 既存の月次締めテストでは、入力ガードで拒否される破損データを明示的にテスト fixture に投入する。入力ガード自体の拒否も検証する。資金繰りテストは合成取引先を指定する。

## 検証済み

| 検証 | 結果 |
|---|---|
| `npm run test:customer-journey` | 6/6 PASS、終了コード0 |
| `npm run test:customer-pilot` | 5/5 PASS |
| 財務回帰5ファイル（隔離 workspace） | 25/25 PASS |
| `npm run typecheck` | PASS |
| 変更した製品コード8ファイルの ESLint | エラー0、既存形式由来の警告3（any×2、prefer-const×1） |
| 専用ランナー・測定スクリプト・関連テストの Prettier | PASS |
| Core/Community workflow 4ファイルの YAML と依存関係 | 静的検査 PASS |
| protocol 同期（合成 export のみ） | 欠落/空を拒否、完全なファイルを同一内容でコピー：PASS |
| Core/Community `git diff --check` | PASS |

HTTP 証跡: `Core/test-results/customer-journey/run-879b2b/evidence.json` と `vitest.json`。開始 `2026-09-21T23:15:09.680Z`、終了 `2026-09-21T23:15:54.194Z`。HEAD は `4090a74111e6f2624cbbdf644a07052a81c388bc`、未コミット差分を含む検証。

財務回帰: `monthly-close-acceptance` 17件、`bank-reconciliation-gl` 3件、`cash-flow-statement` 2件、`external-provider-adapters` 1件、`sole-prop-lane-f-acceptance` 2件。実行用 config/setup と JSON 結果は `/private/tmp/ooo-finance-regression.RHRXjs/`。Git HEAD の `_fixture-books` のみを一時領域にコピーし、各ケースで別 workspace に再コピー。標準の実テナント fixture 復元は使用しない。初回は一時環境の規則データ不足と既存テストの入力ガード不整合で失敗し、環境・テストを修正後に上記25件を再実行した。

## 未検証・残る条件

- 実ブラウザの操作完走、Passkey、CSRF、settlement step-up。HTTP テストは合成セッションで、後二者を無効化している。
- GitHub Actions、Docker、Community E2E の実行。本作業では定義の静的検査まで。
- Community の repository variables `STEWARD_REPO` / `STEWARD_REF`、対象 Core を読み取れる認証。未設定またはアクセス不能なら公開ゲートは失敗する。
- 本番の課金・メール・AI 接続、および実顧客の作業時間削減。実測値は未投入。
- Core の独立した demo-docker 公開は既存 smoke 条件のままで、顧客経路ゲートとは別。

commit / push / deploy / 実テナント変更は実行していない。既存のステージ済みファイル、テナント差分、別 worktree は維持した。
