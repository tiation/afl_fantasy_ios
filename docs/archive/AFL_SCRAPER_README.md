# AFL Fantasy Data Update System

This document explains how the automated data update system works for the AFL Fantasy Intelligence Platform.

## Overview

The platform needs fresh player data to provide accurate analysis. Our system fetches data from multiple sources and updates the central `player_data.json` file that powers all the tools.

## Automated Update Process

1. **Scheduler**: The system runs a background scheduler (`scheduler.py`) that refreshes player data every 12 hours.
2. **Data Sources**: We use a multi-source approach to ensure reliable data:
   - Primary: DFS Australia Fantasy Big Board API
   - Fallback: Process DraftStars slate data from CSV files
   - Last resort: Enhance existing data with newest available statistics
3. **Backup**: Before each update, a timestamped backup of the player data is created (e.g., `player_data_backup_20250501_201717.json`)

## Managing the Scheduler

### Starting the Scheduler
```bash
./start_scheduler.sh
```
This starts the scheduler as a background process that will run continuously.

### Checking Scheduler Status
```bash
python check_scheduler.py
```
This will tell you if the scheduler is currently running and show its process ID.

### Stopping the Scheduler
```bash
python check_scheduler.py stop
```
This sends a termination signal to the scheduler process.

### Running the Application with Scheduler
```bash
./run.sh
```
This script starts both the scheduler and the main application in one command.

## Manual Data Updates

If you need to update the data manually without waiting for the scheduler:

```bash
# Update from DFS Australia
python scraper.py --update-from-dfs

# Process DraftStars data (if you have a new CSV file)
python process_draftstars_data.py

# Enhance existing data with additional statistics
python enhance_player_data.py
```

## Troubleshooting

### Logs
- `scheduler.log` - Contains detailed logs from the scheduler
- `scheduler_output.log` - Contains output from the scheduler process

### Common Issues
- If the scheduler isn't running, check for error messages in the logs
- Make sure the required Python packages are installed (apscheduler, pandas, requests)
- If data isn't updating, check that the data sources are accessible

## Data Backup Retention

The system automatically keeps the 5 most recent backups of player data and removes older ones to prevent excessive disk usage.