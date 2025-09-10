#!/usr/bin/env python3
"""
Update the sample AFL Fantasy Player URLs file to include player names
"""

import pandas as pd

def update_sample_data():
    # Sample data with player names
    data = {
        'playerId': ['player_001', 'player_002', 'player_003'],
        'Player': ['Marcus Bontempelli', 'Patrick Cripps', 'Lachie Neale'],  # Sample names
        'url': [
            'https://www.afl.com.au/fantasy/player/1',
            'https://www.afl.com.au/fantasy/player/2', 
            'https://www.afl.com.au/fantasy/player/3'
        ]
    }
    
    df = pd.DataFrame(data)
    
    # Save to Excel
    df.to_excel("AFL_Fantasy_Player_URLs.xlsx", index=False)
    
    print("✅ Updated AFL_Fantasy_Player_URLs.xlsx with Player names")
    print("📝 Sample data:")
    print(df)
    print("\n💡 Replace with actual player data before using the renaming script")

if __name__ == "__main__":
    update_sample_data()
