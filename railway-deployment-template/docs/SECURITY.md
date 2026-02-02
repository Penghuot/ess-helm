# 🔐 Security Best Practices Guide

## Overview
This document outlines essential security practices for deploying and maintaining a Matrix stack on Railway.app. Following these guidelines will help protect your deployment from common vulnerabilities and attacks.

---

## 🎯 Core Security Principles

### 1. Never Commit Secrets to Version Control

**Critical files to exclude:**
```gitignore
# Add to .gitignore
*.key
*.pem
*secret*
*.env
.env.*
config.local.*
secrets/
railway-deployment/synapse/synapse-config/*.signing.key
railway-deployment/MAS-service/private.pem
```

**Why this matters:**
- Git history is permanent - once committed, secrets are exposed forever
- Public repositories expose secrets to the entire internet
- Even private repositories can be compromised
- Automated bots scan GitHub for exposed credentials

**Best Practice:**
```bash
# Before committing
git status
git diff

# Check for secrets
grep -r "BEGIN.*KEY" .
grep -r "password.*:" .

# If you accidentally committed secrets:
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/secret" \
  --prune-empty --tag-name-filter cat -- --all
```

### 2. Use Railway Environment Variables

**Railway provides secure secret storage:**
- Encrypted at rest
- Never logged or displayed in plaintext
- Injected at runtime
- Can be rotated without code changes

**How to set variables:**
1. Railway Dashboard → Project → Service → Variables
2. Click "New Variable"
3. Name: `SYNAPSE_MACAROON_SECRET_KEY`
4. Value: `<your_secret>`
5. Click "Add"

**In your code:**
```yaml
# homeserver.yaml.template
macaroon_secret_key: "${SYNAPSE_MACAROON_SECRET_KEY}"
```

### 3. Generate Strong Cryptographic Secrets

**Secret Types and Generation:**

```bash
# 64-character hex secrets (most secrets)
openssl rand -hex 32

# 128-character hex secrets (encryption keys)
openssl rand -hex 64

# EC Private Key (MAS signing)
openssl ecparam -name prime256v1 -genkey -noout -out private.pem
cat private.pem  # Copy entire content including BEGIN/END lines

# Ed25519 Signing Key (Synapse federation)
# Run Synapse with --generate-keys flag
# Copy from generated file
```

**Secret Strength Requirements:**
- **Minimum**: 32 characters (256 bits of entropy)
- **Recommended**: 64 characters (512 bits of entropy)
- **Encryption keys**: 128 characters (1024 bits of entropy)
- Use cryptographically secure random generators
- Never use predictable patterns or dictionary words

### 4. Separate Database Credentials

**Why separate databases:**
- Limits blast radius of a breach
- Allows independent scaling
- Enables service-specific backups
- Supports different retention policies

**Railway Setup:**
```bash
# Project Structure
my-matrix-project/
├── Synapse Service
│   ├── PGHOST=postgres-synapse.railway.internal
│   ├── PGUSER=postgres
│   └── PGPASSWORD=<synapse_db_password>
│
└── MAS Service
    ├── MAS_PGHOST=postgres-mas.railway.internal
    ├── MAS_PGUSER=postgres
    └── MAS_PGPASSWORD=<mas_db_password>
```

**Database isolation:**
- Add separate PostgreSQL plugins for each service
- Use different usernames if possible
- Configure connection limits per service
- Monitor access patterns independently

### 5. Enforce HTTPS Everywhere

**Configuration:**
```yaml
# Synapse: homeserver.yaml.template
public_baseurl: "https://matrix.example.com/"  # HTTPS only!

# MAS: config.yaml.template
http:
  listeners:
    - public_base: "https://auth.example.com/"  # HTTPS only!

# Element Web: config.json.template
"default_server_config": {
  "m.homeserver": {
    "base_url": "https://matrix.example.com"  # HTTPS only!
  }
}
```

**Railway SSL:**
- Automatic SSL certificates for *.up.railway.app domains
- Custom domains: Railway auto-provisions Let's Encrypt certs
- Certificates automatically renewed
- No manual configuration needed

**Verify HTTPS:**
```bash
# Test SSL certificate
curl -v https://matrix.example.com 2>&1 | grep "SSL certificate"

# Check certificate expiration
openssl s_client -connect matrix.example.com:443 -servername matrix.example.com | openssl x509 -noout -dates
```

### 6. Disable Open Registration

**Production configuration:**
```bash
# Railway Variables
SYNAPSE_ENABLE_REGISTRATION=false
SYNAPSE_ENABLE_REGISTRATION_WITHOUT_VERIFICATION=false
```

**Alternative: Captcha-protected registration:**
```yaml
# homeserver.yaml.template
enable_registration: true
enable_registration_captcha: true
recaptcha_public_key: "${RECAPTCHA_PUBLIC_KEY}"
recaptcha_private_key: "${RECAPTCHA_PRIVATE_KEY}"
```

**User creation workflow:**
1. Admin creates account via MAS admin panel
2. Send invitation link to user
3. User completes registration with invite token
4. Admin approves account (optional)

---

## 🛡️ Advanced Security Measures

### Rate Limiting

**Prevent brute-force attacks:**
```yaml
# homeserver.yaml.template
rc_login:
  address:
    per_second: 0.17
    burst_count: 3
  account:
    per_second: 0.17
    burst_count: 3
  failed_attempts:
    per_second: 0.17  # Max 1 attempt per ~6 seconds
    burst_count: 3    # Lock after 3 failed attempts

rc_registration:
  per_second: 0.17    # Max 1 registration per ~6 seconds
  burst_count: 3

rc_message:
  per_second: 0.2
  burst_count: 10
```

**MAS rate limiting:**
```yaml
# config.yaml.template
rate_limiting:
  enabled: true
  auth:
    per_second: 0.1  # Max 1 attempt per 10 seconds
    burst: 5
  registration:
    per_second: 0.05  # Max 1 attempt per 20 seconds
    burst: 3
```

### IP Blacklisting

**Prevent SSRF attacks:**
```yaml
# homeserver.yaml.template
federation_ip_range_blacklist:
  # Private networks
  - '127.0.0.0/8'
  - '10.0.0.0/8'
  - '172.16.0.0/12'
  - '192.168.0.0/16'
  - '100.64.0.0/10'
  - '169.254.0.0/16'
  - '198.18.0.0/15'
  
  # IPv6 private ranges
  - '::1/128'
  - 'fe80::/10'
  - 'fc00::/7'
  
  # Other reserved ranges
  - '0.0.0.0/8'
  - '224.0.0.0/4'
  - '240.0.0.0/4'

url_preview_ip_range_blacklist:
  # Same as federation_ip_range_blacklist
```

### Content Security Policy

**Element Web nginx configuration:**
```nginx
# Custom nginx.conf (if needed)
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' https://matrix.example.com; frame-ancestors 'none';";
add_header X-Frame-Options "DENY";
add_header X-Content-Type-Options "nosniff";
add_header Referrer-Policy "strict-origin-when-cross-origin";
```

### Admin Token Protection

**Restrict admin API access:**
```yaml
# homeserver.yaml.template
# Option 1: Admin API token
admin_token: "${SYNAPSE_ADMIN_TOKEN}"

# Option 2: Restrict by IP (if admin API needed)
admin_contact: "admin@example.com"
```

```bash
# Railway Variables
SYNAPSE_ADMIN_TOKEN=<strong_random_token>

# Usage
curl -H "Authorization: Bearer $SYNAPSE_ADMIN_TOKEN" \
  https://matrix.example.com/_synapse/admin/v1/users/@user:example.com
```

---

## 🔄 Secret Rotation Strategy

### Regular Rotation Schedule

**Recommended rotation intervals:**
- **Database passwords**: Every 90 days
- **API tokens**: Every 90 days
- **Session secrets**: Every 180 days
- **Signing keys**: Every 365 days
- **Emergency**: Immediately after any security incident

### Rotation Procedure

**1. Database Password Rotation:**
```bash
# Railway Dashboard
1. PostgreSQL plugin → Settings → Reset Password
2. Copy new password
3. Update service variables:
   - PGPASSWORD (for Synapse)
   - MAS_PGPASSWORD (for MAS)
4. Restart services
```

**2. Application Secret Rotation:**
```bash
# Generate new secret
new_secret=$(openssl rand -hex 32)

# Railway Dashboard
1. Service → Variables → Edit SYNAPSE_MACAROON_SECRET_KEY
2. Paste new secret
3. Service auto-restarts with new secret
```

**3. Signing Key Rotation (Advanced):**
```yaml
# Synapse supports multiple signing keys
signing_key_path: "/data/signing.key"
old_signing_keys:
  "ed25519:old_key_id": "old_key_content"
```

**Process:**
1. Generate new signing key
2. Add to `signing_key_path`
3. Move old key to `old_signing_keys`
4. Wait 7 days for federation propagation
5. Remove old key

---

## 📊 Security Monitoring

### Audit Logging

**Enable comprehensive logging:**
```yaml
# homeserver.yaml.template
log_config: "/config/log.config.yaml"

# log.config.yaml
handlers:
  audit:
    class: logging.handlers.RotatingFileHandler
    filename: /data/audit.log
    maxBytes: 104857600  # 100MB
    backupCount: 10
    formatter: precise

loggers:
  synapse.api.auth:
    level: INFO
    handlers: [audit]
  synapse.federation:
    level: INFO
    handlers: [audit]
```

**MAS audit logging:**
```yaml
# config.yaml.template
logging:
  level: info
  format: json  # Structured logging for parsing
```

**Railway log access:**
```bash
# View logs in Railway Dashboard
Project → Service → Logs

# Or use Railway CLI
railway logs --service synapse
railway logs --service mas
```

### Failed Login Detection

**Monitor for suspicious activity:**
```bash
# Check Synapse logs for failed logins
railway logs --service synapse | grep "Failed login"

# Check MAS logs for brute force
railway logs --service mas | grep "rate limit exceeded"
```

**Alert on patterns:**
- Multiple failed logins from same IP
- Login attempts for non-existent users
- Geographic anomalies (if tracking location)
- Unusual access times

### Database Activity Monitoring

**PostgreSQL connection monitoring:**
```sql
-- Check active connections
SELECT 
    datname,
    usename,
    application_name,
    client_addr,
    state,
    query
FROM pg_stat_activity
WHERE datname IN ('synapse_db', 'mas_db');

-- Check for suspicious queries
SELECT 
    datname,
    query,
    calls,
    total_exec_time
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;
```

---

## 🚨 Incident Response

### Suspected Breach Checklist

**Immediate actions:**
1. ✅ Rotate all secrets immediately
2. ✅ Review recent logs for suspicious activity
3. ✅ Check database for unauthorized changes
4. ✅ Audit user accounts for unauthorized additions
5. ✅ Review Railway access logs
6. ✅ Enable debug logging temporarily
7. ✅ Notify affected users if data exposed

**Investigation steps:**
```bash
# 1. Review authentication logs
railway logs --service mas --since 24h | grep -E "(failed|unauthorized)"

# 2. Check for unexpected user registrations
psql $DATABASE_URL -c "
  SELECT name, creation_ts, admin 
  FROM users 
  WHERE creation_ts > extract(epoch from now() - interval '24 hours')
  ORDER BY creation_ts DESC;
"

# 3. Audit room access
psql $DATABASE_URL -c "
  SELECT room_id, user_id, membership 
  FROM room_memberships 
  WHERE joined_ts > extract(epoch from now() - interval '24 hours')
  ORDER BY joined_ts DESC;
"

# 4. Check for data exfiltration
railway logs --service synapse | grep -E "(download|media|/sync)"
```

### Recovery Steps

**1. Secure the environment:**
```bash
# Rotate all secrets
./scripts/rotate_all_secrets.sh

# Reset database passwords
railway variables --set PGPASSWORD=$(openssl rand -hex 32)

# Revoke all active sessions
psql $DATABASE_URL -c "DELETE FROM access_tokens;"
```

**2. Restore from backup (if needed):**
```bash
# Railway PostgreSQL backup
railway db backup create --service postgres-synapse

# Restore to point-in-time
railway db restore --backup-id <backup_id>
```

**3. Harden security:**
```bash
# Disable registration
railway variables --set SYNAPSE_ENABLE_REGISTRATION=false

# Enable stricter rate limits
railway variables --set MAS_RATE_LIMIT_AUTH_PER_SECOND=0.05

# Review and revoke admin privileges
```

---

## ✅ Security Checklist

### Pre-Deployment
- [ ] All secrets in environment variables (not hardcoded)
- [ ] `.gitignore` configured for sensitive files
- [ ] Strong random secrets generated (64+ characters)
- [ ] Separate PostgreSQL instances for Synapse and MAS
- [ ] HTTPS configured for all public endpoints
- [ ] Registration disabled (or captcha-protected)

### Post-Deployment
- [ ] Test HTTPS certificate validity
- [ ] Verify no hardcoded secrets in deployed configs
- [ ] Confirm rate limiting is active
- [ ] Test admin API access restrictions
- [ ] Enable audit logging
- [ ] Set up monitoring alerts
- [ ] Document secret rotation schedule
- [ ] Create incident response runbook

### Ongoing Maintenance
- [ ] Rotate database passwords quarterly
- [ ] Review logs weekly for suspicious activity
- [ ] Update dependencies monthly
- [ ] Test backup restoration quarterly
- [ ] Conduct security audit annually
- [ ] Review user access monthly
- [ ] Monitor for CVE announcements

---

## 📚 Additional Resources

- **OWASP Top 10**: https://owasp.org/www-project-top-ten/
- **CIS Security Benchmarks**: https://www.cisecurity.org/cis-benchmarks
- **Matrix Security Disclosure**: https://matrix.org/security-disclosure-policy
- **Railway Security**: https://docs.railway.app/reference/security
- **PostgreSQL Security**: https://www.postgresql.org/docs/current/security.html

---

**Remember: Security is an ongoing process, not a one-time setup. Stay vigilant!**
