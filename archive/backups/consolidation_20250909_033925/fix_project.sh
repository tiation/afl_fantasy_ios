#!/bin/bash
set -euo pipefail

# Ensure proper directory structure
mkdir -p AFLFantasy/{Views,Core,Models,Networking,Storage,Utils,Services,Features/{Dashboard,Captain,Settings,CashCow,Players,Trades},Components}

# Get all .swift files
find AFLFantasy -name "*.swift" -type f > /tmp/all_files.txt

# Fix file paths
while IFS= read -r file; do
    # Extract directory name
    dir=$(dirname "$file")
    # Extract filename
    filename=$(basename "$file")
    
    # Move files to proper directories based on naming
    if [[ $filename == *"View.swift" || $filename == *"ViewModel.swift" ]]; then
        feature_dir="Views"
        if [[ $filename == *"Dashboard"* ]]; then
            feature_dir="Features/Dashboard"
        elif [[ $filename == *"Captain"* ]]; then
            feature_dir="Features/Captain"
        elif [[ $filename == *"Settings"* ]]; then
            feature_dir="Features/Settings"
        elif [[ $filename == *"CashCow"* ]]; then
            feature_dir="Features/CashCow"
        elif [[ $filename == *"Player"* ]]; then
            feature_dir="Features/Players"
        elif [[ $filename == *"Trade"* ]]; then
            feature_dir="Features/Trades"
        fi
        mkdir -p "AFLFantasy/$feature_dir"
        mv "$file" "AFLFantasy/$feature_dir/$filename"
    elif [[ $filename == *"Model"* || $filename == *"Type"* || $filename == *"State"* ]]; then
        mv "$file" "AFLFantasy/Models/$filename"
    elif [[ $filename == *"Service"* || $filename == *"Manager"* || $filename == *"Client"* ]]; then
        mv "$file" "AFLFantasy/Services/$filename"
    elif [[ $filename == *"Network"* || $filename == *"API"* || $filename == *"Endpoint"* ]]; then
        mv "$file" "AFLFantasy/Networking/$filename"
    elif [[ $filename == *"Storage"* || $filename == *"Store"* || $filename == *"Cache"* ]]; then
        mv "$file" "AFLFantasy/Storage/$filename"
    elif [[ $dir == *"Core"* || $filename == *"Core"* ]]; then
        mv "$file" "AFLFantasy/Core/$filename"
    elif [[ $filename == *"Helper"* || $filename == *"Util"* ]]; then
        mv "$file" "AFLFantasy/Utils/$filename"
    elif [[ $filename == *"Component"* || $dir == *"Components"* ]]; then
        mv "$file" "AFLFantasy/Components/$filename"
    fi
done < /tmp/all_files.txt

# Remove empty directories
find AFLFantasy -type d -empty -delete

echo "Project files reorganized"
