import json
import pandas as pd

def enhance_with_backup_team_data():
    """Enhance new comprehensive data with team/position info from backup files"""
    print("Enhancing team and position data...")
    
    # Load the new comprehensive data
    with open('player_data.json', 'r') as f:
        new_players = json.load(f)
    
    # Load backup data for team/position mapping
    backup_files = [
        'old_player_data_backup/player_data_backup_20250501_201717.json',
        'old_player_data_backup/player_data_backup_20250501_201800.json'
    ]
    
    # Create lookup from backup data
    backup_lookup = {}
    
    for backup_file in backup_files:
        try:
            with open(backup_file, 'r') as f:
                backup_players = json.load(f)
            
            for player in backup_players:
                name = player.get('name', '').strip()
                if name and 'team' in player:
                    # Normalize name for matching
                    normalized_name = name.lower().replace('.', '').replace(' ', '').replace('-', '')
                    backup_lookup[normalized_name] = {
                        'team': player.get('team', 'Unknown'),
                        'position': player.get('position', 'Unknown'),
                        'price': player.get('price', 0),
                        'averagePoints': player.get('averagePoints', 0),
                        'breakEven': player.get('breakEven', 0),
                        'lastScore': player.get('lastScore', 0)
                    }
            
            print(f"Loaded {len(backup_players)} players from {backup_file}")
        except Exception as e:
            print(f"Error loading {backup_file}: {e}")
    
    print(f"Created lookup with {len(backup_lookup)} players")
    
    # Enhance new players with backup data
    enhanced = 0
    team_fixed = 0
    position_fixed = 0
    
    for player in new_players:
        name = player.get('name', '').strip()
        normalized_name = name.lower().replace('.', '').replace(' ', '').replace('-', '')
        
        if normalized_name in backup_lookup:
            backup_data = backup_lookup[normalized_name]
            
            # Update team if unknown or generic
            if player.get('team') in ['Unknown', None, '']:
                player['team'] = backup_data['team']
                team_fixed += 1
            
            # Update position if unknown or generic
            if player.get('position') in ['Unknown', None, '']:
                player['position'] = backup_data['position']
                position_fixed += 1
            
            # Update other key stats if missing
            if not player.get('price') and backup_data['price']:
                player['price'] = backup_data['price']
            
            if not player.get('averagePoints') and backup_data['averagePoints']:
                player['averagePoints'] = backup_data['averagePoints']
            
            if not player.get('breakEven') and backup_data['breakEven']:
                player['breakEven'] = backup_data['breakEven']
            
            if not player.get('lastScore') and backup_data['lastScore']:
                player['lastScore'] = backup_data['lastScore']
            
            enhanced += 1
    
    # Save enhanced data
    with open('player_data.json', 'w') as f:
        json.dump(new_players, f, indent=2)
    
    # Update backup file too
    timestamp = "20250720_205000"
    backup_file = f"player_data_backup_{timestamp}.json"
    with open(backup_file, 'w') as f:
        json.dump(new_players, f, indent=2)
    
    # Generate summary
    teams = set(p.get('team', 'Unknown') for p in new_players)
    positions = set(p.get('position', 'Unknown') for p in new_players)
    
    summary = {
        'total_players': len(new_players),
        'enhanced_players': enhanced,
        'teams_fixed': team_fixed,
        'positions_fixed': position_fixed,
        'unique_teams': len(teams),
        'teams_list': sorted(list(teams)),
        'unique_positions': len(positions),
        'positions_list': sorted(list(positions))
    }
    
    with open('enhanced_database_summary.json', 'w') as f:
        json.dump(summary, f, indent=2)
    
    print("=" * 60)
    print("TEAM/POSITION ENHANCEMENT COMPLETE!")
    print(f"✓ Enhanced {enhanced} players with backup data")
    print(f"✓ Fixed {team_fixed} team assignments")
    print(f"✓ Fixed {position_fixed} position assignments")
    print(f"✓ {len(teams)} teams: {', '.join(sorted(teams))}")
    print(f"✓ {len(positions)} positions: {', '.join(sorted(positions))}")
    print("=" * 60)
    
    return summary

if __name__ == "__main__":
    enhance_with_backup_team_data()