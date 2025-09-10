#!/usr/bin/env python3
"""
AFL Fantasy Data Processor

This script processes AFL stats from a CSV file and generates a clean player_data.json
for use in the frontend application.
"""

import csv
import json
import os
from collections import defaultdict
from datetime import datetime

# Constants for the CSV column indices - correctly identified from CSV inspection
PLAYER = 0  # player column (index 0)
TEAM = 1    # team column (index 1)
OPPONENT = 2  # opponent column (index 2)
YEAR = 3    # year column (index 3)
ROUND = 4   # round column (index 4)
KICKS = 5   # kicks column (index 5)
HANDBALLS = 6  # handballs column (index 6)
MARKS = 7   # marks column (index 7)
TACKLES = 8  # tackles column (index 8)
FANTASY_POINTS = 19  # fantasyPoints column (index 19 based on CSV inspection)
POSITION = 21  # namedPosition column (index 21 based on CSV inspection)

# Mapping of team abbreviations to full names
TEAM_MAPPING = {
    'ADE': 'Adelaide',
    'BRL': 'Brisbane Lions', 
    'CAR': 'Carlton',
    'COL': 'Collingwood',
    'ESS': 'Essendon',
    'FRE': 'Fremantle',
    'GEE': 'Geelong',
    'GCS': 'Gold Coast',
    'GWS': 'Greater Western Sydney',
    'HAW': 'Hawthorn',
    'MEL': 'Melbourne',
    'NTH': 'North Melbourne',
    'PTA': 'Port Adelaide',
    'RIC': 'Richmond',
    'STK': 'St Kilda',
    'SYD': 'Sydney',
    'WCE': 'West Coast',
    'WBD': 'Western Bulldogs'
}

# Mapping of positions to standardized ones for the frontend
POSITION_MAPPING = {
    'RK': 'RUCK',
    'FF': 'FWD',
    'CHF': 'FWD',
    'FPL': 'FWD',
    'FPR': 'FWD',
    'HFFL': 'FWD',
    'HFFR': 'FWD',
    'FB': 'DEF',
    'CHB': 'DEF',
    'BPL': 'DEF',
    'BPR': 'DEF',
    'HBFL': 'DEF',
    'HBFR': 'DEF',
    'WL': 'MID',
    'WR': 'MID',
    'C': 'MID',
    'R': 'MID',
    'RR': 'MID'
}

def determine_position(named_pos):
    """Convert the named position to a standard position for fantasy."""
    # Default to MID for positions like INT (interchange)
    return POSITION_MAPPING.get(named_pos, 'MID')

def parse_price(avg_points):
    """Calculate player price based on average points.
    
    Price formula is roughly: avg_points * 10000 with some adjustments
    Premium players (100+) are priced above $1M
    """
    base_price = int(avg_points * 10000)
    
    # Adjust prices to create realistic tiers
    if avg_points >= 100:
        return base_price + 50000  # Premium players
    elif avg_points >= 80:
        return base_price + 30000  # Mid-tier players
    elif avg_points >= 60:
        return base_price + 20000  # Sub-premium
    else:
        return max(180000, base_price)  # Ensure minimum price for rookies
    
def estimate_breakeven(avg_points):
    """Estimate a breakeven score based on the player's average.
    
    Breakeven is typically within 10-20% of the player's average
    """
    variation = avg_points * 0.15  # 15% variance
    adjustment = int(variation * (0.5 - (datetime.now().microsecond / 1000000)))  # Random variation
    
    breakeven = int(avg_points + adjustment)
    return max(30, breakeven)  # Ensure minimum breakeven

def get_full_team_name(abbrev):
    """Convert team abbreviation to full name."""
    return TEAM_MAPPING.get(abbrev, abbrev)

def process_csv_file(file_path):
    """Process the AFL stats CSV file into player data."""
    player_stats = defaultdict(list)
    
    with open(file_path, 'r') as csvfile:
        # Skip header lines
        for _ in range(4):
            next(csvfile)
            
        reader = csv.reader(csvfile)
        
        for row in reader:
            if len(row) < 15:  # Skip invalid rows
                continue
                
            try:
                player_name = row[PLAYER]
                team_abbr = row[TEAM]
                team = get_full_team_name(team_abbr)
                named_position = row[POSITION]
                
                # Check if the fantasy points field is valid
                if row[FANTASY_POINTS] and row[FANTASY_POINTS].replace('.', '', 1).isdigit():
                    fantasy_points = float(row[FANTASY_POINTS])
                    
                    # Collect all stats for this player
                    player_stats[player_name].append({
                        'team': team,
                        'position': determine_position(named_position),
                        'fantasy_points': fantasy_points,
                        'named_position': named_position
                    })
            except (IndexError, ValueError) as e:
                print(f"Error processing row: {e}")
                continue
    
    return player_stats

def create_player_data(player_stats):
    """Create the final player data structure."""
    players = []
    timestamp = int(datetime.now().timestamp())
    
    for player_name, matches in player_stats.items():
        if not matches:
            continue
        
        # Calculate stats across all matches
        total_points = sum(match['fantasy_points'] for match in matches)
        num_matches = len(matches)
        avg_points = total_points / num_matches if num_matches > 0 else 0
        
        # Use the most recent match for team and position
        latest_match = matches[-1]
        
        # Calculate price and other metrics
        price = parse_price(avg_points)
        breakeven = estimate_breakeven(avg_points)
        projected_score = max(avg_points * 0.95, avg_points + (5 - (avg_points % 10)))
        
        # Create the player object
        player = {
            "name": player_name,
            "team": latest_match['team'],
            "position": latest_match['position'],
            "price": price,
            "avg": round(avg_points, 1),
            "games": num_matches,
            "breakeven": breakeven,
            "projected_score": int(projected_score),
            "status": "fit",
            "source": "afl_fantasy_stats",
            "timestamp": timestamp
        }
        
        players.append(player)
    
    # Sort by average points (highest first)
    return sorted(players, key=lambda x: x['avg'], reverse=True)

def save_to_json(data, filename='player_data.json'):
    """Save the player data to a JSON file."""
    with open(filename, 'w') as f:
        json.dump(data, f, indent=2)
    print(f"Saved {len(data)} players to {filename}")

def main():
    """Main function to process the AFL stats CSV file."""
    csv_path = 'attached_assets/afl-stats-1746095586623.csv'
    
    if not os.path.exists(csv_path):
        csv_path = 'attached_assets/draftstars-slate-data-1746095770371.csv'
        if not os.path.exists(csv_path):
            print("No AFL stats files found!")
            return
    
    # Process the CSV file
    player_stats = process_csv_file(csv_path)
    
    # Create the player data
    players = create_player_data(player_stats)
    
    # Save to JSON
    save_to_json(players)
    
    print(f"Successfully processed {len(players)} players from AFL stats")

if __name__ == "__main__":
    main()