# Gitea Runner

Run Gitea Actions jobs in containers using the host Docker daemon.

## Quick Start

Runner 6.x requires Gitea 1.26.2 or newer. Enable Actions for the repositories that will use this runner. [Runner 6.0.0 release notes](https://gitea.com/gitea/runner/releases/tag/v6.0.0) · [Gitea Actions quickstart](https://docs.gitea.com/usage/actions/quickstart/)

For a new runner, copy the environment template.

```bash
cp .env.example .env
```

In `.env`, set `INSTANCE_URL` to the Gitea URL reachable from the runner and its job containers. Set `REGISTRATION_TOKEN` from the Gitea Actions runners page. Choose a distinct `RUNNER_NAME` for each runner.

If you use this repository's Gitea Compose example, update its `GITEA__server__ROOT_URL` from the default loopback address to the URL that clients use. [Gitea Compose example](../gitea/docker-compose.yml)

Start the runner.

```bash
docker compose up -d
```

## Access

Check the runner's status in **Actions → Runners** on the Gitea instance configured by `INSTANCE_URL`. The runner polls Gitea and publishes no host ports.

## Configuration

Set `RUNNER_LABELS` in `.env` to override the default labels. Use a separate `./data` directory for each runner.

Keep `./data` and `.env` when upgrading or moving a runner. The image reuses `./data/.runner` for registration and stores the local Actions cache in `./data/cache`. After registration, you can remove `REGISTRATION_TOKEN` from `.env` and recreate the container.

When upgrading to Runner 6.x, replace `builtin:checkout` with `actions/checkout` in existing workflows. [Runner 6.0.0 release notes](https://gitea.com/gitea/runner/releases/tag/v6.0.0)

Use the host Docker socket with trusted workflows.

### Migrate an existing data directory

If the runner previously mounted `./data/runner:/data`, stop it with `docker compose stop runner`. Move the existing `.runner` file, `cache` directory, and any other files referenced under `/data` from `./data/runner` into `./data` before running `docker compose up -d`.

### Custom runner configuration

Edit `config.yaml` to change Runner settings. Compose mounts the file read-only at `/config.yaml` and sets `CONFIG_FILE=/config.yaml`. To adjust concurrency, change `runner.capacity`, which starts at `1`. [Docker installation guide](https://docs.gitea.com/runner/installation/docker/#environment-variables) · [Runner configuration reference](https://gitea.com/gitea/runner/src/tag/v6.0.1/internal/pkg/config/config.example.yaml)

Run `docker compose up -d` to apply the new mount to an existing deployment. For later edits to the YAML file, run `docker compose restart runner` to reload it.

If you previously used `RUNNER_CONFIG_FILE`, merge your settings into `config.yaml` before recreating the runner. Keep configuration secrets in separate files under `./data` and reference their paths under `/data`.

### Shared cache

For shared caching, add `external_server` and `external_secret_file` to the `cache` section of `config.yaml`. Save the secret in `./data/cache-secret` with permissions restricted to its owner. If you previously set `RUNNER_CACHE_URL` and `RUNNER_CACHE_SECRET`, reuse those values before recreating the runner. Use the same secret on the cache server and each runner. [Official shared cache example](https://gitea.com/gitea/runner/src/tag/v6.0.1/README.md#sharing-a-cache-between-runners)

```yaml
cache:
  dir: /data/cache
  external_server: http://192.0.2.10:8088/
  external_secret_file: /data/cache-secret
```

## Troubleshooting

```bash
docker compose logs --tail=100 runner
```

If jobs do not start, check that the runner is online in Gitea and that the workflow's `runs-on` matches a runner label.
