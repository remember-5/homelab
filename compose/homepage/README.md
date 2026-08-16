# Homepage

Homepage dashboard for Unraid-hosted homelab services.

## Quick Start

```bash
cp .env.example .env
docker compose up -d
```

## Access

- URL: `http://192.168.123.2:3000`
- Default username: none
- Default password: none

## Configuration

Homepage configuration is stored in `config/` and mounted directly to `/app/config`.

Set `HOMEPAGE_ALLOWED_HOSTS` in `.env` when you access Homepage through a different host name or address:

```env
HOMEPAGE_ALLOWED_HOSTS=192.168.123.2:3000
```

Service URLs in `config/services.yaml` are written as explicit addresses. Update them directly if the host IP or exposed ports change.

`HOMEPAGE_VAR_*` values are reserved for optional widget secrets so credentials are not committed in YAML files.

## Unraid Notes

The Docker socket is mounted read-only so Homepage can display container status:

```yaml
- /var/run/docker.sock:/var/run/docker.sock:ro
```

Treat Docker socket access as sensitive. Keep this dashboard on a trusted LAN or behind a VPN.

If another service also publishes port `3000` on the same host, change the host-side port in `docker-compose.yml` and update the Homepage URL in `config/services.yaml`.

## Troubleshooting

If Homepage rejects requests, check that `HOMEPAGE_ALLOWED_HOSTS` matches the exact host and port used in the browser.

If changes in `config/` do not appear in the UI, restart the Homepage container with `docker compose restart homepage`.
