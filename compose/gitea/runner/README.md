# Gitea Runner

Gitea Actions runner.

## Quick Start

Generate `config.yaml`:

```bash
docker run --entrypoint="" --rm -it docker.io/gitea/runner:1.0.8 gitea-runner generate-config > config.yaml
```

Set the runner registration values in `.env` or in the shell:

```env
INSTANCE_URL=https://gitea.007966.xyz/
REGISTRATION_TOKEN=change-this-token
RUNNER_NAME=unraid-runner
RUNNER_LABELS=ubuntu-latest:docker://node:20-bookworm
```

Start the runner:

```bash
docker compose up -d
```

## Access

- URL: configured by `INSTANCE_URL`
- Default username: none
- Default password: none

## Configuration

The runner keeps state in `./data` and reads configuration from `./config.yaml`.

The Docker socket is mounted so the runner can start job containers. Treat this as privileged access.

## Troubleshooting

If cache is enabled in `config.yaml`, use `/data/cache` as the cache directory because `./data` is mounted into the container.
