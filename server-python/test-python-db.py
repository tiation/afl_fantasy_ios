#!/usr/bin/env python3
"""
Test Database Connectivity - Python with psycopg2
Tests connection to PostgreSQL database for Flask API
"""

import os
import sys
import psycopg2
from datetime import datetime

DATABASE_URL = os.getenv('DATABASE_URL', 'postgresql://postgres:password@127.0.0.1:5432/afl_fantasy')

def test_python_db_connection():
    """Test Python database connectivity"""
    print("🔄 Testing Python Database Connectivity")
    print("=" * 50)
    
    conn = None
    try:
        # Test connection
        print("📡 Connecting to database...")
        print(f"   URL: {DATABASE_URL.replace('password@', '***@')}")
        
        conn = psycopg2.connect(DATABASE_URL)
        cursor = conn.cursor()
        
        # Test basic query
        cursor.execute("SELECT version(), now() as current_time")
        result = cursor.fetchone()
        
        print("✅ Database connection successful!")
        print(f"   Version: {result[0].split(' ')[0:3]}")
        print(f"   Time: {result[1]}")
        
        # Test player count
        cursor.execute("SELECT COUNT(*) FROM players")
        player_count = cursor.fetchone()[0]
        print(f"\n📊 Players in database: {player_count}")
        
        if player_count > 0:
            # Get sample players
            cursor.execute("""
                SELECT id, name, team, position, price, average_score 
                FROM players 
                ORDER BY price DESC 
                LIMIT 3
            """)
            
            players = cursor.fetchall()
            print("\n📊 Sample players (top 3 by price):")
            for i, player in enumerate(players, 1):
                pid, name, team, pos, price, avg = player
                print(f"   {i}. {name} ({team}) - ${price:,} - {avg} avg")
                
        else:
            print("⚠️  No players found in database. Run sync_players.py first.")
        
        cursor.close()
        return True
        
    except Exception as error:
        print("❌ Database connection failed:")
        print(f"   Error: {error}")
        
        if 'ECONNREFUSED' in str(error):
            print("   💡 Tip: Make sure PostgreSQL is running")
        elif 'authentication' in str(error):
            print("   💡 Tip: Check username/password")
        elif 'database' in str(error) and 'does not exist' in str(error):
            print("   💡 Tip: Create database first")
            
        return False
        
    finally:
        if conn:
            conn.close()
            print("\n🔐 Database connection closed")

if __name__ == "__main__":
    success = test_python_db_connection()
    print(f"\n{'✅' if success else '❌'} Python database connectivity test {'PASSED' if success else 'FAILED'}")
    sys.exit(0 if success else 1)
