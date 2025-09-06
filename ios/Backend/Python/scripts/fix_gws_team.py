import json

def fix_gws_team():
    """Fix Greater Western Sydney team name to GWS"""
    player_files = [
        'player_data.json',
        'player_data_backup_20250501_201717.json',
        'player_data_backup_20250501_201800.json',
        'player_data_backup_2025-05-02T041.json',
        'player_data_backup_2025-05-03T154.json'
    ]
    
    total_fixes = 0
    
    for file_path in player_files:
        try:
            with open(file_path, 'r') as f:
                players = json.load(f)
            
            file_fixes = 0
            for player in players:
                if player.get('team') == 'Greater Western Sydney':
                    player['team'] = 'GWS'
                    file_fixes += 1
                    print(f"Fixed: {player.get('name', 'Unknown')} - Greater Western Sydney -> GWS")
            
            if file_fixes > 0:
                with open(file_path, 'w') as f:
                    json.dump(players, f, indent=2)
                print(f"Made {file_fixes} fixes in {file_path}")
            
            total_fixes += file_fixes
            
        except Exception as e:
            print(f"Error processing {file_path}: {e}")
    
    print(f"Total GWS fixes: {total_fixes}")

if __name__ == "__main__":
    fix_gws_team()