# Auth (OOO extract)

**Not canonical. Do not edit.** Path: `extracts/auth/`. 正本は `Core/` と `Community/` の認証実装。案内: [EXTRACT-NOT-CANONICAL.md](./EXTRACT-NOT-CANONICAL.md)。

Curated copy of authentication-related sources from Core (OpenOrgOS / OS_Steward) and Community.

## Layout

| Subdir | Origin | Contents |
|--------|--------|----------|
| `wire-console/` | Core `apps/wire-console` + `src/lib/wire-console/auth` | WebAuthn/OIDC/session login for Wire Console |
| `steward-chat/` | Core `apps/steward-chat` + `src/lib/steward-chat` auth | WebAuthn gates and chat auth helpers |
| `community/` | OS_Community `apps/web` NextAuth stack | `auth.ts`, providers, identity/OAuth, API routes, scripts/docs |
| `contracts/` | OOO inventory only | Auth contracts / boundaries — **not** a unified implementation |

Relative paths under each subdir mirror the source repo where practical.

## Contracts

See **[contracts/README.md](./contracts/README.md)** for the mechanism map (WebAuthn vs NextAuth vs OIDC), session boundaries, and deferred unification goals. Implementations stay separate.

## Notes

- This is an **extract for review/migration**, not a standalone runnable package.
- Secrets (`.env`, `*.pem`, `*.key`) were excluded from all copies.
- See `SECURITY.md` before integrating or deploying.
