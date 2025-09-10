#!/usr/bin/env python3
"""
Fix specific Hewett player issue
George Hewett should be Carlton, Elijah Hewett should be West Coast
"""

import json

def fix_hewett_players():
    """Fix the Hewett player team assignments"""
    print("Fixing Hewett player team assignments...")
    
    # Load current data
    with open('player_data_stats_enhanced_20250720_205845.json', 'r') as f:
        players = json.load(f)
    
    for player in players:
        name = player.get('name', '')
        
        if 'hewett' in name.lower():
            print(f"Found Hewett player: {name} - {player.get('team', 'Unknown')}")
            
            # Fix George Hewett - should be Carlton
            if name.lower() in ['g hewett', 'george hewett', 'g. hewett']:
                if player.get('team') != 'Carlton':
                    print(f"Fixing George Hewett: {player.get('team')} -> Carlton")
                    player['team'] = 'Carlton'
                    player['position'] = 'MID'
            
            # Fix Elijah Hewett - should be West Coast  
            elif name.lower() in ['e hewett', 'elijah hewett', 'e. hewett']:
                if player.get('team') != 'West Coast':
                    print(f"Fixing Elijah Hewett: {player.get('team')} -> West Coast")
                    player['team'] = 'West Coast'
                    player['position'] = 'MID'
    
    # Save updated data
    with open('player_data_stats_enhanced_20250720_205845.json', 'w') as f:
        json.dump(players, f, indent=2)
    
    with open('player_data.json', 'w') as f:
        json.dump(players, f, indent=2)
    
    print("Hewett player fixes completed!")

if __name__ == "__main__":
    fix_hewett_players()