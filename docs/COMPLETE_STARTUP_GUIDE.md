# 🚀 Complete AFL Fantasy Platform Startup Guide
*Get your entire AFL Fantasy Intelligence Platform running in minutes*

## 🏗️ Platform Architecture

Your AFL Fantasy platform consists of:
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   iOS App       │    │  Web Frontend   │    │  Backend API    │
│  (SwiftUI)      │    │  (React + TS)   │    │ (Express + TS)  │
│  Port: Sim      │◄──►│  Port: 5173     │◄──►│  Port: 5173     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                       │
                                ▼                       ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │  PostgreSQL     │    │  Python AI      │
                       │  Port: 5432     │    │  (Flask/Direct) │
                       │  (Optional)     │    │  Embedded       │
                       └─────────────────┘    └─────────────────┘
```

## 📋 Prerequisites

### Required Tools
```bash
# Check if you have these installed:
node --version    # Should be 18+
npm --version     # Should be 8+
python3 --version # Should be 3.9+
xcode-select --version # For iOS development

# macOS Installation (if missing):
brew install node python3
xcode-select --install

# Install Xcode from App Store for iOS development
```

### Optional (for Database Features)
```bash
# PostgreSQL (optional)
brew install postgresql
brew services start postgresql

# Docker (optional - for containerized setup)
brew install docker
```

## 🚀 One-Command Quick Start

The fastest way to get everything running:

### 1. Setup (First Time Only)
```bash
# From project root
./setup.sh
```

### 2. Start All Services
```bash
# This starts web frontend + API backend
./start.sh

# Your app will be available at:
# http://localhost:5173 (Web Dashboard)
# http://localhost:5173/api (API endpoints)
```

### 3. Start iOS App (Separate Terminal)
```bash
# Open Xcode and run in simulator
open ios/AFLFantasy.xcodeproj

# Or from command line:
cd ios
xcodebuild -scheme AFLFantasy -destination 'platform=iOS Simulator,name=iPhone 15' build
```

## 📝 Manual Step-by-Step Setup

If you prefer to do it manually:

### Step 1: Environment Setup
```bash
# Install dependencies
npm install

# Setup environment variables
cp .env.example .env
# Edit .env with your API keys:
# GEMINI_API_KEY=your_key_here
# OPENAI_API_KEY=your_key_here
```

### Step 2: Start Web Frontend + API
```bash
# This starts both frontend and backend together
npm run dev

# Or start components separately:
# Frontend only: npm run build:frontend 
# Backend only: npm run dev
```

### Step 3: Start Python AI Services (if needed)
```bash
cd backend/python
pip install -r requirements.txt
python3 main.py
```

### Step 4: Start iOS App
```bash
# Option 1: Open in Xcode
open ios/AFLFantasy.xcodeproj
# Then press ⌘+R to build and run

# Option 2: Command line build
cd ios
xcodebuild -scheme AFLFantasy -destination 'platform=iOS Simulator,name=iPhone 15' build
```

### Step 5: Start Database (Optional)
```bash
# Option 1: Docker
docker-compose up postgres

# Option 2: Local PostgreSQL
createdb afl_fantasy
npm run db:push  # Setup schema
```

## 🌐 Access Your Platform

Once everything is running:

| Service | URL | Description |
|---------|-----|-------------|
| **Web Dashboard** | http://localhost:5173 | Main web interface |
| **API Health** | http://localhost:5173/api/health | API status check |
| **API Documentation** | http://localhost:5173/api | API endpoints |
| **iOS App** | iOS Simulator | Native mobile app |
| **Database** | localhost:5432 | PostgreSQL (if enabled) |

## 🔧 Configuration

### Environment Variables (.env)
```bash
# Required for AI features
GEMINI_API_KEY=your_gemini_api_key_here
OPENAI_API_KEY=your_openai_api_key_here

# Database (optional)
DATABASE_URL=postgresql://localhost:5432/afl_fantasy

# Server
NODE_ENV=development
PORT=5173
```

### iOS App Authentication
1. Open the iOS app in simulator
2. Go to Settings → Sign In
3. Enter your AFL Fantasy Team ID and session cookie
4. The app will connect to your local API server

## 🛠️ Development Commands

### Frontend Development
```bash
npm run dev              # Start development server
npm run build           # Build for production
npm run test           # Run tests
npm run lint           # Check code quality
```

### Backend Development
```bash
npm run dev            # Start backend server
npm run db:push        # Update database schema
npm run db:generate    # Generate database migrations
```

### iOS Development
```bash
cd ios
./Scripts/quality.sh   # Run SwiftLint + SwiftFormat
xcodebuild -scheme AFLFantasy test  # Run tests
```

## 🐛 Troubleshooting

### Common Issues

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

**iOS build failures:**
```bash
cd ios
xcodebuild clean -scheme AFLFantasy
# Then rebuild in Xcode
```

**Python module errors:**
```bash
cd backend/python
pip install --upgrade -r requirements.txt
```

**Database connection errors:**
```bash
# Start PostgreSQL
brew services start postgresql

# Create database
createdb afl_fantasy

# Reset schema
npm run db:push
```

**Environment variables not loaded:**
```bash
# Make sure .env exists in project root
cp .env.example .env
# Edit .env with your actual values
```

### Service-Specific Debugging

**Web Frontend Issues:**
- Check browser console for errors
- Verify API endpoints are responding
- Check network tab for failed requests

**API Backend Issues:**
- Check terminal output for error messages
- Visit http://localhost:5173/api/health
- Check database connection if using DB features

**iOS App Issues:**
- Check Xcode console for errors
- Verify API server is running on localhost:5173
- Check app's network permissions

**Python AI Services:**
- Check if all Python dependencies are installed
- Verify API keys are set in environment
- Check backend/python logs for errors

## 🔄 Complete Reset

If things get messy, here's a complete reset:

```bash
# Stop all services
pkill -f "node.*dev"
pkill -f "python.*main.py"

# Clean and reinstall
rm -rf node_modules package-lock.json
npm install

# Reset environment
cp .env.example .env
# Edit .env with your settings

# Restart everything
./start.sh
```

## 🎯 What You Should See

### Successful Startup
1. **Terminal Output:**
   - "serving on port 5173"
   - No error messages
   - API health check passes

2. **Web Dashboard (http://localhost:5173):**
   - AFL Fantasy Intelligence Platform loads
   - Navigation works
   - Data loads (may be sample data initially)

3. **iOS App:**
   - App launches in simulator
   - Settings screen allows credential entry
   - Dashboard shows sample data or connects to local API

### Features Available
- **Web Dashboard:** Player statistics, trade analysis, AI insights
- **iOS App:** Native interface, secure authentication, real-time data
- **API:** RESTful endpoints for all fantasy tools
- **AI Services:** Captain recommendations, trade analysis, price predictions

## 📚 Next Steps

1. **Configure API Keys:** Add your Gemini/OpenAI keys to .env
2. **Load Data:** Use the data import scripts in /scripts
3. **AFL Fantasy Auth:** Set up your AFL Fantasy credentials in iOS app
4. **Explore Features:** Try the various analysis tools and AI recommendations
5. **Development:** Check out the component documentation in /docs

---

## 🆘 Need Help?

- **Documentation:** Check the `/docs` folder for detailed guides
- **API Reference:** Visit http://localhost:5173/api when server is running
- **iOS Guide:** Read `ios/README.md` for mobile app details
- **Issues:** Most problems are solved by the troubleshooting section above

**🏆 Your AFL Fantasy Intelligence Platform is now ready to help you dominate your league!**
