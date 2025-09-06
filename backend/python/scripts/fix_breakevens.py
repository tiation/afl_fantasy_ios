#!/usr/bin/env python3
"""
Fix Breakeven Data Import
Specifically imports breakeven data from authentic CSV files
"""

import json
import csv
import re

def normalize_player_name(name: str) -> str:
    """Normalize player name for matching"""
    if not name:
        return ""
    
    # Remove position suffixes and clean name
    name = re.sub(r'\s+(DEF|MID|FOR|RUC|INJ|SUS)(\s*,\s*(DEF|MID|FOR|RUC))*', '', name)
    name = re.sub(r'\s+', ' ', name).strip()
    return name

def create_name_variants(name: str) -> list:
    """Create name variants for better matching"""
    variants = [name]
    
    # Add full name variants
    parts = name.split()
    if len(parts) >= 2:
        # Add "FirstName LastName" format
        variants.append(f"{parts[0]} {parts[-1]}")
        
        # Add "F. LastName" format
        if len(parts[0]) > 1:
            variants.append(f"{parts[0][0]}. {parts[-1]}")
    
    return variants

def find_best_match(target_name: str, player_names: list) -> str:
    """Find best matching player name"""
    target_variants = create_name_variants(target_name)
    
    # Try exact matches first
    for variant in target_variants:
        if variant in player_names:
            return variant
    
    # Try case-insensitive matches
    for variant in target_variants:
        for player_name in player_names:
            if variant.lower() == player_name.lower():
                return player_name
    
    # Try last name matching
    target_last = target_name.split()[-1].lower()
    for player_name in player_names:
        player_last = player_name.split()[-1].lower()
        if target_last == player_last:
            # Check first name similarity
            target_first = target_name.split()[0].lower()
            player_first = player_name.split()[0].lower()
            
            if (target_first.startswith(player_first) or 
                player_first.startswith(target_first) or
                (len(target_first) >= 2 and len(player_first) >= 2 and 
                 target_first[0] == player_first[0])):
                return player_name
    
    return None

def fix_breakevens():
    """Fix breakeven data"""
    print("Loading player data...")
    
    # Load current player data
    with open('player_data_stats_enhanced_20250720_205845.json', 'r') as f:
        players = json.load(f)
    
    # Create lookup by name
    player_lookup = {player['name']: player for player in players}
    player_names = list(player_lookup.keys())
    
    print(f"Loaded {len(players)} players")
    
    # Load breakeven data
    breakeven_data = {}
    
    # Load from breakevens CSV
    try:
        with open('attached_assets/All_Player_Breakevens_-_Round_7.csv', 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                name = normalize_player_name(row.get('Player Name', ''))
                if name:
                    breakeven_data[name] = {
                        'breakEven': int(row.get('Breakeven', 0)) if row.get('Breakeven') else 0,
                        'breakEvenPercent': int(row.get('Breakeven %', 0)) if row.get('Breakeven %') else 0
                    }
        print(f"Loaded breakevens for {len(breakeven_data)} players from CSV")
    except Exception as e:
        print(f"Error loading breakevens: {e}")
        return
    
    # Load from round 7 prices CSV (has some breakevens too)
    try:
        with open('attached_assets/afl_fantasy_round7_prices.csv', 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                name = normalize_player_name(row.get('Player', ''))
                if name:
                    be_value = row.get('Breakeven', 0)
                    if be_value and str(be_value).isdigit():
                        if name not in breakeven_data:
                            breakeven_data[name] = {}
                        breakeven_data[name]['breakEven'] = int(be_value)
        print(f"Enhanced breakevens from round 7 prices")
    except Exception as e:
        print(f"Error loading round 7 prices: {e}")
    
    # Apply breakevens to players
    updated_count = 0
    matched_count = 0
    
    for be_name, be_data in breakeven_data.items():
        # Find best matching player
        matched_name = find_best_match(be_name, player_names)
        
        if matched_name:
            matched_count += 1
            player = player_lookup[matched_name]
            
            old_be = player.get('breakEven', 0)
            new_be = be_data.get('breakEven', 0)
            
            if new_be > 0:
                player['breakEven'] = new_be
                if be_data.get('breakEvenPercent'):
                    player['breakEvenPercent'] = be_data['breakEvenPercent']
                
                if abs(old_be - new_be) > 5:
                    print(f"Updated {matched_name}: BE {old_be} -> {new_be}")
                    updated_count += 1
    
    print(f"\nBreakeven update completed!")
    print(f"- Matched {matched_count} players from breakeven data")
    print(f"- Updated {updated_count} players with significant breakeven changes")
    
    # Save updated data
    with open('player_data_stats_enhanced_20250720_205845.json', 'w') as f:
        json.dump(players, f, indent=2)
    
    with open('player_data.json', 'w') as f:
        json.dump(players, f, indent=2)
    
    # Show some examples
    print(f"\nBreakeven examples:")
    be_examples = []
    for player in players:
        if player.get('breakEven', 0) > 0:
            be_examples.append(f"{player['name']}: {player['breakEven']}")
            if len(be_examples) >= 10:
                break
    
    for example in be_examples:
        print(f"  {example}")

if __name__ == "__main__":
    fix_breakevens()