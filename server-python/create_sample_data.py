import pandas as pd

# Sample AFL Fantasy player data
# These are example URLs - you'll need to replace with actual AFL Fantasy URLs
sample_data = {
    "playerId": ["player_001", "player_002", "player_003"],
    "url": [
        "https://www.afl.com.au/fantasy/player/1",
        "https://www.afl.com.au/fantasy/player/2", 
        "https://www.afl.com.au/fantasy/player/3"
    ]
}

# Create DataFrame and save to Excel
df = pd.DataFrame(sample_data)
df.to_excel("AFL_Fantasy_Player_URLs.xlsx", index=False)
print("✅ Created sample AFL_Fantasy_Player_URLs.xlsx file")
print("📝 Please update the file with actual player URLs before running the scraper")
print(df)
