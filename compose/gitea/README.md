# Gitea

Self-hosted Git service for a homelab.

## Quick Start

For the single-container SQLite deployment:

```bash
cp .env.example .env
docker compose up -d
```

For the PostgreSQL deployment:

```bash
cp .env.example .env
docker compose -f docker-compose-postgres.yml up -d
```

## Access

- URL: `https://gitea.example.com/`
- Default username: created during first web setup
- Default password: created during first web setup

## Configuration

Set these values in `.env` before starting the service:

```env
GITEA_DB_PASSWORD=change-this-password
GITEA_DOMAIN=gitea.example.com
GITEA_ROOT_URL=https://gitea.example.com/
GITEA_COOKIE_SECURE=true
```

Use `GITEA_COOKIE_SECURE=true` when Gitea is accessed through HTTPS. If logging in directly through `http://IP:PORT`, set it to `false`.

The default Unraid data paths are:

```env
GITEA_APPDATA_DIR=/mnt/user/appdata/gitea/gitea
GITEA_POSTGRES_DIR=/mnt/user/appdata/gitea/postgres
```

Registration, anonymous browsing, SSH, OpenID sign-in/sign-up, and Swagger are disabled by default.

## Authentication Source

For GitLab OAuth, add an authentication source from `Site Administration` -> `Identity & Access` -> `Authentication Sources` -> `Add Authentication Source`.

Example endpoints:

```text
AUTH_URL=https://your-gitlab-domain.com/oauth/authorize
TOKEN_URL=https://your-gitlab-domain.com/oauth/token
PROFILE_URL=https://your-gitlab-domain.com/api/v4/user
```

## Troubleshooting

If Homepage also publishes port `3000` on the same Unraid host, change either `HOMEPAGE_PORT` or `GITEA_HTTP_PORT`.
