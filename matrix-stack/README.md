# Matrix Stack - Simple Bot Development Setup

A minimal Matrix homeserver (Synapse) + Element Web stack for bot development.

## Quick Start

1. **Set environment variables** (Railway/Docker):

### Synapse
```bash
SYNAPSE_SERVER_NAME=your-synapse-url.up.railway.app
SYNAPSE_PUBLIC_BASEURL=https://your-synapse-url.up.railway.app
SYNAPSE_DB_USER=postgres
SYNAPSE_DB_PASSWORD=your-db-password
SYNAPSE_DB_HOST=your-db-host
SYNAPSE_DB_PORT=5432
SYNAPSE_DB_NAME=synapse
SYNAPSE_MACAROON_SECRET_KEY=$(openssl rand -hex 32)
SYNAPSE_FORM_SECRET=$(openssl rand -hex 32)
SYNAPSE_REGISTRATION_SECRET=$(openssl rand -hex 32)
```

### Element Web
```bash
HOMESERVER_URL=https://your-synapse-url.up.railway.app
SERVER_NAME=your-synapse-url.up.railway.app
ELEMENT_DEFAULT_THEME=light
```

2. **Deploy to Railway**:
   - Create new project
   - Add PostgreSQL database
   - Deploy Synapse service (uses port 8008)
   - Deploy Element Web service (uses port 80)

3. **Register a bot account**:
```bash
curl -X POST "https://your-synapse-url.up.railway.app/_synapse/admin/v1/register" \
  -H "Content-Type: application/json" \
  -d '{
    "nonce": "your-nonce",
    "username": "mybot",
    "password": "secure-password",
    "admin": false,
    "shared_secret": "your-SYNAPSE_REGISTRATION_SECRET"
  }'
```

Or use Element Web to register regular users at: https://your-element-url.up.railway.app

## Features

✅ **Registration enabled** - Create bot accounts easily  
✅ **No MAS** - Simple standalone setup  
✅ **PostgreSQL** - Production-ready database  
✅ **Element Web** - Test your bots with a real client  

## Bot Development

Your friend can now:
1. Register bot accounts via registration secret
2. Use Matrix SDK (Python, JS, etc.) to connect
3. Test bot interactions via Element Web
4. Access homeserver at: `https://your-synapse-url.up.railway.app`

## Folder Structure
```
matrix-stack/
├── synapse/
│   ├── Dockerfile
│   ├── homeserver.template.yaml
│   └── entrypoint.sh
└── element-web/
    ├── Dockerfile
    ├── config.template.json
    └── entrypoint.sh
```
