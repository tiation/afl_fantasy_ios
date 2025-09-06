# AFL Fantasy Platform - Quick Start Guide

## 🚀 Get Running in 5 Minutes

### Prerequisites
- Node.js 18+
- Python 3.9+ 
- Terminal/Command Line

### Step 1: Clone & Setup
```bash
git clone <repository>
cd afl_fantasy_ios
./setup.sh          # First-time setup (installs deps, creates .env)
```

### Step 2: Start Services
```bash
./start.sh          # Starts web server + dashboard
```

### Step 3: Access Dashboard
- **Web Dashboard:** http://localhost:5173
- **API Health:** http://localhost:5173/api/health
- **Status Dashboard:** http://localhost:8080/status.html

## ✅ What You Should See

1. **Terminal Output:**
   - "serving on port 5173"
   - No error messages
   - API health check passes

2. **Web Dashboard:**
   - AFL Fantasy Intelligence Platform loads
   - Dashboard with score cards visible
   - Performance chart displays
   - Team structure component shows data

3. **Successful Test:**
   ```bash
   curl http://localhost:5173/api/health
   # Should return: {"status":"healthy",...}
   ```

## 🔧 iOS App (Optional)

```bash
cd ios
open AFLFantasy.xcodeproj
# Press ⌘+R to build and run in simulator
```

## 🐛 Troubleshooting

**Port 5173 already in use:**
```bash
lsof -ti:5173 | xargs kill -9
./start.sh
```

**Dependencies not installing:**
```bash
rm -rf node_modules package-lock.json
npm install
```

**Environment variables missing:**
```bash
cp .env.example .env
# Edit .env with your API keys
```

## 🎯 Next Steps

1. **Add API Keys:** Edit `.env` with your Gemini/OpenAI keys for AI features
2. **Explore Tools:** Navigate to different sections (Stats, Tools, etc.)
3. **Check iOS App:** Build and run the native iOS version
4. **Read Docs:** Check out the full documentation in `/docs`

---

**⚡ That's it! You're now running the AFL Fantasy Intelligence Platform.**
