# Complete Railway Deployment Guide

## Your Services

✅ **Element Web**: https://ess-helm-production.up.railway.app  
✅ **Synapse**: https://synapse-production-e979.up.railway.app  
✅ **MAS**: https://mas-service-production.up.railway.app

## Quick Deploy

```bash
git add railway-deployment/
git commit -m "Complete working deployment with MAS"
git push origin railway-deployment
```

## Service Configuration

### 1. PostgreSQL (Already Running ✅)
- Railway database for Synapse
- Connection: `postgresql://postgres:eEFsjzqXcmIBuvOWLPXXIPVLJQKlTOkC@postgres.railway.internal:5432/railway`

### 2. PostgreSQL for MAS (Separate Database)
- Second database for MAS
- Connection: `postgresql://postgres:wHNhQGDToDcZJfzOxEOCjSYnSooDySqt@postgres-h2zw.railway.internal:5432/railway`

### 3. Synapse Service
- **Root Directory**: `railway-deployment/synapse`
- **Port**: 8008
- **Health Check**: `https://synapse-production-e979.up.railway.app/_matrix/static/`

### 4. MAS Service  
- **Root Directory**: `railway-deployment/MAS-service`
- **Port**: 8080
- **Health Check**: `https://mas-service-production.up.railway.app/health`

### 5. Element Web
- **Root Directory**: `railway-deployment/element-web`
- **Port**: 80
- **Access**: https://ess-helm-production.up.railway.app

## Testing Your Deployment

### 1. Verify Synapse
```bash
curl https://synapse-production-e979.up.railway.app/_matrix/static/
```
Should return: "It works! Synapse is running"

### 2. Verify MAS
```bash
curl https://mas-service-production.up.railway.app/health
```
Should return health status

### 3. Access Element Web
Open: https://ess-helm-production.up.railway.app

## Create Your First User

### Option 1: Using Element Web (Easiest)
1. Go to https://ess-helm-production.up.railway.app
2. Click "Create Account"
3. Fill in username and password
4. You'll be logged in automatically

### Option 2: Using Synapse Admin API
```bash
curl -X POST https://synapse-production-e979.up.railway.app/_synapse/admin/v1/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "YourSecurePassword123",
    "admin": true,
    "displayname": "Admin User"
  }'
```

### Option 3: Using Railway Terminal
1. Open Synapse service in Railway
2. Go to "Deployments" → Click on active deployment → "View Logs" 
3. Use the terminal to run:
```bash
register_new_matrix_user -c /data/homeserver.yaml http://localhost:8008
```

## Login to Element

1. Open https://ess-helm-production.up.railway.app
2. Enter your username and password
3. Start chatting!

## What's Configured

✅ User registration enabled  
✅ Password authentication  
✅ Federation enabled  
✅ Media uploads enabled  
✅ Room directory enabled  
✅ MAS integration ready

## Architecture

```
┌─────────────────┐
│  Element Web    │  Port 80
│  (ess-helm...)  │
└────────┬────────┘
         │
         ├──────────┐
         │          │
┌────────▼────────┐ ┌──────────▼─────────┐
│    Synapse      │ │       MAS          │
│    Port 8008    │ │    Port 8080       │
└────────┬────────┘ └────────┬───────────┘
         │                   │
         │                   │
┌────────▼──────────┬────────▼───────────┐
│   PostgreSQL 1    │   PostgreSQL 2     │
│   (Synapse DB)    │     (MAS DB)       │
└───────────────────┴────────────────────┘
```

## Troubleshooting

### Synapse 502 Error
- Wait 2-3 minutes after deploy
- Check logs for database connection
- Verify port 8008 is exposed

### MAS Errors
- Ensure separate PostgreSQL database
- Check database migration logs
- Verify MAS can reach Synapse

### Element Can't Connect
- Clear browser cache
- Verify Synapse health check works
- Check browser console for errors

### Registration Not Working
- Check `enable_registration: true` in homeserver.yaml
- Verify MAS service is running
- Check MAS logs for auth errors

## Security Notes (For Production Later)

⚠️ **Current setup is for testing only!**

Hardcoded values you should move to environment variables:
- Database passwords
- Registration shared secret
- Macaroon secret key
- Form secret
- MAS encryption keys

## Next Steps

1. ✅ Deploy and verify all services work
2. ✅ Create your admin account
3. ✅ Test creating a room and sending messages
4. Add more users
5. Test federation with matrix.org
6. Configure custom domain (optional)
7. Set up email notifications (optional)
8. Harden security for production

---

**Your deployment is ready! 🎉**

Access Element Web at: https://ess-helm-production.up.railway.app
