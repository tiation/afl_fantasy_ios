#!/usr/bin/env python3
"""
Fix all team assignments using the provided CSV file with correct player names and teams
"""

import pandas as pd
import json
import datetime

def load_team_mapping_from_csv():
    """Load the correct team mapping from the provided CSV"""
    print("Loading team mapping from CSV...")
    
    # Read the CSV file
    df = pd.read_csv('attached_assets/PLAYER TEAM AND NAME_1753070441702.csv')
    
    print(f"Loaded {len(df)} player-team mappings from CSV")
    
    # Create team mapping dictionary
    team_mapping = {}
    
    # Team abbreviation to full name mapping
    team_full_names = {
        'ADE': 'Adelaide',
        'BRL': 'Brisbane',
        'CAR': 'Carlton',
        'COL': 'Collingwood',
        'FRE': 'Fremantle',
        'ESS': 'Essendon',
        'GCS': 'Gold Coast',
        'GEE': 'Geelong',
        'GWS': 'GWS',
        'HAW': 'Hawthorn',
        'MEL': 'Melbourne',
        'NTH': 'North Melbourne',
        'PTA': 'Port Adelaide',
        'RIC': 'Richmond',
        'STK': 'St Kilda',
        'SYD': 'Sydney',
        'WBD': 'Western Bulldogs',
        'WCE': 'West Coast'
    }
    
    for index, row in df.iterrows():
        player_name = str(row['Player']).strip()
        team_abbrev = str(row['Club']).strip()
        
        # Convert abbreviation to full team name
        full_team_name = team_full_names.get(team_abbrev, team_abbrev)
        team_mapping[player_name] = full_team_name
    
    print(f"Created team mapping for {len(team_mapping)} players")
    
    # Show some key mappings
    key_players = ['Connor Rozee', 'Caleb Daniel', 'Bailey Smith', 'Jordan Dawson', 'George Hewett']
    print(f"\nKey player teams from CSV:")
    for name in key_players:
        if name in team_mapping:
            print(f"  {name}: {team_mapping[name]}")
    
    return team_mapping

def update_all_teams():
    """Update all player teams using the CSV mapping"""
    print("\nUpdating all player teams with CSV data...")
    
    # Load team mapping
    team_mapping = load_team_mapping_from_csv()
    
    # Load current player data
    with open('player_data_stats_enhanced_20250720_205845.json', 'r') as f:
        players = json.load(f)
    
    updates_made = 0
    exact_matches = 0
    not_found = []
    
    for player in players:
        current_name = player['name']
        old_team = player['team']
        
        # Try exact match first
        if current_name in team_mapping:
            new_team = team_mapping[current_name]
            if old_team != new_team:
                print(f"Updating {current_name}: {old_team} -> {new_team}")
                player['team'] = new_team
                updates_made += 1
            exact_matches += 1
        else:
            # Try partial matches for name variations
            matched = False
            for csv_name in team_mapping.keys():
                # Match by surname and first initial
                if (len(current_name.split()) >= 2 and len(csv_name.split()) >= 2 and
                    current_name.split()[-1] == csv_name.split()[-1] and  # Same surname
                    current_name.split()[0][0] == csv_name.split()[0][0]):  # Same first initial
                    
                    new_team = team_mapping[csv_name]
                    if old_team != new_team:
                        print(f"Updating {current_name} (matched {csv_name}): {old_team} -> {new_team}")
                        player['team'] = new_team
                        updates_made += 1
                    matched = True
                    break
            
            if not matched:
                not_found.append(current_name)
    
    print(f"\nUpdate Summary:")
    print(f"Exact matches: {exact_matches}")
    print(f"Team updates made: {updates_made}")
    print(f"Players not found in CSV: {len(not_found)}")
    
    if not_found[:10]:  # Show first 10 not found
        print(f"Sample not found: {not_found[:10]}")
    
    # Create backup
    backup_filename = f"player_data_backup_teams_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    try:
        import shutil
        shutil.copy('player_data_stats_enhanced_20250720_205845.json', backup_filename)
        print(f"Created backup: {backup_filename}")
    except:
        print("Could not create backup")
    
    # Save updated data
    with open('player_data_stats_enhanced_20250720_205845.json', 'w') as f:
        json.dump(players, f, indent=2)
    
    with open('player_data.json', 'w') as f:
        json.dump(players, f, indent=2)
    
    # Verify key players
    print(f"\nVerifying key player teams:")
    key_players = ['Connor Rozee', 'Caleb Daniel', 'Bailey Smith', 'Jordan Dawson', 'George Hewett', 'Harry Sheezel']
    for name in key_players:
        for player in players:
            if player['name'] == name or name in player['name']:
                print(f"  {player['name']}: {player['team']} {player['position']} ${player['price']:,}")
                break
    
    # Count teams
    team_counts = {}
    for player in players:
        team = player['team']
        team_counts[team] = team_counts.get(team, 0) + 1
    
    print(f"\nTeam distribution:")
    for team, count in sorted(team_counts.items()):
        if team != 'Unknown':
            print(f"  {team}: {count} players")
    
    if 'Unknown' in team_counts:
        print(f"  Unknown: {team_counts['Unknown']} players")
    
    print(f"\n✅ All teams updated from authentic CSV data!")

if __name__ == "__main__":
    update_all_teams()