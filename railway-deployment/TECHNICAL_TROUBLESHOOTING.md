# Technical Troubleshooting & Advanced Configuration Guide

## Table of Contents
1. [Common Issues & Solutions](#common-issues--solutions)
2. [Error Messages Explained](#error-messages-explained)
3. [Advanced Configuration](#advanced-configuration)
4. [Performance Optimization](#performance-optimization)
5. [Security Hardening](#security-hardening)
6. [Debugging Techniques](#debugging-techniques)

---

## Common Issues & Solutions

### Issue 1: Synapse Returns 502 Bad Gateway

**Symptoms**:
- Browser shows "502 Bad Gateway"
- Element Web shows "Cannot reach homeserver"
- Railway logs show errors

**Root Causes & Solutions**:

#### Cause A: Database Connection Failed
```
Error: connection to server at "postgres.railway.internal" failed
```

**Solutions**:
1. Verify PostgreSQL is running
   - Railway UI → PostgreSQL → Status should be green

2. Check database credentials
   ```bash
   # Test connection manually
   psql postgresql://postgres:PASSWORD@postgres.railway.internal:5432/railway
   ```

3. Verify config has correct password
   ```yaml
   database:
     args:
       password: eEFsjzqXcmIBuvOWLPXXIPVLJQKlTOkC  # Check this value
   ```

4. Check if database needs initialization
   ```bash
   psql postgresql://postgres:PASSWORD@postgres.railway.internal:5432/railway
   \dt  # List tables - should see synapse_* tables
   ```

#### Cause B: Configuration Parsing Error
```
Error: Failed to parse configuration
```

**Check**:
1. YAML syntax is valid
   ```bash
   python -m yaml railway-deployment/synapse/homeserver.yaml
   ```

2. All paths are correct
   ```
   signing_key_path: "/data/synapse-production-e979.up.railway.app.signing.key"
   log_config: "/data/synapse-production-e979.up.railway.app.log.config"
   media_store_path: /data/media_store
   ```

3. All required fields present
   - server_name ✓
   - database ✓
   - signing_key_path ✓
   - listeners ✓

#### Cause C: Permission Issues on /data

```
Error: Permission denied on /data/media_store
```

**Fix**: Dockerfile should handle this:
```dockerfile
RUN mkdir -p /data/media_store
RUN chown -R 991:991 /data && chmod -R 755 /data
```

**If still failing**:
- Try `chmod 777 /data/media_store`
- Check that synapse user (991) can write

#### Cause D: Signing Key Missing or Invalid

```
Error: Invalid signing key format
```

**Check**:
```bash
cat railway-deployment/synapse/synapse-config/synapse-production-e979.up.railway.app.signing.key

# Should look like:
# ed25519 a_ZCeH 9G7js4wnPk7YY4mYVzVtlsBG+TOttmlQpybCScj1VL4

# NOT:
# -----BEGIN PRIVATE KEY-----  (wrong format - this is RSA)
# -----BEGIN EC PRIVATE KEY-----  (wrong format - should be ed25519)
```

**Generate correct key**:
```bash
# Use Synapse to generate
python -m synapse.app.homeserver --generate-keys \
  --config-path /tmp/homeserver.yaml \
  --server-name synapse-production-e979.up.railway.app

# Copy the generated key to your file
```

### Issue 2: MAS Fails to Start

**Symptoms**:
- MAS service restarts continuously
- Logs show error during startup

#### Error: "PEM preamble contains invalid data (NUL byte)"

**Cause**: EC private key is malformed

**Check the key**:
```yaml
# In config.yaml
keys:
  - kid: "default"
    private_key: |
      -----BEGIN EC PRIVATE KEY-----
      MHcCAQEEIJGlh975aqLDMRj14FmkOb5BB89gS8q1EdWAqfTQAnozoAoGCCqGSM49
      AwEHoUQDQgAEvJtmvto/lxwcPKke1usYPJuJvp2eVVWeQt1e3/BUvZQuivHR40Sd
      5C6Wdyv0K5s7Z3kLpZ3K8n8lZ7V7Z3kLpZ3K8n8lZ7Vg==
      -----END EC PRIVATE KEY-----
```

**Issues to check**:
1. No NUL bytes in the key
2. Valid Base64 encoding
3. Correct BEGIN/END lines
4. Proper indentation (spaces, not tabs)

**Generate new key**:
```bash
# Generate EC private key
openssl ecparam -name prime256v1 -genkey -noout -out ec_key.pem
cat ec_key.pem

# Copy entire output including BEGIN/END lines to config.yaml
```

#### Error: "missing field `secrets`"

**Cause**: Entire secrets section missing or malformed

**Check**:
```yaml
secrets:                          # This section must exist
  encryption: "c07af15b849e23d6f9a1b4c8d2e6f0a3b7c1d5e9f3a7b1c5d9e3f7a1b5c9d3e7"
  keys:                           # keys must be a list
    - kid: "default"
      private_key: |
        -----BEGIN EC PRIVATE KEY-----
        ...
        -----END EC PRIVATE KEY-----
```

**Validate YAML**:
```bash
python -m yaml railway-deployment/MAS-service/config.yaml
# Should not throw errors
```

#### Error: "failed to connect to database"

**Cause**: MAS database connection failed

**Verify**:
```bash
psql postgresql://postgres:wHNhQGDToDcZJfzOxEOCjSYnSooDySqt@postgres-h2zw.railway.internal:5432/railway
```

**Check config**:
```yaml
database:
  uri: "postgresql://postgres:wHNhQGDToDcZJfzOxEOCjSYnSooDySqt@postgres-h2zw.railway.internal:5432/railway"
```

- Ensure password is URL-encoded (@ symbols become %40)
- Ensure host and port are correct
- Ensure database name is "railway"

### Issue 3: Element Web Cannot Connect

**Symptoms**:
- Login page loads but shows error after login
- "Cannot reach homeserver" message
- Browser console shows CORS errors

#### Check Browser Console (F12)

**Common errors**:
```
Access to XMLHttpRequest at 'https://...' from origin '...' 
has been blocked by CORS policy
```

**Solutions**:

1. **Verify config.json**:
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

2. **Verify Synapse CORS configuration**:
```yaml
# In homeserver.yaml
http:
  # Should be empty or include Element Web URL
  # Synapse allows all origins by default
```

3. **Test direct API call**:
```bash
curl -H "Content-Type: application/json" \
  https://synapse-production-e979.up.railway.app/_matrix/client/r0/sync?access_token=invalid

# Should return JSON, not HTML error
```

#### Check Network Tab (F12 > Network)

Look for:
1. Requests to `_matrix/client/` endpoints
2. Any 500/502 responses
3. Blocked by CORS (red text)

---

## Error Messages Explained

### Synapse Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `Address already in use` | Port 8008 taken | Change listener port or stop other services |
| `Connection refused` | PostgreSQL not running | Check Railway PostgreSQL status |
| `password authentication failed` | Wrong DB password | Verify password in config |
| `FATAL: database "railway" does not exist` | DB not created | Create database via Railway UI |
| `relation "_synapse_*" does not exist` | DB tables not initialized | Re-run migrations |
| `invalid byte sequence for encoding` | Locale issue | Add `allow_unsafe_locale: true` |

### MAS Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `PEM preamble contains invalid data` | Malformed EC key | Regenerate key with openssl |
| `missing field 'secrets'` | Incomplete config | Ensure all required fields present |
| `Failed to bind to port 8080` | Port in use | Change port in config |
| `Failed to connect to database` | Wrong credentials | Verify URI format and password |
| `OIDC discovery failed` | Cannot reach Synapse | Check matrix.endpoint URL |

### Element Web Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `Cannot reach homeserver` | Synapse unreachable | Check Synapse status and URL |
| `CORS policy: blocked` | Missing CORS headers | Check Synapse CORS config |
| `401 Unauthorized` | Invalid token | Re-login, check auth flow |
| `401: Invalid JWT` | Token expired | Logout and re-login |

---

## Advanced Configuration

### Enable Additional Resources in MAS

Current configuration enables:
- `discovery` - OIDC discovery endpoint
- `human` - Web UI for users
- `oauth` - OAuth 2.0 authorization server
- `compat` - Legacy protocol compatibility
- `graphql` - GraphQL admin API
- `assets` - Static files

**To add more**:
```yaml
http:
  listeners:
    - resources:
        - name: discovery
        - name: human
        - name: oauth
        - name: compat
        - name: graphql
        - name: assets
        # - name: metrics  # Uncomment for Prometheus metrics
```

### Configure SMTP for Email

**Update MAS config**:
```yaml
email:
  from: '"Matrix" <notifications@example.com>'
  reply_to: '"Support" <support@example.com>'
  transport: smtp
  smtp:
    host: smtp.gmail.com
    port: 587
    username: your-email@gmail.com
    password: your-app-password  # Use Railway environment variable
    mode: starttls
```

**Then users can**:
- Verify email on registration
- Reset password via email
- Receive room invitations

### Use Multiple Synapse Workers

For high load, split Synapse into multiple processes:

```yaml
# In homeserver.yaml
instance_map:
  main:
    host: localhost
    port: 8008

# Run separate worker processes
# This requires more advanced configuration
```

### Configure S3 for Media Storage

Instead of storing on disk:

```yaml
media_store_path: /data/media_store

# Add S3 configuration
media_storage:
  bucket: my-matrix-media
  region: us-east-1
  endpoint: https://s3.amazonaws.com
  access_key_id: ${AWS_ACCESS_KEY_ID}
  secret_access_key: ${AWS_SECRET_ACCESS_KEY}
```

---

## Performance Optimization

### Database Connection Pool

```yaml
database:
  args:
    cp_min: 10      # Minimum connections (default: 5)
    cp_max: 20      # Maximum connections (default: 10)
    echo: false     # Enable for query logging
```

**Tuning guide**:
- Small setup (1-100 users): cp_min=5, cp_max=10
- Medium setup (100-1000 users): cp_min=10, cp_max=20
- Large setup (1000+ users): cp_min=20, cp_max=50

### Caching Configuration

```yaml
caches:
  global:
    size: 500M              # Total cache size
    expire_lru_after: 30m   # Expire old entries

  per_cache_factors:
    get_user_by_id: 10      # Cache more user lookups
```

### Event Processing

```yaml
# Speed up sync for clients
send_federation: false      # Temporarily disable if federation is slow
```

---

## Security Hardening

### 1. Move Secrets to Environment Variables

**Current** (insecure):
```yaml
registration_shared_secret: "4578b92c30adf6e1"
```

**Better** (production):
```yaml
registration_shared_secret: ${SYNAPSE_REGISTRATION_SECRET}
```

In Railway UI:
- Service Settings → Variables
- Add: `SYNAPSE_REGISTRATION_SECRET=4578b92c30adf6e1`

### 2. Restrict Registration

**Current** (open registration):
```yaml
enable_registration: true
enable_registration_without_verification: true
```

**Better** (manual review):
```yaml
enable_registration: false                    # Admins only
# Users registered via `mas-cli manage register-user`
```

**Or** (email verified):
```yaml
enable_registration: true
enable_registration_without_verification: false
# Requires email verification
```

### 3. Configure Rate Limiting

```yaml
# Prevent abuse
rc_message:
  per_second: 10
  burst_count: 20

rc_registration:
  per_second: 0.17       # ~1 per 6 seconds
  burst_count: 3

rc_joins:
  per_second: 1
  burst_count: 5
```

### 4. Require HTTPS

```yaml
# Force HTTPS
listeners:
  - port: 8008
    type: http
    x_forwarded: true
    bind_addresses: ["0.0.0.0"]
    # No HTTP listener on 80
```

### 5. Restrict Federation

```yaml
# Only federate with trusted servers
federation_domain_whitelist:
  - "matrix.org"
  - "trusted-server.com"

# Prevent access to private IPs
well_known_ip_range_blacklist:
  - '127.0.0.0/8'
  - '10.0.0.0/8'
  - '172.16.0.0/12'
  - '192.168.0.0/16'
  - 'fe80::/10'
  - 'fc00::/7'
```

### 6. Enable Audit Logging

```yaml
log_config: "/data/synapse.log.config"

# In log config file:
loggers:
  synapse.access.http.incoming_requests:
    level: INFO
```

---

## Debugging Techniques

### Enable Debug Logging

**Synapse** - Create detailed log config:
```yaml
# In synapse-production-e979.up.railway.app.log.config
loggers:
  synapse.storage.SQL:
    level: DEBUG    # Changed from INFO
  synapse.http:
    level: DEBUG
  synapse.state:
    level: DEBUG
```

**Restart Synapse** and check Railway logs for detailed output.

### Monitor Database Queries

```bash
# Connect to PostgreSQL
psql postgresql://postgres:PASSWORD@postgres.railway.internal/railway

# List active connections
SELECT pid, usename, state, query 
FROM pg_stat_activity 
WHERE state != 'idle';

# Kill slow queries
SELECT pg_terminate_backend(pid) 
FROM pg_stat_activity 
WHERE query_start < now() - interval '5 minutes';
```

### Test Matrix Protocol

```bash
# Get server version
curl https://synapse-production-e979.up.railway.app/_synapse/admin/v1/server_version

# Create user (requires shared secret)
curl -X POST https://synapse-production-e979.up.railway.app/_synapse/admin/v1/register \
  -H "Content-Type: application/json" \
  -d '{
    "auth": {"type": "org.matrix.login.dummy"},
    "user_id": "testuser",
    "password": "testpass123"
  }'

# List all users
curl https://synapse-production-e979.up.railway.app/_synapse/admin/v1/users \
  -H "Authorization: Bearer ACCESS_TOKEN"
```

### Check Federation

```bash
# Test federation with matrix.org
curl https://matrix.org/_matrix/key/v2/server

# Get your server's public keys
curl https://synapse-production-e979.up.railway.app/_matrix/key/v2/server

# Send message to federated user (via Element Web first)
```

### Monitor Service Health

**In Railway UI**:
1. Select service
2. Metrics tab → View CPU, memory, network
3. Logs tab → Real-time logs
4. Settings → Environment variables

### Docker Commands (if SSH access available)

```bash
# List running containers
docker ps

# Check Synapse logs
docker logs <container_id>

# Execute command in container
docker exec <container_id> ls -la /data

# Inspect environment
docker inspect <container_id> | grep -A 10 Env
```

---

## Testing Checklist

### Unit Tests

```bash
# Test YAML syntax
python -m yaml railway-deployment/synapse/homeserver.yaml
python -m yaml railway-deployment/MAS-service/config.yaml

# Validate JSON
python -m json.tool railway-deployment/element-web/config.json
```

### Integration Tests

```bash
# 1. Test Synapse API
curl https://synapse-production-e979.up.railway.app/_matrix/client/versions

# 2. Test MAS API
curl https://mas-service-production.up.railway.app/health

# 3. Test Element Web
curl https://ess-helm-production.up.railway.app/ -I

# 4. Test registration flow
# Use Element Web to register and verify
```

### Load Testing

```bash
# Install locust
pip install locust

# Create load test script
# Test with 10 concurrent users
locust -f locustfile.py --users 10 --spawn-rate 1
```

---

## Recovery Procedures

### Database Corruption

```bash
# Dump entire database
pg_dump postgresql://postgres:PASSWORD@HOST/railway > backup.sql

# Restore from backup
psql postgresql://postgres:PASSWORD@HOST/railway < backup.sql
```

### Service Crash Loop

**Steps**:
1. Check logs to identify error
2. Stop service in Railway UI
3. Fix configuration
4. Push changes
5. Redeploy

### Data Loss

**Prevention**:
```bash
# Regular backups (automated via Railway or manual)
pg_dump postgresql://postgres:PASSWORD@HOST/railway > railway_$(date +%Y%m%d).sql

# Store in GitHub or external backup
```

**Recovery**:
```bash
# Create new database
createdb railway

# Restore data
psql railway < railway_backup.sql
```

---

## Version Compatibility

**Current Versions**:
- **Synapse**: Latest (1.146.0 at deployment)
- **MAS**: Latest (main branch)
- **Element Web**: Latest (stable)
- **PostgreSQL**: Latest (15+)

**To upgrade**:
1. Check release notes for breaking changes
2. Back up database
3. Update Docker image tag in Dockerfile
4. Test in staging first
5. Deploy to production during maintenance window

---

## Performance Benchmarks

### Typical Performance (Small Setup)

| Metric | Value |
|--------|-------|
| Messages/second | 10-50 |
| Concurrent users | 50-100 |
| API response time | 100-500ms |
| Database queries/sec | 50-200 |
| Memory usage | 512MB-2GB |
| CPU usage | 5-20% |

### Scaling Indicators

When to scale:
- Response time > 1 second
- CPU > 80% sustained
- Database connections at cp_max
- Memory > 80%

---

**Technical Guide Version**: 1.0  
**Created**: February 2, 2026  
**Status**: For Advanced Users & Operators
