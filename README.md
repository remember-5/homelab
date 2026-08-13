# Shell and Docker Compose Examples

This repository collects operational Shell scripts and Docker Compose deployment examples. Each service lives under `compose/<service-name>/`; read its `README.md` before starting it.

## Quick Start

```bash
cd compose/mysql
cp .env.example .env
# Set passwords and other sensitive values in .env.
docker compose up -d
```

Do not commit `.env`, private keys, certificates, or access tokens. Where available, use the commented proxy environment-variable template in the Compose file.

## Validation

Run this before committing:

```bash
./scripts/validate-repository.sh
```

Run the strict audit after adding or modifying a Compose service:

```bash
./scripts/validate-repository.sh --strict
```

See [AGENTS.md](AGENTS.md) for repository rules. Historical examples are being migrated incrementally; all new and modified services must follow the current standard.

## Convert Docker Compose to Kubernetes YAML

Use [Kompose](https://github.com/kubernetes/kompose).

- Kubernetes documentation: https://kubernetes.io/docs/tasks/configure-pod-container/translate-compose-kubernetes/

## Docker References

- Docker tutorial: https://yeasy.gitbook.io/
- Docker registry mirrors:
  - https://github.com/cmliu/CF-Workers-docker.io
  - https://dockerx.org/about/
  - https://mirror.kentxxq.com/image

```json
{
  "registry-mirrors": [
    "https://docker.1ms.run",
    "https://docker.xuanyuan.me",
    "https://docker.m.daocloud.io"
  ]
}
```

## Proxy Build Examples

```bash
docker build -t my-image:1.0.0 --no-cache \
  --build-arg http_proxy=http://127.0.0.1:1080 \
  --build-arg https_proxy=http://127.0.0.1:1080 .

docker compose up -d --build \
  -e http_proxy=http://127.0.0.1:1080 \
  -e https_proxy=http://127.0.0.1:1080
```

## Build With Docker Compose

```dockerfile
FROM node:18.20.4-alpine AS build
WORKDIR /app

ARG ENV_ARG
ENV BUILD_ENV=$ENV_ARG

COPY package.json .
RUN npm install --registry https://registry.npmmirror.com
COPY . /app
RUN npm run build:${BUILD_ENV}

FROM nginx:1.27.1-alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY deploy/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

```yaml
services:
  my-page:
    build:
      context: .
      args:
        - http_proxy=${http_proxy}
        - https_proxy=${https_proxy}
        - ENV_ARG=${ENV_ARG}
    image: my-page:1.0.0
    ports:
      - 8080:80
```

## Docker Proxy Configuration

### Configure dockerd

Create `/etc/systemd/system/docker.service.d/http-proxy.conf`:

```ini
[Service]
Environment="HTTP_PROXY=http://proxy.example.com:8080/"
Environment="HTTPS_PROXY=http://proxy.example.com:8080/"
Environment="NO_PROXY=localhost,127.0.0.1,.example.com"
```

Reload systemd and restart Docker:

```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### Configure Container Proxy Variables

Add the following to `~/.docker/config.json` when containers need a proxy:

```json
{
  "proxies": {
    "default": {
      "httpProxy": "http://proxy.example.com:8080/",
      "httpsProxy": "http://proxy.example.com:8080/",
      "noProxy": "localhost,127.0.0.1,.example.com"
    }
  }
}
```

### Configure Build Proxy Arguments

```bash
docker build \
  --build-arg "HTTP_PROXY=http://proxy.example.com:8080/" \
  --build-arg "HTTPS_PROXY=http://proxy.example.com:8080/" \
  --build-arg "NO_PROXY=localhost,127.0.0.1,.example.com" .
```

## FAQ

### `mkdir` Does Not Work in an ARM Dockerfile

Prefer `WORKDIR`, which creates the directory automatically:

```dockerfile
FROM bellsoft/liberica-openjdk-debian:17.0.11-cds

WORKDIR /app/server
ENV SERVER_PORT=8080 LANG=C.UTF-8 LC_ALL=C.UTF-8 JAVA_OPTS="" TZ=Asia/Shanghai

EXPOSE ${SERVER_PORT}
```
