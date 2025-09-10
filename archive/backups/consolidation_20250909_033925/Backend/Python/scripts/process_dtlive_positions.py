#!/usr/bin/env python3
"""
Process AFL Fantasy positions from the dtlive file
This contains the correct AFL Fantasy positions (not game positions)
"""

import pandas as pd
import json
import datetime

def process_dtlive_afl_fantasy_positions():
    """Get AFL Fantasy positions from dtlive file"""
    print("Processing AFL Fantasy positions from dtlive file...")
    
    # Read the dtlive file with correct AFL Fantasy positions
    dtlive_file = 'attached_assets/dtlive_1752999476691.xlsx'
    
    # Read Table 1 which has the AFL Fantasy positions
    df = pd.read_excel(dtlive_file, sheet_name='Table 1', header=1)
    
    print(f"Loaded {len(df)} players from dtlive Table 1")
    print(f"Columns: {list(df.columns)}")
    
    # Create position mapping from dtlive data
    position_mapping = {}
    
    for index, row in df.iterrows():
        try:
            if pd.isna(row.get('Player')) or row.get('Player') == '':
                continue
                
            player_name = str(row['Player']).strip()
            afl_fantasy_position = str(row['Position']).strip() if pd.notna(row.get('Position')) else 'MID'
            
            position_mapping[player_name] = afl_fantasy_position
            
        except Exception as e:
            print(f"Error processing row {index}: {e}")
            continue
    
    print(f"Created position mapping for {len(position_mapping)} players")
    
    # Show some key position mappings
    key_players = ['C Rozee', 'C Daniel', 'B Smith', 'J Dawson', 'N Wanganeen-Milera']
    print(f"\nKey AFL Fantasy Positions:")
    for name in key_players:
        if name in position_mapping:
            print(f"  {name}: {position_mapping[name]}")
    
    return position_mapping

def update_player_data_with_correct_positions():
    """Update the player database with correct AFL Fantasy positions"""
    print("\nUpdating player database with correct AFL Fantasy positions...")
    
    # Get position mapping from dtlive
    position_mapping = process_dtlive_afl_fantasy_positions()
    
    # Load current player data
    with open('player_data_stats_enhanced_20250720_205845.json', 'r') as f:
        players = json.load(f)
    
    updates_made = 0
    
    for player in players:
        player_name = player['name']
        
        # Check if we have a correct AFL Fantasy position for this player
        if player_name in position_mapping:
            old_position = player['position']
            new_position = position_mapping[player_name]
            
            if old_position != new_position:
                print(f"Updating {player_name}: {old_position} -> {new_position}")
                player['position'] = new_position
                updates_made += 1
    
    print(f"\nMade {updates_made} position updates")
    
    # Create backup
    backup_filename = f"player_data_backup_positions_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
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
    print(f"\nVerifying key player positions:")
    key_players = ['C Rozee', 'C Daniel', 'B Smith', 'J Dawson', 'N Wanganeen-Milera']
    for name in key_players:
        for player in players:
            if player['name'] == name:
                print(f"  {name}: {player['team']} {player['position']} ${player['price']:,}")
                break
    
    print(f"\nAFL Fantasy positions updated from authentic dtlive source!")

if __name__ == "__main__":
    update_player_data_with_correct_positions()