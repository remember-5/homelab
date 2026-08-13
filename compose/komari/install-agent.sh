#!/usr/bin/env bash
set -euo pipefail

: "${KOMARI_SERVER_URL:?Set KOMARI_SERVER_URL, for example http://192.168.0.1:25774}"
: "${KOMARI_AUTO_DISCOVERY_TOKEN:?Set KOMARI_AUTO_DISCOVERY_TOKEN}"
: "${KOMARI_CUSTOM_IPV4:?Set KOMARI_CUSTOM_IPV4}"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
discovery_file="$script_dir/.komari-auto-discovery.json"
touch "$discovery_file"

docker run -d --name komari-agent \
  --restart=always \
  -e TZ=Asia/Shanghai \
  -v "$discovery_file:/app/auto-discovery.json" \
  ghcr.io/komari-monitor/komari-agent:1.2.13 \
  -e "$KOMARI_SERVER_URL" \
  --auto-discovery "$KOMARI_AUTO_DISCOVERY_TOKEN" \
  --custom-ipv4 "$KOMARI_CUSTOM_IPV4"
