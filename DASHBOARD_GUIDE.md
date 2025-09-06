# 📊 AFL Fantasy Platform - Dashboard Guide

## 🎯 **Dashboard Overview**

Your AFL Fantasy platform now has comprehensive dashboard support for all major operations. Here's how to use them:

## 🚀 **Main Status Dashboard**

### **Live Dashboard (Recommended)**
- **URL**: `http://localhost:8080/status.html`  
- **Access**: Auto-started when server is running
- **Features**: Real-time API calls, live updates, interactive

### **Local Dashboard (Fallback)**
- **URL**: `file://status.html`
- **Access**: Works even when server is offline
- **Features**: Static display, manual refresh needed

## 🛠️ **Script Commands & Their Dashboards**

### 1. **Setup Process** - `./setup.sh`
- **Dashboard**: Opens `setup-dashboard.html` automatically
- **Shows**: Animated progress through setup steps
- **Features**: Progress bars, step-by-step tracking, completion summary

### 2. **Platform Launch** - `./start.sh`  
- **Dashboard**: Automatically opens live status dashboard after 5 seconds
- **URL**: `http://localhost:8080/status.html`
- **Features**: Real-time service monitoring, health checks

### 3. **Status Check** - `./status.sh`
- **Action**: Opens the appropriate dashboard based on server status
- **Live**: `http://localhost:8080/status.html` (if server running)
- **Local**: `file://status.html` (if server offline)

### 4. **Port Cleanup** - `./fix-ports.sh`
- **Dashboard**: Enhanced terminal output with port cleanup summary
- **Shows**: Processes killed, port status, next steps
- **Features**: Color-coded status, process details with PIDs

### 5. **Testing** - `./test.sh`
- **Dashboard**: Comprehensive test results summary
- **Shows**: Test coverage, pass/fail status, timestamps
- **Features**: Professional test reporting, next steps guidance

### 6. **Quick Status** - `./check-status.sh`
- **Dashboard**: Terminal-based status report
- **Shows**: Service status, health details, quick links
- **Features**: Automatically detects live vs local dashboard URLs

## 🌟 **Dashboard Features**

### **Live Status Dashboard** (`/status`)
- ✅ **Real-time Updates**: Auto-refreshes every 30 seconds
- 🌐 **Web Application Status**: Connection and response time
- 🔌 **API Health Monitoring**: Service health, uptime, memory usage  
- 🧠 **AI & Analytics**: Player count, fixtures, tool availability
- 📱 **iOS App Info**: Build status and platform details
- 📋 **Live Logs**: Real-time system logs with filtering
- 🔄 **Manual Refresh**: Force refresh button
- 📊 **Interactive Elements**: Clickable links to services

### **Setup Dashboard** (`setup-dashboard.html`)
- 📈 **Progress Tracking**: Visual progress bar
- ⚡ **Live Updates**: Each step shows progress in real-time
- 🎨 **Beautiful UI**: Animated transitions and status indicators
- 🔗 **Navigation**: Links to main dashboard when complete

## 🎯 **Best Practices**

### **For Development**
1. Always start with `./setup.sh` for first-time setup
2. Use `./start.sh` for daily development - opens dashboard automatically
3. Use `./status.sh` anytime to check current status
4. Use `./fix-ports.sh` if you encounter port conflicts

### **For Troubleshooting**  
1. Run `./check-status.sh` for quick CLI-based status report
2. Check the live dashboard at `http://localhost:8080/status.html` for detailed info
3. Use the logs panel in the dashboard for real-time debugging
4. Run `./test.sh` for comprehensive testing with dashboard output

## 🔧 **Technical Details**

### **CORS Solution**
- Status dashboard is served from a separate HTTP server on port 8080
- Eliminates CORS issues that occur with `file://` URLs
- Allows proper API calls for real-time updates

### **Fallback System**  
- Automatically detects if server is running
- Uses live dashboard when available, falls back to local file
- All scripts intelligently choose the right dashboard URL

### **Auto-Opening**
- Cross-platform browser detection (macOS, Linux, Windows)
- Graceful fallback to manual URL display if browser can't be detected
- Smart timing (waits for server startup before opening)

## 🌐 **Dashboard URLs Quick Reference**

| Service | URL | Purpose |
|---------|-----|---------|
| **Live Status Dashboard** | `http://localhost:8080/status.html` | Real-time platform monitoring |
| **Web Application** | `http://localhost:5173` | Main app interface |
| **API Health Check** | `http://localhost:5173/api/health` | Service health endpoint |
| **Setup Progress** | `file://setup-dashboard.html` | First-time setup tracking |
| **Local Status (Backup)** | `file://status.html` | Offline status dashboard |

## 🎉 **Getting Started**

1. **First Time**: Run `./setup.sh` - opens setup progress dashboard
2. **Daily Development**: Run `./start.sh` - automatically opens live dashboard  
3. **Quick Check**: Run `./check-status.sh` - shows status summary
4. **Deep Monitoring**: Visit `http://localhost:8080/status.html` directly

All dashboards are designed to be professional, informative, and beautiful - giving you instant visibility into your AFL Fantasy platform's status and health!
