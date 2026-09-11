# tenants git policy

- Migration source: `/Users/kk/OS_Steward/tenants` (copy-only into `/Users/kk/OOO/tenants`)
- Copied without a dedicated `.git` (subtree extract)
- Exclusions: node_modules, dist, .next, tmp, scratch, test-results, `.env`, `.env.*`, `*.pem`, `*.key`, plus obvious secret dirs (`secrets`, `credentials`, `private-keys`, `.secrets`, `*.secret`)
- **GitHub ポスト禁止:** テナント情報（`tenants/<id>/` の実データ、チャット、財務、人事、鍵、records）はどの GitHub リポにも commit / push しない。例外は本ファイル `tenants/GIT-POLICY.md` のみ。
- **3B note:** Day-to-day Core CLI tenant data lives under `/Users/kk/OOO/Core/tenants` (auto-detected from cwd). Top-level `/Users/kk/OOO/tenants` remains a migration extract for comparison — not a second live write root unless you intentionally set `ORGOS_WORKSPACE`.
