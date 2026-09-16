# Auth SECURITY

## Rules

1. **No secrets in this tree.** Do not add `.env`, private keys, PEM files, or OAuth client secrets.
2. Copied code may *reference* env vars (`AUTH_SECRET`, provider client IDs, etc.) — configure those only in local/runtime-private stores, never commit them.
3. Community OAuth setup docs describe configuration flows; treat credentials as operator secrets.
4. Wire Console / steward-chat WebAuthn and OIDC code assumes production origin and credential stores — do not weaken challenge/store validation when integrating.
5. This extract may contain test helpers (e.g. webauthn-e2e); keep them out of production builds.

## Incident response

If a secret is ever committed into `/Users/kk/OOO`, rotate credentials immediately and purge from history before any push (migration itself does not push).
