#!/usr/bin/env python3
"""
Enhance player data with additional statistics from multiple sources
- AFL Stats CSV: Detailed game stats
- DraftStars data: Recent performances, consistency metrics
"""
import json
import csv
import os
from datetime import datetime

def read_json_file(filename):
    """Read a JSON file and return its contents"""
    try:
        with open(filename, 'r') as file:
            return json.load(file)
    except Exception as e:
        print(f"Error reading {filename}: {e}")
        return []

def read_csv_file(filename, skip_rows=3):
    """Read a CSV file and return its contents as a list of dictionaries"""
    try:
        data = []
        with open(filename, 'r') as file:
            # Skip header rows
            for _ in range(skip_rows):
                next(file)
                
            reader = csv.DictReader(file)
            for row in reader:
                data.append(row)
        return data
    except Exception as e:
        print(f"Error reading {filename}: {e}")
        return []

def normalize_player_name(name):
    """Normalize player names for matching across datasets"""
    if not name:
        return ""
    # Strip any suffixes like " (Ankle)" or indicators
    if " (" in name:
        name = name.split(" (")[0]
    # Normalize to lowercase for comparison
    return name.lower().strip()

def normalize_team_name(team):
    """Normalize team names for matching across datasets"""
    if not team:
        return ""
        
    # Team name mapping from abbreviations
    team_mapping = {
        "ADE": "Adelaide",
        "BRL": "Brisbane",
        "CAR": "Carlton",
        "COL": "Collingwood",
        "ESS": "Essendon",
        "FRE": "Fremantle",
        "GEE": "Geelong",
        "GCS": "Gold Coast",
        "GWS": "Greater Western Sydney",
        "HAW": "Hawthorn",
        "MEL": "Melbourne",
        "NTH": "North Melbourne",
        "PTA": "Port Adelaide",
        "RIC": "Richmond",
        "STK": "St Kilda",
        "SYD": "Sydney",
        "WCE": "West Coast",
        "WBD": "Western Bulldogs",
        # Add any other abbreviations as needed
    }
    
    if team in team_mapping:
        return team_mapping[team]
    
    return team.strip()

def determine_status(status_code):
    """Convert status code to a readable status"""
    status_mapping = {
        "N": "fit",
        "E": "doubt",
        "O": "out",
        "S": "suspended",
        "?": "doubt"
    }
    
    if status_code in status_mapping:
        return status_mapping[status_code]
    
    return "fit"  # Default status

def enhance_with_draftstars_data(players, draftstars_data):
    """Enhance player data with DraftStars statistics"""
    # Create a mapping from normalized names to DraftStars data
    draftstars_mapping = {}
    for row in draftstars_data:
        name = normalize_player_name(row.get('player', ''))
        draftstars_mapping[name] = row
    
    # Enhance each player with DraftStars data if available
    for player in players:
        name = normalize_player_name(player.get('name', ''))
        ds_data = draftstars_mapping.get(name)
        
        if ds_data:
            # Add last 5 game scores
            for i in range(1, 6):
                last_key = f'last{i}'
                if ds_data.get(last_key) and ds_data[last_key].strip():
                    try:
                        player[last_key] = int(float(ds_data[last_key]))
                    except (ValueError, TypeError):
                        pass
            
            # Recent average (Last 3)
            if ds_data.get('L3') and ds_data['L3'].strip():
                try:
                    player['last_3_avg'] = float(ds_data['L3'])
                except (ValueError, TypeError):
                    pass
            
            # Games played
            if ds_data.get('gms') and ds_data['gms'].strip():
                try:
                    player['games'] = int(ds_data['gms'])
                except (ValueError, TypeError):
                    pass
            
            # Average
            if ds_data.get('avg') and ds_data['avg'].strip():
                try:
                    player['avg'] = float(ds_data['avg'])
                except (ValueError, TypeError):
                    pass
            
            # Standard deviation (consistency metric)
            if ds_data.get('stddev') and ds_data['stddev'].strip():
                try:
                    player['stddev'] = float(ds_data['stddev'])
                except (ValueError, TypeError):
                    pass
            
            # Max score
            if ds_data.get('max') and ds_data['max'].strip():
                try:
                    player['max_score'] = int(float(ds_data['max']))
                except (ValueError, TypeError):
                    pass
                    
            # Min score
            if ds_data.get('min') and ds_data['min'].strip():
                try:
                    player['min_score'] = int(float(ds_data['min']))
                except (ValueError, TypeError):
                    pass
            
            # Win average
            if ds_data.get('win') and ds_data['win'].strip():
                try:
                    player['win_avg'] = float(ds_data['win'])
                except (ValueError, TypeError):
                    pass
            
            # Loss average
            if ds_data.get('loss') and ds_data['loss'].strip():
                try:
                    player['loss_avg'] = float(ds_data['loss'])
                except (ValueError, TypeError):
                    pass
                    
            # Status
            if ds_data.get('status'):
                player['status'] = determine_status(ds_data['status'])
                
            # Last year (2024) average
            if ds_data.get('2024') and ds_data['2024'].strip():
                try:
                    player['last_year_avg'] = float(ds_data['2024'])
                except (ValueError, TypeError):
                    pass
                
            # Position - take from DraftStars if available
            if ds_data.get('position'):
                positions = ds_data['position'].split('/')
                if positions:
                    primary_pos = positions[0]
                    if primary_pos == 'FWD':
                        player['position'] = 'FWD'
                    elif primary_pos == 'MID':
                        player['position'] = 'MID'
                    elif primary_pos == 'DEF':
                        player['position'] = 'DEF'
                    elif primary_pos == 'RK':
                        player['position'] = 'RUC'
    
    return players

def enhance_with_afl_stats(players, afl_stats_data):
    """Enhance player data with AFL statistics from the CSV"""
    # Create a mapping from normalized names to AFL stats data
    # Group by player name to get all games for each player
    afl_stats_mapping = {}
    
    for row in afl_stats_data:
        name = normalize_player_name(row.get('player', ''))
        if name not in afl_stats_mapping:
            afl_stats_mapping[name] = []
        
        # Convert stat fields to integers where possible
        stats_row = {k: int(float(v)) if v.strip() and v.replace('.', '').isdigit() else v for k, v in row.items()}
        afl_stats_mapping[name].append(stats_row)
    
    # Enhance each player with AFL stats data if available
    for player in players:
        name = normalize_player_name(player.get('name', ''))
        games_data = afl_stats_mapping.get(name, [])
        
        if games_data:
            # Get the most recent game
            most_recent_game = games_data[0]
            
            # Additional game stats for the most recent game
            player['kicks'] = most_recent_game.get('kicks')
            player['handballs'] = most_recent_game.get('handballs')
            player['marks'] = most_recent_game.get('marks')
            player['tackles'] = most_recent_game.get('tackles')
            player['hitouts'] = most_recent_game.get('hitouts')
            player['freesFor'] = most_recent_game.get('freesFor')
            player['freesAgainst'] = most_recent_game.get('freesAgainst')
            player['goals'] = most_recent_game.get('goals')
            player['behinds'] = most_recent_game.get('behinds')
            
            # Calculate average kicks, handballs, etc. across all games if multiple games exist
            if len(games_data) > 1:
                total_kicks = sum(g.get('kicks', 0) for g in games_data if isinstance(g.get('kicks'), (int, float)))
                total_handballs = sum(g.get('handballs', 0) for g in games_data if isinstance(g.get('handballs'), (int, float)))
                total_marks = sum(g.get('marks', 0) for g in games_data if isinstance(g.get('marks'), (int, float)))
                total_tackles = sum(g.get('tackles', 0) for g in games_data if isinstance(g.get('tackles'), (int, float)))
                
                player['avg_kicks'] = round(total_kicks / len(games_data), 1)
                player['avg_handballs'] = round(total_handballs / len(games_data), 1)
                player['avg_marks'] = round(total_marks / len(games_data), 1)
                player['avg_tackles'] = round(total_tackles / len(games_data), 1)
                
            # Get position from AFL stats if not already set
            if 'position' not in player or not player['position']:
                pos = most_recent_game.get('namedPosition')
                if pos:
                    position_mapping = {
                        'FPR': 'FWD',
                        'FF': 'FWD',
                        'HF': 'FWD',
                        'F': 'FWD',
                        'FB': 'DEF',
                        'BP': 'DEF',
                        'BPL': 'DEF',
                        'BPR': 'DEF',
                        'HB': 'DEF',
                        'C': 'MID',
                        'W': 'MID',
                        'R': 'MID',
                        'RR': 'MID',
                        'RL': 'MID',
                        'RK': 'RUC',
                    }
                    if pos in position_mapping:
                        player['position'] = position_mapping[pos]
            
            # Use team name from AFL stats if needed
            if 'team' not in player or not player['team']:
                team = most_recent_game.get('team')
                if team:
                    player['team'] = normalize_team_name(team)
    
    return players

def calculate_projected_scores(players):
    """Calculate projected scores based on available data"""
    for player in players:
        # Convert avg to a number if it's a string
        avg = player.get('avg', 0)
        if isinstance(avg, str):
            try:
                avg = float(avg)
            except ValueError:
                avg = 0
        
        # Calculate projected score - use more sophisticated model if we have more data
        if player.get('last1') and player.get('last_3_avg'):
            # Weight recent performance more heavily
            last1 = player.get('last1', 0)
            if isinstance(last1, str):
                try:
                    last1 = float(last1)
                except ValueError:
                    last1 = 0
                    
            last_3_avg = player.get('last_3_avg', 0)
            if isinstance(last_3_avg, str):
                try:
                    last_3_avg = float(last_3_avg)
                except ValueError:
                    last_3_avg = 0
            
            # 40% last game, 40% recent form, 20% season average
            projected = round(0.4 * last1 + 0.4 * last_3_avg + 0.2 * avg)
            player['projected_score'] = projected
            player['projectedScore'] = projected  # Frontend expected field
        else:
            # Simple projection based on average
            projected = round(avg * 1.05)  # 5% improvement
            player['projected_score'] = projected
            player['projectedScore'] = projected  # Frontend expected field

        # Calculate breakeven if not already present
        if 'breakeven' not in player or not player['breakeven']:
            # Breakeven is typically 95% of the average
            breakeven = round(avg * 0.95)
            player['breakeven'] = breakeven
            player['breakEven'] = breakeven  # Frontend expected field
        else:
            be = player['breakeven']
            if isinstance(be, str):
                try:
                    be = int(float(be))
                except ValueError:
                    be = int(avg * 0.95) if avg else 0
            player['breakeven'] = be
            player['breakEven'] = be  # Map existing breakeven to the expected field
    
    # Map between our backend field names and frontend expected field names
    for player in players:
        # Core stats mappings
        player['id'] = player.get('id', hash(player['name']) % 10000 + 1000)  # Generate consistent ID if not present
        player['averagePoints'] = player.get('avg', 0)
        player['roundsPlayed'] = player.get('games', 0)
        player['lastScore'] = player.get('last1', None)
        
        # Recent performance
        if 'last_3_avg' in player:
            player['l3Average'] = player['last_3_avg']
        
        # Calculate L5 average if we have last1 through last5
        if all(f'last{i}' in player for i in range(1, 6)):
            l5_scores = [player[f'last{i}'] for i in range(1, 6)]
            player['l5Average'] = sum(l5_scores) / len(l5_scores)
        
        # Value metrics
        if 'avg' in player:
            avg_value = player['avg']
            if isinstance(avg_value, str):
                try:
                    avg_value = float(avg_value)
                except ValueError:
                    avg_value = 0
            
            if avg_value > 0:
                price = player.get('price', 0)
                player['pricePerPoint'] = round(price / avg_value, 2)
        
        # Consistency metrics
        if 'stddev' in player:
            player['standardDeviation'] = player['stddev']
        if 'max_score' in player:
            player['highScore'] = player['max_score']
        if 'min_score' in player:
            player['lowScore'] = player['min_score']
        
        # Status fields
        player_status = player.get('status', 'fit').lower()
        player['isInjured'] = player_status in ['injured', 'doubt']
        player['isSuspended'] = player_status == 'suspended'
        player['isSelected'] = player_status not in ['out', 'injured', 'suspended']
        
        # Calculate total points estimate
        if 'avg' in player and 'games' in player:
            avg_value = player['avg']
            if isinstance(avg_value, str):
                try:
                    avg_value = float(avg_value)
                except ValueError:
                    avg_value = 0
                    
            games = player['games']
            if isinstance(games, str):
                try:
                    games = int(games)
                except ValueError:
                    games = 0
                    
            player['totalPoints'] = round(avg_value * games)
    
    return players

def enhance_player_data(player_data_file='player_data.json', 
                        draftstars_file='attached_assets/draftstars-slate-data-1746095770371.csv',
                        afl_stats_file='attached_assets/afl-stats-1746095586623.csv'):
    """Main function to enhance player data"""
    print(f"Enhancing player data from {player_data_file}...")
    
    # Load existing player data
    players = read_json_file(player_data_file)
    if not players:
        print("Error: Could not read player data file.")
        return False
    
    print(f"Loaded {len(players)} players from {player_data_file}")
    
    # Load DraftStars data if available
    draftstars_data = []
    if os.path.exists(draftstars_file):
        draftstars_data = read_csv_file(draftstars_file)
        print(f"Loaded {len(draftstars_data)} players from DraftStars data.")
    else:
        print(f"Warning: DraftStars file {draftstars_file} not found.")
    
    # Load AFL stats data if available
    afl_stats_data = []
    if os.path.exists(afl_stats_file):
        afl_stats_data = read_csv_file(afl_stats_file)
        print(f"Loaded {len(afl_stats_data)} game records from AFL stats.")
    else:
        print(f"Warning: AFL stats file {afl_stats_file} not found.")
    
    # Enhance with DraftStars data
    if draftstars_data:
        players = enhance_with_draftstars_data(players, draftstars_data)
        print("Enhanced player data with DraftStars statistics.")
    
    # Enhance with AFL stats
    if afl_stats_data:
        players = enhance_with_afl_stats(players, afl_stats_data)
        print("Enhanced player data with AFL game statistics.")
    
    # Calculate projected scores and other derived values
    players = calculate_projected_scores(players)
    print("Calculated projected scores and other derived values.")
    
    # Add timestamp
    timestamp = int(datetime.now().timestamp())
    for player in players:
        player['timestamp'] = timestamp
        player['source'] = player.get('source', 'enhanced_afl_fantasy')
    
    # Save enhanced player data
    with open(player_data_file, 'w') as f:
        json.dump(players, f, indent=2)
    
    print(f"Successfully enhanced and saved {len(players)} players to {player_data_file}")
    return True

if __name__ == "__main__":
    enhance_player_data()