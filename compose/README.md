# Docker Compose Services

This directory is the entrypoint for Docker Compose deployments in this repository.

## Layout

Each runnable service should use its own lowercase English directory:

```text
compose/<service-name>/
├── docker-compose.yml
├── README.md
├── .env.example
├── config/
├── data/
└── docker-compose-<variant>.yml
```

Use `docker-compose.yml` as the primary deployment file. Historical `compose.yml` files can be migrated when those services are modified.

Some directories are template groups with runnable variants below them, such as `postgres/prod` and `postgres/test`.

## Quick Start

```bash
cd compose/<service-name>
cp .env.example .env
docker compose up -d
```

Only copy `.env.example` when the service provides one. Update `.env` locally and never commit secrets.

For a variant deployment:

```bash
docker compose -f docker-compose-<variant>.yml up -d
```

## Listing Services

This README does not maintain a manual service index. List the current service directories from the repository root:

```bash
find compose -mindepth 1 -maxdepth 1 -type d | sort
```

## Validation

Run repository validation from the repository root:

```bash
./scripts/validate-repository.sh
```

See [../AGENTS.md](../AGENTS.md) for Compose standards.
