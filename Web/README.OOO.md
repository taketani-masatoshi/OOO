# OOO/Web — production overview (oorgos.org) — CANONICAL

**Canonical edit path:** `/Users/kk/OOO/Web`

This tree is the full `coming-soon` static site for `oorgos.org` / `www.oorgos.org`.
Developers edit **here**, not under `Community/sites/coming-soon`.

## Paths

| Role | Path |
|------|------|
| **Canonical edit / daily work** | `/Users/kk/OOO/Web` |
| Publish mirror (optional) | `/Users/kk/OOO/Community/sites/coming-soon` |
| Legacy source (do not prefer) | `/Users/kk/OS_Community/sites/coming-soon` |
| Provisional canvas-web branding | `_provisional-canvas-web/` (not production) |

## Workflow

1. Edit files under `/Users/kk/OOO/Web`.
2. Generate into **this** directory (`npm run build`). That step must not write Community.
3. Deploy from Web, **or** sync the publish mirror in a **separate** step:

```bash
cd Web
npm run build
npm run sync-to-community          # dry-run; shows add/update/delete
# only after reviewing, and never if the mirror is dirty:
npm run sync-to-community:apply
# then, if deploying via Community path:
cd ../Community/sites/coming-soon
npx vercel@latest deploy --prod --yes
```

Generation still needs a Community checkout for `packages/shared` (`COMMUNITY_ROOT` if not the sibling `../Community`). It does not use a hardcoded personal home path.

Or deploy directly from Web if the Vercel project points here:

```bash
cd /Users/kk/OOO/Web
npx vercel@latest deploy --prod --yes
```

## Commands

```bash
cd Web
npm run overview:links   # stamps assets into Web (not Community)
npm run build
```

Community Web (`apps/web` at `community.oorgos.org`) is a separate Next.js app — not this folder.
