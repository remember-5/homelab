# Xinference

Xinference local model-serving deployment with NVIDIA GPU reservation enabled by default.

## Quick Start

```bash
docker compose up -d
```

## Access

- Web interface: http://localhost:9997

## Configuration

- The image is pinned to `xprobe/xinference:v3.1.0`. Review upstream compatibility notes before upgrading.
- `./data` stores models, cache, and runtime data.
- For CPU-only deployments, remove `deploy.resources.reservations.devices` before starting the service.
- Uncomment the proxy template when model downloads need a proxy.
