import requests
import json
import pandas as pd
from bs4 import BeautifulSoup
import time

def scrape_dfs_australia_players():
    """Scrape current player data from DFS Australia to get accurate team assignments"""
    print("Scraping DFS Australia player data...")
    
    try:
        # DFS Australia AFL Fantasy Big Board URL
        url = "https://dfsaustralia.com/afl-fantasy-big-board/"
        
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }
        
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        
        soup = BeautifulSoup(response.content, 'html.parser')
        
        # Look for the player data table
        table = soup.find('table', {'id': 'big-board-table'}) or soup.find('table')
        
        if not table:
            print("Could not find player table on DFS Australia")
            return None
            
        # Extract headers
        headers_row = table.find('thead') or table.find('tr')
        if headers_row:
            headers = [th.get_text(strip=True) for th in headers_row.find_all(['th', 'td'])]
        else:
            headers = ['Name', 'Team', 'Position', 'Price', 'Average', 'Last_Score']
        
        # Extract player data
        players = []
        tbody = table.find('tbody') or table
        rows = tbody.find_all('tr')[1:] if tbody.find('thead') else tbody.find_all('tr')
        
        for row in rows:
            cells = row.find_all(['td', 'th'])
            if len(cells) >= 3:  # At least name, team, position
                player_data = [cell.get_text(strip=True) for cell in cells]
                players.append(player_data)
        
        if players:
            # Create DataFrame with proper column names
            df = pd.DataFrame(players, columns=headers[:len(players[0])])
            print(f"Successfully scraped {len(players)} players from DFS Australia")
            return df
        else:
            print("No player data found in table")
            return None
            
    except Exception as e:
        print(f"Error scraping DFS Australia: {e}")
        return None

def scrape_footywire_players():
    """Scrape player data from FootyWire as backup"""
    print("Scraping FootyWire player data...")
    
    try:
        url = "https://www.footywire.com/afl/footy/dream_team_breakevens"
        
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }
        
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        
        soup = BeautifulSoup(response.content, 'html.parser')
        
        # Look for the breakevens table
        table = soup.find('table')
        
        if not table:
            print("Could not find player table on FootyWire")
            return None
            
        # Extract data
        rows = table.find_all('tr')
        if len(rows) < 2:
            print("Not enough data in FootyWire table")
            return None
            
        # Get headers
        headers = [th.get_text(strip=True) for th in rows[0].find_all(['th', 'td'])]
        
        # Extract player data
        players = []
        for row in rows[1:]:
            cells = row.find_all(['td', 'th'])
            if len(cells) >= 3:
                player_data = [cell.get_text(strip=True) for cell in cells]
                players.append(player_data)
        
        if players:
            df = pd.DataFrame(players, columns=headers[:len(players[0])])
            print(f"Successfully scraped {len(players)} players from FootyWire")
            return df
        else:
            print("No player data found in FootyWire table")
            return None
            
    except Exception as e:
        print(f"Error scraping FootyWire: {e}")
        return None

def update_player_data_with_teams(scraped_df):
    """Update existing player data files with correct team assignments"""
    if scraped_df is None:
        print("No scraped data available for team updates")
        return
    
    # Load existing player data files
    player_files = [
        'player_data.json',
        'player_data_backup_20250501_201717.json',
        'player_data_backup_20250501_201800.json', 
        'player_data_backup_2025-05-02T041.json',
        'player_data_backup_2025-05-03T154.json'
    ]
    
    # Create team mapping from scraped data
    team_mapping = {}
    
    # Try to identify name and team columns
    name_col = None
    team_col = None
    
    for col in scraped_df.columns:
        col_lower = col.lower()
        if 'name' in col_lower or 'player' in col_lower:
            name_col = col
        elif 'team' in col_lower or 'club' in col_lower:
            team_col = col
    
    if name_col and team_col:
        for _, row in scraped_df.iterrows():
            player_name = str(row[name_col]).strip()
            team_name = str(row[team_col]).strip()
            if player_name and team_name:
                # Normalize name for matching
                normalized_name = player_name.lower().replace('.', '').replace(',', '')
                team_mapping[normalized_name] = team_name
                
        print(f"Created team mapping for {len(team_mapping)} players")
        
        # Update each player data file
        updates_made = 0
        for file_path in player_files:
            try:
                with open(file_path, 'r') as f:
                    players = json.load(f)
                
                if isinstance(players, list):
                    for player in players:
                        if 'name' in player:
                            normalized_name = player['name'].lower().replace('.', '').replace(',', '')
                            if normalized_name in team_mapping:
                                old_team = player.get('team', 'Unknown')
                                new_team = team_mapping[normalized_name]
                                if old_team != new_team:
                                    player['team'] = new_team
                                    updates_made += 1
                
                # Save updated file
                with open(file_path, 'w') as f:
                    json.dump(players, f, indent=2)
                    
                print(f"Updated {file_path}")
                
            except Exception as e:
                print(f"Error updating {file_path}: {e}")
        
        print(f"Made {updates_made} team updates across all files")
        
        # Save the scraped data for reference
        scraped_df.to_csv('scraped_player_teams.csv', index=False)
        scraped_df.to_json('scraped_player_teams.json', orient='records', indent=2)
        print("Saved scraped data to scraped_player_teams.csv and .json")
        
    else:
        print(f"Could not identify name and team columns in scraped data. Columns: {list(scraped_df.columns)}")

def main():
    """Main function to scrape and update player team data"""
    print("Starting player team data update...")
    
    # Try DFS Australia first
    df = scrape_dfs_australia_players()
    
    # If that fails, try FootyWire  
    if df is None:
        df = scrape_footywire_players()
    
    # Update player data with correct teams
    if df is not None:
        print(f"Scraped data columns: {list(df.columns)}")
        print(f"First few rows:")
        print(df.head())
        update_player_data_with_teams(df)
    else:
        print("Failed to scrape player data from any source")

if __name__ == "__main__":
    main()