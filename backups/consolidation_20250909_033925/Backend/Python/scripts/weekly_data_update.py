#!/usr/bin/env python3

import json
import csv
import os
import shutil
from datetime import datetime
import sys

def backup_current_data():
    """Create a timestamped backup of current data before replacement"""
    current_file = "player_data_stats_enhanced_20250720_205845.json"
    if not os.path.exists(current_file):
        print(f"Warning: {current_file} not found, skipping backup")
        return None
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_file = f"old_player_data_backup/player_data_backup_{timestamp}.json"
    
    # Create backup directory if it doesn't exist
    os.makedirs("old_player_data_backup", exist_ok=True)
    
    shutil.copy2(current_file, backup_file)
    print(f"✓ Backed up current data to: {backup_file}")
    return backup_file

def process_new_weekly_data(excel_file, team_mapping_csv):
    """Process new weekly AFL Fantasy data from Excel file"""
    
    if not os.path.exists(excel_file):
        print(f"Error: Excel file {excel_file} not found")
        print("Please upload the new weekly currentdt_liveR[X]_[timestamp].xlsx file")
        return False
    
    if not os.path.exists(team_mapping_csv):
        print(f"Error: Team mapping CSV {team_mapping_csv} not found")
        print("Please ensure the player team mapping CSV is available")
        return False
    
    # This would need pandas/openpyxl to process Excel files
    # For now, provide instructions for manual conversion
    print(f"""
    WEEKLY DATA UPDATE PROCESS:
    
    1. Excel Processing Required:
       - Convert {excel_file} to JSON format
       - Extract player data: name, team, position, price, averagePoints, breakEven, etc.
       - Save as JSON array format
    
    2. Team Mapping:
       - Apply corrections from {team_mapping_csv}
       - Ensure all team abbreviations are consistent (ADE, BRL, CAR, etc.)
    
    3. Data Validation:
       - Remove any fictional players
       - Eliminate duplicates (keep appropriate price for each player)
       - Verify all 18 AFL teams are represented
    
    4. File Replacement:
       - Replace player_data_stats_enhanced_20250720_205845.json with new data
       - Restart server to load fresh data
    """)
    
    return True

def clean_and_validate_data(data_file, team_mapping_csv):
    """Clean and validate the weekly data update"""
    
    # Load team mapping
    team_mapping = {}
    try:
        with open(team_mapping_csv, 'r') as f:
            reader = csv.DictReader(f)
            for row in reader:
                player_name = row['Player'].strip()
                team = row['Club'].strip()
                team_mapping[player_name] = team
        print(f"✓ Loaded {len(team_mapping)} team mappings")
    except Exception as e:
        print(f"Error loading team mapping: {e}")
        return False
    
    # Load and clean player data
    try:
        with open(data_file, 'r') as f:
            players = json.load(f)
        print(f"✓ Loaded {len(players)} players from {data_file}")
    except Exception as e:
        print(f"Error loading player data: {e}")
        return False
    
    # Clean data
    cleaned_players = []
    seen_players = set()
    team_updates = 0
    
    for player in players:
        name = player.get('name', '').strip()
        if not name or name in seen_players:
            continue
            
        # Apply team mapping if available
        if name in team_mapping:
            old_team = player.get('team', 'Unknown')
            new_team = team_mapping[name]
            if old_team != new_team:
                player['team'] = new_team
                team_updates += 1
        
        # Standardize team names
        team = player.get('team', '')
        if team == 'Richmond':
            player['team'] = 'RIC'
        elif team == 'St Kilda':
            player['team'] = 'STK'
        
        cleaned_players.append(player)
        seen_players.add(name)
    
    print(f"✓ Cleaned data: {len(cleaned_players)} unique players")
    print(f"✓ Applied {team_updates} team corrections")
    
    # Save cleaned data
    with open(data_file, 'w') as f:
        json.dump(cleaned_players, f, indent=2)
    
    print(f"✓ Saved cleaned data to {data_file}")
    return True

def weekly_data_update(new_excel_file=None, team_csv=None):
    """Complete weekly data update process"""
    
    print("=" * 60)
    print("AFL FANTASY WEEKLY DATA UPDATE")
    print("=" * 60)
    
    # Step 1: Backup current data
    backup_file = backup_current_data()
    
    # Step 2: Set default file paths if not provided
    if not team_csv:
        team_csv = "attached_assets/PLAYER TEAM AND NAME_1753070441702.csv"
    
    if not new_excel_file:
        print("\nLooking for new weekly Excel files...")
        # Look for new currentdt files
        excel_files = [f for f in os.listdir('.') if f.startswith('currentdt_liveR') and f.endswith('.xlsx')]
        if excel_files:
            new_excel_file = max(excel_files)  # Get most recent
            print(f"Found: {new_excel_file}")
        else:
            print("No new Excel files found. Please upload the weekly currentdt_liveR[X]_[timestamp].xlsx file")
            return False
    
    # Step 3: Process new data
    if process_new_weekly_data(new_excel_file, team_csv):
        print("\n✓ Weekly data update instructions provided")
        print("\nIMPORTANT: After replacing the JSON file, restart the server!")
        print("The new data will be loaded and all 630+ players will have fresh weekly stats.")
        return True
    
    return False

if __name__ == "__main__":
    # Can be called with custom file paths
    excel_file = sys.argv[1] if len(sys.argv) > 1 else None
    csv_file = sys.argv[2] if len(sys.argv) > 2 else None
    
    success = weekly_data_update(excel_file, csv_file)
    sys.exit(0 if success else 1)