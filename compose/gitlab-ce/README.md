# GitLab CE

Docker Compose deployment and backup migration helper for GitLab Community Edition.

## Quick Start

```shell
docker compose up -d
```

## Access

- URL: `https://gitlab.com:80`
- Default username: configured during the first GitLab setup
- Default password: configured during the first GitLab setup

## Configuration

`docker-compose.yml` publishes HTTP on port 80, HTTPS on port 443, and Git-over-SSH on port 22. Update `hostname`, `external_url`, and `gitlab_shell_ssh_port` before deploying to a different host or port.

Persistent GitLab configuration, logs, and data are stored in `./config`, `./logs`, and `./data`.

## Backup Transfer

The `sync_script.sh` helper fetches a GitLab backup through SSH using `rsync`. Install the required tools on the machine that runs the script:

```shell
sudo apt-get install -y rsync sshpass
```

Provide connection details through environment variables so that a password is not stored in the script or committed to Git:

```shell
SSH_SERVER=backup.example.com \
SSH_PORT=2222 \
SSH_USER=root \
SSH_PASSWORD='your-password' \
SOURCE_PATH=/backups/gitlab_backup.tar \
DOWNLOAD_PATH=/data \
LOG_FILE=/var/log/gitlab-sync.log \
./sync_script.sh
```

For key authentication, omit `SSH_PASSWORD` and set `SSH_CERT_PATH` to an existing private-key file. The script writes connection and `rsync` errors to `/data/sync.log` by default. Set `LOG_FILE` to an absolute writable path to use a custom location; its parent directory is created automatically.

## Troubleshooting

- Confirm that the source host accepts password authentication (`PasswordAuthentication yes`) and permits the selected user to log in.
- Confirm that `SSH_PORT` is the source server's SSH daemon port, not the GitLab SSH clone port unless they are the same.
- The script uses `StrictHostKeyChecking=no` for compatibility with older OpenSSH clients. Verify the source server address before starting a migration.
- Inspect the error immediately before the final failure line in the log. It distinguishes connection, authentication, host-key, and file-permission failures.
