# 🚀 AFL Fantasy Platform - Quick Start Guide

Welcome to the AFL Fantasy Intelligence Platform! This guide will get you up and running in minutes.

## 📋 **Prerequisites**

- **Node.js 18+** (Download from [nodejs.org](https://nodejs.org/))
- **npm** (comes with Node.js)
- **PostgreSQL** (optional, for database features)

## ⚡ **Super Quick Start**

### 1. First-Time Setup
```bash
./setup.sh
```
This script will:
- ✅ Check your prerequisites
- ✅ Install all dependencies  
- ✅ Set up your environment file
- ✅ Configure the development environment

### 2. Start Development Server
```bash
./start.sh
```
This will start both frontend and backend servers.

**Access your application:**
- 🌐 **Web Dashboard**: http://localhost:5173
- 🔌 **API Endpoints**: http://localhost:5173/api
- 📊 **Health Check**: http://localhost:5173/api/health

### 3. Run Tests (Optional)
```bash
./test.sh
```

### 4. Build for Production
```bash
./build.sh
```

## 📁 **What You Get**

### **🌐 Web Dashboard**
- Real-time AFL Fantasy analytics
- AI-powered captain recommendations  
- Trade analysis and optimization
- Cash generation tracking
- Player performance insights

### **📱 iOS Application**
- Native SwiftUI app (in `/ios` folder)
- Complete AI integration
- Secure credential management
- Real-time data synchronization

### **⚙️ Backend API**
- Express.js + TypeScript
- PostgreSQL database integration
- AI/ML analytics engine
- Python tools integration

## 🔧 **Manual Commands**

If you prefer to run commands manually:

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Run tests
npm test

# Build for production  
npm run build

# Start production server
npm start

# Type checking
npm run check

# Linting
npm run lint

# Format code
npm run format
```

## ⚙️ **Environment Configuration**

Edit `.env` file with your configuration:

```env
# Database (optional)
DATABASE_URL=postgresql://localhost:5432/afl_fantasy

# AI Integration
GEMINI_API_KEY=your_gemini_api_key_here
OPENAI_API_KEY=your_openai_api_key_here

# Server
NODE_ENV=development
PORT=5173
SESSION_SECRET=your_secure_session_secret
```

## 📊 **Application Features**

### **Dashboard**
- Team value tracking
- Score projections  
- Rank monitoring
- Captain analysis

### **Advanced Analytics**
- AI-powered recommendations
- Price prediction algorithms
- Risk assessment tools
- Performance trend analysis

### **Data Sources**
- DFS Australia API
- FootyWire integration
- AFL Fantasy live data
- Excel-based DVP analysis

## 🆘 **Troubleshooting**

### **Common Issues**

**Port 5173 already in use:**
```bash
# Kill any process using the port
lsof -ti:5173 | xargs kill -9
# Then restart
./start.sh
```

**Dependencies not installing:**
```bash
# Clear npm cache
npm cache clean --force
# Delete node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

**Database connection errors:**
```bash
# Make sure PostgreSQL is running
brew services start postgresql
# Or using system package manager
sudo service postgresql start
```

**TypeScript errors:**
```bash
# Run type checking
npm run check
# Fix any type errors before starting
```

## 📚 **Documentation**

- **[Complete Project Documentation](docs/README.md)** - Full technical details
- **[iOS App Deep Dive](docs/IOS_APP_DEEP_DIVE.md)** - Mobile app details  
- **[Development Guide](docs/DEVELOPMENT_WORKFLOW_GUIDE.md)** - Development standards
- **[Component Status](docs/COMPONENT_STATUS_MATRIX.md)** - Implementation tracking

## 🎯 **Next Steps**

1. **Explore the Web Dashboard** at http://localhost:5173
2. **Check out the iOS app** in the `/ios` directory
3. **Review the API endpoints** at http://localhost:5173/api
4. **Read the full documentation** in the `/docs` folder

## 🤝 **Support**

- **Issues**: Create a GitHub issue
- **Documentation**: Check the `/docs` folder
- **API Help**: Visit http://localhost:5173/api/health for status

---

**🏆 Ready to dominate your AFL Fantasy league with AI-powered insights!**
