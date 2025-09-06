"""
Test the scraper module to verify player data access
"""

from scraper import get_player_data

def main():
    """Test main function"""
    players = get_player_data()
    print(f"Loaded {len(players)} players")
    
    # Print first 3 players as sample
    for i, player in enumerate(players[:3]):
        print(f"\nPlayer {i+1}: {player['name']}")
        print(f"  Team: {player.get('team', 'N/A')}")
        print(f"  Price: ${player.get('price', 0):,}")
        print(f"  Breakeven: {player.get('breakeven', 0)}")
        print(f"  Last 3 game avg: {player.get('l3_avg', 0)}")
        print(f"  Games played: {player.get('games', 0)}")
        
if __name__ == "__main__":
    main()