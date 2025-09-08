#!/bin/bash

echo "🏈 Starting AFL Fantasy API Server..."
echo "===========================================" 

cd /Users/tiaastor/workspace/10_projects/afl_fantasy_ios

# Activate virtual environment
source venv/bin/activate

# Start the API server
echo "🚀 Starting server on http://localhost:4000"
echo "Press Ctrl+C to stop the server"
echo "===========================================" 

python api_server.py
