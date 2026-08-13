# Portainer CE

Docker Compose deployment for Portainer CE, a Docker environment management UI.

## Quick Start

```bash
docker compose up -d
```

## Access

- HTTPS UI: https://localhost:9443
- HTTP UI: http://localhost:9000
- Create an administrator account and password on first access.

## Configuration

- The image is pinned to `portainer/portainer-ce:2.39.6`.
- The `portainer_data` named volume stores Portainer configuration and database data. Do not delete it unintentionally.
- Mounting the Docker socket grants Portainer control over the local Docker daemon. Restrict access to the management ports.
- Uncomment the proxy template in the Compose file when required.

## Reference

- https://docs.portainer.io/start/install-ce/server/docker/linux
