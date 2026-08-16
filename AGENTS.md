# AGENTS.md

This file defines the repository rules for Docker Compose services and mirror configuration notes.

## Role

Act as a DevOps infrastructure assistant. Provide practical Docker Compose deployment solutions that are easy to run, inspect, and migrate.

Documentation, comments, user-facing script output, and commit messages must be written in English by default. Use Chinese only when a service requires Chinese-language content or when the user explicitly asks for Chinese.

## Scope

The main deployment entrypoint is `compose/`.

Top-level directories are used as follows:

```text
compose/      Docker Compose service examples
scripts/      Repository validation utilities
MIRRORS.md    Mirror and registry notes
```

## Service Layout

Each Compose service should live in its own lowercase English directory named after the software:

```text
compose/<service-name>/
├── docker-compose.yml              # Primary deployment file
├── README.md                       # Service documentation
├── .env                            # Local variables, never committed
├── .env.example                    # Sanitized template when .env is needed
├── config/                         # Mounted configuration
├── data/                           # Local persistent data, not committed
└── docker-compose-<variant>.yml    # Optional deployment variant
```

New services must use `docker-compose.yml` as the primary deployment file. Historical `compose.yml` files may remain until that service is modified. When modifying a historical service, migrate it to `docker-compose.yml` unless there is a clear reason not to.

Use `docker-compose-<variant>.yml` for alternative deployments, such as `docker-compose-postgres.yml`, `docker-compose-cluster.yml`, or `docker-compose-gpu.yml`.

Template groups are allowed when a directory is intentionally a collection of variants, for example `compose/postgres/prod` and `compose/postgres/test`. In that case, the group directory should still have a short README that points to the runnable variants.

## Compose Rules

Use modern Compose syntax without a `version` declaration:

```yaml
services:
  <service-name>:
    image: <image>:<explicit-version>
    container_name: <service-name>
    restart: always
    environment:
      - TZ=Asia/Shanghai
    ports:
      - "<host-port>:<container-port>"
    volumes:
      - ./data:/var/lib/<service-path>
```

Required rules for new and modified services:

| Rule | Requirement |
| --- | --- |
| Image version | Use an explicit image tag or digest. Do not use `latest`, `main`, `master`, `release`, `stable`, untagged images, or other floating defaults. |
| Restart policy | Every long-running service must set `restart: always`. |
| Container name | Every service must set an explicit `container_name` based on the service name. |
| Time zone | Every service environment must include `TZ=Asia/Shanghai` unless the image does not support `TZ`. |
| Persistent data | Stateful services must mount persistent storage; do not keep data only inside a container. |
| Secrets | Passwords, tokens, private keys, certificates, and production credentials must not be hardcoded in Compose YAML. |

Use relative mounts inside the service directory when possible:

```yaml
volumes:
  - ./data:/var/lib/<service>
  - ./config:/etc/<service>
  - ./logs:/var/log/<service>
```

Use named volumes only when they are shared by multiple containers or when the image specifically benefits from Docker-managed volumes:

```yaml
volumes:
  service_data:
  service_config:
```

Single-container services can use the default network. Multi-container deployments should define a custom bridge network:

```yaml
networks:
  <service-name>-net:
    driver: bridge
```

Use `depends_on` for startup dependencies. For critical databases and caches, add a health check and prefer `condition: service_healthy` for dependent services.

## Environment And Secrets

Use list syntax for Compose environment variables unless a copied upstream Compose file already uses mapping syntax:

```yaml
environment:
  - TZ=Asia/Shanghai
  - SERVICE_PORT=8080
```

Small non-sensitive defaults may be written directly in Compose YAML. Secrets must be supplied through `.env`, `env_file`, or an external secret manager.

If a Compose file uses `.env` or `${VARIABLE}` placeholders for required runtime values, add a sanitized `.env.example` next to it. Example values must be placeholders, not usable production credentials.

Keep `.env` ignored by Git. Commit `.env.example` only.

## Optional Settings

Apply resource limits to heavy services when it helps prevent accidental host exhaustion:

```yaml
deploy:
  resources:
    limits:
      cpus: "4"
      memory: 4G
```

Add health checks for databases, caches, web applications, and services that other containers depend on:

```yaml
healthcheck:
  test: ["CMD", "<check-command>"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 10s
```

Keep this commented proxy template in services that commonly need outbound network access:

```yaml
# - http_proxy=http://127.0.0.1:1080
# - https_proxy=http://127.0.0.1:1080
# - no_proxy=localhost,127.0.0.1
```

## README Rules

Every runnable service directory must contain an English `README.md` with these sections:

```markdown
# <Service Name>

One-sentence description.

## Quick Start

docker compose up -d

## Access

- URL: http://localhost:<port>
- Default username: xxx
- Default password: xxx

## Configuration

Explain required variables, mounted paths, ports, and non-standard settings.

## Troubleshooting

Document known issues and useful commands.
```

Document default addresses, ports, credentials, migration procedures, plugin installation steps, and any required first-run setup.

## Prohibited Practices

- Using floating image tags or untagged images for new and modified services.
- Omitting persistent storage for stateful services.
- Hardcoding production passwords, tokens, private keys, certificates, or usable access credentials.
- Committing `.env`, generated secrets, private keys, certificates, or local runtime state.
- Adding non-English documentation or comments unless the user or service requirements explicitly call for it.
- Adding a manual service index that must be updated every time a directory changes.

## Validation

Keep validation lightweight and reliable.

Run validation before committing:

```bash
./scripts/validate-repository.sh
```

The validation checks Compose parsing and Shell syntax. This is the default CI-level check.

Do not turn the validation script into a broad policy linter unless the repository is ready to enforce that policy on every existing service. For now, apply the Compose rules in this file during reviews and while adding or modifying services.
