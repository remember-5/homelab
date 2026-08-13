#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 [repository-path] [from-date] [to-date]" >&2
  echo "Example: $0 . 2026-01-01 2026-01-31" >&2
}

repo_path="${1:-.}"
from_date="${2:-$(date +%Y-01-01)}"
to_date="${3:-$(date +%F)}"

if [[ $# -gt 3 ]]; then
  usage
  exit 2
fi

if ! git -C "$repo_path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a Git repository: $repo_path" >&2
  exit 1
fi

while IFS= read -r author; do
  [[ -z "$author" ]] && continue
  commits="$(git -C "$repo_path" log --author="$author" --after="$from_date" --before="$to_date 23:59:59" --oneline | wc -l | tr -d ' ')"
  lines="$(git -C "$repo_path" log --author="$author" --after="$from_date" --before="$to_date 23:59:59" --numstat | awk '$1 ~ /^[0-9]+$/ && $2 ~ /^[0-9]+$/ { total += $1 + $2 } END { print total + 0 }')"
  echo "Author: $author"
  echo "Commits: $commits"
  echo "Changed lines: $lines"
  echo
done < <(git -C "$repo_path" log --pretty='%aN' --after="$from_date" --before="$to_date 23:59:59" | sort -u)
