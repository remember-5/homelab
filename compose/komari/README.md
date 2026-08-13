# Komari

Docker Compose deployment for Komari host monitoring.

## Quick Start

```bash
docker compose up -d
```

## Access

- Web interface: http://localhost:25774

## Configuration

- The image is pinned to `ghcr.io/komari-monitor/komari:1.4.2`.
- `./data` stores service data. Back it up before upgrading or recreating the container.
- The agent requires an explicit server URL, auto-discovery token, and public IPv4 address:

```bash
KOMARI_SERVER_URL=http://192.168.1.10:25774 \
KOMARI_AUTO_DISCOVERY_TOKEN=replace-with-your-token \
KOMARI_CUSTOM_IPV4=192.168.1.20 \
./install-agent.sh
```
