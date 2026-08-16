#!/usr/bin/env bash

# Values can be overridden for a single run, for example:
# SSH_PASSWORD='secret' SSH_SERVER='backup.example.com' LOG_FILE='/var/log/gitlab-sync.log' ./sync_script.sh
SSH_SERVER="${SSH_SERVER:-127.0.0.1}"
SSH_PORT="${SSH_PORT:-22}"
SSH_USER="${SSH_USER:-root}"
SSH_PASSWORD="${SSH_PASSWORD:-}"
SSH_CERT_PATH="${SSH_CERT_PATH:-}"

SOURCE_PATH="${SOURCE_PATH:-/backups/1737700056_2025_01_24_17.8.1-ee_gitlab_backup.tar}"
DOWNLOAD_PATH="${DOWNLOAD_PATH:-/data}"
LOG_FILE="${LOG_FILE:-/data/sync.log}"

mkdir -p "$(dirname "${LOG_FILE}")" "${DOWNLOAD_PATH}"
touch "${LOG_FILE}"
chmod 600 "${LOG_FILE}"

log() {
    printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "${LOG_FILE}"
}

ssh_options=(
    -p "${SSH_PORT}"
    # This setting is supported by older OpenSSH clients.
    -o StrictHostKeyChecking=no
    -o ConnectTimeout=15
    -o ServerAliveInterval=60
)

if [[ -n "${SSH_CERT_PATH}" && -f "${SSH_CERT_PATH}" ]]; then
    AUTH_METHOD="certificate"
    ssh_options+=( -i "${SSH_CERT_PATH}" )
elif [[ -n "${SSH_PASSWORD}" ]]; then
    AUTH_METHOD="password"
    ssh_options+=(
        -o PreferredAuthentications=password,keyboard-interactive
        -o PubkeyAuthentication=no
        -o PasswordAuthentication=yes
    )
else
    log "No usable SSH authentication method was configured. Set SSH_PASSWORD or SSH_CERT_PATH."
    printf 'No usable SSH authentication method. See %s for details.\n' "${LOG_FILE}" >&2
    exit 1
fi

if [[ "${AUTH_METHOD}" == "password" ]] && ! command -v sshpass >/dev/null 2>&1; then
    log "sshpass is required for password authentication but is not installed."
    printf 'sshpass is required for password authentication. See %s for details.\n' "${LOG_FILE}" >&2
    exit 1
fi

log "Testing SSH connection to ${SSH_USER}@${SSH_SERVER}:${SSH_PORT} using ${AUTH_METHOD} authentication."
if [[ "${AUTH_METHOD}" == "password" ]]; then
    SSHPASS="${SSH_PASSWORD}" sshpass -e ssh "${ssh_options[@]}" "${SSH_USER}@${SSH_SERVER}" exit >> "${LOG_FILE}" 2>&1
else
    ssh "${ssh_options[@]}" "${SSH_USER}@${SSH_SERVER}" exit >> "${LOG_FILE}" 2>&1
fi

if [[ $? -ne 0 ]]; then
    log "SSH connection failed. Review the preceding SSH error in this log."
    printf 'SSH connection failed. See %s for the SSH error.\n' "${LOG_FILE}" >&2
    exit 1
fi

ssh_command="ssh -p ${SSH_PORT} -o StrictHostKeyChecking=no -o ConnectTimeout=15 -o ServerAliveInterval=60"
if [[ "${AUTH_METHOD}" == "certificate" ]]; then
    ssh_command+=" -i ${SSH_CERT_PATH}"
else
    ssh_command+=" -o PreferredAuthentications=password,keyboard-interactive -o PubkeyAuthentication=no -o PasswordAuthentication=yes"
fi

log "SSH connection succeeded. Starting rsync from ${SOURCE_PATH}."
if [[ "${AUTH_METHOD}" == "password" ]]; then
    SSHPASS="${SSH_PASSWORD}" sshpass -e rsync -avz --partial --progress --timeout=60 \
        -e "${ssh_command}" "${SSH_USER}@${SSH_SERVER}:${SOURCE_PATH}" "${DOWNLOAD_PATH}/" >> "${LOG_FILE}" 2>&1
else
    rsync -avz --partial --progress --timeout=60 \
        -e "${ssh_command}" "${SSH_USER}@${SSH_SERVER}:${SOURCE_PATH}" "${DOWNLOAD_PATH}/" >> "${LOG_FILE}" 2>&1
fi

if [[ $? -eq 0 ]]; then
    log "GitLab backup transfer completed successfully."
    printf 'GitLab backup transfer completed successfully.\n'
else
    log "GitLab backup transfer failed. Review the preceding rsync error in this log."
    printf 'GitLab backup transfer failed. See %s for details.\n' "${LOG_FILE}" >&2
    exit 1
fi
