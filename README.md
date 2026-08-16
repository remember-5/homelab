# Homelab

This repository collects homelab Docker Compose services and mirror configuration notes.

## Repository Layout

```text
compose/      Docker Compose service examples
scripts/      Repository validation utilities
MIRRORS.md    Mirror and registry notes
```

Use `compose/` as the entrypoint for Docker Compose deployments. Each runnable service lives under `compose/<service-name>/` or a documented variant directory such as `compose/postgres/prod`.

## Prerequisites

- Docker Engine with the Docker Compose plugin
- Bash

## Quick Start

```bash
cd compose/mysql
cp .env.example .env
# Edit .env and set a strong MYSQL_ROOT_PASSWORD.
docker compose up -d
docker compose ps
```

Read the service README before starting a service. Some services require first-run setup, external domains, reverse proxy configuration, or secrets in `.env`.

## Service Conventions

New and modified Compose services should follow these conventions:

- Use `docker-compose.yml` as the primary deployment file.
- Use explicit image tags or digests; do not use `latest`, `main`, `master`, `release`, or untagged images.
- Set `container_name`, `restart: always`, and `TZ=Asia/Shanghai` where supported.
- Store persistent data in `./data`, `./config`, `./logs`, or named volumes.
- Keep secrets in `.env` or an external secret manager, not in Compose YAML.
- Commit `.env.example` when a service requires local variables.

Full repository rules are documented in [AGENTS.md](AGENTS.md).

## Validation

Run validation before committing:

```bash
./scripts/validate-repository.sh
```

The validation is intentionally small: it checks Compose parsing and Shell syntax. Repository conventions are documented in [AGENTS.md](AGENTS.md) and should be reviewed when adding or modifying services.

## Working With Compose Services

Start a service:

```bash
cd compose/<service-name>
docker compose up -d
```

Stop a service:

```bash
docker compose down
```

View logs:

```bash
docker compose logs -f
```

Pull updated images:

```bash
docker compose pull
docker compose up -d
```

Use a variant file:

```bash
docker compose -f docker-compose-postgres.yml up -d
```

## Proxy Examples

For image builds, pass proxy values as build arguments:

```bash
docker build -t my-image:1.0.0 --no-cache \
  --build-arg HTTP_PROXY=http://127.0.0.1:1080 \
  --build-arg HTTPS_PROXY=http://127.0.0.1:1080 \
  --build-arg NO_PROXY=localhost,127.0.0.1 .
```

For Compose builds, define build arguments in the Compose file and provide values through the shell or `.env`:

```yaml
services:
  my-page:
    build:
      context: .
      args:
        - HTTP_PROXY=${HTTP_PROXY}
        - HTTPS_PROXY=${HTTPS_PROXY}
        - NO_PROXY=${NO_PROXY}
    image: my-page:1.0.0
    container_name: my-page
    restart: always
    environment:
      - TZ=Asia/Shanghai
    ports:
      - "8080:80"
```

```bash
HTTP_PROXY=http://127.0.0.1:1080 \
HTTPS_PROXY=http://127.0.0.1:1080 \
NO_PROXY=localhost,127.0.0.1 \
docker compose up -d --build
```

## Docker Daemon Proxy

Create `/etc/systemd/system/docker.service.d/http-proxy.conf`:

```ini
[Service]
Environment="HTTP_PROXY=http://proxy.example.com:8080/"
Environment="HTTPS_PROXY=http://proxy.example.com:8080/"
Environment="NO_PROXY=localhost,127.0.0.1,.example.com"
```

Reload systemd and restart Docker:

```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

## Docker And Mirror References

- Docker tutorial: https://yeasy.gitbook.io/
- Mirror and registry notes: [MIRRORS.md](MIRRORS.md)

## Convert Compose To Kubernetes YAML

Use [Kompose](https://github.com/kubernetes/kompose) when a Compose service needs a Kubernetes manifest.

- Kubernetes documentation: https://kubernetes.io/docs/tasks/configure-pod-container/translate-compose-kubernetes/
