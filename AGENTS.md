# AGENTS.md

This file defines the standards for Docker and Docker Compose content in this repository.

## Role

Act as a DevOps infrastructure assistant and provide Docker and Docker Compose deployment solutions. Documentation, comments, user-facing script output, and commit messages must be written in English by default. Use Chinese only when a service requires Chinese-language content or when the user explicitly requests it.

## Directory and File Layout

Each service must use its own lowercase English directory named after the software:

```
<service-name>/
├── docker-compose.yml              # Required primary deployment file
├── README.md                       # Required English documentation
├── .env                            # Optional local variables, never committed
├── .env.example                    # Required sanitized template when .env is used
├── config/                         # Optional mounted configuration
└── docker-compose-<variant>.yml    # Optional deployment variant
```

- New services must use `docker-compose.yml` as the primary file. Migrate historical `compose.yml` files when modifying those services.
- Use `docker-compose-<variant>.yml` for alternative deployments, such as `docker-compose-mysql.yml` or `docker-compose-cluster.yml`.
- Keep mounted configuration in `config/`.
- Store persistent data under `data/` or `./data`.
- Ignore `.env` through `.gitignore`. Commit only `.env.example`, without usable passwords, keys, or tokens.

## Docker Compose Standards

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

### Required Rules

| Rule | Requirement |
| --- | --- |
| Explicit image version | Do not use `latest`, `main`, `master`, or an untagged image. Use a concrete version such as `rabbitmq:4.0.5-management`. |
| Restart policy | Every service must set `restart: always`. |
| Container name | Every service must set an explicit `container_name` based on the service name. |
| Time zone | Every service environment must include `TZ=Asia/Shanghai`. |
| Persistent data | Stateful services must mount persistent storage; do not keep data only inside a container. |

### Volumes

Use relative mounts within the service directory when possible:

```yaml
volumes:
  - ./data:/var/lib/<service>
  - ./config:/etc/<service>
  - ./logs:/var/log/<service>
```

For data shared by multiple containers, use named volumes declared at the bottom of the file:

```yaml
volumes:
  service_data:
  service_config:
```

### Networks and Dependencies

- Single-container services can use the default network.
- Multi-container deployments must define a custom bridge network.
- Use `depends_on` for startup dependencies.
- For critical databases and caches, add a health check and prefer `condition: service_healthy` for dependent services.

```yaml
networks:
  <service-name>-net:
    driver: bridge
```

### Environment Variables

- Use list syntax: `- KEY=VALUE`.
- Small non-sensitive settings may be written directly under `environment`.
- Passwords, keys, and tokens must be supplied through `.env` and `env_file` or via an external secret manager. Never hardcode production credentials in YAML.

### Optional Resource and Health Settings

Apply resource limits to resource-intensive services when appropriate:

```yaml
deploy:
  resources:
    limits:
      cpus: '4'
      memory: 4G
```

Add health checks for important services:

```yaml
healthcheck:
  test: ["CMD", "<check-command>"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 10s
```

### Proxy Template

Keep this commented proxy template in services that may need it:

```yaml
# - http_proxy=http://127.0.0.1:1080
# - https_proxy=http://127.0.0.1:1080
# - no_proxy=localhost,127.0.0.1
```

## README Standard

Every service directory must contain an English `README.md` with the following sections:

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

Explain non-standard settings in docker-compose.yml.

## Troubleshooting

Document known issues and resolutions when applicable.
```

Document default addresses, ports, credentials, migration procedures, and plugin installation steps where applicable.

## Prohibited Practices

- Using `latest`, `main`, `master`, or untagged images.
- Omitting persistent storage for stateful services.
- Hardcoding production passwords in Compose YAML.
- Omitting `restart: always`, `container_name`, or `TZ=Asia/Shanghai`.
- Committing `.env`, private keys, certificates, or usable access tokens.
- Adding non-English documentation or comments unless the user or service requirements explicitly call for them.

## Validation

Run the following before committing to validate Compose parsing and Shell syntax:

```bash
./scripts/validate-repository.sh
```

Run the strict audit after adding or modifying Compose services:

```bash
./scripts/validate-repository.sh --strict
```

The strict audit checks floating image tags, obsolete `version` declarations, container names, restart policies, and time zone configuration. Historical examples may be migrated incrementally, but new changes must not introduce violations.
