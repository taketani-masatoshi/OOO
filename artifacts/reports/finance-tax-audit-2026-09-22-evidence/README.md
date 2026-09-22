# 会計・税務再監査の証拠

すべて合成データ。製品のソースは Core / Community が正本で、このディレクトリは監査時点の観測記録です。

- `manifest.json`: ソースHEAD・会計/税務ソースのハッシュ・結果件数。HEADだけでは未コミット変更を識別できないためファイルハッシュを収録。
- `fix-regression-results.json` / `fix-regression-evidence.json`: 最終版の修正回帰29/29。HTTP操作と復旧16ケースを含む。
- `broad-regression-results.json`: 広域回帰114件の実結果。95成功/19失敗。省略したテナントへの依存と実装不具合を混同しないこと。
- `observations.jsonl`: C1〜C4 / I1 / D1 / A1 / B1 / E1 / O1 / T1 / P1 / P2 の13件の観測値。P1/P2はここでは給与の観測IDで、優先度とは別（P1=社会保険、P2=給与源泉税）。
- `observation-results.json`: 上記13件の再現成否。テストは現行の誤動作を期待しているため、成功は製品合格ではない。
- `annual-observation-results.json`: A2（期首切替後の障害状態）とA3（締め後の銀行取込）の再現結果。元の既存5件はこの実行では対象外。
- `audit-observations.test.ts` / `annual-close-observations.test.ts`: 追試用コード。通常の回帰テストへ誤動作の期待値を移植しないこと。

## 追試

`python3 reproduce.py` は `/private/tmp/ooo-finance-audit-*` にコードコピーを作り、Git HEAD の `_fixture-books` / `demo` だけを初期データに使います。Core のソース・schemas・tests の現在の変更をコピーし、実テナントのローカル台帳・鍵・環境設定はコピーしません。既存の Core/node_modules が必要です。

再現コードは現行の欠陥を確認します。修正後にはこれらが失敗することがあり、その場合は正しい期待値を持つ製品回帰テストを別途実装してください。`prepare-audit.py` が選ぶ23ファイルの広域回帰は、作成された一時ディレクトリで `python3 run-audit.py` を実行します。

2026-09-22に、このディレクトリの `reproduce.py` 自体を実行し、新しい隔離コピーでも13件＋年次締め2件の同じ不具合を再現できることを確認しました。

型チェック・ESLint・Prettier・Community artifactテストは正本で実行しました。GitHub変更後run、実テナント、ブラウザ、申告受理、電源断の証拠は含みません。復旧のSIGKILL試験と年次締めの故障状態再現は区別しています。
