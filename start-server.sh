#!/usr/bin/env bash
# AFL Fantasy - Single Backend Startup

echo "🏆 Starting AFL Fantasy Server (Python Only)"
echo "============================================="

# Activate virtual environment if it exists
if [ -d "venv" ]; then
    source venv/bin/activate
    echo "✅ Virtual environment activated"
fi

# Install/update requirements
cd server-python
pip install -r requirements.txt

# Start the unified Python server
echo "🚀 Starting server on http://localhost:8080"
python api_server.py
