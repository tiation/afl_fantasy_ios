#!/usr/bin/env python3
"""
Comprehensive Player Data Correction Script
Imports authentic AFL Fantasy data from CSV files to fix team assignments, prices, and breakevens
"""

import json
import csv
import re
from typing import Dict, List, Any
import pandas as pd

# Team name mapping for consistency
TEAM_MAPPING = {
    'Blues': 'Carlton',
    'Bombers': 'Essendon', 
    'Crows': 'Adelaide',
    'Bulldogs': 'Western Bulldogs',
    'Cats': 'Geelong',
    'Demons': 'Melbourne',
    'Dockers': 'Fremantle',
    'Eagles': 'West Coast',
    'Giants': 'GWS',
    'Hawks': 'Hawthorn',
    'Kangaroos': 'North Melbourne',
    'Lions': 'Brisbane',
    'Magpies': 'Collingwood',
    'Power': 'Port Adelaide',
    'Saints': 'St Kilda',
    'Suns': 'Gold Coast',
    'Swans': 'Sydney',
    'Tigers': 'Richmond'
}

def normalize_player_name(name: str) -> str:
    """Normalize player name for matching"""
    if not name:
        return ""
    
    # Remove position suffixes and clean name
    name = re.sub(r'\s+(DEF|MID|FOR|RUC|INJ|SUS)(\s*,\s*(DEF|MID|FOR|RUC))*', '', name)
    name = re.sub(r'\s+', ' ', name).strip()
    
    # Handle common name variations
    name_parts = name.split()
    if len(name_parts) >= 2:
        # Convert "M. Bontempelli" to "Marcus Bontempelli" style matching
        if len(name_parts[0]) == 2 and name_parts[0].endswith('.'):
            # Keep the initial for matching purposes
            return name
    
    return name

def normalize_team_name(team: str) -> str:
    """Normalize team name"""
    if not team:
        return "Unknown"
    return TEAM_MAPPING.get(team, team)

def parse_price(price_str: str) -> int:
    """Parse price string to integer"""
    if not price_str:
        return 0
    
    # Remove $ and commas, handle different formats
    clean_price = re.sub(r'[,$"]', '', str(price_str))
    try:
        return int(clean_price)
    except ValueError:
        return 0

def load_authentic_data() -> Dict[str, Dict]:
    """Load authentic AFL Fantasy data from CSV files"""
    print("Loading authentic AFL Fantasy data...")
    
    authentic_data = {}
    
    # Load R7 Stats with teams and prices
    try:
        with open('attached_assets/AFL_Fantasy_R7_Stats.csv', 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                name = normalize_player_name(row.get('Player', ''))
                if name:
                    authentic_data[name] = {
                        'name': name,
                        'team': normalize_team_name(row.get('Team', '')),
                        'price': parse_price(row.get('Price', 0)),
                        'games': int(row.get('Games', 0)) if row.get('Games') else 0,
                        'averagePoints': float(row.get('Average', 0)) if row.get('Average') else 0,
                        'totalPoints': int(row.get('Total Points', 0)) if row.get('Total Points') else 0,
                        'source': 'AFL_Fantasy_R7_Stats'
                    }
        print(f"Loaded {len(authentic_data)} players from R7 Stats")
    except Exception as e:
        print(f"Error loading R7 Stats: {e}")
    
    # Load breakevens data
    try:
        with open('attached_assets/All_Player_Breakevens_-_Round_7.csv', 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                name = normalize_player_name(row.get('Player Name', ''))
                if name and name in authentic_data:
                    authentic_data[name]['breakEven'] = int(row.get('Breakeven', 0)) if row.get('Breakeven') else 0
                    authentic_data[name]['breakEvenPercent'] = int(row.get('Breakeven %', 0)) if row.get('Breakeven %') else 0
                elif name:
                    # Create entry if not exists
                    authentic_data[name] = {
                        'name': name,
                        'price': parse_price(row.get('Price ($)', 0)),
                        'breakEven': int(row.get('Breakeven', 0)) if row.get('Breakeven') else 0,
                        'breakEvenPercent': int(row.get('Breakeven %', 0)) if row.get('Breakeven %') else 0,
                        'source': 'Breakevens_R7'
                    }
        print(f"Updated breakevens for players")
    except Exception as e:
        print(f"Error loading breakevens: {e}")
    
    # Load additional price data
    try:
        with open('attached_assets/afl_fantasy_round7_prices.csv', 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                name = normalize_player_name(row.get('Player', ''))
                if name and name in authentic_data:
                    # Update with more detailed data
                    authentic_data[name]['averagePoints'] = float(row.get('Avg', 0)) if row.get('Avg') else authentic_data[name].get('averagePoints', 0)
                    authentic_data[name]['games'] = int(row.get('G', 0)) if row.get('G') else authentic_data[name].get('games', 0)
                    authentic_data[name]['team'] = normalize_team_name(row.get('Team', '')) or authentic_data[name].get('team', 'Unknown')
        print(f"Enhanced data for players with round 7 prices")
    except Exception as e:
        print(f"Error loading round 7 prices: {e}")
    
    return authentic_data

def create_name_mapping(authentic_data: Dict, existing_data: List[Dict]) -> Dict[str, str]:
    """Create mapping between existing player names and authentic names"""
    name_mapping = {}
    
    for existing_player in existing_data:
        existing_name = existing_player.get('name', '')
        best_match = None
        best_score = 0
        
        # Try exact match first
        for auth_name in authentic_data.keys():
            if existing_name == auth_name:
                best_match = auth_name
                break
        
        if not best_match:
            # Try fuzzy matching based on last name
            existing_parts = existing_name.split()
            if existing_parts:
                existing_last = existing_parts[-1].lower()
                
                for auth_name in authentic_data.keys():
                    auth_parts = auth_name.split()
                    if auth_parts and auth_parts[-1].lower() == existing_last:
                        # Check if first name matches or is initial
                        if len(existing_parts) > 1 and len(auth_parts) > 1:
                            existing_first = existing_parts[0].lower()
                            auth_first = auth_parts[0].lower()
                            
                            if (existing_first == auth_first or 
                                existing_first.startswith(auth_first) or 
                                auth_first.startswith(existing_first) or
                                (len(existing_first) == 2 and existing_first[0] == auth_first[0])):
                                best_match = auth_name
                                break
        
        if best_match:
            name_mapping[existing_name] = best_match
    
    print(f"Created name mapping for {len(name_mapping)} players")
    return name_mapping

def correct_player_data():
    """Main function to correct player data"""
    print("Starting comprehensive player data correction...")
    
    # Load authentic data
    authentic_data = load_authentic_data()
    
    # Load existing enhanced data
    with open('player_data_stats_enhanced_20250720_205845.json', 'r') as f:
        existing_data = json.load(f)
    
    print(f"Loaded {len(existing_data)} existing players")
    
    # Create name mapping
    name_mapping = create_name_mapping(authentic_data, existing_data)
    
    # Correct the data
    corrected_count = 0
    for player in existing_data:
        existing_name = player.get('name', '')
        
        if existing_name in name_mapping:
            auth_name = name_mapping[existing_name]
            auth_player = authentic_data[auth_name]
            
            # Update with authentic data while preserving match statistics
            original_team = player.get('team')
            original_price = player.get('price')
            original_breakeven = player.get('breakEven')
            
            if auth_player.get('team') and auth_player['team'] != 'Unknown':
                player['team'] = auth_player['team']
            
            if auth_player.get('price') and auth_player['price'] > 0:
                player['price'] = auth_player['price']
            
            if auth_player.get('breakEven') and auth_player['breakEven'] > 0:
                player['breakEven'] = auth_player['breakEven']
            
            if auth_player.get('averagePoints') and auth_player['averagePoints'] > 0:
                player['averagePoints'] = auth_player['averagePoints']
                player['avg'] = auth_player['averagePoints']  # Ensure both fields are updated
            
            if auth_player.get('games') and auth_player['games'] > 0:
                player['games'] = auth_player['games']
            
            if auth_player.get('totalPoints') and auth_player['totalPoints'] > 0:
                player['totalPoints'] = auth_player['totalPoints']
            
            # Log significant changes
            if (original_team != player.get('team') or 
                abs(original_price - player.get('price', 0)) > 50000 or
                abs(original_breakeven - player.get('breakEven', 0)) > 10):
                print(f"Corrected {existing_name}: Team {original_team} -> {player.get('team')}, "
                      f"Price ${original_price:,} -> ${player.get('price', 0):,}, "
                      f"BE {original_breakeven} -> {player.get('breakEven', 0)}")
                corrected_count += 1
    
    # Create backup
    import shutil
    backup_filename = f"player_data_backup_before_correction_{pd.Timestamp.now().strftime('%Y%m%d_%H%M%S')}.json"
    shutil.copy('player_data_stats_enhanced_20250720_205845.json', backup_filename)
    print(f"Created backup: {backup_filename}")
    
    # Save corrected data
    with open('player_data_stats_enhanced_20250720_205845.json', 'w') as f:
        json.dump(existing_data, f, indent=2)
    
    # Also update the main player_data.json
    with open('player_data.json', 'w') as f:
        json.dump(existing_data, f, indent=2)
    
    print(f"\nData correction completed!")
    print(f"- Corrected {corrected_count} players with significant changes")
    print(f"- Updated both enhanced and main player data files")
    print(f"- Preserved all match statistics and comprehensive data")
    
    # Generate summary report
    team_counts = {}
    price_ranges = {'Under_500K': 0, '500K_1M': 0, 'Over_1M': 0}
    be_ranges = {'Under_100': 0, '100_120': 0, 'Over_120': 0}
    
    for player in existing_data:
        team = player.get('team', 'Unknown')
        team_counts[team] = team_counts.get(team, 0) + 1
        
        price = player.get('price', 0)
        if price < 500000:
            price_ranges['Under_500K'] += 1
        elif price < 1000000:
            price_ranges['500K_1M'] += 1
        else:
            price_ranges['Over_1M'] += 1
        
        be = player.get('breakEven', 0)
        if be < 100:
            be_ranges['Under_100'] += 1
        elif be < 120:
            be_ranges['100_120'] += 1
        else:
            be_ranges['Over_120'] += 1
    
    print(f"\nData Summary:")
    print(f"Teams: {dict(sorted(team_counts.items()))}")
    print(f"Price ranges: {price_ranges}")
    print(f"Breakeven ranges: {be_ranges}")

if __name__ == "__main__":
    correct_player_data()