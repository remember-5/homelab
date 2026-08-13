# Kanboard

Docker Compose deployment for the Kanboard project management application.

## Quick Start

```bash
docker compose up -d
```

## Access

- HTTP: http://localhost:38080
- HTTPS: https://localhost:30443
- Default username: `admin`
- Default password: `admin`. Change it immediately after the first login.

## Configuration

- The image is pinned to `kanboard/kanboard:v1.2.53`.
- `data/` stores the SQLite database and attachments, `plugins/` stores extensions, and `ssl/` holds custom HTTPS certificates.
- Before exposing this service publicly, restrict access through a reverse proxy or firewall and replace the contents of `ssl/` with valid certificates.
