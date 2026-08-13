# MongoDB

Single-container MongoDB 5.0 deployment with authentication enabled.

## Quick Start

```bash
cp .env.example .env
# Set the administrator username and password in .env.
docker compose up -d
```

## Access

- MongoDB endpoint: `localhost:27017`
- Administrator username: `MONGO_INITDB_ROOT_USERNAME` in `.env`
- Administrator password: `MONGO_INITDB_ROOT_PASSWORD` in `.env`

## Configuration

- `data/` stores database data and `configdb/` stores MongoDB configuration data.
- The initial administrator is created only when the data directory is empty. Verify the initialization state before changing credentials.
- In production, restrict access to port `27017` with a firewall and expose it only to application containers where possible.
