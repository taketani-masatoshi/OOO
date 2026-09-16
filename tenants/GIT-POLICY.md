# tenants git policy

- Migration source: `/Users/kk/OS_Steward/tenants` (copy-only into `tenants/`)
- Copied without a dedicated `.git` (subtree extract)
- Exclusions: node_modules, dist, .next, tmp, scratch, test-results, `.env`, `.env.*`, `*.pem`, `*.key`, plus obvious secret dirs (`secrets`, `credentials`, `private-keys`, `.secrets`, `*.secret`)
- **GitHub ポスト禁止:** テナント情報（`tenants/<id>/` の実データ、チャット、財務、人事、鍵、records）はどの GitHub リポにも commit / push しない。例外は本ファイル `tenants/GIT-POLICY.md` のみ。
- **Tip isolation:** OpenOrgOS tip から秘密・実テナント runtime を外す。履歴 rewrite はしない（過去コミットに残る可能性あり）。
- **3B note:** Day-to-day tenant data for Core CLI lives under `Core/tenants` (detected from cwd). Umbrella `tenants/` tracks this policy file only.
