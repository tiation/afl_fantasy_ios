import json
import pandas as pd
from datetime import datetime
import os

def create_comprehensive_player_database():
    """Create new player database from comprehensive data sources"""
    print("Creating comprehensive player database...")
    
    # Load the DFS individual data (601 players with detailed stats)
    dfs_file = "dfs_individual_data_20250720_204512.json"
    keeper_file = "keeper_data_20250720_204512.json" 
    round13_file = "round13_live_20250720_204512.json"
    
    players = []
    dfs_data = {}
    keeper_insights = {}
    round13_data = {}
    
    # Load DFS individual player data
    if os.path.exists(dfs_file):
        with open(dfs_file, 'r') as f:
            dfs_raw = json.load(f)
        
        print(f"Processing {len(dfs_raw)} DFS individual files...")
        
        for dfs_player in dfs_raw:
            player_name = dfs_player['name']
            
            # Extract key information from DFS data
            career_stats = dfs_player.get('data', {}).get('career_stats', [])
            game_logs = dfs_player.get('data', {}).get('game_logs', [])
            opponent_splits = dfs_player.get('data', {}).get('opponent_splits', [])
            
            # Build comprehensive player profile
            player = {
                'name': player_name,
                'source': 'dfs_comprehensive',
                'last_updated': datetime.now().isoformat(),
                'comprehensive_data': True,
                
                # Default values that will be enhanced
                'team': 'Unknown',
                'position': 'Unknown', 
                'price': 0,
                'averagePoints': 0,
                'lastScore': 0,
                'breakEven': 0,
                'projScore': 0,
                
                # Enhanced data from DFS
                'career_statistics': career_stats,
                'recent_game_logs': game_logs[:10] if game_logs else [],  # Last 10 games
                'opponent_performance': opponent_splits,
                'data_sheets': dfs_player.get('sheets', []),
                
                # Flags for available data
                'has_career_averages': len(career_stats) > 0,
                'has_game_logs': len(game_logs) > 0,
                'has_opponent_splits': len(opponent_splits) > 0
            }
            
            # Try to extract team and position from career stats
            if career_stats:
                for stat in career_stats:
                    if isinstance(stat, dict):
                        # Look for team information
                        for key, value in stat.items():
                            if 'team' in key.lower() and value:
                                player['team'] = str(value).strip()
                            elif 'position' in key.lower() and value:
                                player['position'] = str(value).strip()
                            elif 'price' in key.lower() and value:
                                try:
                                    player['price'] = float(str(value).replace('$', '').replace(',', ''))
                                except:
                                    pass
                            elif 'average' in key.lower() and value:
                                try:
                                    player['averagePoints'] = float(value)
                                except:
                                    pass
            
            # Extract recent performance from game logs
            if game_logs:
                recent_scores = []
                for game in game_logs[:5]:  # Last 5 games
                    if isinstance(game, dict):
                        for key, value in game.items():
                            if 'score' in key.lower() or 'points' in key.lower():
                                try:
                                    score = float(value)
                                    recent_scores.append(score)
                                    break
                                except:
                                    continue
                
                if recent_scores:
                    player['lastScore'] = recent_scores[0] if recent_scores else 0
                    player['l3Average'] = sum(recent_scores[:3]) / len(recent_scores[:3]) if recent_scores else 0
                    player['recentForm'] = recent_scores
            
            players.append(player)
    
    # Load keeper data for additional insights
    if os.path.exists(keeper_file):
        with open(keeper_file, 'r') as f:
            keeper_raw = json.load(f)
        
        print(f"Integrating {len(keeper_raw)} keeper datasets...")
        
        # Create keeper insights lookup
        for dataset in keeper_raw:
            filename = dataset.get('filename', '')
            data = dataset.get('data', [])
            
            if 'CBA' in filename:
                # Centre bounce attendance data
                for record in data:
                    if isinstance(record, dict) and 'Player' in record:
                        player_name = record['Player']
                        if player_name not in keeper_insights:
                            keeper_insights[player_name] = {}
                        keeper_insights[player_name]['cba_percentage'] = record.get('CBA%', 0)
            
            elif 'kick' in filename.lower():
                # Kick-ins data
                for record in data:
                    if isinstance(record, dict) and 'Player' in record:
                        player_name = record['Player']
                        if player_name not in keeper_insights:
                            keeper_insights[player_name] = {}
                        keeper_insights[player_name]['kickins_percentage'] = record.get('KI%', 0)
            
            elif 'Breakout' in filename:
                # Breakout candidate data
                for record in data:
                    if isinstance(record, dict) and 'Player' in record:
                        player_name = record['Player']
                        if player_name not in keeper_insights:
                            keeper_insights[player_name] = {}
                        keeper_insights[player_name]['breakout_candidate'] = True
    
    # Apply keeper insights to players
    for player in players:
        player_name = player['name']
        if player_name in keeper_insights:
            player['keeper_league_data'] = keeper_insights[player_name]
    
    # Load Round 13 live data
    if os.path.exists(round13_file):
        with open(round13_file, 'r') as f:
            round13_raw = json.load(f)
        
        if 'Sheet1' in round13_raw:
            live_data = round13_raw['Sheet1'].get('data', [])
            print(f"Integrating Round 13 live data for {len(live_data)} entries...")
            
            # Create live data lookup
            live_lookup = {}
            for record in live_data:
                if isinstance(record, dict) and 'Player' in record:
                    live_lookup[record['Player']] = record
            
            # Apply live data to players
            for player in players:
                if player['name'] in live_lookup:
                    live_record = live_lookup[player['name']]
                    player['round13_live'] = live_record
                    
                    # Update with live stats if available
                    if 'Price' in live_record:
                        try:
                            player['price'] = float(str(live_record['Price']).replace('$', '').replace(',', ''))
                        except:
                            pass
                    
                    if 'Average' in live_record:
                        try:
                            player['averagePoints'] = float(live_record['Average'])
                        except:
                            pass
    
    # Standardize team names
    team_mapping = {
        'Brisbane Lions': 'Brisbane',
        'Greater Western Sydney': 'GWS',
        'GWS Giants': 'GWS',
        'North Melbourne Kangaroos': 'North Melbourne',
        'Port Adelaide Power': 'Port Adelaide',
        'St Kilda Saints': 'St Kilda',
        'Sydney Swans': 'Sydney',
        'West Coast Eagles': 'West Coast',
        'Western Bulldogs': 'Western Bulldogs'
    }
    
    for player in players:
        team = player.get('team', '')
        if team in team_mapping:
            player['team'] = team_mapping[team]
    
    # Save comprehensive database
    print("Saving comprehensive player database...")
    
    with open('player_data.json', 'w') as f:
        json.dump(players, f, indent=2)
    
    # Create timestamped backup
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_file = f"player_data_backup_{timestamp}.json"
    with open(backup_file, 'w') as f:
        json.dump(players, f, indent=2)
    
    # Create summary
    teams = set(p.get('team', 'Unknown') for p in players)
    positions = set(p.get('position', 'Unknown') for p in players)
    
    summary = {
        'total_players': len(players),
        'teams_count': len(teams),
        'teams': sorted(list(teams)),
        'positions_count': len(positions), 
        'positions': sorted(list(positions)),
        'players_with_career_stats': len([p for p in players if p.get('has_career_averages')]),
        'players_with_game_logs': len([p for p in players if p.get('has_game_logs')]),
        'players_with_keeper_data': len([p for p in players if p.get('keeper_league_data')]),
        'players_with_live_data': len([p for p in players if p.get('round13_live')]),
        'created_timestamp': timestamp
    }
    
    with open('comprehensive_database_summary.json', 'w') as f:
        json.dump(summary, f, indent=2)
    
    print("=" * 60)
    print("COMPREHENSIVE DATABASE CREATED!")
    print(f"✓ Total players: {summary['total_players']}")
    print(f"✓ Teams: {summary['teams_count']}")
    print(f"✓ Positions: {summary['positions_count']}")
    print(f"✓ With career stats: {summary['players_with_career_stats']}")
    print(f"✓ With game logs: {summary['players_with_game_logs']}")
    print(f"✓ With keeper data: {summary['players_with_keeper_data']}")
    print(f"✓ With live Round 13 data: {summary['players_with_live_data']}")
    print("=" * 60)
    
    return summary

if __name__ == "__main__":
    create_comprehensive_player_database()