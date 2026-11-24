# Gitea

Self-hosted Git service for a homelab.

## Quick Start

For the single-container SQLite deployment:

```bash
docker compose up -d
```

For a new PostgreSQL deployment:

```bash
cp .env.example .env
```

Set `GITEA_DB_PASSWORD` in `.env` to a random password before starting the stack. If the database is already initialized, use the password of the existing PostgreSQL role.

```bash
docker compose -f docker-compose-postgres.yml up -d
```

For a fresh installation, open the Gitea setup page through a private or access-controlled connection. Create the first administrator under **Administrator Account Settings** and finish the setup. Gitea then writes `INSTALL_LOCK = true` under `[security]` in `/data/gitea/conf/app.ini`. Verify that you can sign in before opening the public route.

For an existing PostgreSQL 14 deployment, back up the database with `pg_dump` before switching. Point the PostgreSQL bind mount in `docker-compose-postgres.yml` at a fresh host directory and restore the dump into PostgreSQL 18 before starting Gitea. PostgreSQL 18 mounts that directory at `/var/lib/postgresql`.

## Access

- URL: `https://gitea.example.com/`
- Default username: created during first web setup
- Default password: created during first web setup

## Configuration

For HTTPS through Cloudflare Tunnel, set the hostname, URL, and cookie settings under `server.environment` in the Compose file you use.

```yaml
- GITEA__server__DOMAIN=gitea.example.com
- GITEA__server__ROOT_URL=https://gitea.example.com/
- GITEA__session__COOKIE_SECURE=true
```

For a deployment accessed directly over HTTP, set `GITEA__server__ROOT_URL` to the address clients use and set `GITEA__session__COOKIE_SECURE=false`.

Gitea uses UID and GID `1000`. The Gitea bind mount uses `/mnt/user/appdata/gitea/gitea` on Unraid, and the PostgreSQL bind mount uses `/mnt/user/appdata/gitea/postgres`. The default PostgreSQL database and role are both named `gitea`.

If you previously customized any of these settings in `.env`, copy the values into the corresponding Compose entries before recreating the containers. Keep the PostgreSQL password in `.env`.

Registration, anonymous browsing, OpenID sign-in/sign-up, and Swagger are disabled by default.

The PostgreSQL deployment publishes SSH on host port `222` on all interfaces. Set `GITEA__server__SSH_DOMAIN` to your Unraid LAN address to generate the correct clone URLs. Add your public key in Gitea and use `ssh://git@<unraid-lan-host>:222/<owner>/<repository>.git`. Keep the router and public Tunnel route restricted to the intended web access.

## Authentication Source

For GitLab OAuth, add an authentication source from `Site Administration` -> `Identity & Access` -> `Authentication Sources` -> `Add Authentication Source`.

Example endpoints:

```text
AUTH_URL=https://your-gitlab-domain.com/oauth/authorize
TOKEN_URL=https://your-gitlab-domain.com/oauth/token
PROFILE_URL=https://your-gitlab-domain.com/api/v4/user
```

## Troubleshooting

If Homepage also publishes port `3000` on the same Unraid host, change the host side of one of the port mappings. Update any links that use that host port.
