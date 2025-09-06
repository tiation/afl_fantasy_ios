#!/bin/bash

# This script sets up and starts the cash tools API for AFL Fantasy

echo "Setting up the Cash Tools API..."

# Make sure all the python scripts are executable
chmod +x cash_api.py
chmod +x cash_tools.py
chmod +x scraper.py

# Start the API
echo "Starting the Cash Tools API..."
python cash_api.py > cash_api.log 2>&1 &

# Wait a moment to ensure the API starts
sleep 2

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
fi

echo "Setup complete!"