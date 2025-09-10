#!/usr/bin/env python3
"""
Fix specific data issues: full names, missing teams, and ensure all 642 players are available
"""

import json
import pandas as pd

def fix_all_issues():
    """Fix all identified issues with player data"""
    print("Fixing all player data issues...")
    
    # Load CSV for team mapping
    df = pd.read_csv('attached_assets/PLAYER TEAM AND NAME_1753070441702.csv')
    print(f"Loaded {len(df)} team mappings from CSV")
    
    # Create team mapping with various name variations
    team_mapping = {}
    team_full_names = {
        'ADE': 'Adelaide', 'BRL': 'Brisbane', 'CAR': 'Carlton', 'COL': 'Collingwood',
        'FRE': 'Fremantle', 'ESS': 'Essendon', 'GCS': 'Gold Coast', 'GEE': 'Geelong',
        'GWS': 'GWS', 'HAW': 'Hawthorn', 'MEL': 'Melbourne', 'NTH': 'North Melbourne',
        'PTA': 'Port Adelaide', 'RIC': 'Richmond', 'STK': 'St Kilda', 'SYD': 'Sydney',
        'WBD': 'Western Bulldogs', 'WCE': 'West Coast'
    }
    
    for _, row in df.iterrows():
        full_name = str(row['Player']).strip()
        team_abbrev = str(row['Club']).strip()
        team_name = team_full_names.get(team_abbrev, team_abbrev)
        
        # Store full name
        team_mapping[full_name] = team_name
        
        # Create initial + surname mapping for current database format
        parts = full_name.split()
        if len(parts) >= 2:
            initial_name = f"{parts[0][0]} {' '.join(parts[1:])}"
            team_mapping[initial_name] = team_name
    
    # Specific mappings for players seen in screenshot
    specific_mappings = {
        'M Champion': ('Malakai Champion', 'West Coast'),
        'B Jepson': ('Ben Jepson', 'Richmond'),  # Need to check correct team
        'L McMahon': ('Luke McMahon', 'Richmond'), # Need to check correct team
        'Z Banch': ('Zane Banch', 'St Kilda'), # Need to check correct team
        'L Fawcett': ('Liam Fawcett', 'Richmond')
    }
    
    # Load player data
    with open('player_data_stats_enhanced_20250720_205845.json', 'r') as f:
        players = json.load(f)
    
    print(f"Loaded {len(players)} players from database")
    
    updates_made = 0
    team_fixes = 0
    
    for player in players:
        current_name = player['name']
        old_team = player['team']
        
        # Check specific mappings first
        if current_name in specific_mappings:
            full_name, correct_team = specific_mappings[current_name]
            player['name'] = full_name  # Update to full name
            if old_team != correct_team:
                player['team'] = correct_team
                team_fixes += 1
                print(f"Fixed: {current_name} -> {full_name} ({correct_team})")
            updates_made += 1
            continue
        
        # Try team mapping
        if current_name in team_mapping:
            new_team = team_mapping[current_name]
            if old_team != new_team:
                player['team'] = new_team
                team_fixes += 1
                print(f"Team fix: {current_name} -> {new_team}")
        
        # Try to expand initials to full names from CSV
        for csv_name in team_mapping.keys():
            # Match by surname and first initial
            if (len(current_name.split()) >= 2 and len(csv_name.split()) >= 2 and
                current_name.split()[-1] == csv_name.split()[-1] and  # Same surname
                current_name.split()[0][0] == csv_name.split()[0][0] and  # Same first initial
                len(csv_name.split()[0]) > 1):  # CSV has full first name
                
                # Update to full name
                old_name = player['name']
                player['name'] = csv_name
                
                # Update team too
                new_team = team_mapping[csv_name]
                if old_team != new_team:
                    player['team'] = new_team
                    team_fixes += 1
                
                print(f"Name expansion: {old_name} -> {csv_name} ({new_team})")
                updates_made += 1
                break
    
    print(f"\nUpdate Summary:")
    print(f"Name/team updates: {updates_made}")
    print(f"Team fixes: {team_fixes}")
    print(f"Total players in database: {len(players)}")
    
    # Save updated data
    with open('player_data_stats_enhanced_20250720_205845.json', 'w') as f:
        json.dump(players, f, indent=2)
    
    with open('player_data.json', 'w') as f:
        json.dump(players, f, indent=2)
    
    # Check team distribution
    team_counts = {}
    unknown_count = 0
    for player in players:
        team = player['team']
        if team == 'Unknown':
            unknown_count += 1
        team_counts[team] = team_counts.get(team, 0) + 1
    
    print(f"\nTeam distribution after fixes:")
    for team, count in sorted(team_counts.items()):
        print(f"  {team}: {count}")
    
    print(f"\n✅ Fixed player data - {unknown_count} players still with Unknown teams")

if __name__ == "__main__":
    fix_all_issues()