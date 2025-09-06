#!/usr/bin/env python3
"""
Debug the team assignment issue by checking what's actually in the JSON
"""

import json

def debug_teams():
    """Debug team assignments"""
    print("Debugging team assignments...")
    
    # Load current data
    with open('player_data_stats_enhanced_20250720_205845.json', 'r') as f:
        players = json.load(f)
    
    # Check key players
    key_names = ['J Dawson', 'G Hewett', 'B Smith', 'C Rozee', 'C Daniel', 'H Sheezel']
    
    print("Current data in JSON:")
    for name in key_names:
        for player in players:
            if player['name'] == name:
                print(f"  {name}: {player['team']} {player['position']} ${player['price']:,}")
                break
        else:
            print(f"  {name}: NOT FOUND")
    
    # Also check full names
    print("\nChecking full names:")
    full_names = ['Jordan Dawson', 'George Hewett', 'Bailey Smith', 'Connor Rozee', 'Caleb Daniel', 'Harry Sheezel']
    for name in full_names:
        for player in players:
            if player['name'] == name:
                print(f"  {name}: {player['team']} {player['position']} ${player['price']:,}")
                break
    
    # Fix the teams directly
    corrections = [
        ('J Dawson', 'Adelaide'),
        ('G Hewett', 'Carlton'),
        ('Jordan Dawson', 'Adelaide'),
        ('George Hewett', 'Carlton')
    ]
    
    updates_made = 0
    for player in players:
        for name, correct_team in corrections:
            if player['name'] == name and player['team'] != correct_team:
                print(f"FIXING: {name} from {player['team']} to {correct_team}")
                player['team'] = correct_team
                updates_made += 1
    
    print(f"Made {updates_made} direct corrections")
    
    # Save corrected data
    if updates_made > 0:
        with open('player_data_stats_enhanced_20250720_205845.json', 'w') as f:
            json.dump(players, f, indent=2)
        
        with open('player_data.json', 'w') as f:
            json.dump(players, f, indent=2)
        
        print("Saved corrections to files")

if __name__ == "__main__":
    debug_teams()