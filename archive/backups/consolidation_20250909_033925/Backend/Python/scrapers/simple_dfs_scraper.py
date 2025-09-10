import requests
import pandas as pd
import json
import time
from bs4 import BeautifulSoup

def scrape_player_data(player_id, url):
    """Scrape individual player data from DFS Australia"""
    print(f"🔄 Scraping {player_id}...")
    
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    }
    
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        
        soup = BeautifulSoup(response.content, 'html.parser')
        
        # Extract player data
        player_data = {
            'playerId': player_id,
            'url': url,
            'name': '',
            'team': '',
            'position': '',
            'price': '',
            'average': '',
            'last_score': ''
        }
        
        # Try to find player name
        name_element = soup.find('h1') or soup.find('title')
        if name_element:
            player_data['name'] = name_element.get_text(strip=True).split(' - ')[0]
        
        # Try to find key stats tables
        tables = soup.find_all('table')
        
        for table in tables:
            # Look for career averages table
            if 'career' in str(table).lower() or 'average' in str(table).lower():
                rows = table.find_all('tr')
                for row in rows:
                    cells = row.find_all(['td', 'th'])
                    if len(cells) >= 2:
                        header = cells[0].get_text(strip=True).lower()
                        value = cells[1].get_text(strip=True)
                        
                        if 'team' in header:
                            player_data['team'] = value
                        elif 'position' in header:
                            player_data['position'] = value
                        elif 'price' in header:
                            player_data['price'] = value
                        elif 'average' in header:
                            player_data['average'] = value
        
        # Try to extract from page text if tables don't work
        if not player_data['team']:
            page_text = soup.get_text()
            # Look for team abbreviations in common patterns
            for team in ['ADE', 'BRL', 'CAR', 'COL', 'ESS', 'FRE', 'GEE', 'GCS', 'GWS', 'HAW', 'MEL', 'NTH', 'PA', 'RIC', 'STK', 'SYD', 'WCE', 'WB']:
                if team in page_text:
                    player_data['team'] = team
                    break
        
        print(f"✅ Scraped {player_id}: {player_data['name']} ({player_data['team']})")
        return player_data
        
    except Exception as e:
        print(f"❌ Error scraping {player_id}: {e}")
        return None

def main():
    """Main scraper function"""
    print("Starting DFS Australia player scraper...")
    
    # Load player URLs
    try:
        df = pd.read_excel("AFL_Fantasy_Player_URLs.xlsx")
        print(f"Loaded {len(df)} players to scrape")
    except Exception as e:
        print(f"Error loading player URLs: {e}")
        return
    
    # Create output directory
    import os
    output_folder = "dfs_player_summary"
    os.makedirs(output_folder, exist_ok=True)
    
    # Scrape each player
    all_player_data = []
    
    for index, row in df.iterrows():
        player_id = row["playerId"]
        url = row["url"]
        
        player_data = scrape_player_data(player_id, url)
        if player_data:
            all_player_data.append(player_data)
        
        # Add delay to be respectful to the server
        time.sleep(2)
    
    # Save consolidated data
    if all_player_data:
        # Save as JSON
        with open('scraped_players.json', 'w') as f:
            json.dump(all_player_data, f, indent=2)
        
        # Save as CSV
        df_output = pd.DataFrame(all_player_data)
        df_output.to_csv('scraped_players.csv', index=False)
        
        print(f"✅ Scraping complete! Saved {len(all_player_data)} players")
        print(f"Files saved: scraped_players.json, scraped_players.csv")
        
        # Display summary
        print("\nPlayer summary:")
        for player in all_player_data:
            print(f"  {player['name']} ({player['team']}) - {player['position']}")
    else:
        print("No player data was successfully scraped")

if __name__ == "__main__":
    main()