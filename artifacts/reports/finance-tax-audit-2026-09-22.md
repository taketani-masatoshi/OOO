# OOO 会計・税務 修正後の厳格再監査（2026-09-22）

前回の消込復旧に関する認証・記録順序・監査記録の永続化を修正した。CI には実際に E2E 到達を阻んでいたスクリプト名の誤りがあり、併せて修正した。しかし、会計・税務全体を本番の確定計算に使える状態とは判定できない。再監査では新たに **15件（P1: 13件、P2: 2件）** を合成環境で再現した。以下の15件は今回の再監査で見つかった未修正事項である。

対象は `/Users/kk/OOO/Core`（HEAD `4090a74111e6f2624cbbdf644a07052a81c388bc` ＋作業中の変更）と Community の CI。別 worktree の実装は統合済みとみなしていない。実テナントの台帳・秘密情報は検証に使用せず、既存の staged / unstaged 変更を保持した。今回 commit・push・公開・本番復旧は実行していない。

## 今回修正した範囲

| 対象 | 修正内容 | 確認結果 |
|---|---|---|
| 復旧権限 | 最新 registry の鍵・active 状態・有効期限・ceo/approver・finance:reconcile・規程バインディングを確認。開発用認証省略を適用せず、AIA コンテキストから拒否 | 不正鍵・任意ID・無効/失効/サービス席の拒否 |
| 復旧記録 | started → 復旧書込み/fsync/ハッシュ確認 → completed。失敗は failed と未完了状態を残す。再試行時の完了重複を防止 | 書込み失敗、完了後の整理失敗、再実行を検証 |
| 永続化・異常終了 | 二ファイルの更新前コピー、原子的な完了マーカー、コミット後の誤 rollback 防止。所有者付きプロセスロックと終了した所有者の安全な回収 | 実プロセスの SIGKILL、生存ロック保護、複数プロセス競合を検証 |
| 監査記録 | 一意ID・連番・ハッシュ連鎖付きのイベントを一ファイルずつ fsync/rename。旧 JSONL を保持・ハッシュで関連付け | 途中の一時ファイル・内容改変・ファイル欠落/空ファイルの区別を検証 |
| Community CI | 存在しない `db:push` / `db:seed` を workspace の `push` / `seed` に修正。別 checkout で artifact を復元する公開なしの検証ジョブを追加 | ローカル4テスト、YAML解析・npmスクリプト実在確認。変更後の GitHub 実行は未確認 |

実装: [復旧処理](/Users/kk/OOO/Core/src/lib/finance/reconciliation-transaction.ts)、[ロック](/Users/kk/OOO/Core/src/lib/finance/finance-mutation-lock.ts)、[監査](/Users/kk/OOO/Core/src/lib/finance/reconciliation-recovery-audit.ts)、[復旧手順](/Users/kk/OOO/Core/docs/product/reconciliation-recovery.md)、[CI](/Users/kk/OOO/Community/.github/workflows/ci.yml)。

GitHubの[現在のローカルHEADに対応する既存CI](https://github.com/taketani-masatoshi/OS_Community/actions/runs/35217587665)では、build / e2e とも `Missing script: "db:push"` で停止していた。今回の変更を検証した run ではない。新しい `protocol-handoff` と公開ジョブの実行成功をまだ保証していない。

## 新たに再現した問題

### 1. [P1 / C1] 消費税で売上取消が減算されず、税額が倍になる

税抜売上10,000円と同額の正式な reversal を登録すると、正味売上は0円なのに売上税額が **2,000円** になる。`debit_yen || credit_yen` が借方・貸方の符号を捨てるため、返品や経費返金も同種の危険がある。

[原因](/Users/kk/OOO/Core/src/lib/finance/consumption-tax.ts:79)。修正条件: 通常仕訳・取消・部分返品・期跨ぎ返品を税区分ごとに符号付きで集計し、GL と照合する。

### 2. [P1 / C2] 消費税集計が壊れた台帳を「税額0円」に変える

`journal-entries.yaml` を構文不正にすると、集計は例外を握り潰し、`net_tax_yen=0`、`direction=payable` を返した。手動入力を指定していない通常のGL集計でも起きる。復旧待ちの読取拒否も同じ catch に隠され得る。

[原因](/Users/kk/OOO/Core/src/lib/finance/consumption-tax.ts:96)。修正条件: データ不存在・破損・復旧待ち・完全な手動計算を区別し、不完全な入力から確定額を返さない。

### 3. [P1 / C3] 課税固定資産の購入が仕入税額から抜ける

課税用途の固定資産100,000円＋仮払消費税10,000円／現金110,000円を登録しても、`input_tax_yen=0`。集計対象が収益・費用科目だけで、資産科目を除外している。

[原因](/Users/kk/OOO/Core/src/lib/finance/consumption-tax.ts:78)。課税資産購入の控除は購入課税期間で扱う必要がある。[国税庁 No.6355](https://www.nta.go.jp/taxes/shiraberu/taxanswer/shohi/6355.htm)。修正条件: 固定資産・棚卸資産も含め、取引の課税区分と控除可否から集計する。

### 4. [P1 / C4] 仕入用途・インボイス区分を保存しても控除計算で使わない

非課税売上のみに使用する費用10,000円に `purchase_use=non_taxable_only` を付けても **1,000円を控除**した。保存済みの `invoice_status`、`tax_amount_yen`、用途を集計で参照せず、手動の一括率・一括控除額だけで調整している。混在明細のGLからの自動計算を保証できない。

[原因](/Users/kk/OOO/Core/src/lib/finance/consumption-tax.ts:147)。[国税庁の控除対象外消費税の説明](https://www.nta.go.jp/taxes/shiraberu/taxanswer/shohi/6921.htm)。修正条件: 明細ごとの登録区分・取引日・課税売上割合・用途・丸め方法を適用し、必要条件不足なら未計算にする。

### 5. [P1 / A2] 年次締めは期首残高切替後の障害から再開できない

正常な年次締め後、最後の状態保存だけ失敗した状態（期首残高は翌期、phase は `committing`）を再現した。再実行は `ok=false`、`equity rollforward retained` / `betsu-5 retained mismatch` となり、phase が `committing` のまま残る。既存テストは期首残高を旧年度へ戻してから再試行するため、この実際の故障点をカバーしない。

[書込み順序](/Users/kk/OOO/Core/src/lib/finance/annual-close.ts:363)／[再開前ゲート](/Users/kk/OOO/Core/src/lib/finance/annual-close.ts:301)。修正条件: phase ごとの永続成果物と元データを使って再開し、全書込み境界で障害を注入する。

### 6. [P1 / A3] 月次ロック後の銀行明細追加を年次締めが検出しない

12か月を正規手順でロック後、取込サービスから締め済み月へ未消込明細を1件追加できた。その後も **`can_close=true, errors=[]`**。年次締めは仕訳ハッシュだけを再照合し、銀行と試算表の保存済みハッシュを照合しない。さらに銀行証跡自体も件数と未消込件数しかハッシュ化していない。

[取込](/Users/kk/OOO/Core/src/lib/finance/bank-statement-import-service.ts:343)／[年次確認](/Users/kk/OOO/Core/src/lib/finance/annual-close.ts:148)／[銀行証跡](/Users/kk/OOO/Core/src/lib/finance/monthly-close.ts:160)。修正条件: 締め済み入力の変更を拒否するか締めを無効化し、明細内容まで照合する。

### 7. [P1 / A1] 年次損益振替が逆残高の勘定を倍増させる

売上勘定の借方残高100円に対して損益振替を実行すると、借方残高が **200円** に増えた。本来は0円にする振替が必要。`Math.abs()` により残高の向きを無視して常に売上を借方・費用を貸方へ振り替える。

[原因](/Users/kk/OOO/Core/src/lib/finance/annual-close.ts:200)。修正条件: 収益・費用とも正負の残高をゼロにし、繰越利益との対応と翌期残高を検証する。

### 8. [P1 / O1] 期首残高の再生成が締め済み帳簿を変更できる

9月をロックしたまま `saveOpeningBalances()` が成功し、同月末の現金残高が **1,000,000円→777円** に変わった。この保存関数は実際の `ledger opening-balance generate` から呼ばれ、期間ロック・変更前残高の版・締め証跡を確認しない。

[保存](/Users/kk/OOO/Core/src/lib/finance/ledger/opening-balance.ts:23)／[CLI経路](/Users/kk/OOO/Core/src/commands/ledger.ts:419)。修正条件: 開始残高の確定・訂正を明示的に管理し、確定後の上書きと過年度帳票の静かな変化を防ぐ。

### 9. [P1 / B1] 通常の請求書発行が取引先必須ガードで止まる

請求書仕訳の売掛金行に `counterparty_id` がなく、入力引数にも渡す場所がない。通常の請求書を転記すると `counterparty_id required on AR/AP line 1150` で失敗し、仕訳0件。請求書生成サービスもこの関数を使うため、画面表示だけの問題ではない。

[原因](/Users/kk/OOO/Core/src/lib/finance/journal-sources.ts:429)／[発行元](/Users/kk/OOO/Core/src/lib/invoice-generate.ts:167)。修正条件: 発行先の正規IDを売掛補助元帳へ一貫して渡し、請求書生成から入金消込まで確認する。

### 10. [P1 / D1] 償却済み資産への償却が止まらない

取得価額1,200,000円、耐用年数1年、供用2020年、現在簿価1円の資産について、2026年9月の償却費が **100,000円**。定額法は現在簿価・償却累計・残存下限を参照しない。定率法も保証率・改定償却率を読み込むだけで、計算では通常率のみを使う。

[原因](/Users/kk/OOO/Core/src/lib/finance/depreciation.ts:87)。[国税庁 No.2106](https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/2106.htm)。修正条件: 未償却残高による上限、最終月端数、除却、年度更新、定率法の切替を扱う。

### 11. [P1 / P2] 令和8年給与の源泉税計算が公式電算機計算と一致しない

月額280,000円、社会保険料41,300円、扶養0人を固定して比較した。実装 **4,851円** に対し、令和8年の電算機計算では **5,720円**。給与所得控除の基礎を社会保険料控除前にしており、控除表・基礎控除・税率表・10円単位の四捨五入も公式式と一致しない。既存テストは4,851円を正解にしている。

[計算](/Users/kk/OOO/Core/src/lib/finance/payroll-jp.ts:164)／[既定税率表](/Users/kk/OOO/Core/steward/jurisdiction-packs/JP/modules/jp_payroll/seed/payroll-rates-2026.yaml.example:1)。照合根拠: [国税庁 令和8年 電算機計算の特例](https://www.nta.go.jp/publication/pamph/gensen/zeigakuhyo2026/data/18.pdf)。修正条件: 公式例・各境界・扶養/甲乙区分・適用年を独立オラクルで検証する。

### 12. [P1 / P1] 社会保険が既定の短い等級表へ黙ってフォールバックする

テナント固有料率表がないと example を本計算に使用する。月給1,000,000円でも末尾の標準報酬350,000円が選ばれ、厚生年金本人負担は **32,025円**。標準報酬650,000円の一般被保険者での本人負担59,475円と一致しない。また健康保険と厚生年金に同じ等級を使い、`computePayrollMonth` は入力月から適用年度を選ばない。

[フォールバック](/Users/kk/OOO/Core/src/lib/finance/payroll-jp.ts:85)／[範囲外の等級選択](/Users/kk/OOO/Core/src/lib/finance/payroll-jp.ts:106)。[日本年金機構の料額表](https://www.nenkin.go.jp/service/kounen/hokenryo/ryogaku/ryogakuhyo/20200825.html)。修正条件: 適用時点・保険者・確定標準報酬を必須化し、example や未対応範囲では本計算を拒否する。

### 13. [P1 / T1] 所得10億円超の中小法人でも軽減税率15%を出す

FY2026（2026-02開始）、資本金100万円、課税所得11億円で **254,544,000円**、`official_pending=[]` を返した。この条件の軽減部分を17%で計算すると **254,704,000円**で、160,000円不足。年度・所得条件による17%分岐がなく、軽減税率15%が固定されている。

[原因](/Users/kk/OOO/Core/src/lib/finance/tax-adjustment.ts:261)。[国税庁 No.5759 注7](https://www.nta.go.jp/taxes/shiraberu/taxanswer/hojin/5759.htm)。修正条件: 事業年度・法人区分・適用除外・所得条件を版管理し、未対応条件は税額未確定とする。

### 14. [P2 / I1] 所得税を100円単位に早く切り捨て、復興特別所得税もずれる

課税所得149,000円、税額控除・源泉・予定納税0円の場合、基準所得税7,450円を7,400円へ先に切り捨て、納付額 **7,500円**を返す。基準所得税7,450円＋復興特別所得税156円から最終端数処理すれば **7,600円**。

[原因](/Users/kk/OOO/Core/src/lib/finance/income-tax-policy.ts:104)。[国税庁の復興特別所得税計算](https://www.nta.go.jp/taxes/shiraberu/shinkoku/tebiki/2025/03/order4/3-4_45.htm)／[申告税額の計算順序](https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1000.htm)。修正条件: 基準税額を保持し、各法定段階の丸めを分離する。

### 15. [P2 / E1] 電子帳簿の完全性評価が実際の検証になっていない

過去の仕訳を100円から900円へ貸借一致を保ったまま変更しても、`append_only_ok=true, issues=[]`。値は無条件の true。`search_index_ok` も `probe.length >= 0` により常にtrueとなる。これは記録内容の改変検出や検索要件の適合を証明しない。

[原因](/Users/kk/OOO/Core/src/lib/finance/ledger/electronic-ledger.ts:173)。修正条件: 未検証を明示し、履歴・改訂証跡・検索条件の組合せを実証してから合格とする。電帳法への適合そのものを、この再現試験だけで判定しているわけではない。

## 検証範囲と結果の読み方

- 修正回帰: Core **29/29**、Community artifact **4/4**。Core型チェック・変更箇所ESLint・Prettier・両repoの `git diff --check` 成功。
- 広域回帰: 隔離コピーで23ファイル・**114テスト中95成功/19失敗**。12件は意図的に持ち込まなかった `mal` / 海外テナントへの依存、5件は旧テスト入力と現行ガードの不整合、2件は請求書転記の実装不具合。全会計テスト成功とはしていない。
- 追加の再現: 13ケース＋年次締め2ケースで、上記15件の現象を確認。**現行の誤動作を確かめる観測用アサーション**であり、製品の正常性を示す「15テスト合格」ではない。製品の通常回帰テストへ誤った期待値を追加していない。
- ソース確認: 仕訳/取消・銀行取込/消込・AR/AP/請求書・月次/年次・期首/財務諸表・減価償却・消費税/還付・法人税別表ドラフト・個人事業所得税・給与/納付・承認/監査・税理士handoff・readiness・CI受渡し。
- e-Tax / eLTAX は現正本の評価対象で本番提出済みと扱っていない。法人税XMLは明示的に `submission="not-for-etax"`。別 worktree にある地方税/電子申告実装も、この正本へ統合された証拠にしていない。
- ブラウザE2E、実テナント全社検査、実際の申告受理、税理士の最終確認、電源断/ネットワークFS、全年度・全法人区分の法令網羅は未検証。新しい復旧監査ハッシュは外部署名やWORMの代替ではなく、監査ディレクトリ全体/末尾の削除を単独では検出できない。

## 修正の優先順と受入条件

1. **誤計算の抑止**: C1〜C4、給与P1/P2、法人税T1。対応外の入力は確定金額を返さない。公式例と独立した期待値を使う。
2. **締めと台帳の保全**: A2/A3/O1/A1。各永続化境界の障害注入、再実行、締め後変更、異常符号を確認する。
3. **実務フロー完走**: B1/D1/I1。請求→売掛→消込、取得→月次償却→除却、税理士用計算の帳簿整合を確認する。
4. **証明の正確さ**: E1と試験データの整備。内部スコア・隔離試験・実運用確認を別表示にし、未検証の合格扱いをなくす。GitHubでは変更後コミットの e2e / protocol-handoff の成功URLを保存する。

[再現コード・観測値・試験記録](/Users/kk/OOO/artifacts/reports/finance-tax-audit-2026-09-22-evidence/README.md)には合成データのみを収録。金額・原因・修正条件を次の作業で照合できるよう保存した。
