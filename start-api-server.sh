#!/bin/bash
# AFL Fantasy API Server Starter
# Updated for reorganized project structure

cd "$(dirname "$0")"
echo "🏈 Starting AFL Fantasy API Server..."
echo "📁 Project root: $(pwd)"
echo "🐍 Server location: server-python/"
echo ""

cd server-python
echo "📂 Changed to server-python directory"
echo "🚀 Starting API server..."

# Check if virtual environment exists
if [ -d "../venv" ]; then
    echo "🔧 Activating virtual environment..."
    source ../venv/bin/activate
fi

# Install requirements if they don't exist
if [ ! -d "../venv/lib/python*/site-packages/flask" ]; then
    echo "📦 Installing Python requirements..."
    pip install -r requirements.txt
fi

echo "▶️ Running: python api_server.py"
echo ""
python api_server.py
