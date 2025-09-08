#!/usr/bin/env python3

import json
import sys

def fix_jhye_clark_price():
    """Fix Jhye Clark's price to the lower, more accurate amount"""
    
    data_file = "player_data_stats_enhanced_20250720_205845.json"
    
    try:
        with open(data_file, 'r') as f:
            players = json.load(f)
    except FileNotFoundError:
        print(f"Error: {data_file} not found")
        return False
    
    print(f"Looking for Jhye Clark in {len(players)} players")
    
    found = False
    for player in players:
        if player.get('name') == 'Jhye Clark':
            old_price = player.get('price', 0)
            # Set to the lower, more accurate price
            player['price'] = 449000
            print(f"Updated Jhye Clark price: ${old_price:,} -> $449,000")
            found = True
            break
    
    if not found:
        print("Jhye Clark not found in player data")
        return False
    
    # Save the updated data
    with open(data_file, 'w') as f:
        json.dump(players, f, indent=2)
    
    print(f"Updated {data_file}")
    return True

if __name__ == "__main__":
    success = fix_jhye_clark_price()
    sys.exit(0 if success else 1)