# 🚀 Quick Reference Card

## Essential Commands

### Secret Generation
```bash
# Generate all secrets at once
./scripts/generate_secrets.sh

# Individual secrets
openssl rand -hex 32    # 64-char hex (most secrets)
openssl rand -hex 64    # 128-char hex (encryption)
openssl ecparam -name prime256v1 -genkey -noout  # EC key (MAS)
```

### Railway CLI
```bash
# Install
npm i -g @railway/cli

# Login
railway login

# Link project
railway link

# Deploy service
railway up --service synapse

# View logs
railway logs --service synapse --tail

# Set variable
railway variables --set KEY=value

# SSH into container
railway shell --service synapse
```

### Database Access
```bash
# From Railway dashboard
Project → PostgreSQL → Data Tab

# Or via CLI
railway connect postgres-synapse

# Run query
psql $DATABASE_URL -c "SELECT * FROM users LIMIT 10;"
```

---

## Service Endpoints

| Service | Health Check | Purpose |
|---------|-------------|---------|
| **Synapse** | `/_matrix/static/` | Matrix homeserver |
| **MAS** | `/health` | Authentication service |
| **Element Web** | `/` | Web client |

---

## Critical Environment Variables

### Must Match Across Services
```bash
# These MUST be identical:
SYNAPSE_REGISTRATION_SHARED_SECRET = MAS_MATRIX_SECRET

# These MUST match:
SYNAPSE_SERVER_NAME = MAS_MATRIX_HOMESERVER = ELEMENT_HOMESERVER_NAME

# These MUST match (with protocol difference):
SYNAPSE_PUBLIC_BASEURL = https://domain/
MAS_MATRIX_ENDPOINT = https://domain (no trailing /)
ELEMENT_HOMESERVER_URL = https://domain
```

---

## Common Operations

### Create Admin User
```bash
# Via Railway terminal (MAS service)
mas-cli manage register-user

# Follow prompts:
# - Username: admin
# - Password: <strong>
# - Email: admin@example.com
# - Admin: yes
```

### Reset User Password
```bash
# SSH into MAS service
railway shell --service mas

# Reset password
mas-cli manage reset-password <username>
```

### View Recent Registrations
```bash
# SSH into Synapse service
railway shell --service synapse

# Query database
psql $DATABASE_URL -c "
  SELECT name, creation_ts, admin
  FROM users
  ORDER BY creation_ts DESC
  LIMIT 10;
"
```

### Restart Service
```bash
# Railway Dashboard
Service → Settings → Restart

# Or trigger redeploy
git commit --allow-empty -m "Trigger redeploy"
git push
```

---

## Troubleshooting Quick Checks

### Service Won't Start
```bash
# 1. Check logs
railway logs --service <service> --tail

# 2. Verify required variables
railway variables --service <service>

# 3. Test database connection
railway connect postgres-synapse
\l  # List databases
\dt # List tables
```

### Can't Login to Element Web
```bash
# 1. Verify Synapse is running
curl https://synapse-domain.com/_matrix/static/

# 2. Check Synapse logs for auth errors
railway logs --service synapse | grep -i "login\|auth\|error"

# 3. Verify MAS is accessible
curl https://mas-domain.com/health

# 4. Check Element Web config
railway shell --service element-web
cat /app/config.json
```

### Federation Not Working
```bash
# 1. Test federation endpoint
curl https://matrix.example.com/_matrix/federation/v1/version

# 2. Verify .well-known (if using custom domain)
curl https://example.com/.well-known/matrix/server

# 3. Check Synapse signing key
railway shell --service synapse
cat /data/signing.key
```

---

## File Locations (in containers)

### Synapse
```
/data/homeserver.yaml      # Generated config
/data/signing.key          # Federation signing key
/data/media_store/         # Uploaded media
/config/log.config.yaml    # Log configuration
```

### MAS
```
/config/config.yaml        # Generated config
```

### Element Web
```
/app/config.json          # Generated config
```

---

## Environment Variable Templates

### Minimal Synapse (Required Only)
```bash
PGHOST=postgres.railway.internal
PGUSER=postgres
PGPASSWORD=<db_password>
PGDATABASE=railway
SYNAPSE_SERVER_NAME=matrix.example.com
SYNAPSE_PUBLIC_BASEURL=https://matrix.example.com/
SYNAPSE_REGISTRATION_SHARED_SECRET=<secret>
SYNAPSE_MACAROON_SECRET_KEY=<secret>
SYNAPSE_FORM_SECRET=<secret>
```

### Minimal MAS (Required Only)
```bash
MAS_PGHOST=postgres-mas.railway.internal
MAS_PGUSER=postgres
MAS_PGPASSWORD=<db_password>
MAS_PGDATABASE=railway
MAS_PUBLIC_BASE=https://auth.example.com/
MAS_MATRIX_HOMESERVER=matrix.example.com
MAS_MATRIX_ENDPOINT=https://matrix.example.com
MAS_MATRIX_SECRET=<matches_synapse_registration_secret>
MAS_CLIENT_SECRET=<secret>
MAS_ENCRYPTION_SECRET=<128char_secret>
MAS_SIGNING_KEY=<ec_private_key_pem>
```

### Minimal Element Web (Required Only)
```bash
ELEMENT_HOMESERVER_URL=https://matrix.example.com
ELEMENT_HOMESERVER_NAME=matrix.example.com
```

---

## Security Checklist

- [ ] All secrets generated with `openssl rand`
- [ ] Secrets stored in Railway variables (not code)
- [ ] `.gitignore` excludes `*.key`, `*.pem`, `*secret*`
- [ ] Registration disabled: `SYNAPSE_ENABLE_REGISTRATION=false`
- [ ] Separate PostgreSQL instances for Synapse and MAS
- [ ] HTTPS configured for all public URLs
- [ ] Admin user created successfully
- [ ] Regular backups configured

---

## Monitoring

### Service Health
```bash
# Check all services
curl -f https://synapse.example.com/_matrix/static/ || echo "Synapse DOWN"
curl -f https://mas.example.com/health || echo "MAS DOWN"
curl -f https://element.example.com/ || echo "Element DOWN"
```

### Database Size
```sql
-- Synapse database size
SELECT pg_size_pretty(pg_database_size('railway'));

-- Table sizes
SELECT
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename))
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
LIMIT 10;
```

### Active Users
```sql
-- Recently active users (Synapse)
SELECT
  name,
  admin,
  creation_ts,
  deactivated
FROM users
WHERE deactivated = 0
ORDER BY creation_ts DESC;
```

---

## Backup & Restore

### Backup Database
```bash
# Railway automatic backups
Railway Dashboard → PostgreSQL → Backups Tab → Create Backup

# Manual backup
railway connect postgres-synapse
pg_dump -Fc railway > backup_$(date +%Y%m%d).dump
```

### Restore Database
```bash
# Railway restore
Railway Dashboard → PostgreSQL → Backups Tab → Restore

# Manual restore
railway connect postgres-synapse
pg_restore -d railway backup_YYYYMMDD.dump
```

### Backup Media Files
```bash
# SSH into Synapse
railway shell --service synapse

# Create tar archive
tar -czf media_backup_$(date +%Y%m%d).tar.gz /data/media_store/

# Download via Railway CLI
railway files download /data/media_backup_*.tar.gz
```

---

## Performance Tuning

### Synapse Connection Pool
```bash
# Increase if database connections maxed out
SYNAPSE_DB_CP_MIN=10
SYNAPSE_DB_CP_MAX=20
```

### MAS Database Connections
```bash
# Adjust based on load
MAS_DB_MAX_CONNECTIONS=20
MAS_DB_MIN_CONNECTIONS=5
```

### Disable Features to Reduce Load
```bash
# Synapse
SYNAPSE_PRESENCE_ENABLED=false  # Disable online/offline status
SYNAPSE_URL_PREVIEW_ENABLED=false  # Disable URL previews

# Element Web
ELEMENT_ENABLE_PRESENCE=false
```

---

## Update Services

### Update Synapse
```bash
# Rebuild with latest image
railway up --service synapse

# Or trigger from dashboard
Service → Settings → Redeploy
```

### Update MAS
```bash
railway up --service mas
```

### Update Element Web
```bash
railway up --service element-web
```

---

## Emergency Procedures

### Revoke All Sessions
```sql
-- Connect to Synapse database
DELETE FROM access_tokens;
DELETE FROM refresh_tokens;
```

### Disable Registration Immediately
```bash
railway variables --set SYNAPSE_ENABLE_REGISTRATION=false --service synapse
```

### Rotate Secrets
```bash
# Generate new secret
new_secret=$(openssl rand -hex 32)

# Update in Railway
railway variables --set SYNAPSE_MACAROON_SECRET_KEY=$new_secret --service synapse

# Service auto-restarts
```

---

## Useful SQL Queries

### User Statistics
```sql
-- Total users
SELECT COUNT(*) FROM users WHERE deactivated = 0;

-- Admins
SELECT name, creation_ts FROM users WHERE admin = 1;

-- Recently registered
SELECT name, creation_ts
FROM users
WHERE creation_ts > extract(epoch from now() - interval '7 days')
ORDER BY creation_ts DESC;
```

### Room Statistics
```sql
-- Total rooms
SELECT COUNT(*) FROM rooms;

-- Largest rooms
SELECT room_id, creator, COUNT(*) as members
FROM room_memberships
GROUP BY room_id, creator
ORDER BY members DESC
LIMIT 10;
```

### Storage Usage
```sql
-- Media storage
SELECT
  COUNT(*) as file_count,
  pg_size_pretty(SUM(size)) as total_size
FROM local_media_repository;
```

---

## Contact & Support

- **Template Issues**: GitHub Issues
- **Railway Support**: [Discord](https://discord.gg/railway)
- **Matrix Community**: `#matrix:matrix.org`
- **Synapse Support**: `#synapse:matrix.org`

---

**For detailed guides, see:**
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - Step-by-step setup
- [SECURITY.md](SECURITY.md) - Security best practices
- [ENVIRONMENT_VARIABLES.md](ENVIRONMENT_VARIABLES.md) - Complete variable reference
