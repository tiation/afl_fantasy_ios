#!/usr/bin/env python3
"""
Fix team assignments for players showing incorrect teams
"""

import json

def fix_team_assignments():
    """Fix specific team assignment issues"""
    print("Fixing team assignments...")
    
    # Load current data
    with open('player_data_stats_enhanced_20250720_205845.json', 'r') as f:
        players = json.load(f)
    
    # Corrections needed
    corrections = {
        'G Hewett': 'Carlton',  # Not West Coast
        'J Dawson': 'Adelaide',  # Should be MID not DEF
        'N Wanganeen-Milera': 'St Kilda',  # Keep as DEF
        'B Smith': 'Geelong',  # Keep as Mid,Fwd
        'H Sheezel': 'North Melbourne'
    }
    
    updates_made = 0
    
    for player in players:
        name = player['name']
        
        if name in corrections:
            old_team = player['team']
            new_team = corrections[name]
            
            if old_team != new_team:
                print(f"Updating {name}: {old_team} -> {new_team}")
                player['team'] = new_team
                updates_made += 1
    
    print(f"Made {updates_made} team corrections")
    
    # Save corrected data
    with open('player_data_stats_enhanced_20250720_205845.json', 'w') as f:
        json.dump(players, f, indent=2)
    
    with open('player_data.json', 'w') as f:
        json.dump(players, f, indent=2)
    
    # Verify corrections
    key_players = ['G Hewett', 'J Dawson', 'N Wanganeen-Milera', 'B Smith', 'C Daniel', 'C Rozee']
    print(f"\nVerified team assignments:")
    for name in key_players:
        for player in players:
            if player['name'] == name:
                print(f"  {name}: {player['team']} {player['position']} ${player['price']:,}")
                break
    
    print("Team assignments corrected!")

if __name__ == "__main__":
    fix_team_assignments()