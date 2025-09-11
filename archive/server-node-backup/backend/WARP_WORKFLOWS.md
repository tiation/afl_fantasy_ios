# 🏈 AFL Fantasy iOS Backend - Warp Workflows

## Updated Workflow Commands

```yaml
# 🚀 Start AFL Fantasy Backend Server
afl_fantasy_start:
  name: "🚀 Start AFL Fantasy Backend"
  command: "cd ~/workspace/10_projects/afl_fantasy_ios/backend && ./start_server.sh"
  description: "Start the AFL Fantasy Trade API server on port 9001"

# ⚡ Quick Backend Health Check
afl_fantasy_health:
  name: "⚡ AFL Fantasy Health Check" 
  command: "curl http://127.0.0.1:9001/health"
  description: "Test if AFL Fantasy backend is running and healthy"

# 📊 Test Trade Score API
afl_fantasy_test_trade:
  name: "📊 Test Trade Score API"
  command: "curl -X POST http://127.0.0.1:9001/api/trade_score -H 'Content-Type: application/json' -d '{\"player_in\": {\"price\": 1100000, \"breakeven\": 114, \"proj_scores\": [125, 122, 118, 130, 120], \"is_red_dot\": false}, \"player_out\": {\"price\": 930000, \"breakeven\": 120, \"proj_scores\": [105, 110, 102, 108, 104], \"is_red_dot\": false}, \"round_number\": 13, \"team_value\": 15800000, \"league_avg_value\": 15200000}'"
  description: "Test the trade analysis endpoint with sample data"

# 🔄 Refresh AFL Fantasy Data
afl_fantasy_refresh:
  name: "🔄 Refresh AFL Fantasy Data"
  command: "curl -X POST http://127.0.0.1:9001/api/afl-fantasy/refresh"
  description: "Force refresh of live AFL Fantasy data (requires credentials)"

# 📱 Get Dashboard Data
afl_fantasy_dashboard:
  name: "📱 AFL Fantasy Dashboard"
  command: "curl http://127.0.0.1:9001/api/afl-fantasy/dashboard-data"
  description: "Get complete dashboard data (team value, score, rank, captain)"

# ⚙️ Setup Environment Variables
afl_fantasy_setup_env:
  name: "⚙️ Setup AFL Fantasy Environment"
  command: "cd ~/workspace/10_projects/afl_fantasy_ios && ./setup_env.sh"
  description: "Create .env file with placeholders for AFL Fantasy credentials"

# 📋 View Server Logs
afl_fantasy_logs:
  name: "📋 AFL Fantasy Server Logs"
  command: "tail -f /tmp/afl_fantasy_server.log"
  description: "View real-time server logs"

# 🛑 Stop AFL Fantasy Backend
afl_fantasy_stop:
  name: "🛑 Stop AFL Fantasy Backend"
  command: "lsof -t -i:9001 | head -1 | xargs -r kill"
  description: "Stop the AFL Fantasy backend server running on port 9001"

# 🔧 Backend Development Mode
afl_fantasy_dev:
  name: "🔧 AFL Fantasy Development Mode"
  command: "cd ~/workspace/10_projects/afl_fantasy_ios/backend/python && source ../../venv/bin/activate && python api/trade_api.py"
  description: "Run server in development mode (with console output)"

# 📦 Install Backend Dependencies
afl_fantasy_install_deps:
  name: "📦 Install AFL Fantasy Dependencies"
  command: "cd ~/workspace/10_projects/afl_fantasy_ios && source venv/bin/activate && pip install flask flask-cors numpy requests beautifulsoup4 selenium lxml"
  description: "Install required Python packages for the backend"

# 🧪 Run All Backend Tests
afl_fantasy_test_all:
  name: "🧪 AFL Fantasy Full Test Suite"
  command: "cd ~/workspace/10_projects/afl_fantasy_ios && curl http://127.0.0.1:9001/health && echo '\\n' && curl -X POST http://127.0.0.1:9001/api/trade_score -H 'Content-Type: application/json' -d '{\"player_in\": {\"price\": 1100000, \"breakeven\": 114, \"proj_scores\": [125, 122, 118, 130, 120], \"is_red_dot\": false}, \"player_out\": {\"price\": 930000, \"breakeven\": 120, \"proj_scores\": [105, 110, 102, 108, 104], \"is_red_dot\": false}, \"round_number\": 13, \"team_value\": 15800000, \"league_avg_value\": 15200000}' | python3 -m json.tool"
  description: "Run comprehensive backend API tests with formatted output"

# 🔍 Check Backend Status
afl_fantasy_status:
  name: "🔍 AFL Fantasy Backend Status"
  command: "echo 'Server Process:' && ps aux | grep trade_api | grep -v grep || echo 'No server running' && echo '\\nPort 9001 Status:' && lsof -i:9001 || echo 'Port 9001 is free' && echo '\\nServer Health:' && curl -s http://127.0.0.1:9001/health || echo 'Server not responding'"
  description: "Comprehensive status check for backend server"

# 📚 Open API Documentation
afl_fantasy_docs:
  name: "📚 Open AFL Fantasy API Docs"
  command: "open ~/workspace/10_projects/afl_fantasy_ios/backend/API_DOCUMENTATION.md"
  description: "Open the complete API documentation in your default editor"
```

## Quick Setup Instructions

1. **First Time Setup:**
   ```bash
   # Run this once to set up environment
   afl_fantasy_setup_env
   ```

2. **Start Development:**
   ```bash
   # Start the server
   afl_fantasy_start
   
   # Test it's working
   afl_fantasy_health
   ```

3. **Development Workflow:**
   ```bash
   # Check status
   afl_fantasy_status
   
   # View logs
   afl_fantasy_logs
   
   # Test APIs
   afl_fantasy_test_all
   ```

## Key Changes from Original Workflow

- **Port changed**: `8001` → `9001`
- **Updated script path**: Now uses `./start_server.sh` for cleaner startup
- **Added comprehensive testing**: Multiple test commands for different scenarios
- **Environment setup**: Dedicated command for credential configuration
- **Better status monitoring**: Enhanced status checking with process and port info

## Environment Setup

Before using AFL Fantasy data endpoints, run:

```bash
afl_fantasy_setup_env
```

Then edit the generated `.env` file with your actual AFL Fantasy credentials:
- `AFL_FANTASY_TEAM_ID` - Your team ID
- `AFL_FANTASY_SESSION_COOKIE` - Your session cookie
- `AFL_FANTASY_API_TOKEN` - Your API token (if available)

## Troubleshooting Commands

```bash
# If server won't start (port conflict)
afl_fantasy_stop

# If missing dependencies
afl_fantasy_install_deps

# If server is unresponsive
afl_fantasy_status
```
