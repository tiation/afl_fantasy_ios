#!/bin/bash

# Check if the scheduler is already running
if pgrep -f "python scheduler.py" > /dev/null; then
    echo "Scheduler is already running."
    exit 0
fi

# Start the scheduler in background
echo "Starting AFL Fantasy data scheduler..."
nohup python scheduler.py > scheduler_output.log 2>&1 &

# Check if successfully started
if [ $? -eq 0 ]; then
    echo "Scheduler started successfully. Process ID: $!"
    echo "Logs will be written to scheduler.log and scheduler_output.log"
else
    echo "Failed to start scheduler."
    exit 1
fi