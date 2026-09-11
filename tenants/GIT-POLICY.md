# tenants git policy

- Migration source: `/Users/kk/OS_Steward/tenants` (copy-only into `/Users/kk/OOO/tenants`)
- Copied without a dedicated `.git` (subtree extract)
- Exclusions: node_modules, dist, .next, tmp, scratch, test-results, `.env`, `.env.*`, `*.pem`, `*.key`, plus obvious secret dirs (`secrets`, `credentials`, `private-keys`, `.secrets`, `*.secret`)
- Do not push tenant private data to public remotes without review
- **3B note:** Day-to-day Core CLI tenant data lives under `/Users/kk/OOO/Core/tenants` (auto-detected from cwd). Top-level `/Users/kk/OOO/tenants` remains a migration extract for comparison — not a second live write root unless you intentionally set `ORGOS_WORKSPACE`.
