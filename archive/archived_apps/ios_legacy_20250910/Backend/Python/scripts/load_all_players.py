#!/usr/bin/env python3

import pandas as pd
import json
import os
from pathlib import Path

def load_complete_player_database():
    """Load all 643 players from the authentic AFL Fantasy Round 13 data"""
    
    print("Loading complete AFL Fantasy player database...")
    
    # Read the authentic Round 13 data
    excel_path = "attached_assets/currentdt_liveR13_1753069161334.xlsx"
    
    try:
        # Read with proper header (row 1 contains column names)
        df = pd.read_excel(excel_path, header=1)
        print(f"✓ Loaded {len(df)} players from authentic AFL Fantasy data")
        
        # Clean and process the data
        players = []
        
        for index, row in df.iterrows():
            try:
                # Skip rows with missing player names
                if pd.isna(row.get('Player')) or row.get('Player') == '':
                    continue
                
                player_name = str(row['Player']).strip()
                if not player_name or player_name.lower() in ['nan', 'none']:
                    continue
                
                # Extract basic player information
                player = {
                    "id": index + 1,
                    "name": player_name,
                    "position": str(row.get('Position', 'Unknown')).upper(),
                    "price": int(row.get('Price $', 0)) if pd.notna(row.get('Price $')) else 0,
                    "startPrice": int(row.get('Start $', 0)) if pd.notna(row.get('Start $')) else 0,
                    "priceChange": int(row.get('$ Change', 0)) if pd.notna(row.get('$ Change')) else 0,
                    "ownership": float(row.get('Own (%)', 0)) if pd.notna(row.get('Own (%)')) else 0.0,
                    "games": int(row.get('Games', 0)) if pd.notna(row.get('Games')) else 0,
                    "averageScore": float(row.get('Avg', 0)) if pd.notna(row.get('Avg')) else 0.0,
                    "totalPoints": int(row.get('Points', 0)) if pd.notna(row.get('Points')) else 0,
                    "breakeven": int(row.get('BE', 0)) if pd.notna(row.get('BE')) else 0,
                    "ppm": float(row.get('PPM', 0)) if pd.notna(row.get('PPM')) else 0.0,
                    "economy": int(row.get('Eco', 0)) if pd.notna(row.get('Eco')) else 0,
                    "priceRise": float(row.get('PR', 0)) if pd.notna(row.get('PR')) else 0.0,
                }
                
                # Add team (default to Unknown for now - can be enhanced later)
                player["team"] = "Unknown"
                
                # Calculate derived fields
                if player["games"] > 0:
                    player["projectedScore"] = round(player["averageScore"] * 1.05, 1)  # 5% projection boost
                    player["pricePerPoint"] = round(player["price"] / max(player["averageScore"], 1), 0)
                else:
                    player["projectedScore"] = 0
                    player["pricePerPoint"] = 0
                
                # Add recent form data (last 5 rounds from columns 14-18)
                recent_scores = []
                for i in range(14, 19):  # Columns 14-18 for last 5 rounds
                    if i < len(row) and pd.notna(row.iloc[i]):
                        recent_scores.append(int(row.iloc[i]))
                
                player["recentForm"] = recent_scores
                player["l5Average"] = round(sum(recent_scores) / len(recent_scores), 1) if recent_scores else 0
                
                # Set category based on price
                if player["price"] >= 600000:
                    player["category"] = "Premium"
                elif player["price"] >= 400000:
                    player["category"] = "Mid-Priced"
                else:
                    player["category"] = "Rookie"
                
                players.append(player)
                
            except Exception as e:
                print(f"Warning: Error processing player {row.get('Player', 'Unknown')}: {e}")
                continue
        
        print(f"✓ Successfully processed {len(players)} players")
        
        # Write to player_data.json
        output_path = "player_data.json"
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(players, f, indent=2, ensure_ascii=False)
        
        print(f"✓ Saved complete player database to {output_path}")
        print(f"✓ Player count: {len(players)}")
        
        # Show sample of loaded players
        print("\nSample players loaded:")
        for i in range(min(10, len(players))):
            player = players[i]
            print(f"  {player['name']} ({player['position']}) - ${player['price']:,} - {player['averageScore']} avg")
        
        return players
        
    except Exception as e:
        print(f"Error loading player database: {e}")
        return None

if __name__ == "__main__":
    players = load_complete_player_database()
    if players:
        print(f"\n🎉 Successfully loaded {len(players)} players!")
        print("The AFL Fantasy platform now has access to all authentic player data.")
    else:
        print("❌ Failed to load complete player database")