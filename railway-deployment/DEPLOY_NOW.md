# 🚀 Minimal Railway Deployment - Quick Start

## What You Have Now

✅ **Synapse** - Simplified, working Matrix homeserver  
✅ **Element Web** - Web client (simplified)  
❌ **MAS** - Skipped for now (adds complexity)

## Deploy Steps

### 1. Commit Everything
```bash
git add railway-deployment/
git commit -m "Minimal working Railway deployment"
git push origin railway-deployment
```

### 2. Railway Services You Need

#### Service 1: PostgreSQL Database
- Already created ✅
- Connection string: `postgresql://postgres:eEFsjzqXcmIBuvOWLPXXIPVLJQKlTOkC@postgres.railway.internal:5432/railway`

#### Service 2: Synapse
- **Root Directory**: `railway-deployment/synapse`
- **No environment variables needed** (everything is hardcoded)
- **Enable Public Networking**
- **Port**: 8008 (should auto-detect)

#### Service 3: Element Web  
- **Root Directory**: `railway-deployment/element-web`
- **No environment variables needed**
- **Enable Public Networking**
- **Port**: 80 (should auto-detect)

### 3. Access Your Services

Once deployed:

**Synapse Health Check:**  
`https://your-synapse-domain.up.railway.app/_matrix/static/`  
Should show: "It works! Synapse is running"

**Element Web:**  
`https://your-element-domain.up.railway.app/`  
Should load Element login page

### 4. Create Your First User

Once Synapse is running, create an admin user:

```bash
# In Railway Synapse service, open Terminal/Shell and run:
register_new_matrix_user -c /data/homeserver.yaml http://localhost:8008

# Follow the prompts:
# Username: admin
# Password: (choose a password)
# Make admin? y
```

Or use the shared secret to register via API (easier):

```bash
curl -X POST https://your-synapse-domain.up.railway.app/_synapse/admin/v1/register \
-H "Content-Type: application/json" \
-d '{
  "nonce": "anything",
  "username": "admin",
  "password": "YourPassword123",
  "admin": true,
  "mac": "not_checked_with_shared_secret"
}'
```

### 5. Login to Element

1. Go to your Element Web URL
2. Click "Sign In"
3. Enter:
   - **Username**: admin
   - **Password**: (what you set)
   - **Homeserver**: `https://your-synapse-domain.up.railway.app`

## What's Hardcoded (No Secrets in Git Usually!)

**This is for testing only. In production, use environment variables!**

### Synapse homeserver.yaml
- Database: `postgres.railway.internal:5432/railway`
- Password: `eEFsjzqXcmIBuvOWLPXXIPVLJQKlTOkC`
- Registration secret: `4578b92c30adf6e1`
- Macaroon secret: `6f01b8a9c5e2d437`
- Form secret: `32f4cb150ed867a9`

## Troubleshooting

**502 Bad Gateway on Synapse:**
- Wait 2-3 minutes after deployment for initialization
- Check Railway logs for errors
- Verify port 8008 is exposed in Railway settings

**Element Web can't connect:**
- Make sure you're using the correct Synapse URL
- Check that Synapse health check works first
- Clear browser cache

**Database errors:**
- Verify PostgreSQL service is running
- Check connection string matches in homeserver.yaml

## What We Skipped

- MAS (Matrix Authentication Service) - too complex for first deploy
- Environment variables - everything hardcoded for simplicity
- Security best practices - this is for testing only!
- Custom domains - using Railway domains
- Email notifications - not configured
- Federation - will work but not optimized

## Next Steps After It Works

1. Test creating rooms and sending messages
2. Add more users
3. Later: Add MAS for modern auth (optional)
4. Later: Move secrets to environment variables
5. Later: Set up custom domain

---

**Need help?** Check Railway logs for each service to see what's happening.
