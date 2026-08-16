#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 0 ]]; then
  echo "Usage: $0" >&2
  exit 2
fi

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root_dir"

check_compose() {
  local file="$1"
  docker compose -f "$file" config \
    --no-interpolate \
    --no-env-resolution \
    --no-path-resolution \
    --no-consistency \
    -q
}

while IFS= read -r -d '' file; do
  check_compose "$file"
  echo "Valid Compose configuration: $file"
done < <(find compose -type f \( -name 'docker-compose*.yml' -o -name 'compose.yml' \) -print0 | sort -z)

shell_search_dirs=(compose)
if [[ -d shell ]]; then
  shell_search_dirs+=(shell)
fi

while IFS= read -r -d '' file; do
  bash -n "$file"
  echo "Valid Shell syntax: $file"
done < <(find "${shell_search_dirs[@]}" -type f -name '*.sh' -print0 | sort -z)
