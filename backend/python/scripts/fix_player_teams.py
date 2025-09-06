import json
import requests
import time

def get_current_player_data():
    """Get current player data from our working API endpoints"""
    print("Fetching current player data from API...")
    
    try:
        # Try our combined stats API which loads from backup files
        response = requests.get('http://localhost:5000/api/stats/combined-stats')
        if response.status_code == 200:
            return response.json()
        else:
            print(f"API returned status: {response.status_code}")
            return None
    except Exception as e:
        print(f"Error fetching from API: {e}")
        return None

def create_team_mapping():
    """Create team mapping from known correct team names"""
    # AFL team mapping - full names to standard abbreviations
    team_mapping = {
        # Standard names
        'Adelaide': 'Adelaide',
        'Brisbane': 'Brisbane', 
        'Carlton': 'Carlton',
        'Collingwood': 'Collingwood',
        'Essendon': 'Essendon',
        'Fremantle': 'Fremantle',
        'Geelong': 'Geelong',
        'Gold Coast': 'Gold Coast',
        'GWS': 'GWS',
        'Hawthorn': 'Hawthorn',
        'Melbourne': 'Melbourne',
        'North Melbourne': 'North Melbourne',
        'Port Adelaide': 'Port Adelaide',
        'Richmond': 'Richmond',
        'St Kilda': 'St Kilda',
        'Sydney': 'Sydney',
        'West Coast': 'West Coast',
        'Western Bulldogs': 'Western Bulldogs',
        
        # Alternative names and abbreviations
        'ADE': 'Adelaide',
        'BRL': 'Brisbane',
        'BRI': 'Brisbane',
        'CAR': 'Carlton',
        'COL': 'Collingwood',
        'ESS': 'Essendon',
        'FRE': 'Fremantle',
        'GEE': 'Geelong',
        'GCS': 'Gold Coast',
        'GOLD': 'Gold Coast',
        'GWS GIANTS': 'GWS',
        'GIANTS': 'GWS',
        'HAW': 'Hawthorn',
        'MEL': 'Melbourne',
        'NTH': 'North Melbourne',
        'NORTH': 'North Melbourne',
        'PA': 'Port Adelaide',
        'PORT': 'Port Adelaide',
        'RIC': 'Richmond',
        'STK': 'St Kilda',
        'SYD': 'Sydney',
        'WCE': 'West Coast',
        'WB': 'Western Bulldogs',
        'DOGS': 'Western Bulldogs',
        'BULLDOGS': 'Western Bulldogs',
        
        # Common variations
        'Adelaide Crows': 'Adelaide',
        'Brisbane Lions': 'Brisbane',
        'Carlton Blues': 'Carlton', 
        'Collingwood Magpies': 'Collingwood',
        'Essendon Bombers': 'Essendon',
        'Fremantle Dockers': 'Fremantle',
        'Geelong Cats': 'Geelong',
        'Gold Coast Suns': 'Gold Coast',
        'GWS Giants': 'GWS',
        'Hawthorn Hawks': 'Hawthorn',
        'Melbourne Demons': 'Melbourne',
        'North Melbourne Kangaroos': 'North Melbourne',
        'Port Adelaide Power': 'Port Adelaide',
        'Richmond Tigers': 'Richmond',
        'St Kilda Saints': 'St Kilda',
        'Sydney Swans': 'Sydney',
        'West Coast Eagles': 'West Coast',
        'Western Bulldogs': 'Western Bulldogs'
    }
    
    return team_mapping

def fix_player_teams():
    """Fix player team assignments in all data files"""
    print("Starting team assignment fixes...")
    
    team_mapping = create_team_mapping()
    
    # Player data files to update
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
            print(f"\nProcessing {file_path}...")
            
            # Load the file
            with open(file_path, 'r') as f:
                players = json.load(f)
            
            if not isinstance(players, list):
                print(f"Skipping {file_path} - not a list format")
                continue
            
            file_fixes = 0
            
            for player in players:
                if 'team' in player and player['team']:
                    original_team = player['team'].strip()
                    
                    # Try to find a standard team name
                    if original_team in team_mapping:
                        standard_team = team_mapping[original_team]
                        if standard_team != original_team:
                            player['team'] = standard_team
                            file_fixes += 1
                            print(f"  Fixed: {player.get('name', 'Unknown')} - {original_team} -> {standard_team}")
            
            # Save the updated file
            with open(file_path, 'w') as f:
                json.dump(players, f, indent=2)
            
            print(f"  Made {file_fixes} fixes in {file_path}")
            total_fixes += file_fixes
            
        except Exception as e:
            print(f"Error processing {file_path}: {e}")
    
    print(f"\n✅ Total fixes made: {total_fixes}")
    
    # Also create a summary of team distributions
    create_team_summary()

def create_team_summary():
    """Create a summary of player distributions by team"""
    print("\nCreating team distribution summary...")
    
    try:
        with open('player_data_backup_20250501_201717.json', 'r') as f:
            players = json.load(f)
        
        team_counts = {}
        unknown_teams = set()
        
        for player in players:
            team = player.get('team', 'Unknown').strip()
            if team:
                team_counts[team] = team_counts.get(team, 0) + 1
                
                # Track teams that might need fixing
                known_teams = [
                    'Adelaide', 'Brisbane', 'Carlton', 'Collingwood', 'Essendon', 'Fremantle',
                    'Geelong', 'Gold Coast', 'GWS', 'Hawthorn', 'Melbourne', 'North Melbourne',
                    'Port Adelaide', 'Richmond', 'St Kilda', 'Sydney', 'West Coast', 'Western Bulldogs'
                ]
                
                if team not in known_teams:
                    unknown_teams.add(team)
        
        print("\nTeam distribution:")
        for team, count in sorted(team_counts.items()):
            print(f"  {team}: {count} players")
        
        if unknown_teams:
            print(f"\nUnknown/non-standard teams found: {unknown_teams}")
        
        # Save team summary
        summary = {
            'team_counts': team_counts,
            'unknown_teams': list(unknown_teams),
            'total_players': len(players)
        }
        
        with open('team_distribution_summary.json', 'w') as f:
            json.dump(summary, f, indent=2)
        
        print("Saved team distribution summary to team_distribution_summary.json")
        
    except Exception as e:
        print(f"Error creating team summary: {e}")

if __name__ == "__main__":
    fix_player_teams()