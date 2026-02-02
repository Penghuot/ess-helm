# 📄 Railway Matrix Stack Template - Complete Documentation

## Executive Summary

This repository contains a **production-ready, reusable deployment template** for running a complete Matrix communication stack on Railway.app. The template emphasizes security, modularity, and ease of deployment through environment variable-based configuration.

---

## 🎯 Key Achievements

### ✅ Security-First Design
- **Zero hardcoded secrets** - All sensitive values via environment variables
- **Separate database instances** - Independent PostgreSQL for Synapse and MAS
- **Automatic HTTPS** - Railway-managed SSL certificates
- **Built-in rate limiting** - Protection against brute-force attacks
- **Registration disabled by default** - Admin-only user creation
- **SSRF protection** - IP blacklisting for internal networks

### ✅ Production-Ready Components
- **Synapse** (Matrix homeserver) with automated migrations
- **MAS** (Matrix Authentication Service) with OAuth 2.0
- **Element Web** (Web client) with runtime configuration
- **PostgreSQL** (2 instances) managed by Railway
- **Health checks** for all services
- **Automated startup scripts** with validation

### ✅ Comprehensive Documentation
- **5 detailed guides** covering all aspects
- **Step-by-step deployment** with validation checkpoints
- **Security best practices** following OWASP guidelines
- **Complete environment variable reference** (60+ variables)
- **Troubleshooting guide** with common solutions
- **Quick reference card** for daily operations

---

## 📦 What's Included

### Service Templates

#### 1. Synapse (Matrix Homeserver)
**Location**: `synapse/`

**Files:**
- `Dockerfile` - Multi-stage build with validation
- `homeserver.yaml.template` - Configuration with ${VAR} placeholders
- `entrypoint.sh` - Startup script with:
  - Environment variable validation
  - Configuration generation from template
  - Signing key management
  - Database migration execution
  - Health check validation
- `log.config.yaml` - Structured logging configuration
- `railway.json` - Railway-specific deployment settings

**Key Features:**
- Validates all required environment variables on startup
- Generates signing key if not provided (with warning to save it)
- Runs database migrations automatically
- Supports both Railway domains and custom domains
- Configurable media storage paths
- Rate limiting and IP blacklisting
- Federation security built-in

#### 2. MAS (Matrix Authentication Service)
**Location**: `MAS-service/`

**Files:**
- `Dockerfile` - Multi-stage build with PostgreSQL client
- `config.yaml.template` - Complete configuration template
- `entrypoint.sh` - Startup script with:
  - PEM key format validation
  - YAML syntax checking
  - Database connectivity testing
  - Migration execution
  - Comprehensive error messages
- `railway.json` - Railway deployment configuration

**Key Features:**
- Validates EC private key format (prevents NUL byte errors)
- Tests database connection before startup
- Proper YAML indentation for PEM keys
- Supports multiple OAuth2 providers
- Email configuration with SMTP
- Rate limiting with configurable thresholds
- Session management with TTL

#### 3. Element Web (Web Client)
**Location**: `element-web/`

**Files:**
- `Dockerfile` - Static file build with runtime injection
- `config.json.template` - UI configuration template
- `entrypoint.sh` - Runtime configuration generation
- `railway.json` - Railway deployment settings

**Key Features:**
- Runtime configuration injection (no rebuild needed)
- JSON syntax validation
- Customizable branding and themes
- Feature flags for experimental features
- Jitsi integration for video calls
- Element Call support

### Scripts

#### Secret Generation Script
**Location**: `scripts/generate_secrets.sh`

**Features:**
- Generates all required secrets in one command
- Uses cryptographically secure random (`openssl rand`)
- Creates properly formatted EC private keys
- Ensures MAS_MATRIX_SECRET matches SYNAPSE_REGISTRATION_SHARED_SECRET
- Outputs copy-pasteable format for Railway variables
- Optional secure file export
- Clear security reminders

**Generated Secrets:**
- Synapse: registration, macaroon, form, password pepper, admin token
- MAS: encryption (128-char), client secret, EC private key
- Automatic matching of shared secrets

### Documentation

#### 1. README.md (Main)
**Purpose**: Project overview and quick start
**Content:**
- Feature highlights
- Quick start guide (5 steps)
- Service overview table
- Essential environment variables
- Security highlights
- Use cases
- Troubleshooting quick tips

#### 2. DEPLOYMENT_GUIDE.md
**Purpose**: Step-by-step deployment walkthrough
**Content:**
- **9 phases** with detailed steps
- Prerequisites checklist
- Repository setup instructions
- Secret generation process
- Railway project configuration
- Service-by-service setup
- Domain configuration (Railway + custom)
- Verification procedures
- First user creation
- Troubleshooting section
- Post-deployment checklist

**Key Phases:**
1. Repository Setup (fork, clone, branch)
2. Secret Generation (automated script)
3. Railway Project Setup (databases, services)
4. Service Configuration (all environment variables)
5. Domain Configuration (Railway domains or custom)
6. Verification (health checks, logs, databases)
7. First User Creation (MAS CLI)
8. Troubleshooting (common issues)
9. Post-Deployment (checklist)

#### 3. ENVIRONMENT_VARIABLES.md
**Purpose**: Complete reference for all configuration options
**Content:**
- **60+ environment variables** documented
- **Organized by service** (Synapse, MAS, Element Web)
- **Each variable includes:**
  - Description and purpose
  - Example values
  - Valid value ranges
  - Default values
  - Security risk level (LOW/MEDIUM/HIGH/CRITICAL)
  - Rotation schedule recommendations
  - Generation commands
  - Notes and warnings
- **Variable validation examples**
- **Bulk import templates**
- **Pre-deployment checklists**

**Security Risk Levels:**
- **CRITICAL**: Federation keys, encryption secrets
- **HIGH RISK**: Database passwords, API tokens, session secrets
- **MEDIUM RISK**: Database usernames, less sensitive configs
- **LOW RISK**: Hostnames, ports, feature flags

#### 4. SECURITY.md
**Purpose**: Security best practices and hardening guide
**Content:**
- **Core Security Principles** (7 principles)
- Never commit secrets (with .gitignore examples)
- Railway variable usage
- Strong secret generation
- Database separation
- HTTPS enforcement
- Registration policies
- **Advanced Security Measures:**
  - Rate limiting configuration
  - IP blacklisting (SSRF protection)
  - Content Security Policy
  - Admin token protection
- **Secret Rotation Strategy:**
  - Rotation schedules (90/180/365 days)
  - Step-by-step rotation procedures
  - Emergency rotation process
- **Security Monitoring:**
  - Audit logging setup
  - Failed login detection
  - Database activity monitoring
- **Incident Response:**
  - Breach checklist
  - Investigation procedures (SQL queries)
  - Recovery steps
  - System hardening after incident
- **Security Checklists:**
  - Pre-deployment (6 items)
  - Post-deployment (8 items)
  - Ongoing maintenance (7 items)

#### 5. QUICK_REFERENCE.md
**Purpose**: Quick commands and troubleshooting
**Content:**
- **Essential Commands:**
  - Secret generation (one-liners)
  - Railway CLI operations
  - Database access methods
- **Service Endpoints** (health check URLs)
- **Critical Environment Variables** (cross-service matching requirements)
- **Common Operations:**
  - Create admin user
  - Reset passwords
  - View registrations
  - Restart services
- **Troubleshooting Quick Checks:**
  - Service startup failures
  - Login problems
  - Federation issues
- **File Locations** (in containers)
- **Environment Variable Templates** (minimal required only)
- **Security Checklist** (8 items)
- **Monitoring** (health checks, database queries)
- **Backup & Restore** (commands and procedures)
- **Performance Tuning** (connection pools, feature disabling)
- **Update Services** (rebuild commands)
- **Emergency Procedures:**
  - Revoke all sessions
  - Disable registration immediately
  - Rotate secrets
- **Useful SQL Queries:**
  - User statistics
  - Room statistics
  - Storage usage

---

## 🔧 Technical Implementation Details

### Environment Variable Substitution

**How it works:**
1. Template files use `${VARIABLE}` placeholders
2. Entrypoint scripts validate required variables
3. `envsubst` substitutes values at runtime
4. Generated config written to runtime location
5. Service starts with generated config

**Example Flow:**
```
homeserver.yaml.template → envsubst → /data/homeserver.yaml → Synapse reads
```

**Benefits:**
- No secrets in git repository
- Same template for all environments
- Easy variable updates (no rebuild)
- Runtime validation catches missing vars

### Startup Validation

**Each service validates:**
1. **Required variables exist** - Lists missing vars with helpful error
2. **Format correctness** - Checks PEM keys, URL formats
3. **Database connectivity** - Tests connection before starting
4. **YAML/JSON syntax** - Validates generated configs
5. **Key strength** (optional) - Warns about weak secrets

**Error Messages:**
- Clear, actionable messages
- Include fix instructions
- Show example values
- List all issues at once (not one at a time)

### Database Migrations

**Automatic migrations:**
- Synapse: `--run-background-updates`
- MAS: Built-in migration on startup

**Safety:**
- Test connection before migration
- Show migration status in logs
- Fail fast if migration errors
- Idempotent (safe to run multiple times)

### Health Checks

**Railway health monitoring:**
- HTTP endpoint checks
- Container restart detection
- Resource usage alerts

**Custom health checks:**
- Synapse: `/_matrix/static/` (200 response)
- MAS: `/health` (JSON response)
- Element Web: `/` (HTML response)

### Security Implementation

**Secret Management:**
- Railway environment variables (encrypted at rest)
- Never logged or displayed in plaintext
- Injected at runtime only
- Rotatable without code changes

**Network Security:**
- IP blacklisting for private ranges (SSRF protection)
- Rate limiting on all endpoints
- HTTPS-only URLs
- Content Security Policy headers

**Authentication:**
- MAS OAuth2 integration
- Admin-only registration by default
- Session timeouts
- Failed login throttling

---

## 📊 Template Statistics

### Code Metrics
- **Total Files**: 20+
- **Docker Images**: 3 services
- **Configuration Templates**: 3 files
- **Entrypoint Scripts**: 3 files (500+ lines total)
- **Documentation**: 5 comprehensive guides
- **Total Documentation**: 5,000+ lines

### Environment Variables
- **Total Variables**: 60+
- **Required Variables**: 20
- **Optional Variables**: 40+
- **Secrets to Generate**: 8

### Security Features
- **Rate Limiters**: 5
- **IP Blacklist Ranges**: 10+
- **Secret Rotation Points**: 8
- **Validation Checks**: 15+

---

## 🚀 Deployment Timeline

**Estimated deployment time breakdown:**

| Phase | Time | Description |
|-------|------|-------------|
| **Repository Setup** | 5 min | Fork, clone, verify structure |
| **Secret Generation** | 2 min | Run script, save output |
| **Railway Project** | 5 min | Create project, add databases |
| **Variable Configuration** | 10 min | Copy secrets to Railway |
| **Initial Deployment** | 5 min | Railway builds and deploys |
| **Verification** | 5 min | Test endpoints, check logs |
| **User Creation** | 3 min | Create first admin account |
| **Total** | **35 min** | Complete working deployment |

**Additional time for:**
- Custom domain setup: +15 minutes
- Email configuration: +10 minutes
- Advanced security hardening: +30 minutes
- Production optimization: +1 hour

---

## 🎯 Use Cases

### 1. Personal Matrix Server
**Scenario**: Individual wants private communication server
**Configuration**: Single user, minimal resources
**Benefits**: Complete control over data, privacy-focused

### 2. Small Team Chat
**Scenario**: Organization with 5-50 users
**Configuration**: Multiple rooms, moderate resources
**Benefits**: Self-hosted alternative to Slack/Teams

### 3. Development/Testing
**Scenario**: Developer testing Matrix integrations
**Configuration**: Rapid deployment, easy teardown
**Benefits**: Quick setup, full API access, no external dependencies

### 4. Federation Testing
**Scenario**: Testing Matrix federation protocol
**Configuration**: Multiple instances, custom domains
**Benefits**: Full control over federation settings

### 5. Migration from Hosted
**Scenario**: Moving from matrix.org or other hosted service
**Configuration**: Production-grade setup
**Benefits**: Data ownership, custom features

---

## 🔄 Maintenance & Operations

### Regular Maintenance Tasks

**Weekly:**
- Review logs for errors or warnings
- Check disk usage (media storage)
- Verify backup completion
- Monitor user activity

**Monthly:**
- Review user accounts (deactivate unused)
- Update dependencies
- Check for Synapse/MAS updates
- Review security logs

**Quarterly:**
- Rotate database passwords
- Review and update secrets
- Audit admin permissions
- Performance optimization review

**Annually:**
- Rotate signing keys (with federation notice)
- Security audit
- Disaster recovery test
- Infrastructure review

### Monitoring Recommendations

**Railway Built-in:**
- CPU usage alerts (>80%)
- Memory usage alerts (>90%)
- Disk usage alerts (>75%)
- Service restart notifications

**Custom Monitoring (Optional):**
- Prometheus + Grafana
- Database query performance
- Federation latency
- User growth tracking

---

## 🆚 Comparison with Alternatives

### vs Manual Installation
**This Template:**
- ✅ Automated setup (35 min vs 4-8 hours)
- ✅ Pre-configured security
- ✅ Environment variable management
- ✅ Comprehensive documentation

**Manual Installation:**
- ❌ Time-consuming configuration
- ❌ Easy to misconfigure
- ❌ No standardization
- ✅ More control over every detail

### vs Docker Compose
**This Template (Railway):**
- ✅ Managed infrastructure
- ✅ Automatic SSL certificates
- ✅ Zero-downtime deployments
- ✅ Built-in monitoring
- ❌ Platform lock-in
- ❌ Cost considerations

**Docker Compose:**
- ✅ Complete control
- ✅ Any infrastructure
- ✅ No platform costs
- ❌ Manual SSL management
- ❌ Manual monitoring setup
- ❌ More maintenance

### vs Kubernetes
**This Template (Railway):**
- ✅ Much simpler setup
- ✅ Lower learning curve
- ✅ Suitable for small-medium scale
- ❌ Less control
- ❌ Scaling limitations

**Kubernetes:**
- ✅ Maximum scalability
- ✅ Complete control
- ✅ Enterprise features
- ❌ Very complex
- ❌ High operational overhead
- ❌ Requires K8s expertise

---

## 🛠️ Customization Scenarios

### Scenario 1: Add External OAuth Provider

**Goal**: Allow users to login with Google/GitHub

**Steps:**
1. Update MAS config template:
   ```yaml
   upstream_oauth2:
     providers:
       - id: google
         issuer: https://accounts.google.com
         client_id: "${GOOGLE_CLIENT_ID}"
         client_secret: "${GOOGLE_CLIENT_SECRET}"
   ```
2. Add Railway variables: `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`
3. Redeploy MAS service

### Scenario 2: Enable SMTP Email Notifications

**Goal**: Send email for password resets, invites

**Steps:**
1. Sign up for email service (SendGrid, Mailgun)
2. Add Railway variables:
   ```bash
   SMTP_HOST=smtp.sendgrid.net
   SMTP_PORT=587
   SMTP_USER=apikey
   SMTP_PASS=SG.xxxxxxx
   EMAIL_FROM=Matrix <noreply@example.com>
   ```
3. Update Synapse and MAS templates (already included)
4. Redeploy services

### Scenario 3: Custom Element Web Branding

**Goal**: White-label Element Web with company branding

**Steps:**
1. Add Railway variables:
   ```bash
   ELEMENT_BRAND=MyCompany
   ELEMENT_DEFAULT_THEME=dark
   ```
2. (Optional) Add custom CSS/assets
3. Update Dockerfile to copy assets
4. Redeploy Element Web

### Scenario 4: S3 Media Storage

**Goal**: Use S3 instead of local disk for media

**Steps:**
1. Update Synapse config template:
   ```yaml
   media_storage_providers:
     - module: s3_storage_provider.S3StorageProviderBackend
       config:
         bucket: "${S3_BUCKET}"
         access_key_id: "${S3_ACCESS_KEY}"
   ```
2. Add S3 credentials to Railway
3. Update Dockerfile to install s3_storage_provider
4. Redeploy Synapse

---

## 📈 Scaling Recommendations

### Small Deployment (1-50 users)
- **Synapse**: 1 vCPU, 1GB RAM
- **MAS**: 0.5 vCPU, 512MB RAM
- **Element Web**: 0.25 vCPU, 256MB RAM
- **PostgreSQL**: Default Railway sizing
- **Cost**: ~$10-20/month on Railway

### Medium Deployment (50-500 users)
- **Synapse**: 2 vCPUs, 4GB RAM
- **MAS**: 1 vCPU, 2GB RAM
- **Element Web**: 0.5 vCPU, 512MB RAM
- **PostgreSQL**: Larger Railway plan
- **Cost**: ~$40-60/month on Railway

### Large Deployment (500+ users)
- **Synapse**: Multiple workers (requires custom setup)
- **MAS**: 2+ vCPUs, 4GB RAM
- **PostgreSQL**: Dedicated instance, read replicas
- **Consider**: Moving to Kubernetes or dedicated servers
- **Cost**: Variable, consult Railway for custom pricing

---

## 🐛 Known Limitations

### Platform Limitations (Railway)
- **No persistent volumes** - Media storage in container
- **Network egress costs** - High traffic may be expensive
- **Resource limits** - Maximum 8 vCPUs, 32GB RAM per service
- **Build time limits** - Very large images may timeout

### Template Limitations
- **Single-instance services** - No built-in horizontal scaling
- **No worker support** - Synapse workers require custom setup
- **Basic monitoring** - Advanced metrics require additional setup
- **English only** - Documentation and scripts in English only

### Recommended Workarounds
- **Media storage**: Implement S3 storage provider
- **Scaling**: Use vertical scaling until limits reached
- **Workers**: Consider Kubernetes template for large deployments
- **Monitoring**: Add Prometheus/Grafana for advanced metrics

---

## 🎓 Learning Resources

### Matrix Protocol
- **Matrix Specification**: https://spec.matrix.org
- **Matrix.org Documentation**: https://matrix.org/docs/
- **Matrix Community**: `#matrix:matrix.org`

### Synapse
- **Official Documentation**: https://matrix-org.github.io/synapse/
- **Admin Guide**: https://matrix-org.github.io/synapse/latest/usage/administration/
- **Community**: `#synapse:matrix.org`

### MAS (Matrix Authentication Service)
- **GitHub Repository**: https://github.com/matrix-org/matrix-authentication-service
- **Documentation**: https://element-hq.github.io/matrix-authentication-service/
- **Community**: `#matrix-authentication-service:matrix.org`

### Railway Platform
- **Documentation**: https://docs.railway.app
- **Discord Community**: https://discord.gg/railway
- **Blog**: https://blog.railway.app

### Security
- **OWASP Top 10**: https://owasp.org/www-project-top-ten/
- **Web Security**: https://infosec.mozilla.org/guidelines/web_security
- **PostgreSQL Security**: https://www.postgresql.org/docs/current/security.html

---

## 📞 Support & Contribution

### Getting Help

**Template Issues:**
- GitHub Issues for bugs
- GitHub Discussions for questions
- Pull Requests for improvements

**Matrix/Synapse Questions:**
- Matrix HQ: `#matrix:matrix.org`
- Synapse Admins: `#synapse:matrix.org`
- MAS Room: `#matrix-authentication-service:matrix.org`

**Railway Questions:**
- Railway Discord: https://discord.gg/railway
- Railway Docs: https://docs.railway.app
- Railway Support: support@railway.app

### Contributing

**Areas for Contribution:**
- Additional security features
- Performance optimizations
- Documentation improvements
- Bug fixes
- Translation to other languages
- Alternative deployment platforms (Docker Compose, K8s)

**Contribution Process:**
1. Fork repository
2. Create feature branch
3. Make changes with tests
4. Update documentation
5. Submit pull request
6. Wait for review

---

## 🏆 Credits & Acknowledgments

### Technologies
- **Matrix Protocol** - Open communication standard
- **Synapse** - Reference Matrix homeserver implementation
- **Matrix Authentication Service** - Modern OIDC authentication
- **Element Web** - Feature-rich Matrix client
- **PostgreSQL** - Reliable database system
- **Railway.app** - Developer-friendly deployment platform

### Contributors
- Template created based on real-world deployment experience
- Incorporates feedback from Matrix community
- Security practices from OWASP and Matrix.org

### Inspiration
- Matrix.org deployment guides
- Element's Kubernetes Helm charts
- Railway community templates
- Community feedback and requests

---

## 📝 Changelog

### Version 1.0.0 (February 2026)
**Initial Release**
- Complete Synapse, MAS, and Element Web templates
- Environment variable-based configuration
- Automated secret generation script
- Comprehensive documentation (5 guides)
- Security best practices implementation
- Railway-optimized deployment
- Health checks and validation
- Database migration automation

**Future Roadmap:**
- v1.1: Docker Compose variant
- v1.2: Kubernetes manifests
- v1.3: Ansible playbook
- v2.0: Synapse workers support
- v2.1: Advanced monitoring integration

---

## ✅ Final Checklist

Before using this template, ensure you have:

**Prerequisites:**
- [ ] Railway.app account created
- [ ] Git installed locally
- [ ] OpenSSL available (for secret generation)
- [ ] Basic understanding of environment variables
- [ ] Reviewed security documentation

**Deployment:**
- [ ] Forked/cloned repository
- [ ] Generated all secrets
- [ ] Saved secrets securely
- [ ] Created Railway project
- [ ] Added PostgreSQL databases (2)
- [ ] Configured all environment variables
- [ ] Deployed all services
- [ ] Verified health endpoints
- [ ] Created admin user
- [ ] Tested login functionality

**Security:**
- [ ] No secrets in git repository
- [ ] All secrets in Railway variables
- [ ] Separate database passwords
- [ ] Registration disabled
- [ ] HTTPS configured
- [ ] Backup strategy planned
- [ ] Secret rotation schedule documented

**Documentation:**
- [ ] Read DEPLOYMENT_GUIDE.md
- [ ] Reviewed SECURITY.md
- [ ] Bookmarked QUICK_REFERENCE.md
- [ ] Understand ENVIRONMENT_VARIABLES.md

---

## 🎉 Conclusion

This template provides a **complete, production-ready solution** for deploying Matrix on Railway.app. It emphasizes:

1. **Security** - Environment variables, no hardcoded secrets
2. **Reliability** - Automated validation and health checks
3. **Maintainability** - Comprehensive documentation
4. **Ease of Use** - 35-minute deployment time
5. **Flexibility** - Modular architecture, easy customization

**You're now ready to deploy your own Matrix server!**

For questions or issues, consult the documentation or reach out to the community.

---

**Template Version**: 1.0.0  
**Last Updated**: February 2, 2026  
**Minimum Railway Version**: Any  
**Supported Matrix Versions**: Synapse 1.100+, MAS latest  

---

**Happy deploying! 🚀**
