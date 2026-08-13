#!/usr/bin/env bash
set -euo pipefail

BACKUP_ROOT="/data/gitlab"
CONFIG_BACKUP_DIR="${BACKUP_ROOT}/config-backups"
LOG_FILE="/var/log/gitlab-backup.log"
DATE="$(date +%F_%H-%M-%S)"

mkdir -p "${CONFIG_BACKUP_DIR}"

echo "[$(date '+%F %T')] Starting GitLab data backup..."

docker exec -t gitlab gitlab-backup create CRON=1

echo "[$(date '+%F %T')] GitLab data backup completed."

echo "[$(date '+%F %T')] Starting GitLab config backup..."

tar -czf "${CONFIG_BACKUP_DIR}/gitlab-config-${DATE}.tar.gz" \
  -C "${BACKUP_ROOT}" \
  config/gitlab.rb \
  config/gitlab-secrets.json \
  config/ssl \
  compose.yml \
  public.key \
  result.gitlab-license

echo "[$(date '+%F %T')] GitLab config backup completed."

find "${CONFIG_BACKUP_DIR}" -type f -name 'gitlab-config-*.tar.gz' -mtime +30 -delete

echo "[$(date '+%F %T')] Backup finished successfully."