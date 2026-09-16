# tenants git policy

- Migration source: legacy OS_Steward `tenants/` (copy-only into umbrella `tenants/` at migration time)
- Copied without a dedicated `.git` (subtree extract)
- Exclusions: node_modules, dist, .next, tmp, scratch, test-results, `.env`, `.env.*`, `*.pem`, `*.key`, plus obvious secret dirs (`secrets`, `credentials`, `private-keys`, `.secrets`, `*.secret`)
- **GitHub ポスト禁止:** テナント情報（`tenants/<id>/` の実データ、チャット、財務、人事、鍵、records）はどの GitHub リポにも commit / push しない。例外は本ファイル `tenants/GIT-POLICY.md` と案内 `tenants/00-README.md` のみ。
- **Tip isolation:** OpenOrgOS tip から秘密・実テナント runtime を外す。履歴 rewrite はしない（過去コミットに残る可能性あり）。詳細は Core `docs/org-os/tenant-github-tip-policy.md`。
- **3B note:** Day-to-day tenant data for Core CLI lives under `Core/tenants` (detected from cwd). Umbrella `tenants/` tracks policy/README only.
