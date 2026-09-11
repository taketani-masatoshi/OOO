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
2. Deploy from Web, **or** sync back to Community before a Community-rooted Vercel deploy:

```bash
cd /Users/kk/OOO/Web
npm run sync-to-community
# then, if deploying via Community path:
cd /Users/kk/OOO/Community/sites/coming-soon
npx vercel@latest deploy --prod --yes
```

Or deploy directly from Web if the Vercel project points here:

```bash
cd /Users/kk/OOO/Web
npx vercel@latest deploy --prod --yes
```

## Commands

```bash
cd /Users/kk/OOO/Web
npm run overview:links   # stamps ecosystem/locale assets via Community workspace script
npm run build
```

Community Web (`apps/web` at `community.oorgos.org`) is a separate Next.js app — not this folder.
