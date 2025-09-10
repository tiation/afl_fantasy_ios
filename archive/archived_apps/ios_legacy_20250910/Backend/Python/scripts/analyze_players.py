#!/usr/bin/env python3
"""
Analyze player data to verify format and distribution
"""
import json
import sys
from collections import Counter

def analyze_player_data(filename='player_data.json'):
    """Analyze player data in the given JSON file"""
    try:
        with open(filename, 'r') as f:
            players = json.load(f)
        
        # Basic stats
        print(f"Total players: {len(players)}")
        
        # Positions
        positions = Counter(p['position'] for p in players)
        print("\nPlayers by position:")
        for pos, count in positions.most_common():
            print(f"- {pos}: {count} players")
        
        # Teams
        teams = Counter(p['team'] for p in players)
        print("\nPlayers by team:")
        for team, count in teams.most_common():
            print(f"- {team}: {count} players")
        
        # Price ranges
        prices = [p['price'] for p in players]
        price_ranges = {
            "Under $500k": 0,
            "$500k - $750k": 0,
            "$750k - $1M": 0,
            "Over $1M": 0
        }
        
        for price in prices:
            if price < 500000:
                price_ranges["Under $500k"] += 1
            elif price < 750000:
                price_ranges["$500k - $750k"] += 1
            elif price < 1000000:
                price_ranges["$750k - $1M"] += 1
            else:
                price_ranges["Over $1M"] += 1
        
        print("\nPlayers by price range:")
        for range_name, count in price_ranges.items():
            print(f"- {range_name}: {count} players")
        
        # Top players by price
        top_players = sorted(players, key=lambda p: p['price'], reverse=True)[:10]
        print("\nTop 10 players by price:")
        for i, player in enumerate(top_players, 1):
            print(f"{i}. {player['name']} ({player['team']}) - ${player['price']/1000:.1f}k - {player['position']}")
        
        # Verify all required fields are present
        required_fields = ['name', 'team', 'position', 'price', 'avg', 'breakeven', 'projected_score', 'status']
        missing_fields = {}
        
        for player in players:
            for field in required_fields:
                if field not in player:
                    if field not in missing_fields:
                        missing_fields[field] = []
                    missing_fields[field].append(player['name'])
        
        if missing_fields:
            print("\nWARNING: Missing required fields:")
            for field, players_list in missing_fields.items():
                print(f"- {field} missing in {len(players_list)} players")
                if len(players_list) <= 3:
                    for p in players_list:
                        print(f"  * {p}")
        else:
            print("\nAll players have the required fields! ✓")
            
    except Exception as e:
        print(f"Error analyzing player data: {e}", file=sys.stderr)
        return False
    
    return True

if __name__ == "__main__":
    analyze_player_data()