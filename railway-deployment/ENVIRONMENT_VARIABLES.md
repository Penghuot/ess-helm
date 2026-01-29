# 🔐 Railway Environment Variables - Ready to Copy & Paste

Generated on: January 29, 2026

**IMPORTANT**: Keep these secrets safe and never commit them to Git!

---

## 📊 Service 1: Synapse (Matrix Homeserver)

Copy and paste these variables into your **Synapse** service in Railway:

```
POSTGRES_HOST=${{Postgres.PGHOST}}
POSTGRES_PORT=${{Postgres.PGPORT}}
POSTGRES_DB=${{Postgres.PGDATABASE}}
POSTGRES_PASSWORD=${{Postgres.PGPASSWORD}}
REGISTRATION_SHARED_SECRET=4578b92c30adf6e1
MACAROON_SECRET_KEY=6f01b8a9c5e2d437
FORM_SECRET=32f4cb150ed867a9
```

### How to add these to Railway:
1. Go to your Railway project
2. Click on the **Synapse** service
3. Go to **Variables** tab
4. Click **+ New Variable**
5. For database variables, click **Reference** and select:
   - `POSTGRES_HOST` → Reference → Postgres → `PGHOST`
   - `POSTGRES_PORT` → Reference → Postgres → `PGPORT`
   - `POSTGRES_DB` → Reference → Postgres → `PGDATABASE`
   - `POSTGRES_PASSWORD` → Reference → Postgres → `PGPASSWORD`
6. For the secret variables, add them as regular variables (copy the value)

---

## 🔑 Service 2: MAS (Matrix Authentication Service)

Copy and paste these variables into your **MAS** service in Railway:

```
DATABASE_URL=${{Postgres.DATABASE_URL}}
REGISTRATION_SHARED_SECRET=4578b92c30adf6e1
MAS_ENCRYPTION_SECRET=c07af15b849e23d6
MAS_SIGNING_KEY=76281ea0c3bfd954
MAS_KEY_ID=default
```

### How to add these to Railway:
1. Go to your Railway project
2. Click on the **MAS** service
3. Go to **Variables** tab
4. Click **+ New Variable**
5. For `DATABASE_URL`, click **Reference** and select:
   - Reference → Postgres → `DATABASE_URL`
6. For the other variables, add them as regular variables (copy the value)

**Note**: The `REGISTRATION_SHARED_SECRET` must be the SAME value as in Synapse!

---

## 🌐 Service 3: Element Web

**No environment variables needed** - Element Web configuration is in the config.json file.

You will need to update the [element-web/config.json](element-web/config.json) file with your actual Railway domain URLs after deployment.

---

## ✅ Quick Checklist

- [ ] Created PostgreSQL database in Railway
- [ ] Added variables to Synapse service
- [ ] Added variables to MAS service
- [ ] Deployed all three services
- [ ] Updated domain URLs in configuration files after deployment:
  - [ ] synapse/homeserver.yaml (server_name and public_baseurl)
  - [ ] MAS-service/config.yaml (http.public_base and upstream_oauth2.endpoint)
  - [ ] element-web/config.json (base_url and server_name)

---

## 🔄 If You Need to Regenerate Secrets

Run this command to generate new secrets:
```bash
powershell -ExecutionPolicy Bypass -File gen-secrets.ps1
```

Or use the batch file:
```bash
.\generate-secrets.bat
```

---

## 📋 Variable Reference Summary

| Variable | Used By | Purpose |
|----------|---------|---------|
| `REGISTRATION_SHARED_SECRET` | Synapse + MAS | Shared secret for user registration |
| `MACAROON_SECRET_KEY` | Synapse | Secret for macaroon token generation |
| `FORM_SECRET` | Synapse | Secret for form validation |
| `MAS_ENCRYPTION_SECRET` | MAS | Encryption key for MAS data |
| `MAS_SIGNING_KEY` | MAS | Signing key for MAS tokens |
| `MAS_KEY_ID` | MAS | Identifier for the signing key |
| `POSTGRES_*` | Synapse | PostgreSQL connection details |
| `DATABASE_URL` | MAS | Full PostgreSQL connection string |

---

## 🆘 Troubleshooting

**Problem**: Synapse won't start
- Check that all POSTGRES_* variables are correctly referenced
- Verify REGISTRATION_SHARED_SECRET is set

**Problem**: MAS won't start
- Check that DATABASE_URL is correctly referenced
- Verify REGISTRATION_SHARED_SECRET matches Synapse
- Ensure all MAS_* secrets are set

**Problem**: Services can't connect
- Make sure PostgreSQL is running and healthy
- Check Railway logs for each service
- Verify that variable references use the ${{Service.VARIABLE}} syntax

---

## 📚 Next Steps

1. Deploy your services to Railway
2. Wait for Railway to assign public domains
3. Update the domain URLs in your configuration files (see RAILWAY_DEPLOY_GUIDE.md)
4. Commit and push changes
5. Railway will automatically redeploy with the updated configuration
6. Access Element Web at your assigned domain and create your admin account!

**Full deployment guide**: See [RAILWAY_DEPLOY_GUIDE.md](RAILWAY_DEPLOY_GUIDE.md)
