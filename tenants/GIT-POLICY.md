# tenants git policy

- Migration source: `/Users/kk/OS_Steward/tenants` (copy-only into `/Users/kk/OOO/tenants`)
- Copied without a dedicated `.git` (subtree extract)
- Exclusions: node_modules, dist, .next, tmp, scratch, test-results, `.env`, `.env.*`, `*.pem`, `*.key`, plus obvious secret dirs (`secrets`, `credentials`, `private-keys`, `.secrets`, `*.secret`)
- Do not push tenant private data to public remotes without review
- **3B note:** Day-to-day Core CLI tenant data lives under `Core/tenants` (auto-detected from cwd). Top-level `tenants/` remains a migration extract for comparison — not a second live write root unless you intentionally set `ORGOS_WORKSPACE`.
- **EXTRACT:** Do not edit this directory as product source. Development Agents must not treat it as a standard write target. Live tenant data is `Core/tenants`. Do not change operational events or ledgers for verification.
