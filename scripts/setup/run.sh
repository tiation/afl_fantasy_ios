#!/bin/bash

# Start the scheduler in background
echo "Starting AFL Fantasy data scheduler..."
if ! pgrep -f "python scheduler.py" > /dev/null; then
    nohup python scheduler.py > scheduler_output.log 2>&1 &
    echo "Scheduler started. PID: $!"
else
    echo "Scheduler is already running."
fi

# Start the main application
echo "Starting main application..."
npm run dev