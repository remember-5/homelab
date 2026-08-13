#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || -z "${REDIS_PASSWORD:-}" ]]; then
  echo "Usage: REDIS_PASSWORD='strong-password' $0 <cluster-reachable-ip>" >&2
  exit 2
fi

cluster_ip="$1"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for port in $(seq 6379 6384); do
  config_dir="$script_dir/node-${port}/conf"
  mkdir -p "$config_dir"
  cat >"$config_dir/redis.conf" <<EOF
# Service port
port ${port}
requirepass ${REDIS_PASSWORD}
# Bind address
bind 0.0.0.0
# Disable protected mode
protected-mode no
daemonize no
# Persist write operations with AOF
appendonly yes
# Enable cluster mode
cluster-enabled yes
# Cluster configuration file
cluster-config-file nodes.conf
# Cluster node timeout
cluster-node-timeout 5000
# Public address announced by each cluster node
cluster-announce-ip ${cluster_ip}
cluster-announce-port ${port}
cluster-announce-bus-port 1${port}
EOF
done

echo "Generated configuration for 6 Redis nodes."
