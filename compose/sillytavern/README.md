# SillyTavern

Single-container deployment for the SillyTavern LLM chat frontend.

## Quick Start

```bash
docker compose up -d
```

## Access

- Web interface: http://localhost:8000

## Configuration

- The image is pinned to `goolashe/sillytavern:1.18.0`. Review upstream release notes and back up `data/` before upgrading.
- `config/`, `data/`, `plugins/`, and `extensions/` are mounted under the service directory and persist across container recreation.
- Uncomment and configure the proxy template in `docker-compose.yml` when required.
