# Redmine

Two-container Redmine and PostgreSQL deployment.

## Quick Start

```bash
cp .env.example .env
# Set POSTGRES_PASSWORD in .env.
docker compose up -d
```

## Access

- Web interface: http://localhost:3000
- Default username: `admin`
- Default password: `admin`. Change it immediately after the first login.

## Configuration

- `.env` stores local database credentials and must not be committed.
- `data/redmine/` stores attachments and `data/postgres/` stores PostgreSQL data.
- Services communicate through `redmine-net`; the database port is not exposed to the host.
- The Redmine image is pinned to `redmine:6.1.3-bookworm`. Back up `data/` before upgrading.
