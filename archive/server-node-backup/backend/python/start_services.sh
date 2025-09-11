#!/bin/bash

# AFL Fantasy Backend Services Startup Script
# This script starts both the player data scraper and the Flask API server

# Set the base directory
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$BASE_DIR"

# Create logs directory if it doesn't exist
mkdir -p logs

# Activate the virtual environment if it exists
if [ -f "../../venv/bin/activate" ]; then
    echo "📦 Activating virtual environment..."
    source ../../venv/bin/activate
else
    echo "⚠️ Virtual environment not found. Using system Python."
fi

# Check if Python and required packages are available
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 not found. Please install Python 3."
    exit 1
fi

# Check if required packages are installed
echo "🔍 Checking required packages..."
PACKAGES=("flask" "flask-cors" "pandas" "selenium" "beautifulsoup4" "numpy")
MISSING_PACKAGES=()

for package in "${PACKAGES[@]}"; do
    python3 -c "import $package" 2>/dev/null || MISSING_PACKAGES+=("$package")
done

if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
    echo "⚠️ Missing packages: ${MISSING_PACKAGES[*]}"
    echo "Installing missing packages..."
    pip install ${MISSING_PACKAGES[*]}
fi

# Start the player scraper in the background
echo "🔄 Preparing player data scraper..."
mkdir -p scrapers/dfs_player_summary

# Check if the Excel file exists
if [ ! -f "AFL_Fantasy_Player_URLs.xlsx" ]; then
    echo "⚠️ AFL_Fantasy_Player_URLs.xlsx not found. Will use mock data."
    # Create a simple example file
    cat > scrapers/README.md << EOF
# AFL Player Data Scraper

To use the real player data scraper, you need an Excel file with player URLs.
Create a file named 'AFL_Fantasy_Player_URLs.xlsx' with columns:
- playerId (string): Unique identifier for the player
- url (string): URL to the player's AFL Fantasy page

For now, mock data will be used.
EOF
fi

# Start the Flask API server
echo "🚀 Starting AFL Fantasy API server..."
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
nohup python api/trade_api.py > "logs/api_server_${TIMESTAMP}.log" 2>&1 &
API_PID=$!

echo "✅ Services started successfully!"
echo "📝 API server log: logs/api_server_${TIMESTAMP}.log"
echo "🌐 API server running at: http://127.0.0.1:9001"
echo "🛑 To stop services: kill $API_PID"

# Save the PID for later use
echo $API_PID > .api_server.pid

# Helpful commands to check status
echo -e "\n📋 Useful commands:"
echo "  curl http://127.0.0.1:9001/health               # Check if API is running"
echo "  curl http://127.0.0.1:9001/api/players          # Get all players"
echo "  curl http://127.0.0.1:9001/api/cash-cows        # Get cash cow analysis"
echo "  kill \$(cat .api_server.pid)                     # Stop the API server"
