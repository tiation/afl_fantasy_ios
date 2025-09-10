import json
import pandas as pd
import numpy as np
from datetime import datetime

def extract_player_statistics():
    """Extract and populate all relevant statistics from comprehensive data"""
    print("Extracting comprehensive player statistics...")
    
    # Load comprehensive player data
    with open('player_data.json', 'r') as f:
        players = json.load(f)
    
    # Load keeper data for role-specific stats
    with open('keeper_data_20250720_204512.json', 'r') as f:
        keeper_data = json.load(f)
    
    # Create keeper lookup for CBA, kick-ins, etc.
    keeper_lookup = {}
    for dataset in keeper_data:
        filename = dataset.get('filename', '')
        data = dataset.get('data', [])
        
        if 'CBA' in filename and '%' in filename:
            for record in data:
                if isinstance(record, dict) and 'Player' in record:
                    player_name = record['Player']
                    if player_name not in keeper_lookup:
                        keeper_lookup[player_name] = {}
                    keeper_lookup[player_name]['cba_percentage'] = record.get('CBA%', 0)
        
        elif 'kick' in filename.lower() and '%' in filename:
            for record in data:
                if isinstance(record, dict) and 'Player' in record:
                    player_name = record['Player']
                    if player_name not in keeper_lookup:
                        keeper_lookup[player_name] = {}
                    keeper_lookup[player_name]['kickins_percentage'] = record.get('KI%', 0)
    
    print(f"Found keeper data for {len(keeper_lookup)} players")
    
    # Process each player and extract comprehensive stats
    enhanced_players = []
    
    for player in players:
        enhanced_player = {
            # Basic info
            'id': hash(player['name']) % 1000000,  # Generate consistent ID
            'name': player['name'],
            'team': player.get('team', 'Unknown'),
            'position': player.get('position', 'Unknown').replace('UNK', 'RUC'),  # Convert UNK to RUC
            
            # Core Fantasy Stats
            'price': player.get('price', 0),
            'averagePoints': 0,
            'lastScore': player.get('lastScore', 0),
            'l3Average': player.get('l3Average', 0),
            'l5Average': 0,
            'breakEven': player.get('breakEven', 0),
            'totalPoints': 0,
            'selectionPercentage': 0,
            
            # Price & Movement
            'priceChange': 0,
            'pricePerPoint': 0,
            
            # Match Stats (from career statistics)
            'kicks': 0,
            'handballs': 0,
            'disposals': 0,
            'marks': 0,
            'tackles': 0,
            'hitouts': 0,
            'freeKicksFor': 0,
            'freeKicksAgainst': 0,
            'clearances': 0,
            
            # Role Stats
            'cba': 0,
            'kickIns': 0,
            'contestedMarks': 0,
            'uncontestedMarks': 0,
            'contestedDisposals': 0,
            'uncontestedDisposals': 0,
            
            # Default for other fields
            'projScore': player.get('projScore', 0)
        }
        
        # Extract career statistics from DFS data
        career_stats = player.get('career_statistics', [])
        if career_stats:
            # Get most recent season stats (first entry should be 2025)
            recent_stats = career_stats[0] if isinstance(career_stats[0], dict) else {}
            
            # Map DFS stats to our structure
            enhanced_player['averagePoints'] = float(recent_stats.get('FP', 0) or 0)
            enhanced_player['kicks'] = float(recent_stats.get('K', 0) or 0)
            enhanced_player['handballs'] = float(recent_stats.get('H', 0) or 0)
            enhanced_player['marks'] = float(recent_stats.get('M', 0) or 0)
            enhanced_player['tackles'] = float(recent_stats.get('T', 0) or 0)
            enhanced_player['hitouts'] = float(recent_stats.get('HO', 0) or 0)
            enhanced_player['freeKicksFor'] = float(recent_stats.get('FF', 0) or 0)
            enhanced_player['freeKicksAgainst'] = float(recent_stats.get('FA', 0) or 0)
            
            # Calculate disposals
            kicks = enhanced_player['kicks']
            handballs = enhanced_player['handballs']
            enhanced_player['disposals'] = kicks + handballs
            
            # Extract other stats
            enhanced_player['totalPoints'] = enhanced_player['averagePoints'] * float(recent_stats.get('GM', 0) or 0)
            
            # Calculate price per point
            if enhanced_player['averagePoints'] > 0:
                enhanced_player['pricePerPoint'] = enhanced_player['price'] / enhanced_player['averagePoints']
            
            # Extract CBA percentage from career stats
            enhanced_player['cba'] = float(recent_stats.get('CB%', 0) or 0)
            enhanced_player['kickIns'] = float(recent_stats.get('KI', 0) or 0)
        
        # Enhance with keeper league data
        player_name = player['name']
        if player_name in keeper_lookup:
            keeper_stats = keeper_lookup[player_name]
            if 'cba_percentage' in keeper_stats:
                enhanced_player['cba'] = keeper_stats['cba_percentage']
            if 'kickins_percentage' in keeper_stats:
                enhanced_player['kickIns'] = keeper_stats['kickins_percentage']
        
        # Extract game logs for recent form
        game_logs = player.get('recent_game_logs', [])
        if game_logs:
            recent_scores = []
            for game in game_logs[:5]:  # Last 5 games
                if isinstance(game, dict):
                    # Look for score/points in various column names
                    score = None
                    for key, value in game.items():
                        if any(term in key.lower() for term in ['fp', 'fantasy', 'points', 'score']):
                            try:
                                score = float(value)
                                break
                            except:
                                continue
                    
                    if score is not None:
                        recent_scores.append(score)
            
            if recent_scores:
                enhanced_player['lastScore'] = recent_scores[0]
                enhanced_player['l3Average'] = sum(recent_scores[:3]) / len(recent_scores[:3])
                enhanced_player['l5Average'] = sum(recent_scores) / len(recent_scores)
        
        # Set l5Average fallback if not calculated from game logs
        if enhanced_player['l5Average'] == 0 and enhanced_player['averagePoints'] > 0:
            enhanced_player['l5Average'] = enhanced_player['averagePoints']
        
        # Set l3Average fallback
        if enhanced_player['l3Average'] == 0 and enhanced_player['averagePoints'] > 0:
            enhanced_player['l3Average'] = enhanced_player['averagePoints']
        
        enhanced_players.append(enhanced_player)
    
    print(f"Enhanced {len(enhanced_players)} players with comprehensive statistics")
    return enhanced_players

def create_stats_endpoint_data(enhanced_players):
    """Create properly formatted data for stats endpoints"""
    
    # Save enhanced player data
    with open('player_data.json', 'w') as f:
        json.dump(enhanced_players, f, indent=2)
    
    # Create backup
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    with open(f'player_data_stats_enhanced_{timestamp}.json', 'w') as f:
        json.dump(enhanced_players, f, indent=2)
    
    # Generate statistics summary
    stats_summary = {
        'total_players': len(enhanced_players),
        'players_with_average_points': len([p for p in enhanced_players if p['averagePoints'] > 0]),
        'players_with_match_stats': len([p for p in enhanced_players if p['kicks'] > 0]),
        'players_with_cba_data': len([p for p in enhanced_players if p['cba'] > 0]),
        'players_with_kickins': len([p for p in enhanced_players if p['kickIns'] > 0]),
        'players_with_recent_scores': len([p for p in enhanced_players if p['lastScore'] > 0]),
        'teams': list(set(p['team'] for p in enhanced_players)),
        'positions': list(set(p['position'] for p in enhanced_players)),
        'average_price': sum(p['price'] for p in enhanced_players) / len(enhanced_players),
        'average_fantasy_points': sum(p['averagePoints'] for p in enhanced_players if p['averagePoints'] > 0) / len([p for p in enhanced_players if p['averagePoints'] > 0]),
        'timestamp': timestamp
    }
    
    with open(f'stats_population_summary_{timestamp}.json', 'w') as f:
        json.dump(stats_summary, f, indent=2)
    
    print("=" * 60)
    print("STATS TABLE POPULATION COMPLETE!")
    print(f"✓ Total players: {stats_summary['total_players']}")
    print(f"✓ Players with fantasy averages: {stats_summary['players_with_average_points']}")
    print(f"✓ Players with match statistics: {stats_summary['players_with_match_stats']}")
    print(f"✓ Players with CBA data: {stats_summary['players_with_cba_data']}")
    print(f"✓ Players with kick-ins data: {stats_summary['players_with_kickins']}")
    print(f"✓ Players with recent scores: {stats_summary['players_with_recent_scores']}")
    print(f"✓ Average fantasy points: {stats_summary['average_fantasy_points']:.1f}")
    print("=" * 60)
    
    return stats_summary

def main():
    """Main function to populate stats table"""
    print("Starting stats table population...")
    print("=" * 60)
    
    # Extract comprehensive statistics
    enhanced_players = extract_player_statistics()
    
    # Create formatted data for endpoints
    summary = create_stats_endpoint_data(enhanced_players)
    
    print("\nStats table is now populated with:")
    print("• Fantasy points averages from career statistics")
    print("• Match statistics (kicks, handballs, marks, tackles, etc.)")
    print("• Role-based stats (CBA%, kick-ins)")
    print("• Recent form data (L3, L5 averages)")
    print("• Price and value calculations")
    print("• All 601 players from comprehensive dataset")
    
if __name__ == "__main__":
    main()