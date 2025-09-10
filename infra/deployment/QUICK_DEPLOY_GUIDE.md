# AFL Fantasy Platform - Quick Deployment Guide

## Your VPS Infrastructure

| Service | Domain | IP | Purpose |
|---------|--------|-------|---------|
| API/Dashboard | docker.sxc.codes | 145.223.22.7 | Node.js API + React Dashboard |
| Scraper | docker.tiation.net | 145.223.22.9 | Python Scraper Service |
| Database | supabase.sxc.codes | 93.127.167.157 | PostgreSQL + Auth |
| Monitoring | grafana.sxc.codes | 153.92.214.1 | Metrics & Logs |
| Search | elastic.sxc.codes | 145.223.22.14 | Elasticsearch |

## Quick Start (Deploy Everything)

```bash
# Make deployment script executable
chmod +x deployment/deploy-production.sh

# Deploy everything to your VPS servers
./deployment/deploy-production.sh all
```

## Step-by-Step Deployment

### 1. Prepare Your Environment

```bash
# Copy and edit the production environment file
cp deployment/.env.production .env.production
# Edit with your actual database credentials, API keys, etc.
nano .env.production
```

### 2. Deploy API Server to docker.sxc.codes

```bash
# Deploy API and Dashboard
./deployment/deploy-production.sh api

# Setup Nginx reverse proxy
./deployment/deploy-production.sh nginx

# Check if it's running
curl http://145.223.22.7:5000/api/health
```

### 3. Deploy Scraper to docker.tiation.net

```bash
# Deploy Python scraper
./deployment/deploy-production.sh scraper

# Check scraper health
curl http://145.223.22.9:8000/internal/health
```

### 4. Configure Database (Supabase)

1. Go to https://supabase.sxc.codes
2. Create a new project "afl-fantasy"
3. Get your connection string and update .env.production
4. Run migrations:

```bash
# Copy your Supabase connection string
export DATABASE_URL="postgresql://postgres:[password]@db.supabase.co:5432/postgres"

# Run migrations (if you have them)
psql $DATABASE_URL < database/schema.sql
```

### 5. Test Everything

```bash
# Run health checks
./deployment/deploy-production.sh health

# View logs
./deployment/deploy-production.sh logs api
./deployment/deploy-production.sh logs scraper
```

## Manual Server Setup (First Time Only)

### On docker.sxc.codes (145.223.22.7)

```bash
# SSH into server
ssh root@145.223.22.7

# Install Node.js 20.x
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
apt-get install -y nodejs

# Install PM2 globally
npm install -g pm2

# Install Nginx
apt-get install -y nginx certbot python3-certbot-nginx

# Create app directory
mkdir -p /opt/afl-fantasy
```

### On docker.tiation.net (145.223.22.9)

```bash
# SSH into server
ssh root@145.223.22.9

# Install Python and dependencies
apt-get update
apt-get install -y python3-pip python3-venv chromium-browser chromium-driver xvfb supervisor

# Create scraper directory
mkdir -p /opt/scrapers

# Setup virtual display for Selenium
echo "export DISPLAY=:99" >> ~/.bashrc
```

## Accessing Your Services

After deployment, your services will be available at:

- **API**: http://docker.sxc.codes/api (port 5000)
- **Dashboard**: http://docker.sxc.codes (port 3000)
- **Scraper API**: http://docker.tiation.net:8000 (internal only)
- **Database**: Via Supabase dashboard or connection string
- **Monitoring**: http://grafana.sxc.codes

## SSL Setup (After Initial Deploy)

```bash
# On docker.sxc.codes
ssh root@145.223.22.7
certbot --nginx -d docker.sxc.codes -d api.docker.sxc.codes

# On docker.tiation.net (if exposing publicly)
ssh root@145.223.22.9
certbot --nginx -d docker.tiation.net
```

## Monitoring Commands

```bash
# Check service status on API server
ssh root@145.223.22.7 "pm2 status"

# Check scraper status
ssh root@145.223.22.9 "systemctl status afl-scraper"

# View real-time logs
ssh root@145.223.22.7 "pm2 logs afl-api --lines 100"
ssh root@145.223.22.9 "journalctl -u afl-scraper -f"

# Restart services
ssh root@145.223.22.7 "pm2 restart all"
ssh root@145.223.22.9 "systemctl restart afl-scraper"
```

## Troubleshooting

### API Server Not Responding
```bash
ssh root@145.223.22.7
pm2 logs afl-api
pm2 restart afl-api
```

### Scraper Not Working
```bash
ssh root@145.223.22.9
systemctl status afl-scraper
journalctl -u afl-scraper -n 50
# Check if Xvfb is running
ps aux | grep Xvfb
```

### Database Connection Issues
- Check Supabase dashboard for connection limits
- Verify DATABASE_URL in .env files on both servers
- Test connection: `psql $DATABASE_URL -c "SELECT 1"`

## Daily Operations

### Manual Scraper Run
```bash
# Trigger scraper from API server
curl -X POST http://145.223.22.9:8000/internal/scrape/players \
  -H "Content-Type: application/json" \
  -d '{"force_update": true}'
```

### Backup Database
```bash
# Run from any server with psql
pg_dump $DATABASE_URL > backup_$(date +%Y%m%d).sql
```

### Update Code
```bash
# Pull latest changes
git pull origin main

# Redeploy specific service
./deployment/deploy-production.sh api     # For API updates
./deployment/deploy-production.sh scraper # For scraper updates
```

## Security Checklist

- [ ] Change default passwords in .env.production
- [ ] Setup firewall rules (ufw or iptables)
- [ ] Enable SSL certificates
- [ ] Restrict database access to VPS IPs only
- [ ] Setup fail2ban for SSH protection
- [ ] Regular security updates: `apt update && apt upgrade`

---

**Support**: For issues, check logs first, then refer to deployment/VPS_DEPLOYMENT_STRATEGY.md for detailed architecture information.
