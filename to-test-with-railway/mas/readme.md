# Matrix Authentication Service (MAS) - Local Docker Setup

This directory contains configuration for running the Matrix Authentication Service locally with Docker.

## Overview

MAS (Matrix Authentication Service) is an OAuth2/OIDC provider designed specifically for Matrix homeservers. It provides:
- Modern authentication flow for Matrix clients
- OAuth2/OIDC compatibility for integrations
- Centralized user authentication
- Support for external identity providers

## Prerequisites

- Docker installed
- PostgreSQL database for MAS (running on port 5434)
- Synapse homeserver (will connect to MAS on port 8080)
- MAS signing key (EC private key in PEM format)

## Quick Start

### 1. Database Setup

MAS requires a PostgreSQL database:
```bash
# Create PostgreSQL container for MAS
docker run -d \
  --name mas-db \
  -e POSTGRES_USER=mas \
  -e POSTGRES_PASSWORD=maspass \
  -e POSTGRES_DB=mas \
  -p 5434:5432 \
  postgres:15
```

### 2. Generate Signing Key

If you don't have a signing key yet:
```bash
# Generate EC P-256 signing key
openssl ecparam -name prime256v1 -genkey -noout -out mas-signing.key
```

### 3. Build MAS Docker Image

```bash
docker build --no-cache -t local-mas .
```

### 4. Run MAS Container

**Using PowerShell (Recommended for Windows):**
```powershell
$key = Get-Content "d:/Internship2/ess test/mas-signing.key" -Raw
cd "d:/Internship2/ess test/ess-helm/to-test-with-railway/mas"
docker run -d `
  --name mas `
  --env-file mas.env `
  -e MAS_SIGNING_KEY="$key" `
  --link mas-db:mas-db `
  -p 8080:8080 `
  local-mas
```

**Using Bash:**
```bash
key=$(cat ../../../mas-signing.key)
docker run -d \
  --name mas \
  --env-file mas.env \
  -e MAS_SIGNING_KEY="$key" \
  --link mas-db:mas-db \
  -p 8080:8080 \
  local-mas
```

## Configuration

### Environment Variables (mas.env)

| Variable | Description | Example |
|----------|-------------|---------|
| `MAS_PUBLIC_URL` | Public URL for MAS | `http://localhost:8080` |
| `MAS_PUBLIC_BASE` | Base URL for MAS | `http://localhost:8080` |
| `MAS_DATABASE_URI` | PostgreSQL connection string | `postgresql://mas:maspass@host.docker.internal:5434/mas` |
| `MAS_MATRIX_ENDPOINT` | Synapse homeserver URL | `http://host.docker.internal:8008` |
| `MAS_MATRIX_SERVER_NAME` | Matrix server name | `localhost` |
| `MAS_MATRIX_HOMESERVER` | Matrix homeserver name | `localhost` |
| `MAS_MATRIX_SHARED_SECRET` | Shared secret with Synapse | `local_shared_secret_123` |
| `MAS_CLIENT_ID` | OIDC client ID (min 28 chars) | `0000000000000000000SYNAPSE` |
| `MAS_CLIENT_SECRET` | OIDC client secret | `local_shared_secret_123` |
| `MAS_ENCRYPTION_KEY` | 64-char hex key for encryption | Generate with `openssl rand -hex 32` |
| `MAS_SIGNING_KEY` | EC private key in PEM format | Loaded from `mas-signing.key` file |
| `MAS_EMAIL_DOMAIN` | Email domain for notifications | `localhost` |

### Important Notes

1. **Client ID Length**: `MAS_CLIENT_ID` must be at least 28 characters for security. Use the format: `0000000000000000000SYNAPSE`

2. **Signing Key Format**: The signing key must be passed as a multi-line environment variable, not through the `.env` file due to Docker limitations.

3. **Database Connection**: Use `host.docker.internal` to connect to databases running on the host machine from within Docker.

## Integration with Synapse

### Synapse Configuration

Your Synapse `homeserver.yaml` should include:

```yaml
oidc_providers:
  - idp_id: mas
    idp_name: "Matrix Authentication Service"
    issuer: "http://host.docker.internal:8080"
    client_id: "0000000000000000000SYNAPSE"
    client_secret: "local_shared_secret_123"
    discover: true
    scopes: ["openid", "profile"]
    client_auth_method: "client_secret_basic"
    user_mapping_provider:
      config:
        localpart_template: "{{ user.sub }}"
        display_name_template: "{{ user.name }}"
```

### Synapse Environment Variables

Ensure Synapse has these environment variables set:
```bash
MAS_MATRIX_ENDPOINT=http://host.docker.internal:8080
MAS_CLIENT_ID=0000000000000000000SYNAPSE
MAS_CLIENT_SECRET=local_shared_secret_123
```

## Verification

### Check MAS Status

```bash
# View logs
docker logs mas --tail 50

# Check if MAS is running
docker ps | grep mas

# Test MAS endpoint
curl http://localhost:8080/.well-known/openid-configuration
```

### Expected Logs (Success)

```
INFO mas_cli::commands::server:62 Starting up version="v1.10.0"
INFO mas_cli::commands::server:71 Connecting to the database
INFO mas_cli::commands::server:84 Running pending database migrations
INFO mas_cli::sync:101 Acquiring configuration lock
INFO mas_cli::sync:108 Syncing providers and clients
INFO mas_cli::sync:386 Updating client client.id=0000000000000000000SYNAPSE
INFO mas_cli::commands::server:102 Starting server
INFO mas_http:194 Listening on http://0.0.0.0:8080
```

## Troubleshooting

### Error: "invalid length for key default.0.client_id.clients"

**Cause**: Client ID is too short (less than 28 characters)

**Solution**: Use a properly formatted client ID:
```bash
MAS_CLIENT_ID=0000000000000000000SYNAPSE
```

### Error: "could not import keys from config - Unsupported format"

**Cause**: Signing key not properly formatted or not passed as multi-line

**Solution**: Pass the signing key via command line as shown in Quick Start

### Error: "Connection refused" to database

**Cause**: MAS database is not running or not accessible

**Solution**: 
1. Verify database is running: `docker ps | grep mas-db`
2. Check connection string uses `host.docker.internal` for host databases
3. Verify database port (5434) is correct

## Docker Commands Reference

```bash
# Start MAS
docker start mas

# Stop MAS
docker stop mas

# Restart MAS
docker restart mas

# View logs (follow)
docker logs -f mas

# View last 50 log lines
docker logs mas --tail 50

# Remove container (to recreate with new config)
docker stop mas && docker rm mas

# Execute command in container
docker exec -it mas sh

# View generated config
docker exec mas cat /app/config.yaml
```

## Files

- `Dockerfile` - Docker image definition for MAS
- `entrypoint.sh` - Container startup script that processes templates
- `config.template.yaml` - MAS configuration template
- `mas.env` - Environment variables (except signing key)
- `mas-signing.env` - Signing key in single-line format (backup)
- `README.md` - This file

## Next Steps

1. ✅ MAS is running and configured
2. Configure and start Synapse with MAS integration
3. Set up Element Web to use Synapse
4. Test authentication flow
5. Deploy to Railway

## Railway Deployment

For Railway deployment, you'll need to:
1. Set all environment variables in Railway dashboard
2. Use Railway's PostgreSQL add-on for the database
3. Update URLs to use Railway's public domains
4. Add the signing key as a Railway environment variable (base64 encoded or as multi-line)

See the Railway deployment documentation for detailed instructions.

## Resources

- [MAS Documentation](https://github.com/matrix-org/matrix-authentication-service)
- [Matrix Spec - OIDC](https://spec.matrix.org/latest/)
- [Synapse OIDC Configuration](https://matrix-org.github.io/synapse/latest/usage/configuration/config_documentation.html#oidc_providers)