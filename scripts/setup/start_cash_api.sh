#!/bin/bash

# This script starts the cash tools API for AFL Fantasy
echo "Starting the Cash Tools API..."

# Kill any existing cash_api.py processes
pkill -f "python cash_api.py" || true

# Start the API with nohup to keep it running in the background
nohup python cash_api.py > cash_api.log 2>&1 &

# Wait a moment to ensure the API starts
sleep 3

# Check if the API is running
if pgrep -f "python cash_api.py" > /dev/null; then
    echo "✅ Cash Tools API running successfully on http://localhost:5001"
    echo "API endpoints available:"
    echo "  - GET /api/cash/generation_tracker"
    echo "  - GET /api/cash/rookie_price_curve"
    echo "  - GET /api/cash/downgrade_targets"
    echo "  - GET /api/cash/ceiling_floor"
    echo "  - POST /api/cash/price_predictor"
    echo "  - GET /api/cash/price_ceiling_floor"
else
    echo "❌ Failed to start Cash Tools API. Check cash_api.log for errors."
    cat cash_api.log
fi