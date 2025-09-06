#!/usr/bin/env python3
"""
DFS Australia Data Parser for AFL Fantasy

This script parses the CSV data from DFS Australia and processes it into the format used by the AFL Fantasy app.
"""

import csv
import json
import os
from datetime import datetime

def team_abbrev_to_full(abbrev):
    """Convert team abbreviation to full name"""
    teams = {
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
    return teams.get(abbrev, abbrev)

def parse_dfs_data(csv_path):
    """Parse DFS Australia CSV data into our application format"""
    players = []
    
    with open(csv_path, 'r') as f:
        # Skip the first 3 lines (header info)
        for _ in range(3):
            next(f)
        
        # Read the CSV data
        reader = csv.DictReader(f)
        
        for row in reader:
            # Skip empty rows
            if not row['player'] or not row['avg']:
                continue
                
            try:
                # Process numeric fields
                avg = float(row['avg']) if row['avg'] else 0
                # Convert Draftstars salaries to AFL Fantasy prices
                # Create a more realistic mapping:
                # - Top premium players (16000-17000) -> $1M-$1.2M
                # - Mid-tier players (10000-15999) -> $500K-$999K
                # - Rookies (6000-9999) -> $200K-$499K
                raw_salary = float(row['salary']) if row['salary'] else 0
                
                # Use salary brackets with different scaling for each tier
                if raw_salary >= 16000:  # Premium tier
                    # Scale 16000-17000 to 1000000-1200000
                    normalized = (raw_salary - 16000) / (17000 - 16000)
                    price = int(1000000 + normalized * 200000)
                elif raw_salary >= 10000:  # Mid-tier
                    # Scale 10000-15999 to 500000-999999
                    normalized = (raw_salary - 10000) / (16000 - 10000)
                    price = int(500000 + normalized * 500000)
                elif raw_salary >= 6000:  # Rookie tier
                    # Scale 6000-9999 to 200000-499999
                    normalized = (raw_salary - 6000) / (10000 - 6000)
                    price = int(200000 + normalized * 300000)
                else:  # Below rookie minimum
                    # Anything below 6000 is scaled proportionally to 200K
                    price = int((raw_salary / 6000) * 200000)
                games = int(row['gms']) if row['gms'] else 0
                stddev = int(row['stddev']) if row['stddev'] else 0
                max_score = int(row['max']) if row['max'] else 0
                min_score = int(row['min']) if row['min'] else 0
                
                # Last 5 rounds
                last1 = int(row['last1']) if row['last1'] else None
                last2 = int(row['last2']) if row['last2'] else None
                last3 = int(row['last3']) if row['last3'] else None
                last4 = int(row['last4']) if row['last4'] else None
                last5 = int(row['last5']) if row['last5'] else None
                
                # Win/loss averages
                win_avg = float(row['win']) if row['win'] else None
                loss_avg = float(row['loss']) if row['loss'] else None
                
                # Opposition data 
                opposition1 = int(row['O1']) if row['O1'] else None
                opposition2 = int(row['O2']) if row['O2'] else None
                
                # Calculate last 3 and last 5 averages
                last_3_scores = [s for s in [last1, last2, last3] if s is not None]
                last_5_scores = [s for s in [last1, last2, last3, last4, last5] if s is not None]
                
                last_3_avg = sum(last_3_scores) / len(last_3_scores) if last_3_scores else None
                last_5_avg = sum(last_5_scores) / len(last_5_scores) if last_5_scores else None
                
                # Calculate breakeven (estimated)
                # This is simplified - real breakeven calculations are more complex
                last_score = last1 if last1 else (last2 if last2 else None)
                breakeven = int(avg - (last_score - avg)/2) if last_score else int(avg * 0.9)
                
                # Get position
                position = row['position']
                if '/' in position:
                    # If multiple positions, use the first one
                    position = position.split('/')[0]
                
                # Create player object
                player = {
                    "name": row['player'],
                    "position": position,
                    "team": team_abbrev_to_full(row['team']),
                    "price": price,
                    "avg": avg,
                    "games": games,
                    "breakeven": breakeven,
                    "last_5_avg": last_5_avg,
                    "last_3_avg": last_3_avg,
                    "proj_score": last_3_avg if last_3_avg else avg,
                    "value": round(avg / (price / 1000000), 2),
                    "last_score": last1,
                    "stddev": stddev,
                    "max_score": max_score,
                    "min_score": min_score,
                    "last1": last1,
                    "last2": last2,
                    "last3": last3,
                    "last4": last4,
                    "last5": last5,
                    "win_avg": win_avg,
                    "loss_avg": loss_avg,
                    "opposition1": opposition1,
                    "opposition2": opposition2,
                    "source": "dfs_australia",
                    "timestamp": int(datetime.now().timestamp())
                }
                
                players.append(player)
            except Exception as e:
                print(f"Error processing row for {row.get('player', 'unknown player')}: {e}")
    
    # Sort by average points, descending
    players.sort(key=lambda x: x['avg'], reverse=True)
    
    return players

def save_to_json(data, filename='player_data.json'):
    """Save the player data to a JSON file"""
    with open(filename, 'w') as f:
        json.dump(data, f, indent=2)
    print(f"Saved {len(data)} players to {filename}")

def manual_player_adjustments(players):
    """
    Make manual adjustments to specific players with known accurate data
    from the official AFL Fantasy website
    """
    # Find Nick Daicos in players list
    for player in players:
        if player["name"] == "Nick Daicos":
            # Update with exact values from the Fantasy screenshot
            player.update({
                "price": 1092000,  
                "avg": 107.7,
                "games": 7,
                "breakeven": 95,
                "last_5_avg": 119.8,
                "last_3_avg": 129,
                "proj_score": 105,
                "total_points": 754,
                "season_price_change": 18000,
                "price_per_point": 10100,
                "projected_price_change": 16000,
                "bye_round": 14,
                "source": "afl_fantasy_official",
            })
            print(f"Updated Nick Daicos stats with official AFL Fantasy data")
    
    return players

def main():
    # Get the script directory
    csv_path = 'attached_assets/draftstars-slate-data-1746095770371.csv'
    if not os.path.exists(csv_path):
        print(f"CSV file not found: {csv_path}")
        return
    
    # Parse DFS Australia data
    players = parse_dfs_data(csv_path)
    
    # Apply manual adjustments for verified players
    players = manual_player_adjustments(players)
    
    # Save to JSON
    save_to_json(players)
    print(f"Processed {len(players)} players from DFS Australia data with official corrections")

if __name__ == "__main__":
    main()