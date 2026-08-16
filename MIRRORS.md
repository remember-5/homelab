# Mirror And Registry Notes

This file collects mirror and registry configuration examples for development and server bootstrap tasks.

Use mirrors only when they are appropriate for your network environment. For production hosts, review each mirror source before applying it.

## Linux Package Mirrors

The `linuxmirrors.cn` script can switch common Linux distribution package repositories.

- Website: https://linuxmirrors.cn/

```bash
bash <(curl -sSL https://linuxmirrors.cn/main.sh)
```

## Docker Install Mirrors

The `linuxmirrors.cn` Docker script can switch Docker installation repositories.

- Website: https://linuxmirrors.cn/

```bash
bash <(curl -sSL https://linuxmirrors.cn/docker.sh)
```

## Docker Registry Mirrors

Example Docker daemon registry mirror configuration:

```json
{
  "registry-mirrors": [
    "https://docker.1ms.run",
    "https://docker.xuanyuan.me",
    "https://docker.m.daocloud.io"
  ]
}
```

Common registry mirror references:

- https://github.com/cmliu/CF-Workers-docker.io
- https://dockerx.org/about/
- https://mirror.kentxxq.com/image

## Maven Mirrors

Add one mirror entry to your Maven `settings.xml`.

Alibaba Cloud public repository:

```xml
<mirror>
  <id>aliyunmaven</id>
  <mirrorOf>*</mirrorOf>
  <name>Aliyun Maven Public Repository</name>
  <url>https://maven.aliyun.com/repository/public</url>
</mirror>
```

NetEase 163 repository:

```xml
<mirror>
  <id>nexus-163</id>
  <mirrorOf>*</mirrorOf>
  <name>Nexus 163</name>
  <url>http://mirrors.163.com/maven/repository/maven-public/</url>
</mirror>
```

## Node.js Registry

Use the npmmirror registry for one command:

```bash
npm install -g pnpm --registry=https://registry.npmmirror.com
```

Set npmmirror as the default npm registry:

```bash
npm config set registry https://registry.npmmirror.com
```
