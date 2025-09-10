#!/usr/bin/env python3
"""
Fix Caleb Daniel's position to MID/FWD
"""

import json

def fix_caleb_daniel():
    """Fix Caleb Daniel's position"""
    print("Fixing Caleb Daniel's position...")
    
    # Load current data
    with open('player_data_stats_enhanced_20250720_205845.json', 'r') as f:
        players = json.load(f)
    
    for player in players:
        if player['name'] == 'Caleb Daniel':
            print(f"Correcting Caleb Daniel:")
            print(f"  Position: {player['position']} -> MID/FWD")
            player['position'] = 'MID/FWD'
            break
    
    # Save corrected data
    with open('player_data_stats_enhanced_20250720_205845.json', 'w') as f:
        json.dump(players, f, indent=2)
    
    with open('player_data.json', 'w') as f:
        json.dump(players, f, indent=2)
    
    print("Caleb Daniel position corrected to MID/FWD")

if __name__ == "__main__":
    fix_caleb_daniel()