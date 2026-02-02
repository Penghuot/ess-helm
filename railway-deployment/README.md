# Railway Deployment Documentation

Welcome! This folder contains **complete documentation** for your Matrix Synapse + MAS + Element Web deployment on Railway.

## 📚 Documentation Files

### 1. **DEPLOYMENT_DOCUMENTATION.md** ⭐ START HERE
The comprehensive guide covering everything:
- System overview and architecture
- Detailed configuration for each service
- Step-by-step deployment process
- Verification and testing procedures
- User management
- Troubleshooting guide
- Production next steps

**→ Read this first for complete understanding**

---

### 2. **QUICK_REFERENCE.md** 🚀 FOR DAILY USE
Fast reference guide with essential information:
- Current service URLs and credentials
- File structure and architecture
- Common operations (restart, logs, test)
- Quick troubleshooting
- Useful commands

**→ Use this for daily operations and quick checks**

---

### 3. **TECHNICAL_TROUBLESHOOTING.md** 🔧 FOR ADVANCED USERS
In-depth technical guide:
- Common issues with detailed solutions
- Error messages explained
- Advanced configuration
- Performance optimization
- Security hardening
- Professional debugging

**→ Use this for solving issues and optimization**

---

## 🎯 Quick Start

### First Time Setup?
1. Read **DEPLOYMENT_DOCUMENTATION.md** sections:
   - Overview & Architecture
   - Detailed Configuration
   - Deployment Process
2. Verify all services running
3. Test endpoints
4. Create first user

### Doing Something Specific?
1. **Quick operation?** → Check **QUICK_REFERENCE.md**
2. **Configuration?** → Check **DEPLOYMENT_DOCUMENTATION.md**
3. **Problem solving?** → Check **TECHNICAL_TROUBLESHOOTING.md**

---

## ✅ Current Status

### Services Running
- ✅ **Synapse**: https://synapse-production-e979.up.railway.app
- ✅ **MAS**: https://mas-service-production.up.railway.app  
- ✅ **Element Web**: https://ess-helm-production.up.railway.app

### Databases
- Synapse: `postgres.railway.internal:5432/railway`
- MAS: `postgres-h2zw.railway.internal:5432/railway`

---

## 📖 How to Read This Documentation

### By Role
- **Administrator** → DEPLOYMENT_DOCUMENTATION + TECHNICAL_TROUBLESHOOTING
- **Operator** → QUICK_REFERENCE for daily tasks
- **Developer** → DEPLOYMENT_DOCUMENTATION for configuration
- **End User** → Just use Element Web!

### By Task
- **Setup** → DEPLOYMENT_DOCUMENTATION "Deployment Process" section
- **Operations** → QUICK_REFERENCE "Common Operations" section
- **Troubleshooting** → TECHNICAL_TROUBLESHOOTING "Common Issues" section
- **Security** → TECHNICAL_TROUBLESHOOTING "Security Hardening" section

---

## 🚀 What to Do Next

1. **Immediate**: Test all services work
2. **Today**: Create test users, verify functionality
3. **Week 1**: Set up backups, configure custom domain
4. **Month 1**: Move secrets to env vars, disable open registration
5. **Production**: Full security hardening, monitoring setup

See **DEPLOYMENT_DOCUMENTATION.md** "Next Steps" section for details.

---

## 📞 Need Help?

1. **Check** QUICK_REFERENCE.md (common tasks)
2. **Check** DEPLOYMENT_DOCUMENTATION.md (detailed info)
3. **Check** TECHNICAL_TROUBLESHOOTING.md (error solutions)
4. **Read** linked documentation (Matrix, Synapse, Railway docs)

---

**👉 Start with DEPLOYMENT_DOCUMENTATION.md →**

📝 Section 5: Element Web Configuration
File: railway-deployment/element-web/config.json

🔐 Section 6: Generate Required Secrets
Before deploying, generate these secrets locally:

# Generate Synapse signing key
docker run --rm -it matrixdotorg/synapse:v1.118.0 generate_signing_key

# Generate random secrets (macaroon, form secret, registration shared secret)
openssl rand -hex 32  # Use for MACAROON_SECRET_KEY
openssl rand -hex 32  # Use for FORM_SECRET
openssl rand -hex 32  # Use for REGISTRATION_SHARED_SECRET
🚂 Section 7: Railway Environment Variables
Synapse Service Variables:
Element Web Service Variables:
📦 Section 8: Railway Deployment Steps
Step 1: Prepare Your Repository
# In your forked ess-helm repo
git checkout -b railway-deployment
mkdir -p railway-deployment/synapse railway-deployment/element-web

# Copy all files from sections 2-5 above into their respective folders
# Commit and push
git add railway-deployment/
git commit -m "Add Railway deployment configuration"
git push origin railway-deployment
Step 2: Create Railway Project
Go to Railway.app
Click "New Project"
Select "Deploy from GitHub repo"
Choose your forked ess-helm repository
Select the railway-deployment branch
Step 3: Add PostgreSQL Database
In your Railway project, click "+ New"
Select "Database" → "Add PostgreSQL"
Railway automatically creates connection variables
Note the database service name (usually "Postgres")
Step 4: Deploy Synapse
Click "+ New" → "GitHub Repo"

Select your repo again

Configure the service:

Name: Synapse
Root Directory: railway-deployment/synapse
Build Command: (leave empty - Docker handles this)
Start Command: (leave empty - Dockerfile CMD handles this)
Add environment variables (from Section 7)

Under Settings → Networking:

Enable "Public Networking"
Note the public domain
Step 5: Initialize Synapse Database
Before first run, we need to create the database schema:

In Railway dashboard, go to Synapse service
Open "Deployments" tab
Wait for initial deployment to fail (expected - DB not initialized)
Click "Connect" → "Command"
Run:
python -m synapse.app.homeserver \
  -c /data/homeserver.yaml \
  --generate-keys
This creates the signing key at /data/keys/signing.key. Since Railway uses ephemeral storage, we need to handle this differently:

IMPORTANT: Persistent Storage Workaround

Since Railway doesn't persist volumes by default, you have two options:

Option A: Use Railway Volumes (Recommended)

Go to Synapse service → Settings → Volumes
Click "+ New Volume"
Mount path: data
This persists media_store and signing.key
Option B: Store Signing Key as Environment Variable

Generate the key locally:
Copy the output (looks like: ed25519 a_key ASDFjkl...)
Add to Railway env vars: SIGNING_KEY=<your-key>
Modify homeserver.yaml:
Step 6: Run Database Migration
After keys are generated:

This will:

Initialize PostgreSQL schema
Create necessary tables
Start Synapse on port 8008
Step 7: Deploy Element Web
Click "+ New" → "GitHub Repo"
Select your repo
Configure:
Name: ElementWeb
Root Directory: railway-deployment/element-web
Add environment variables (Element Web section from Section 7)
Enable public networking
Deploy
Step 8: Configure Custom Domain (Optional)
In Synapse service → Settings → Networking
Click "Add Custom Domain"
Add: matrix.your-domain.com
Update DNS with provided CNAME
Repeat for Element Web:

Add: app.your-domain.com
Step 9: Test Deployment
Visit Element Web URL: https://elementweb-production-xxxx.up.railway.app
Click "Create Account" (should be disabled)
Create first admin user via command line:
Log in with @admin:your-domain.com
🔧 Section 9: Well-Known Delegation (Federation)
For federation to work with custom domains, serve these files:

Option A: Railway Static Service
Create a new service with nginx:

File: railway-deployment/well-known/Dockerfile

File: railway-deployment/well-known/server.json

{
  "m.server": "matrix.your-domain.com:443"
}
File: railway-deployment/well-known/client.json

Deploy this as a third Railway service, accessible at your-domain.com.

Option B: Use Your Main Website
If you already have a website, add these routes serving the JSON above.

⚠️ Section 10: Important Limitations & Notes
Storage Limitations:
Railway volumes are limited to 100GB on Hobby plan
Media files stored in /data/media_store can grow quickly
Consider using S3-compatible storage (Backblaze B2, Cloudflare R2) for media
To use S3 for media, modify homeserver.yaml:

Scaling Limitations:
Railway is single-instance per service (no horizontal scaling)
For high load, consider:
Enabling Synapse workers (requires Redis)
Using Railway's Redis plugin
Splitting workers into separate services
Database Backups:
Railway provides automatic PostgreSQL backups on Pro plan. For Hobby:

Performance:
Synapse is resource-intensive (plan for 1-2GB RAM minimum)
Railway Hobby: 512MB RAM (upgrade to Pro for 8GB)
Monitor usage in Railway dashboard
Federation:
Matrix federation requires publicly accessible homeserver
DNS must point to Railway domain or custom domain
Port 8448 federation listener not needed (Railway uses 443)
Security Considerations:
Always use HTTPS (Railway provides this automatically)
Never commit secrets to Git
Rotate secrets regularly via Railway dashboard
Enable rate limiting (already configured in homeserver.yaml)
Monitor logs for suspicious activity
🚀 Section 11: Quick Start Checklist
 Generate signing key, macaroon secret, form secret, registration secret
 Create Railway project
 Add PostgreSQL plugin
 Deploy Synapse service with env vars
 Add Railway volume for data persistence
 Run database migration
 Create admin user via CLI
 Deploy Element Web service with env vars
 Test login at Element Web URL
 (Optional) Configure custom domains
 (Optional) Set up .well-known delegation
 (Optional) Configure S3 for media storage
📚 Section 12: Useful Commands
Create User (Admin):
Create User (Regular):
Reset User Password:
Check Synapse Health:
View Logs:
Database Query:
🎯 Section 13: Troubleshooting
"Database connection failed"
Check PostgreSQL service is running
Verify ${{Postgres.PGHOST}} reference syntax in env vars
Ensure database exists (Railway creates it automatically)
"Signing key not found"
Ensure Railway volume is mounted at data
Or store signing key in environment variable
"Cannot register users"
enable_registration: false by design for security
Use register_new_matrix_user command instead
Element Web shows "Homeserver not reachable"
Check Synapse service is running and public
Verify SYNAPSE_URL env var in Element Web
Check CORS headers (already configured)
Federation not working
Verify .well-known files are accessible at https://your-domain.com/.well-known/matrix/server
Check DNS points to Railway domain
Test with Matrix Federation Tester
High memory usage
Synapse is memory-hungry (1-2GB typical)
Upgrade Railway plan if hitting limits
Enable workers to distribute load
✅ You're Done!
You now have a fully functional Matrix homeserver on Railway with:

✅ Synapse homeserver with PostgreSQL
✅ Element Web client
✅ Environment-based configuration
✅ Secure secrets management
✅ Production-ready logging
✅ Health checks
✅ Optional federation support
Next Steps:

Customize Element Web branding in config.json
Set up S3 media storage for scalability
Enable Synapse workers for better performance
Configure TURN server for VoIP/video calls
Set up monitoring and alerts
Support:

Railway Docs: https://docs.railway.app
Synapse Docs: https://element-hq.github.io/synapse
Element Web Docs: https://github.com/element-hq/element-web
This guide gives you everything needed to deploy and run Matrix on Railway. Copy the files, set the env vars, deploy, and you're live! 🚀