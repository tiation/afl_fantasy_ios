# 🚀 AFL Fantasy Platform - Quick Start Guide

Welcome to the AFL Fantasy Intelligence Platform! This guide will get you up and running in minutes.

## 📋 Prerequisites

Before starting, ensure you have:
- **Docker**: [Install Docker](https://docs.docker.com/get-docker/)
- **Git** (optional): For cloning from GitHub

## 🎯 Step 1: Get the Platform

### Option A: Fork from GitHub (Recommended)
```bash
# Fork the repository on GitHub, then:
git clone https://github.com/yourusername/afl-fantasy-platform.git
cd afl-fantasy-platform
```

### Option B: Download from Replit
1. Click "Download as ZIP" from your Replit project
2. Extract the ZIP file
3. Open terminal in the extracted folder

## 🚀 Step 2: Deploy (30 seconds)

Run the quick deploy script:
```bash
./quick-deploy.sh
```

Choose deployment option:
- **Option 1**: Docker Compose (recommended for beginners)
- **Option 2**: Kubernetes (for production)
- **Option 3**: Helm Charts (enterprise)

## ✅ Step 3: Verify Everything Works

### Health Check
```bash
curl http://localhost:5000/api/health
```
Expected response: `{"status":"healthy"}`

### Player Data Check
```bash
curl http://localhost:5000/api/stats/combined-stats | jq 'length'
```
Expected: `642` (all players loaded)

### Open the Application
Visit: http://localhost:5000

You should see:
- **Dashboard** with team overview
- **642 authentic AFL players** in the stats page
- **25+ fantasy tools** ready to use

## 🎮 What You Can Do Now

### 1. Explore Player Data
- Visit **Stats** page to see all 642 players
- Search for specific players
- Filter by team, position, price range
- View detailed player statistics

### 2. Use Fantasy Tools
- **Captain Selector**: Get AI-powered captain recommendations
- **Trade Analyzer**: Optimize your trades with score projections
- **Cash Generation**: Find the best cash cows and rookies
- **DVP Analysis**: See matchup difficulty for upcoming rounds
- **Price Predictor**: Forecast player price changes

### 3. Team Management
- **Dashboard**: Manage your fantasy team
- **Lineup**: Set captain, vice-captain, and bench
- **Performance**: Track your team's weekly scores

## 🔧 Configuration (Optional)

### Basic Configuration
The platform works out-of-the-box with sample data. For enhanced features:

```bash
# Copy environment template
cp .env.example .env

# Edit with your preferences
nano .env
```

### API Keys for Enhanced Features
Add these to your `.env` file for additional functionality:

```bash
# AFL Fantasy authentication (real user data)
AFL_FANTASY_USERNAME=your_username
AFL_FANTASY_PASSWORD=your_password

# DFS Australia API (enhanced statistics)
DFS_AUSTRALIA_API_KEY=your_api_key

# OpenAI (AI-powered analysis)
OPENAI_API_KEY=your_openai_key
```

### Restart After Configuration
```bash
docker-compose down
docker-compose up -d
```

## 📊 Monitoring Your Platform

### Application Monitoring
- **Grafana Dashboard**: http://localhost:3001 (admin/admin)
- **Prometheus Metrics**: http://localhost:9090
- **Application Logs**: `docker-compose logs afl-fantasy-app`

### Performance Verification
```bash
# Response time test
time curl -s http://localhost:5000/api/stats/combined-stats > /dev/null

# Load test (simple)
for i in {1..50}; do curl -s http://localhost:5000/api/health > /dev/null & done
```

## 🛠️ Troubleshooting

### Port 5000 Already in Use
```bash
# Find process using port 5000
lsof -i :5000

# Kill the process
kill -9 <PID>

# Or use different port
export PORT=5001
./quick-deploy.sh
```

### Docker Issues
```bash
# Clean Docker system
docker system prune -f

# Rebuild from scratch
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

### Player Data Not Loading
```bash
# Check player data file
wc -l player_data.json  # Should show ~16230 lines

# Check API response
curl http://localhost:5000/api/stats/combined-stats | head

# Restart application
docker-compose restart afl-fantasy-app
```

### Database Connection Issues
```bash
# Check database status
docker-compose logs postgres

# Test connection
docker-compose exec postgres psql -U postgres -d afl_fantasy -c "SELECT 1;"
```

## 🎯 Next Steps

### Explore Features
1. **Player Stats Page**: See all 642 players with filtering
2. **Fantasy Tools**: Try the captain selector and trade analyzer
3. **Team Dashboard**: Set up your fantasy team
4. **DVP Analysis**: Check matchup difficulties

### Advanced Usage
- **Production Deployment**: See [PRODUCTION_CHECKLIST.md](../PRODUCTION_CHECKLIST.md)
- **API Integration**: Check [API documentation](./api.md)
- **Custom Development**: Review [architecture guide](../AFL_Fantasy_Platform_Documentation/PROJECT_ARCHITECTURE.md)

### Get Help
- **Documentation**: Browse the `/docs` directory
- **Issues**: Check [Known Issues](../AFL_Fantasy_Platform_Documentation/KNOWN_ISSUES.md)
- **Support**: Create an issue on GitHub

## 🏆 Success Indicators

Your platform is working correctly when:

✅ **Application responds** at http://localhost:5000  
✅ **All 642 players** display in stats page  
✅ **Dashboard loads** without errors  
✅ **Fantasy tools** provide recommendations  
✅ **Search and filtering** work properly  
✅ **Response times** are under 200ms  

## 🎉 You're Ready!

Congratulations! Your AFL Fantasy Intelligence Platform is now running with:

- **Complete player database** (642 authentic players)
- **Advanced analytics** (score projections, price predictions)
- **Strategic tools** (captain selection, trade optimization)
- **Professional infrastructure** (monitoring, scaling, security)

**Start dominating your fantasy league!** 🏆

---

**Need more help?** Check out the complete documentation in the `/docs` directory or create an issue on GitHub.