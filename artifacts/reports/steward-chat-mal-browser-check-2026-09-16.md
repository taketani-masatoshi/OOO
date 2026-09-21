# Steward Chat MAL browser / API check — 2026-09-16

## Environments

| Environment | Used? | Notes |
|-------------|-------|-------|
| Local safe test (Vite `:5174` + BFF `:9471`, `STEWARD_CHAT_AUTH=0`, tenant `mal`) | **Yes** | Dev-bypass operator; **not** production auth |
| Authenticated real MAL Operator Console (Community SSO / PassKey) | **No — 未検証** | No access in this session; must not be treated as success |

Auth / approval gates were **not** bypassed beyond the documented local `STEWARD_CHAT_AUTH=0` eval path.

## Routes checked (local)

| Route | UI | API | Console JS errors |
|-------|----|-----|-------------------|
| `/secretary/workbench/` | Loaded: mail setup gap, drafts list (subjects only), approvals count, company cash | `GET /chat/v1/secretary/workbench` → 200 `ok=true` | none observed |
| `/properties/` | Loaded: PROP-001 / PROP-002 cards, due items, permits, P&L | `GET /chat/v1/properties/ops` → 200 `ok=true` | none observed |
| `/modules/maturity/` | Loaded: catalog summary + lanes; `drafts=42` (real count) | `GET /chat/v1/modules/maturity` → 200 `ok=true` | none observed |
| `/wire/demo/` | Loaded: MAL↔Southwood steps, Open next links, no seed button run | `GET /chat/v1/wire/demo` → 200 `ok=true` | none observed |

Also probed: `GET /chat/v1/executive/home` → 200; `finance_runway_months` null, `finance_cash_balance` number (Today path succeeded for finance cash; runway may be unset).

## Empty vs error vs missing data

| Surface | Observation | Classification |
|---------|-------------|----------------|
| Workbench inbox | “No unprocessed mail” / mail not set up | **Data / setup gap** (SMTP dry_run), not UI crash |
| Workbench drafts | Subjects + `pending_approval` visible | Data present; **body / PII kept off-screen** by design |
| Property insurance | “No policies” / unset hints | **Data gap** |
| Wire demo approvals / pending | 0 with Info status | Expected when nothing proposed; not an API failure |

## L2 / L3 / secrets exposure check

- UI copy states guest names and secrets stay off-screen; property cards showed L1 labels (property id, address line, permit ids) without guest PII fields.
- API JSON scan: substring `secret` matched inside **`secretary`** (false positive). Digit runs matched IDs like `APR-########` patterns, not bank numbers.
- Draft list shows **subjects and local-part addresses** — treat as L1 operational metadata on Secretary surface; no message bodies observed in the viewport text.

## Navigation

- Subnav: Executive home ↔ Property operations ↔ Secretary workbench worked.
- SPA `pushState` to `/modules/maturity/` and `/wire/demo/` rendered the expected pages without reload auth loop after initial session.

## Explicitly 未検証

1. Production / Community-authenticated MAL session.
2. PassKey / Settlement approval flows.
3. Wire seed / destructive inter-org demo CLI from UI (intentionally not run).
4. Mobile layout / performance beyond “page rendered.”
5. Wire Console nested surface at `/wire/` (showed tenant error historically when Wire BFF `:9470` down) — **not re-validated** in this pass beyond `/wire/demo/`.

## Conclusion

Local safe environment: the four target surfaces and matching Chat APIs respond and render without JS console errors in this check. Authenticated real-MAL confirmation remains **未検証**.

## 2026-09-16 evening follow-up (finance boundary)

- API: `/chat/v1/secretary/workbench` から `cash_balance` / `runway_months` をスキーマ除外（Secretary は `data/finance/**` 読取禁止）。
- `/chat/v1/today`・`/chat/v1/today.md`・`/chat/v1/executive/home` は `chat:approve`（ceo/approver 席）以外へ財務 KPI を null/削除。権限意味の新設なし。
- ローカル合成 HTTP テスト: `_fixture-books` の OP-READONLY vs OP-001（Today は合成値モック）。
- 認証済み MAL 実環境: **未検証**（Community SSO / PassKey を迂回しない）。再現: 本番相当で auth 有効の BFF に ceo と readonly でログインし、上記3 API の JSON を比較。

## 2026-09-16 production-auth verification attempt

### Preflight evidence

- Production entry points checked from Safari:
  - `https://community.oorgos.org/ops/console/start?next=%2F` → Cloudflare `1033`
  - `https://operator.oorgos.org/` → Cloudflare `1033`
- Local listeners for Community (`:3000`) and Operator Console (`:9470`) were absent.
- Colima was stopped; no integrated-stack containers were available.
- The saved deployment configuration was checked without printing secret values: tenant `mal`, `WIRE_CONSOLE_AUTH=prod`, `WIRE_CONSOLE_PROD_ADAPTER=webauthn`, Community issuer and public Console URL matched the two hosts above.
- MAL operator registry contains an active CEO seat and non-CEO seats. No role or permission was changed for this check.

### Recovery boundary

The planned recovery command was the existing stack runbook with the current canonical Core explicitly mounted:

```bash
STEWARD_HOST_PATH=/Users/kk/OOO/Core \
  /Users/kk/OS_Community/scripts/start-local-stack.sh --ensure
```

The command was **not executed** because automatic approval review rejected the external-state effects: it starts Colima, force-recreates services, and re-publishes the Cloudflare Tunnel. No authentication, permission, tenant-data, or deployment state was changed.

### Status

Authenticated readonly / CEO / Secretary UI verification remains **blocked by the stopped production tunnel**. The earlier local safe-test evidence must not be promoted to production-auth evidence. After explicit approval to restore the existing stack, verify read-only rendering only; do not submit approvals, send mail, seed Wire data, or change operator roles.
