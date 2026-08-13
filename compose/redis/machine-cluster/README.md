# Redis Cluster

Six-node Redis Cluster deployment example.

## Generate Configuration

```bash
REDIS_PASSWORD='replace-with-a-strong-password' ./init.sh 192.168.1.10
```

The IP address must be reachable by every cluster node. Generated `node-*/conf/redis.conf` files contain the password and must not be committed.

## Start the Cluster

```bash
docker compose -f docker-compose-cluster.yml up -d
```

## Create the Cluster

```bash
docker exec -it redis-6379 redis-cli -a "$REDIS_PASSWORD" \
  --cluster create \
  192.168.1.10:6379 192.168.1.10:6380 192.168.1.10:6381 \
  192.168.1.10:6382 192.168.1.10:6383 192.168.1.10:6384 \
  --cluster-replicas 1
```
