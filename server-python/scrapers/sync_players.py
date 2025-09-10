#!/usr/bin/env python3
"""
AFL Fantasy Player Sync Script
Syncs player data from scrapers into the PostgreSQL database
"""

import os
import sys
import json
import argparse
import psycopg2
from psycopg2 import sql
from datetime import datetime

# Add backend to path
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'backend', 'python'))
from scrapers.scraper import get_dfs_australia_player_data

def get_db_connection(database_url=None):
    """Get database connection"""
    if not database_url:
        database_url = os.getenv('DATABASE_URL', 'postgresql://postgres:password@127.0.0.1:5432/afl_fantasy')
    
    try:
        conn = psycopg2.connect(database_url)
        return conn
    except Exception as e:
        print(f"Error connecting to database: {e}")
        return None

def create_sample_players():
    """Create sample player data for testing"""
    return [
        {"name": "Max Gawn", "position": "RUC", "team": "Melbourne", "price": 800000, "average_score": 105.2, "break_even": 78},
        {"name": "Clayton Oliver", "position": "MID", "team": "Melbourne", "price": 750000, "average_score": 115.8, "break_even": 82},
        {"name": "Christian Petracca", "position": "MID", "team": "Melbourne", "price": 720000, "average_score": 110.4, "break_even": 85},
        {"name": "Marcus Bontempelli", "position": "MID", "team": "Western Bulldogs", "price": 700000, "average_score": 108.7, "break_even": 89},
        {"name": "Touk Miller", "position": "MID", "team": "Gold Coast", "price": 650000, "average_score": 102.3, "break_even": 76},
        {"name": "Lachie Neale", "position": "MID", "team": "Brisbane", "price": 680000, "average_score": 112.1, "break_even": 88},
        {"name": "Sam Walsh", "position": "MID", "team": "Carlton", "price": 620000, "average_score": 98.5, "break_even": 72},
        {"name": "Tim Taranto", "position": "MID", "team": "Richmond", "price": 580000, "average_score": 95.2, "break_even": 65},
        {"name": "Rory Laird", "position": "DEF", "team": "Adelaide", "price": 600000, "average_score": 92.8, "break_even": 68},
        {"name": "Jake Lloyd", "position": "DEF", "team": "Sydney", "price": 590000, "average_score": 89.4, "break_even": 71},
        {"name": "Jeremy McGovern", "position": "DEF", "team": "West Coast", "price": 550000, "average_score": 85.6, "break_even": 63},
        {"name": "Jordan Dawson", "position": "DEF", "team": "Adelaide", "price": 570000, "average_score": 88.9, "break_even": 69},
        {"name": "Nick Daicos", "position": "DEF", "team": "Collingwood", "price": 650000, "average_score": 95.7, "break_even": 78},
        {"name": "Tom Stewart", "position": "DEF", "team": "Geelong", "price": 620000, "average_score": 91.3, "break_even": 75},
        {"name": "Charlie Curnow", "position": "FWD", "team": "Carlton", "price": 750000, "average_score": 98.5, "break_even": 92},
        {"name": "Jeremy Cameron", "position": "FWD", "team": "Geelong", "price": 700000, "average_score": 89.7, "break_even": 86},
        {"name": "Tom Hawkins", "position": "FWD", "team": "Geelong", "price": 600000, "average_score": 82.4, "break_even": 71},
        {"name": "Taylor Walker", "position": "FWD", "team": "Adelaide", "price": 580000, "average_score": 78.9, "break_even": 68},
        {"name": "Isaac Heeney", "position": "FWD", "team": "Sydney", "price": 650000, "average_score": 85.3, "break_even": 79},
        {"name": "Toby Greene", "position": "FWD", "team": "GWS", "price": 620000, "average_score": 88.1, "break_even": 74},
        # Add some rookies
        {"name": "George Wardlaw", "position": "MID", "team": "North Melbourne", "price": 350000, "average_score": 45.2, "break_even": 32},
        {"name": "Mattaes Phillipou", "position": "MID", "team": "St Kilda", "price": 380000, "average_score": 52.8, "break_even": 38},
        {"name": "Cam Mackenzie", "position": "FWD", "team": "Hawthorn", "price": 320000, "average_score": 38.5, "break_even": 28},
        {"name": "Jye Amiss", "position": "FWD", "team": "Fremantle", "price": 410000, "average_score": 58.3, "break_even": 42},
        {"name": "Sam Darcy", "position": "FWD", "team": "Western Bulldogs", "price": 450000, "average_score": 62.7, "break_even": 48},
    ]

def sync_players_to_db(players, conn, dry_run=False):
    """Sync player data to database"""
    cursor = conn.cursor()
    
    try:
        if dry_run:
            print(f"DRY RUN: Would sync {len(players)} players to database")
            for player in players[:5]:  # Show first 5
                print(f"  - {player['name']} ({player['position']}) - ${player['price']:,}")
            if len(players) > 5:
                print(f"  ... and {len(players) - 5} more players")
            return True
        
        # Clear existing players for fresh sync
        cursor.execute("TRUNCATE TABLE players RESTART IDENTITY CASCADE")
        
        insert_query = """
            INSERT INTO players (name, position, team, price, average_score, break_even, 
                               last_score, projected_score, rounds_played, ownership_percentage)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        
        inserted_count = 0
        for player in players:
            # Map scraper fields to database fields
            name = player.get('name', 'Unknown')
            position = player.get('position', 'UNK')
            team = player.get('team', 'Unknown')
            price = int(player.get('price', 0))
            
            # Handle different naming conventions for averages
            avg_score = float(player.get('average_score', 
                                      player.get('l3_avg', 
                                               player.get('avg', 0))))
            
            break_even = int(player.get('break_even', 
                                      player.get('breakeven', 0)))
            
            last_score = int(player.get('last_score', 0))
            projected_score = int(player.get('projected_score', avg_score))
            rounds_played = int(player.get('rounds_played', 
                                         player.get('games', 3)))
            ownership = float(player.get('ownership_percentage', 
                                       player.get('ownership', 5.0)))
            
            cursor.execute(insert_query, (
                name, position, team, price, avg_score, break_even,
                last_score, projected_score, rounds_played, ownership
            ))
            inserted_count += 1
        
        conn.commit()
        print(f"Successfully synced {inserted_count} players to database")
        return True
        
    except Exception as e:
        conn.rollback()
        print(f"Error syncing players to database: {e}")
        return False
    finally:
        cursor.close()

def get_player_count(conn):
    """Get current player count in database"""
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT COUNT(*) FROM players")
        count = cursor.fetchone()[0]
        return count
    except Exception as e:
        print(f"Error getting player count: {e}")
        return 0
    finally:
        cursor.close()

def main():
    parser = argparse.ArgumentParser(description='Sync AFL Fantasy players to database')
    parser.add_argument('--dry-run', action='store_true', 
                       help='Show what would be synced without making changes')
    parser.add_argument('--use-sample', action='store_true',
                       help='Use sample data instead of scraping')
    
    args = parser.parse_args()
    
    print("AFL Fantasy Player Sync")
    print("=" * 40)
    
    # Get database connection
    conn = get_db_connection()
    if not conn:
        print("Failed to connect to database")
        return 1
    
    print(f"Connected to database successfully")
    
    # Get current player count
    current_count = get_player_count(conn)
    print(f"Current players in database: {current_count}")
    
    # Get player data
    try:
        if args.use_sample:
            print("Using sample player data...")
            players = create_sample_players()
        else:
            print("Fetching player data from scrapers...")
            players = get_dfs_australia_player_data()
            
            # If scraping failed, fall back to sample data
            if not players:
                print("Scraping failed, falling back to sample data...")
                players = create_sample_players()
        
        if not players:
            print("No player data available")
            return 1
            
        print(f"Retrieved {len(players)} players")
        
        # Sync to database
        success = sync_players_to_db(players, conn, dry_run=args.dry_run)
        
        if success and not args.dry_run:
            new_count = get_player_count(conn)
            print(f"Database now contains {new_count} players")
        
        return 0 if success else 1
        
    except Exception as e:
        print(f"Error: {e}")
        return 1
    finally:
        conn.close()

if __name__ == "__main__":
    exit(main())
