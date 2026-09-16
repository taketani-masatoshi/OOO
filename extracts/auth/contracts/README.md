# Auth contracts (inventory — not a unified package)

Implementations remain separate under `wire-console/`, `steward-chat/`, and `community/`.
This folder documents **shared contracts / boundaries** only. Do not merge runtimes here.

## Surfaces

| Surface | Mechanism | Session / boundary | Key paths (under Auth/) |
|---------|-----------|--------------------|-------------------------|
| Wire Console | WebAuthn (passkey) + optional OIDC | Console session cookies / challenge store; Community handoff for login start | `wire-console/src/lib/wire-console/auth/*`, `wire-console/apps/.../webauthn-*.ts` |
| Operator Console / Steward Chat | WebAuthn gate + chat auth helpers | Chat/BFF auth (`steward-chat` auth.ts); BudgetAuthGate UI | `steward-chat/src/lib/steward-chat/auth.ts`, `steward-chat/apps/.../webauthn-*.ts`, `BudgetAuthGate.tsx` |
| Community (Next.js) | NextAuth (Auth.js) + OAuth providers | JWT/session cookie; middleware; identity merge | `community/apps/web/src/auth.ts`, `auth.config.ts`, `lib/auth-*`, `lib/identity/*`, `app/api/auth/[...nextauth]` |

## Do not conflate

- **WebAuthn** (Core consoles) ≠ **NextAuth/OAuth** (Community)
- **OIDC** on Wire Console is console-side; Community OAuth is NextAuth providers
- **Handoff:** Console login CTA starts at Community (`/ops/console/start`); see wire-console `community-handoff.ts`
- Secrets (`.env`, keys, cookie secrets) are **out of scope** for this extract — see `../SECURITY.md`

## Shared contract goals (future, not done)

1. Error shape / HTTP status conventions across surfaces  
2. Session boundary documentation (who issues cookies, where they are valid)  
3. Identity claims mapping (Community JWT ↔ Console session) without merging codebases  

Unification of implementations is **explicitly deferred**.
