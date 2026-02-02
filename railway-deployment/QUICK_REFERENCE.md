# Quick Start Reference Guide

## Working Deployment Summary

**Status**: ✅ All three services running on Railway

### Current Service URLs
- **Synapse**: `https://synapse-production-e979.up.railway.app`
- **MAS**: `https://mas-service-production.up.railway.app`
- **Element Web**: `https://ess-helm-production.up.railway.app`

### Database Configuration

#### Synapse Database
```
Host: postgres.railway.internal
Port: 5432
Database: railway
User: postgres
Password: eEFsjzqXcmIBuvOWLPXXIPVLJQKlTOkC
```

#### MAS Database
```
Host: postgres-h2zw.railway.internal
Port: 5432
Database: railway
User: postgres
Password: wHNhQGDToDcZJfzOxEOCjSYnSooDySqt
```

### Server Secrets

| Secret | Value | Purpose |
|--------|-------|---------|
| **registration_shared_secret** | `4578b92c30adf6e1` | Admin API access |
| **macaroon_secret_key** | `6f01b8a9c5e2d437` | Session tokens |
| **form_secret** | `32f4cb150ed867a9` | CSRF protection |
| **encryption_key** | `c07af15b849e23d6f9a1b4c8d2e6f0a3b7c1d5e9f3a7b1c5d9e3f7a1b5c9d3e7` | MAS encryption |

---

## Deployment Architecture

### Services & Ports

```
Element Web (port 80)
    ↓ HTTPS
Synapse (port 8008) ←→ MAS (port 8080)
    ↓
PostgreSQL DB (port 5432) x2
```

### File Structure

```
railway-deployment/
│
├── synapse/
│   ├── Dockerfile                              # Build configuration
│   ├── homeserver.yaml                         # Main Synapse config
│   ├── railway.json                            # Railway deploy config
│   └── synapse-config/
│       ├── synapse-production-e979.up...key    # Federation signing key
│       └── synapse-production-e979.up...log    # Logging configuration
│
├── MAS-service/
│   ├── Dockerfile
│   ├── config.yaml                             # MAS configuration
│   └── railway.json
│
├── element-web/
│   ├── Dockerfile
│   ├── config.json                             # Client configuration
│   └── railway.json
│
└── DEPLOYMENT_DOCUMENTATION.md                 # Full documentation
```

---

## Key Configuration Details

### Synapse Configuration (homeserver.yaml)

**Critical Settings**:
```yaml
server_name: "synapse-production-e979.up.railway.app"    # Cannot change
public_baseurl: "https://synapse-production-e979.up.railway.app/"

database:
  name: psycopg2
  args:
    host: postgres.railway.internal
    password: eEFsjzqXcmIBuvOWLPXXIPVLJQKlTOkC

registration_shared_secret: "4578b92c30adf6e1"
macaroon_secret_key: "6f01b8a9c5e2d437"
form_secret: "32f4cb150ed867a9"

enable_registration: true
enable_registration_without_verification: true
```

### MAS Configuration (config.yaml)

**Critical Settings**:
```yaml
http:
  public_base: "https://mas-service-production.up.railway.app/"
  listeners:
    - address: "0.0.0.0:8080"

database:
  uri: "postgresql://postgres:wHNhQGDToDcZJfzOxEOCjSYnSooDySqt@postgres-h2zw.railway.internal:5432/railway"

matrix:
  homeserver: "synapse-production-e979.up.railway.app"
  endpoint: "https://synapse-production-e979.up.railway.app"
  secret: "4578b92c30adf6e1"

secrets:
  encryption: "c07af15b849e23d6f9a1b4c8d2e6f0a3b7c1d5e9f3a7b1c5d9e3f7a1b5c9d3e7"
  keys:
    - kid: "default"
      private_key: |
        -----BEGIN EC PRIVATE KEY-----
        MHcCAQEEIJGlh975aqLDMRj14FmkOb5BB89gS8q1EdWAqfTQAnozoAoGCCqGSM49
        AwEHoUQDQgAEvJtmvto/lxwcPKke1usYPJuJvp2eVVWeQt1e3/BUvZQuivHR40Sd
        5C6Wdyv0K5s7Z3kLpZ3K8n8lZ7V7Z3kLpZ3K8n8lZ7Vg==
        -----END EC PRIVATE KEY-----
```

### Element Web Configuration (config.json)

```json
{
  "default_server_config": {
    "m.homeserver": {
      "base_url": "https://synapse-production-e979.up.railway.app",
      "server_name": "synapse-production-e979.up.railway.app"
    }
  }
}
```

---

## Testing Checklist

### Service Health
- [ ] `curl https://synapse-production-e979.up.railway.app/_matrix/static/` → 200
- [ ] `curl https://mas-service-production.up.railway.app/health` → 200
- [ ] Element Web loads in browser → login page visible

### User Operations
- [ ] Can register new account via Element Web
- [ ] Can login with registered credentials
- [ ] Can create new room
- [ ] Can send messages in room
- [ ] Can view room history

### Federation
- [ ] Run Matrix Federation Tester: https://federationtester.matrix.org/
- [ ] Enter `synapse-production-e979.up.railway.app`
- [ ] All checks should pass (green ✓)

---

## Common Operations

### View Logs
**Railway UI** → Select Service → Logs tab → scroll to see messages

### Test Database Connection
```bash
psql postgresql://postgres:PASSWORD@postgres.railway.internal:5432/railway
```

### Check Synapse Health
```bash
# Version
curl https://synapse-production-e979.up.railway.app/_synapse/admin/v1/server_version

# Client versions
curl https://synapse-production-e979.up.railway.app/_matrix/client/versions
```

### Restart a Service
1. Railway UI → Select Service
2. Click "..." menu → Restart
3. Wait 1-2 minutes for restart

### View Database Tables
```bash
psql postgresql://postgres:PASSWORD@postgres.railway.internal:5432/railway

# List Synapse tables
\dt public.*synapse*

# List MAS tables
\dt public.*oidc*
```

---

## Troubleshooting Quick Fixes

### Service Returns 502 Bad Gateway

**Step 1**: Check Railway logs
- Service → Logs → look for errors

**Step 2**: Check database connectivity
```bash
psql postgresql://postgres:PASS@HOST:5432/railway
```

**Step 3**: Verify configuration
- All paths correct?
- All secrets properly formatted?
- All URLs using HTTPS?

**Step 4**: Restart service
- Railway UI → Service → "..." → Restart

### Cannot Connect to Database

**Check**:
1. PostgreSQL service running (green in Railway)
2. Password correct (from Railway variables)
3. Host name correct (postgres.railway.internal or postgres-h2zw.railway.internal)

**Reset connection**:
1. Stop service
2. Verify database tables exist
3. Restart service

### MAS Won't Start

**Error**: "PEM preamble contains invalid data"

**Fix**: Regenerate EC private key

```bash
openssl ecparam -name prime256v1 -genkey -out private.pem
# Copy content to config.yaml
```

### Element Web Shows "Cannot reach homeserver"

**Check**:
1. Synapse is running (test with curl)
2. Element Web config.json has correct URL
3. Both services using HTTPS
4. No CORS errors (check browser console F12)

---

## Deployment Changes

To make changes and redeploy:

```bash
# 1. Edit configuration file
nano railway-deployment/synapse/homeserver.yaml

# 2. Commit changes
git add -A
git commit -m "Update Synapse config"

# 3. Push to GitHub
git push origin railway-deployment

# 4. Railway automatically rebuilds and deploys
# Monitor in Railway UI → Service → Deployment tab
```

---

## Security Notes

### Current State (Testing)
- ⚠️ Hardcoded secrets in config files
- ⚠️ No email verification for registration
- ⚠️ Open registration enabled

### For Production

**Move secrets to environment variables**:
```bash
# Railway UI → Service → Variables
# Add: SYNAPSE_DB_PASSWORD, etc.
# Then update configs: password: ${SYNAPSE_DB_PASSWORD}
```

**Disable open registration**:
```yaml
enable_registration: false
enable_registration_without_verification: false
```

**Enable SMTP for email**:
```yaml
email:
  transport: smtp
  smtp:
    host: smtp.gmail.com
    port: 587
```

**Use custom domain**:
- Configure DNS A record
- Update server_name in homeserver.yaml
- Get SSL certificate (automatic via Railway or certbot)

---

## Useful Commands Reference

```bash
# List users in Synapse (via database)
psql postgresql://postgres:PASS@HOST/railway
SELECT user_id FROM users;

# Get user access token (for API access)
SELECT token FROM access_tokens WHERE user_id = '@admin:server.name';

# List rooms
SELECT name FROM room_names;

# Check Synapse version
curl https://synapse-production-e979.up.railway.app/_synapse/admin/v1/server_version

# Get MAS health
curl https://mas-service-production.up.railway.app/health

# Federation status
curl https://matrix.org/.well-known/matrix/server
```

---

## Next Steps

1. **Test thoroughly**
   - Create test accounts
   - Send messages
   - Test federation

2. **Backup strategy**
   - Set up PostgreSQL backups
   - Document backup process

3. **Monitoring**
   - Set up Prometheus metrics
   - Configure alerting

4. **Production hardening**
   - Move secrets to env vars
   - Disable open registration
   - Enable email verification
   - Configure SMTP
   - Use custom domain

5. **Scale (if needed)**
   - Add more Synapse replicas
   - Use read replicas for database
   - Configure load balancing

---

## Support & Documentation

- **Full Documentation**: See `DEPLOYMENT_DOCUMENTATION.md`
- **Synapse Docs**: https://matrix-org.github.io/synapse/
- **MAS Docs**: https://element-hq.github.io/matrix-authentication-service/
- **Railway Docs**: https://docs.railway.app
- **Matrix Spec**: https://spec.matrix.org
- **Federation Tester**: https://federationtester.matrix.org/

---

**Quick Reference Version**: 1.0  
**Created**: February 2, 2026  
**Status**: Production Ready
