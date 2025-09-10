#!/usr/bin/env python3
"""
Fix the dtlive parsing to get the correct AFL Fantasy positions
"""

import pandas as pd
import json
import datetime

def parse_dtlive_correctly():
    """Parse the dtlive file correctly to get AFL Fantasy positions"""
    print("Parsing dtlive file correctly for AFL Fantasy positions...")
    
    # Read the dtlive file - Table 1 has the data
    dtlive_file = 'attached_assets/dtlive_1752999476691.xlsx'
    
    # Read without header first to see the structure
    df_raw = pd.read_excel(dtlive_file, sheet_name='Table 1', header=None)
    print("Raw data structure:")
    print(df_raw.head(5).to_string())
    
    # The actual header is in row 0, data starts from row 1
    df = pd.read_excel(dtlive_file, sheet_name='Table 1', header=0)
    
    print(f"\nProcessed {len(df)} rows")
    print(f"Columns: {list(df.columns)}")
    
    # Show first few rows to understand the data
    print("\nFirst 5 rows of processed data:")
    print(df.head(5).to_string())
    
    position_mapping = {}
    
    # Process each row - the data might be structured differently
    for index, row in df.iterrows():
        try:
            # Skip header row or empty rows
            if pd.isna(row.iloc[1]) or str(row.iloc[1]).strip() == '' or str(row.iloc[1]) == 'Player':
                continue
            
            player_name = str(row.iloc[1]).strip()  # Column 2 is Player
            afl_position = str(row.iloc[2]).strip()  # Column 3 is Position
            
            if player_name and afl_position and afl_position != 'nan':
                position_mapping[player_name] = afl_position
                
        except Exception as e:
            print(f"Error processing row {index}: {e}")
            continue
    
    print(f"\nCreated position mapping for {len(position_mapping)} players")
    
    # Show key mappings
    key_players = ['C Rozee', 'C Daniel', 'B Smith', 'J Dawson', 'N Wanganeen-Milera']
    print(f"\nKey AFL Fantasy Positions from dtlive:")
    for name in key_players:
        if name in position_mapping:
            print(f"  {name}: {position_mapping[name]}")
        else:
            # Try variations
            for mapped_name in position_mapping.keys():
                if name.split()[-1] in mapped_name or mapped_name.split()[-1] in name:
                    print(f"  {name} (found as {mapped_name}): {position_mapping[mapped_name]}")
                    break
    
    return position_mapping

def apply_dtlive_positions():
    """Apply the dtlive AFL Fantasy positions to our player database"""
    position_mapping = parse_dtlive_correctly()
    
    if not position_mapping:
        print("No position mapping found")
        return
    
    # Load current player data
    with open('player_data_stats_enhanced_20250720_205845.json', 'r') as f:
        players = json.load(f)
    
    updates_made = 0
    
    for player in players:
        player_name = player['name']
        
        # Direct match first
        if player_name in position_mapping:
            old_position = player['position']
            new_position = position_mapping[player_name]
            
            if old_position != new_position:
                print(f"Updating {player_name}: {old_position} -> {new_position}")
                player['position'] = new_position
                updates_made += 1
        else:
            # Try partial matches for names like "C Rozee" vs "Connor Rozee"
            for mapped_name in position_mapping.keys():
                if (player_name.split()[-1] == mapped_name.split()[-1] and 
                    player_name.split()[0][0] == mapped_name.split()[0][0]):
                    old_position = player['position']
                    new_position = position_mapping[mapped_name]
                    
                    if old_position != new_position:
                        print(f"Updating {player_name} (matched {mapped_name}): {old_position} -> {new_position}")
                        player['position'] = new_position
                        updates_made += 1
                    break
    
    print(f"\nMade {updates_made} position updates")
    
    # Save updated data
    with open('player_data_stats_enhanced_20250720_205845.json', 'w') as f:
        json.dump(players, f, indent=2)
    
    with open('player_data.json', 'w') as f:
        json.dump(players, f, indent=2)
    
    print("AFL Fantasy positions updated successfully!")

if __name__ == "__main__":
    apply_dtlive_positions()