# runtime-private

Local-only runtime data (logs, temp, secret placeholders, parked copies).

**Never commit secrets.** Do not copy `.env`, `*.pem`, or `*.key` into tracked trees.
This directory is for private runtime material outside normal project sync.

## Parked umbrella tenants

`parked-umbrella-tenants-2026-09-16/` holds former umbrella `tenants/<id>/` trees moved off the daily root so the umbrella tracks policy files only. Live day-to-day data is `Core/tenants/`. Delete or archive this park when you no longer need the comparison copy.
