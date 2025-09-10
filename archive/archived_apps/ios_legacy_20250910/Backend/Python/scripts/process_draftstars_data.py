#!/usr/bin/env python3
"""
Process DraftStars player data into player_data.json

This script converts DraftStars CSV data into the proper format for our AFL Fantasy application.
"""

import pandas as pd
import json
import os
import sys
from typing import Dict, List, Any, Optional


def team_abbrev_to_full(abbrev: str) -> str:
    """Convert team abbreviation to full name"""
    teams = {
        "ADE": "Adelaide",
        "BRL": "Brisbane",
        "CAR": "Carlton",
        "COL": "Collingwood",
        "ESS": "Essendon",
        "FRE": "Fremantle",
        "GCS": "Gold Coast",
        "GEE": "Geelong",
        "GWS": "Greater Western Sydney",
        "HAW": "Hawthorn",
        "MEL": "Melbourne",
        "NTH": "North Melbourne",
        "PTA": "Port Adelaide",
        "RIC": "Richmond",
        "STK": "St Kilda",
        "SYD": "Sydney",
        "WBD": "Western Bulldogs",
        "WCE": "West Coast",
    }
    return teams.get(abbrev, abbrev)


def determine_position(position_str: str) -> str:
    """Convert various position formats to standard positions (DEF, MID, FWD, RUC)"""
    if not position_str or pd.isna(position_str):
        return "UNK"
    
    position_str = position_str.upper()
    
    if "DEF" in position_str:
        return "DEF"
    elif "RUC" in position_str or "RUCK" in position_str:
        return "RUC"
    elif "MID" in position_str:
        return "MID"
    elif "FWD" in position_str or "FOR" in position_str:
        return "FWD"
    else:
        return "UNK"


def estimate_breakeven(avg_points: float) -> int:
    """Estimate a breakeven score based on the player's average"""
    # Simple estimation: breakeven is similar to average +/- some variation
    import random
    variation = random.uniform(-10, 10)
    return max(0, int(avg_points + variation))


def process_draftstars_data(csv_path: str) -> List[Dict[str, Any]]:
    """Process DraftStars CSV data into player data"""
    print(f"Processing DraftStars data from {csv_path}")
    
    # Skip the first 3 rows (headers and info)
    df = pd.read_csv(csv_path, skiprows=3)
    
    players = []
    for _, row in df.iterrows():
        # Basic validation
        if pd.isna(row['player']) or not row['player']:
            continue
        
        # Extract data
        name = row['player']
        team_abbrev = row.get('team', '')
        team = team_abbrev_to_full(team_abbrev)
        
        # Calculate fields based on available data
        avg = float(row.get('avg', 0)) if not pd.isna(row.get('avg', 0)) else 0
        l3_avg = float(row.get('L3', 0)) if not pd.isna(row.get('L3', 0)) else avg
        games = int(row.get('gms', 0)) if not pd.isna(row.get('gms', 0)) else 0
        
        # Convert salary to price (AFL Fantasy format)
        salary = row.get('salary', 0)
        if pd.isna(salary):
            salary = 0
        price = int(salary) * 100 if int(salary) > 0 else int(avg * 10000)
        
        # Calculate breakeven
        breakeven = estimate_breakeven(avg)
        
        # Determine position
        position = determine_position(row.get('position', ''))
        
        # Create player object
        player = {
            "name": name,
            "team": team,
            "position": position,
            "price": price,
            "breakeven": breakeven,
            "l3_avg": l3_avg,
            "avg": avg,
            "games": games,
            "score_history": [],
        }
        
        # Add score history if available (last5, last4, last3, last2, last1)
        score_history = []
        for i in range(5, 0, -1):
            key = f'last{i}'
            if key in row and not pd.isna(row[key]):
                score_history.append(float(row[key]))
            
        if score_history:
            player["score_history"] = score_history
            
        players.append(player)
    
    print(f"Processed {len(players)} players")
    return players


def save_to_json(data: List[Dict], filename: str = 'player_data.json') -> None:
    """Save the player data to a JSON file"""
    with open(filename, 'w') as f:
        json.dump(data, f, indent=2)
    print(f"Saved {len(data)} players to {filename}")


def load_existing_data(filename: str = 'player_data.json') -> List[Dict]:
    """Load existing player data if available"""
    try:
        with open(filename, 'r') as f:
            data = json.load(f)
        print(f"Loaded {len(data)} players from existing {filename}")
        return data
    except (FileNotFoundError, json.JSONDecodeError):
        print(f"No valid existing data found at {filename}")
        return []


def merge_player_data(existing_data: List[Dict], new_data: List[Dict]) -> List[Dict]:
    """Merge existing player data with new data, preferring new data for conflicts"""
    if not existing_data:
        return new_data
    
    # Create lookup dictionaries
    existing_dict = {(p["name"].lower(), p.get("team", "").lower()): p for p in existing_data}
    
    # Start with copy of new data
    merged_data = new_data.copy()
    
    # Add any players from existing data that aren't in new data
    for player in existing_data:
        key = (player["name"].lower(), player.get("team", "").lower())
        if key not in {(p["name"].lower(), p.get("team", "").lower()) for p in new_data}:
            merged_data.append(player)
    
    print(f"Merged data contains {len(merged_data)} players")
    return merged_data


def main():
    """Main function to process the DraftStars data"""
    # Default CSV file path
    csv_file = "attached_assets/draftstars-slate-data-1746095770371.csv"
    
    # Check command line arguments for a different file
    if len(sys.argv) > 1:
        csv_file = sys.argv[1]
    
    # Verify the file exists
    if not os.path.exists(csv_file):
        print(f"Error: File {csv_file} not found")
        return
    
    # Load existing data if available
    existing_data = load_existing_data()
    
    # Process DraftStars data
    player_data = process_draftstars_data(csv_file)
    
    # Merge with existing data if needed
    if existing_data:
        player_data = merge_player_data(existing_data, player_data)
    
    # Save to JSON
    save_to_json(player_data)


if __name__ == "__main__":
    main()