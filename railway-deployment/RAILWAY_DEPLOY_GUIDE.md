# Railway Deployment Guide for Matrix Stack

This guide will help you deploy Matrix Synapse + MAS + Element Web on Railway.

## 🏗️ Architecture

Your deployment will consist of:
- **Synapse**: Matrix homeserver (main service)
- **MAS** (Matrix Authentication Service): Modern authentication system
- **Element Web**: Web client interface
- **PostgreSQL**: Managed database (Railway plugin)

## 📋 Prerequisites

1. A Railway account (https://railway.app)
2. Git installed locally
3. Docker installed locally (for generating secrets)

## 🔐 Step 1: Generate Required Secrets

Before deploying, you need to generate several secrets. Run these commands locally:

```bash
# Generate registration shared secret (used by both Synapse and MAS)
openssl rand -hex 32
# Save this as REGISTRATION_SHARED_SECRET

# Generate macaroon secret for Synapse
openssl rand -hex 32
# Save this as MACAROON_SECRET_KEY

# Generate form secret for Synapse
openssl rand -hex 32
# Save this as FORM_SECRET

# Generate MAS encryption secret
openssl rand -hex 32
# Save this as MAS_ENCRYPTION_SECRET

# Generate MAS signing key
openssl rand -hex 32
# Save this as MAS_SIGNING_KEY
```

**Important**: Keep these secrets safe! You'll need them in the next steps.

## 🚂 Step 2: Create Railway Project

1. Go to [Railway.app](https://railway.app)
2. Click **"New Project"**
3. Select **"Empty Project"**
4. Name your project (e.g., "Matrix Stack")

## 🗄️ Step 3: Add PostgreSQL Database

1. In your Railway project, click **"+ New"**
2. Select **"Database"** → **"Add PostgreSQL"**
3. Railway will automatically create the database
4. Note: Railway creates these environment variables automatically:
   - `PGHOST` (use as `POSTGRES_HOST`)
   - `PGPORT` (use as `POSTGRES_PORT`)
   - `PGDATABASE` (use as `POSTGRES_DB`)
   - `PGPASSWORD` (use as `POSTGRES_PASSWORD`)
   - `DATABASE_URL` (full connection string for MAS)

## 🏠 Step 4: Deploy Synapse

### 4.1 Create Synapse Service

1. Click **"+ New"** → **"GitHub Repo"**
2. Connect your GitHub account if not already connected
3. Select your repository
4. Railway will ask you to configure the service

### 4.2 Configure Synapse Service

In the service settings:

**General:**
- Service Name: `synapse`
- Root Directory: `railway-deployment/synapse`

**Variables:** Add these environment variables:

```
POSTGRES_HOST=${{Postgres.PGHOST}}
POSTGRES_PORT=${{Postgres.PGPORT}}
POSTGRES_DB=${{Postgres.PGDATABASE}}
POSTGRES_PASSWORD=${{Postgres.PGPASSWORD}}
REGISTRATION_SHARED_SECRET=<paste the secret you generated>
MACAROON_SECRET_KEY=<paste the secret you generated>
FORM_SECRET=<paste the secret you generated>
```

**Settings:**
- Enable **Public Networking**
- Railway will assign a domain like `synapse-production-xxxx.up.railway.app`

### 4.3 Update Server Name

**IMPORTANT**: After Railway assigns your domain, you need to update the server name:

1. Go to [railway-deployment/synapse/homeserver.yaml](railway-deployment/synapse/homeserver.yaml)
2. Update these lines with your actual Railway domain:
   ```yaml
   server_name: "synapse-production-xxxx.up.railway.app"
   public_baseurl: "https://synapse-production-xxxx.up.railway.app/"
   ```
3. Commit and push the changes
4. Railway will automatically redeploy

### 4.4 Initialize Database

After first deployment, the Synapse database needs to be initialized:

1. Go to the Synapse service in Railway
2. Click **"Deployments"**
3. Find the deployment and click **"View Logs"**
4. The service should start successfully and create the database schema automatically

## 🔑 Step 5: Deploy MAS (Matrix Authentication Service)

### 5.1 Create MAS Service

1. Click **"+ New"** → **"GitHub Repo"**
2. Select your repository again
3. Configure the service:

**General:**
- Service Name: `mas-service`
- Root Directory: `railway-deployment/MAS-service`

**Variables:** Add these environment variables:

```
DATABASE_URL=${{Postgres.DATABASE_URL}}
REGISTRATION_SHARED_SECRET=<same secret as Synapse>
MAS_ENCRYPTION_SECRET=<paste the secret you generated>
MAS_SIGNING_KEY=<paste the secret you generated>
MAS_KEY_ID=default
```

**Settings:**
- Enable **Public Networking**
- Railway will assign a domain like `mas-service-production-xxxx.up.railway.app`

### 5.2 Update MAS Configuration

After Railway assigns your domain:

1. Go to [railway-deployment/MAS-service/config.yaml](railway-deployment/MAS-service/config.yaml)
2. Update the `public_base` URL with your actual domain:
   ```yaml
   http:
     public_base: "https://mas-service-production-xxxx.up.railway.app/"
   ```
3. Update the Synapse endpoint if needed:
   ```yaml
   upstream_oauth2:
     endpoint: "https://synapse-production-xxxx.up.railway.app"
   ```
4. Commit and push
5. Railway will redeploy automatically

## 🌐 Step 6: Deploy Element Web

### 6.1 Create Element Web Service

1. Click **"+ New"** → **"GitHub Repo"**
2. Select your repository
3. Configure:

**General:**
- Service Name: `element-web`
- Root Directory: `railway-deployment/element-web`

**Settings:**
- Enable **Public Networking**

### 6.2 Update Element Configuration

1. Go to [railway-deployment/element-web/config.json](railway-deployment/element-web/config.json)
2. Update with your actual domains:
   ```json
   {
     "default_server_config": {
       "m.homeserver": {
         "base_url": "https://synapse-production-xxxx.up.railway.app",
         "server_name": "synapse-production-xxxx.up.railway.app"
       },
       "m.identity_server": {
         "base_url": "https://vector.im"
       }
     }
   }
   ```
3. Commit and push

## ✅ Step 7: Verify Deployment

### Check Service Health

1. **Synapse**: Visit `https://your-synapse-domain.up.railway.app/_matrix/static/`
   - You should see "It works! Synapse is running"

2. **MAS**: Visit `https://your-mas-domain.up.railway.app/health`
   - Should return a health status

3. **Element Web**: Visit your Element domain
   - Should load the Element login page

### Create Admin Account

Use the Railway terminal or connect to Synapse service:

```bash
# Register an admin user
register_new_matrix_user -c /data/homeserver.yaml -u admin -p YOUR_PASSWORD --admin
```

Or using the registration shared secret via API:

```bash
curl -X POST https://your-synapse-domain.up.railway.app/_synapse/admin/v1/register \
  -H "Content-Type: application/json" \
  -d '{
    "nonce": "unused",
    "username": "admin",
    "password": "YOUR_PASSWORD",
    "admin": true,
    "mac": "GENERATE_VIA_SHARED_SECRET"
  }'
```

## 🐛 Troubleshooting

### Synapse won't start

**Check logs:**
1. Go to Synapse service
2. Click "Deployments" → View Logs
3. Common issues:
   - Database connection: Verify PostgreSQL variables
   - Missing secrets: Check all environment variables are set
   - Signing key: Should be generated automatically on first run

### Database Connection Failed

Verify that:
1. PostgreSQL service is running
2. Environment variables are correctly referencing the database:
   ```
   POSTGRES_HOST=${{Postgres.PGHOST}}
   ```
3. The database variables are using Railway's template syntax

### MAS Service Fails

1. Check that `DATABASE_URL` is set correctly
2. Verify the `REGISTRATION_SHARED_SECRET` matches Synapse
3. Ensure all required secrets are generated and set

### Element Can't Connect

1. Verify the Synapse domain in [element-web/config.json](railway-deployment/element-web/config.json)
2. Check that Synapse is responding at `/_matrix/static/`
3. Ensure CORS is properly configured (should be automatic)

## 🔄 Updating Your Deployment

To update any service:

1. Make changes to the files in `railway-deployment/`
2. Commit and push to your repository
3. Railway will automatically detect changes and redeploy

## 📊 Service Reference Variables

### Synapse Variables
- `POSTGRES_HOST` - Database host
- `POSTGRES_PORT` - Database port
- `POSTGRES_DB` - Database name
- `POSTGRES_PASSWORD` - Database password
- `REGISTRATION_SHARED_SECRET` - Shared with MAS
- `MACAROON_SECRET_KEY` - Synapse secret
- `FORM_SECRET` - Synapse form secret

### MAS Variables
- `DATABASE_URL` - Full PostgreSQL connection string
- `REGISTRATION_SHARED_SECRET` - Shared with Synapse
- `MAS_ENCRYPTION_SECRET` - MAS encryption key
- `MAS_SIGNING_KEY` - MAS signing key
- `MAS_KEY_ID` - Key identifier (default: "default")

### Element Web Variables
- No environment variables needed (configuration in config.json)

## 🎯 Next Steps

1. **Configure Federation**: Update DNS records for your domain
2. **Set up SSL**: Railway provides automatic SSL certificates
3. **Disable Registration**: After creating accounts, set `enable_registration: false`
4. **Configure Email**: Set up SMTP for email notifications
5. **Monitoring**: Use Railway's built-in metrics and logs

## 📚 Additional Resources

- [Synapse Documentation](https://element-hq.github.io/synapse/latest/)
- [MAS Documentation](https://github.com/matrix-org/matrix-authentication-service)
- [Railway Documentation](https://docs.railway.app)
- [Element Web](https://github.com/element-hq/element-web)

## 🆘 Need Help?

- Check Railway logs for each service
- Review the Synapse homeserver.yaml configuration
- Verify all environment variables are set correctly
- Ensure PostgreSQL is running and accessible
- Check that domains match in all configuration files
