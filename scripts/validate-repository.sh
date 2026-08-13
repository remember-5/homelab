#!/usr/bin/env bash
set -euo pipefail

strict=false
if [[ "${1:-}" == "--strict" ]]; then
  strict=true
elif [[ $# -ne 0 ]]; then
  echo "Usage: $0 [--strict]" >&2
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

while IFS= read -r -d '' file; do
  bash -n "$file"
  echo "Valid Shell syntax: $file"
done < <(find shell compose -type f -name '*.sh' -print0 | sort -z)

if [[ "$strict" == false ]]; then
  exit 0
fi

failed=false
while IFS= read -r -d '' file; do
  if rg -q '^[[:space:]]*version:' "$file"; then
    echo "Strict validation failed, obsolete version declaration: $file" >&2
    failed=true
  fi
  if rg -q 'image:[[:space:]]*[^#[:space:]]+:(latest|main|master)([[:space:]]|$)' "$file"; then
    echo "Strict validation failed, floating image tag: $file" >&2
    failed=true
  fi
  while IFS= read -r issue; do
    [[ -z "$issue" ]] && continue
    echo "Strict validation failed, $file: $issue" >&2
    failed=true
  done < <(
    docker compose -f "$file" config \
      --format json \
      --no-interpolate \
      --no-env-resolution \
      --no-path-resolution \
      --no-consistency |
      ruby -rjson -e '
        JSON.parse(STDIN.read).fetch("services", {}).each do |name, service|
          image = service["image"].to_s
          image_name = image.rpartition("/").last
          unless image.include?("@") || image_name.include?(":")
            puts "service #{name} uses an untagged image: #{image}"
          end
          puts "service #{name} is missing container_name" unless service.key?("container_name")
          puts "service #{name} is missing restart: always" unless service["restart"] == "always"
          environment = Array(service["environment"])
          has_timezone = environment.any? { |value| value == "TZ=Asia/Shanghai" } ||
            (service["environment"].is_a?(Hash) && service["environment"]["TZ"] == "Asia/Shanghai")
          puts "service #{name} is missing TZ=Asia/Shanghai" unless has_timezone
        end
      '
  )
done < <(find compose -type f \( -name 'docker-compose*.yml' -o -name 'compose.yml' \) -print0 | sort -z)

if [[ "$failed" == true ]]; then
  echo "Fix the findings according to AGENTS.md, or migrate historical examples incrementally." >&2
  exit 1
fi
