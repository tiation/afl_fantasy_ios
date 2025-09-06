#!/usr/bin/env python3
"""
Fix specific player data issues based on user feedback
"""

import json

def fix_specific_issues():
    """Fix Connor Rozee position and Caleb Daniel team"""
    print("Fixing specific player issues...")
    
    # Load current data
    with open('player_data_stats_enhanced_20250720_205845.json', 'r') as f:
        players = json.load(f)
    
    corrections_made = 0
    
    for player in players:
        name = player['name']
        
        if name == 'Connor Rozee':
            print(f"Correcting Connor Rozee:")
            print(f"  Position: {player['position']} -> DEF/MID")
            player['position'] = 'DEF/MID'  # Multi-positional
            corrections_made += 1
            
        elif name == 'Caleb Daniel':
            print(f"Correcting Caleb Daniel:")
            print(f"  Team: {player['team']} -> North Melbourne")
            player['team'] = 'North Melbourne'  # User confirms he plays for North Melbourne
            corrections_made += 1
    
    print(f"Made {corrections_made} corrections")
    
    # Save corrected data
    with open('player_data_stats_enhanced_20250720_205845.json', 'w') as f:
        json.dump(players, f, indent=2)
    
    with open('player_data.json', 'w') as f:
        json.dump(players, f, indent=2)
    
    # Verify corrections
    print("\nVerifying corrections:")
    for player in players:
        if player['name'] in ['Connor Rozee', 'Caleb Daniel']:
            print(f"  {player['name']}: {player['team']} {player['position']}")
    
    print("Specific corrections completed!")

if __name__ == "__main__":
    fix_specific_issues()