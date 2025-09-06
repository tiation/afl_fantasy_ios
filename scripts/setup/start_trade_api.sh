#!/bin/bash

# Kill any existing python processes running the trade_api.py
pkill -f "python trade_api.py" || true

# Start the Flask API
echo "Starting Flask API..."
python trade_api.py > trade_api.log 2>&1 &

# Wait for the API to start
sleep 2

# Print the status
echo "API should be running on http://localhost:5001"
echo "Check trade_api.log for any errors"