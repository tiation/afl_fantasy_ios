import requests
from bs4 import BeautifulSoup
import json
import re
import csv
import os
from datetime import datetime
import pandas as pd  # For Excel file processing

def scrape_footywire():
    """Scrape AFL Fantasy stats from Footywire website (only Fantasy, not Dream Team or SuperCoach)"""
    urls = [
        # Main Fantasy stats pages
        "https://www.footywire.com/afl/footy/ft_player_rankings?year=2025&rt=LA&st=AF", # AFL Fantasy stats for 2025
        "https://www.footywire.com/afl/footy/ft_player_rankings?year=2024&rt=LA&st=AF", # AFL Fantasy stats for 2024 
        "https://www.footywire.com/afl/footy/ft_player_rankings?year=2023&rt=LA&st=AF", # AFL Fantasy stats for 2023
        "https://www.footywire.com/afl/footy/ft_player_rankings", # Default stats
        
        # Breakeven pages (based on the reference code in afl_fantasy_scraper.py)
        "https://www.footywire.com/afl/footy/dream_team_breakevens",
        "https://www.footywire.com/afl/footy/dream_team_breakevens?year=2024",
        "https://www.footywire.com/afl/footy/dream_team_breakevens?year=2023"
    ]
    
    all_player_data = []
    
    for url in urls:
        print(f"Sending request to Footywire website: {url}")
        try:
            response = requests.get(url, timeout=10)
            
            # Check if the request was successful
            if response.status_code != 200:
                print(f"Failed to retrieve the webpage. Status code: {response.status_code}")
                continue
            
            # Parse the HTML content
            print("Parsing HTML content...")
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Find the main table containing player data
            player_table = soup.find('table', {'class': 'data'})
            
            if not player_table:
                print("Player table not found on this page.")
                continue
            
            # Extract player data
            # Get all rows from the table and skip the header
            table_rows = player_table.find_all('tr')
            rows = table_rows[1:] if table_rows else []
            
            print(f"Extracting player data from {url}...")
            for row in rows:
                columns = row.find_all('td')
                if len(columns) >= 6:  # Ensure row has enough columns
                    # Extract name and team
                    name_column = columns[1]
                    name_text = name_column.get_text(strip=True)
                    
                    # Split into name and team
                    name_parts = name_text.split('(')
                    if len(name_parts) > 1:
                        name = name_parts[0].strip()
                        team = name_parts[1].strip().rstrip(')')
                    else:
                        name = name_text
                        team = "Unknown"
                    
                    # Create player data dict
                    player_info = {
                        'name': name,
                        'team': team,
                        'source': 'footywire'
                    }
                    
                    # Extract games, avg, price, breakeven if available
                    # The column indices might be different across pages
                    for i, col in enumerate(columns[2:8]):  # Check a few columns after name
                        text = col.get_text(strip=True)
                        if text:
                            # Try to guess what this column represents
                            if re.match(r'^\d+$', text):  # Looks like games played
                                if 'games' not in player_info:
                                    player_info['games'] = text
                            elif re.match(r'^\d+\.\d+$', text):  # Looks like an average
                                if 'avg' not in player_info:
                                    player_info['avg'] = text
                            elif re.match(r'^\$[\d,]+$', text) or re.match(r'^[\d,]+$', text):  # Looks like price
                                if 'price' not in player_info:
                                    player_info['price'] = re.sub(r'[^\d]', '', text)
                            elif text == 'N/A' or re.match(r'^-?\d+$', text):  # Looks like breakeven
                                if 'breakeven' not in player_info:
                                    player_info['breakeven'] = text
                    
                    all_player_data.append(player_info)
        except Exception as e:
            print(f"Error scraping {url}: {e}")
    
    return all_player_data

def scrape_afl_com():
    """Scrape data from AFL.com fantasy section"""
    urls = [
        "https://fantasy.afl.com.au/classic/rankings/players",
        "https://www.afl.com.au/fantasy/players",
        "https://www.afl.com.au/stats/player-ratings/overall-standings"
    ]
    
    all_player_data = []
    
    for url in urls:
        print(f"Sending request to AFL.com website: {url}")
        try:
            # Use headers to mimic a browser request
            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
            }
            response = requests.get(url, headers=headers, timeout=10)
            
            if response.status_code != 200:
                print(f"Failed to retrieve AFL.com data. Status code: {response.status_code}")
                continue
            
            # Parse the HTML content
            print("Parsing AFL.com content...")
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Find player data - this will need customization based on actual page structure
            player_data = []
            
            # Look for tables or specific divs containing player data
            tables = soup.find_all('table')
            player_containers = soup.find_all('div', {'class': lambda c: c and 'player-card' in c.lower()})
            
            if tables:
                for table in tables:
                    rows = table.find_all('tr')
                    if len(rows) > 1:  # Has header row and data rows
                        for row in rows[1:]:  # Skip header row
                            cols = row.find_all('td')
                            if len(cols) >= 3:  # Basic columns we need
                                player_info = {}
                                
                                # Extract player name and team
                                name_elem = row.find('a') or cols[0]
                                if name_elem:
                                    name_text = name_elem.get_text(strip=True)
                                    # Try to parse name and team
                                    if '(' in name_text and ')' in name_text:
                                        name = name_text.split('(')[0].strip()
                                        team = name_text.split('(')[1].split(')')[0].strip()
                                    else:
                                        name = name_text
                                        team = cols[1].get_text(strip=True) if len(cols) > 1 else "Unknown"
                                    
                                    player_info['name'] = name
                                    player_info['team'] = team
                                    player_info['source'] = 'afl.com'
                                    
                                    # Try to find other stats
                                    for i, col in enumerate(cols):
                                        text = col.get_text(strip=True)
                                        if '$' in text or re.match(r'^\d{3,7}$', text):  # Looks like price
                                            player_info['price'] = re.sub(r'[^\d]', '', text)
                                        elif re.match(r'^\d+\.\d+$', text):  # Looks like average
                                            player_info['avg'] = text
                                    
                                    player_data.append(player_info)
            
            if player_containers:
                for container in player_containers:
                    name_elem = container.find('h3') or container.find('div', {'class': 'name'})
                    team_elem = container.find('div', {'class': 'team'})
                    price_elem = container.find('div', {'class': lambda c: c and 'price' in c.lower()})
                    
                    if name_elem:
                        player_info = {
                            'name': name_elem.get_text(strip=True),
                            'team': team_elem.get_text(strip=True) if team_elem else "Unknown",
                            'source': 'afl.com'
                        }
                        
                        if price_elem:
                            price_text = price_elem.get_text(strip=True)
                            player_info['price'] = re.sub(r'[^\d]', '', price_text)
                        
                        player_data.append(player_info)
            
            # Add the data from this URL to our collection
            all_player_data.extend(player_data)
            
        except Exception as e:
            print(f"Error scraping {url}: {e}")
    
    return all_player_data

def scrape_footywire_breakevens(url):
    """Scrape breakeven data from Footywire website - based on reference code and scrapy examples"""
    print(f"Scraping breakeven data from: {url}")
    try:
        response = requests.get(url, timeout=10)
        
        if response.status_code != 200:
            print(f"Failed to retrieve breakeven data. Status code: {response.status_code}")
            return []
            
        soup = BeautifulSoup(response.text, 'html.parser')
        # Find the relevant table - it should be a table with class "data" based on Scrapy example
        player_table = soup.find('table', {'class': 'data'})
        
        if not player_table:
            print("Breakeven table not found. Looking for any table...")
            # Fallback to any table that might have player data
            player_table = soup.find('table')
            if not player_table:
                print("No tables found on the page.")
                return []
            
        rows = player_table.find_all('tr')
        if len(rows) < 2:
            print("Not enough rows in table.")
            return []
            
        # Get headers - look for th elements specifically
        header_row = rows[0]
        headers = []
        for th in header_row.find_all('th'):
            headers.append(th.text.strip())
        
        # If no headers found, try using first row as header
        if not headers:
            print("No headers found, using first row values...")
            headers = [td.text.strip() for td in rows[0].find_all('td')]
        
        # Clean up header strings to remove newlines and excessive spaces
        headers = [re.sub(r'\s+', ' ', h).strip() for h in headers]
        print(f"Found headers: {headers}")
        
        # Map headers to common field names
        header_map = {}
        for i, header in enumerate(headers):
            header_lower = header.lower()
            if 'player' in header_lower or 'name' in header_lower:
                header_map['name'] = i
            elif 'team' in header_lower or 'club' in header_lower:
                header_map['team'] = i
            elif 'position' in header_lower or 'pos' in header_lower:
                header_map['position'] = i
            elif 'price' in header_lower or '$' in header_lower or 'cost' in header_lower:
                header_map['price'] = i
            elif 'breakeven' in header_lower or 'be' in header_lower:
                header_map['breakeven'] = i
            elif 'average' in header_lower or 'avg' in header_lower or 'score' in header_lower:
                header_map['avg'] = i
        
        player_data = []
        # Start from row 1 (skipping header)
        for row_idx, row in enumerate(rows[1:], 1):
            # Skip rows that might be subheaders or menu elements
            if 'mainheading' in row.get('class', []) or 'menuheading' in row.get('class', []):
                continue
                
            cols = row.find_all('td')
            if not cols or len(cols) < 3:
                continue
                
            values = []
            for col in cols:
                # Extract text but clean it up to remove excessive whitespace, newlines
                text = col.get_text(strip=True)
                text = re.sub(r'\s+', ' ', text).strip()
                values.append(text)
            
            # Filter out non-player rows (headers, navigation, etc.)
            if any(['Home' in v for v in values]) or any(['Position' in v for v in values]):
                continue
            
            # Need at least name, team, and some other value
            if len(values) < 3:
                continue
            
            player_info = {'source': 'footywire_breakevens'}
            
            # Get player name - this is usually in a specific column with a link
            name_link = None
            if 'name' in header_map:
                name_idx = header_map['name']
                if name_idx < len(cols):
                    name_link = cols[name_idx].find('a')
            else:
                # Try the first column if no name header was found
                name_link = cols[0].find('a')
            
            # If we found a link, use its text as the player name
            if name_link:
                name_value = name_link.text.strip()
                # Check if name has team in parentheses
                if '(' in name_value and ')' in name_value:
                    name_parts = name_value.split('(')
                    player_info['name'] = name_parts[0].strip()
                    player_info['team'] = name_parts[1].strip().rstrip(')')
                else:
                    player_info['name'] = name_value
            elif 'name' in header_map and header_map['name'] < len(values):
                # Use the mapped name column value if no link was found
                name_value = values[header_map['name']]
                if '(' in name_value and ')' in name_value:
                    name_parts = name_value.split('(')
                    player_info['name'] = name_parts[0].strip()
                    player_info['team'] = name_parts[1].strip().rstrip(')')
                else:
                    player_info['name'] = name_value
            else:
                # Use first column as a fallback
                name_value = values[0]
                if '(' in name_value and ')' in name_value:
                    name_parts = name_value.split('(')
                    player_info['name'] = name_parts[0].strip()
                    player_info['team'] = name_parts[1].strip().rstrip(')')
                else:
                    player_info['name'] = name_value
            
            # Skip rows that don't look like player data
            if (len(player_info['name']) > 50 or 
                len(player_info['name']) == 0 or 
                "AFL" in player_info['name'] or 
                "Team" in player_info['name'] or
                "Player" in player_info['name'] or  # Header row
                "Position" in player_info['name'] or
                "All" in player_info['name'] or
                "Home" in player_info['name'] or
                player_info['name'].strip() == ""):
                continue
                
            # Get team if not already extracted
            if 'team' not in player_info and 'team' in header_map and header_map['team'] < len(values):
                player_info['team'] = values[header_map['team']]
            elif 'team' not in player_info:
                player_info['team'] = "Unknown"
            
            # Extract other fields based on header mapping
            for field, idx in header_map.items():
                if field not in player_info and idx < len(values):
                    value = values[idx]
                    # Skip empty values
                    if not value:
                        continue
                    
                    if field == 'price':
                        # Extract only digits
                        player_info[field] = re.sub(r'[^\d]', '', value)
                    else:
                        player_info[field] = value
            
            player_data.append(player_info)
                
        print(f"Successfully extracted {len(player_data)} player records from {url}")
        return player_data
    except Exception as e:
        print(f"Error scraping breakeven data: {e}")
        return []
        
def scrape_dfs_australia():
    """Scrape data from DFS Australia - attempt direct scraping first, fallback to local CSV"""
    print("Attempting to access DFS Australia data...")
    
    # First try to scrape from the website based on reference code and Scrapy spider
    url = "https://dfsaustralia.com/afl-fantasy-price-projector/"
    try:
        print(f"Sending request to DFS Australia: {url}")
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }
        response = requests.get(url, headers=headers, timeout=5)
        
        if response.status_code == 200:
            soup = BeautifulSoup(response.text, 'html.parser')
            player_table = soup.find('table')
            
            if player_table:
                print("Found DFS Australia table, processing...")
                rows = player_table.find_all('tr')
                headers = [th.text.strip() for th in rows[0].find_all('th')]
                
                # Based on Scrapy spider, we know these columns should exist
                # "Player Name": row.css("td:nth-child(1)::text").get()
                # "Projected Score": row.css("td:nth-child(2)::text").get()
                # "Projected Price Change": row.css("td:nth-child(3)::text").get()
                
                player_data = []
                for row in rows[1:]:
                    cols = row.find_all('td')
                    if cols:
                        values = [col.text.strip() for col in cols]
                        
                        if len(values) >= 2:
                            # Extract player name and team if combined in one field
                            name_value = values[0]
                            if '(' in name_value and ')' in name_value:
                                name_parts = name_value.split('(')
                                name = name_parts[0].strip()
                                team = name_parts[1].strip().rstrip(')')
                            else:
                                name = name_value
                                # Try to find team in other columns
                                team = "Unknown"
                                for val in values:
                                    if val in ['ADE', 'BRL', 'CAR', 'COL', 'ESS', 'FRE', 'GCS', 'GEE', 'GWS', 'HAW', 
                                             'MEL', 'NTH', 'PTA', 'RIC', 'STK', 'SYD', 'WBD', 'WCE']:
                                        team = val
                                        break
                            
                            player_info = {
                                'name': name,
                                'team': team,
                                'source': 'dfs_australia_web'
                            }
                            
                            # Map column headers to data fields (based on specifics from Scrapy spider)
                            for i, header in enumerate(headers):
                                if i < len(values):
                                    header_lower = header.lower()
                                    value = values[i]
                                    
                                    if i == 1 and ('project' in header_lower and 'score' in header_lower):
                                        player_info['projected_score'] = value
                                        # Use as avg if not yet present
                                        if 'avg' not in player_info:
                                            player_info['avg'] = value
                                    elif i == 2 and ('price' in header_lower and 'change' in header_lower):
                                        player_info['projected_price_change'] = value
                                        # Extract current price if possible
                                        if '$' in value:
                                            player_info['price'] = re.sub(r'[^\d]', '', value)
                                    elif 'price' in header_lower or '$' in value:
                                        player_info['price'] = re.sub(r'[^\d]', '', value)
                                    elif 'breakeven' in header_lower or 'be' in header_lower:
                                        player_info['breakeven'] = value
                                    elif 'average' in header_lower or 'avg' in header_lower or 'points' in header_lower:
                                        player_info['avg'] = value
                            
                            player_data.append(player_info)
                
                print(f"Successfully scraped {len(player_data)} players from DFS Australia website")
                return player_data
    except Exception as e:
        print(f"Failed to scrape from DFS Australia website: {e}")
    
    # Fallback to local file if web scraping failed
    print("Falling back to local DFS Australia data...")
    dfs_data_file = 'attached_assets/afl-stats-1746087348666.csv'
    
    if os.path.exists(dfs_data_file):
        # Process the CSV data with special source name
        player_data = process_csv_data(dfs_data_file)
        
        # Update the source for all entries
        for player in player_data:
            player['source'] = 'dfs_australia_local'
            
        return player_data
    else:
        print("No local DFS Australia data available.")
        return []

def scrape_dt_talk():
    """Scrape data from DT Talk"""
    urls = [
        "https://dreamteamtalk.com/afl-fantasy-cheat-sheet/",
        "https://dreamteamtalk.com/afl-fantasy-stats/",
        "https://dreamteamtalk.com/category/afl-fantasy/"
    ]
    
    all_player_data = []
    
    for url in urls:
        print(f"Sending request to DT Talk website: {url}")
        try:
            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
            }
            response = requests.get(url, headers=headers, timeout=10)
            
            if response.status_code != 200:
                print(f"Failed to retrieve DT Talk data from {url}. Status code: {response.status_code}")
                continue
            
            # Parse the HTML content
            print(f"Parsing DT Talk content from {url}...")
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Find player data tables
            player_data = []
            tables = soup.find_all('table')
            
            for table in tables:
                rows = table.find_all('tr')
                if len(rows) > 1:  # Has header row and data rows
                    for row in rows[1:]:  # Skip header row
                        cols = row.find_all('td')
                        if len(cols) >= 3:  # Basic columns we need
                            name_elem = cols[0]
                            if name_elem:
                                name_text = name_elem.get_text(strip=True)
                                
                                # Try to extract team
                                team = "Unknown"
                                for col in cols:
                                    col_text = col.get_text(strip=True)
                                    if col_text in ['ADE', 'BRL', 'CAR', 'COL', 'ESS', 'FRE', 'GCS', 'GEE', 'GWS', 'HAW', 
                                                  'MEL', 'NTH', 'PTA', 'RIC', 'STK', 'SYD', 'WBD', 'WCE']:
                                        team = col_text
                                        break
                                
                                player_info = {
                                    'name': name_text,
                                    'team': team,
                                    'source': 'dt_talk'
                                }
                                
                                # Try to find other stats
                                for i, col in enumerate(cols):
                                    text = col.get_text(strip=True)
                                    if '$' in text or re.match(r'^\d{3,7}$', text):  # Looks like price
                                        player_info['price'] = re.sub(r'[^\d]', '', text)
                                    elif re.match(r'^\d+\.\d+$', text):  # Looks like average
                                        player_info['avg'] = text
                                
                                player_data.append(player_info)
            
            # Add the data from this URL to our collection
            all_player_data.extend(player_data)
            
        except Exception as e:
            print(f"Error scraping DT Talk from {url}: {e}")
    
    return all_player_data

def scrape_all_fantasy_sources():
    """Scrape AFL Fantasy stats from multiple sources"""
    all_player_data = []
    
    # Scrape from Footywire
    footywire_data = scrape_footywire()
    if footywire_data:
        print(f"Found {len(footywire_data)} players from Footywire")
        all_player_data.extend(footywire_data)
    
    # Scrape from AFL.com
    afl_data = scrape_afl_com()
    if afl_data:
        print(f"Found {len(afl_data)} players from AFL.com")
        all_player_data.extend(afl_data)
    
    # Scrape from DFS Australia
    dfs_data = scrape_dfs_australia()
    if dfs_data:
        print(f"Found {len(dfs_data)} players from DFS Australia")
        all_player_data.extend(dfs_data)
    
    # Scrape from DT Talk
    dt_talk_data = scrape_dt_talk()
    if dt_talk_data:
        print(f"Found {len(dt_talk_data)} players from DT Talk")
        all_player_data.extend(dt_talk_data)
    
    return all_player_data

def process_csv_data(file_path):
    """Process CSV data from the attached file"""
    print(f"Processing local data from {file_path}...")
    player_data = []
    
    try:
        with open(file_path, 'r', encoding='utf-8') as csvfile:
            # Skip any comment lines at the beginning
            pos = csvfile.tell()
            line = csvfile.readline()
            while line.startswith('Stats downloaded') or 'beer' in line or line.strip() == '':
                pos = csvfile.tell()
                line = csvfile.readline()
            csvfile.seek(pos)  # Go back to the beginning of the header line
            
            # Read the CSV file
            reader = csv.DictReader(csvfile)
            
            # Create a dictionary to avoid duplicates
            player_dict = {}
            
            for row in reader:
                # Check for different column naming conventions across files
                name = None
                team = None
                games = None
                fantasy_pts = None
                
                # Find the name column
                if 'Player' in row:
                    name = row['Player'].strip()
                elif 'player' in row:
                    name = row['player'].strip()
                elif any('name' in col.lower() for col in row.keys()):
                    for col in row.keys():
                        if 'name' in col.lower():
                            name = row[col].strip()
                            break
                
                # Find the team column
                if 'team' in row:
                    team = row['team'].strip()
                elif 'Team' in row:
                    team = row['Team'].strip()
                elif any('club' in col.lower() for col in row.keys()):
                    for col in row.keys():
                        if 'club' in col.lower():
                            team = row[col].strip()
                            break
                
                # Skip if we don't have name or team
                if not name or not team:
                    continue
                
                # Create a unique key for player
                key = f"{name}_{team}".lower()
                
                # Skip if we already have this player
                if key in player_dict:
                    continue
                
                # Find games played
                if 'Games' in row:
                    games = row['Games']
                elif 'games' in row:
                    games = row['games']
                elif 'round' in row:
                    games = '1'  # If we have round data, assume at least 1 game
                
                # Find fantasy points
                if 'Fantasy' in row:
                    fantasy_pts = row['Fantasy']
                elif 'fantasyPoints' in row:
                    fantasy_pts = row['fantasyPoints']
                elif 'fantasy' in row:
                    fantasy_pts = row['fantasy']
                elif 'avg' in row and row['avg'].strip():
                    fantasy_pts = row['avg']
                
                # Extract position if available
                position = None
                if 'Position' in row:
                    position = row['Position']
                elif 'position' in row:
                    position = row['position']
                elif 'namedPosition' in row:
                    position = row['namedPosition']
                
                # Build player data
                player_info = {
                    'name': name,
                    'team': team,
                    'source': f'local_csv_{os.path.basename(file_path)}'
                }
                
                if games:
                    player_info['games'] = games
                if fantasy_pts:
                    player_info['avg'] = fantasy_pts
                if position:
                    player_info['position'] = position
                
                # Add any other useful stats
                for stat_key in ['kicks', 'handballs', 'marks', 'tackles', 'breakeven', 'price']:
                    if stat_key in row and row[stat_key] and str(row[stat_key]).strip():
                        player_info[stat_key] = row[stat_key]
                
                # Add player to dictionary
                player_dict[key] = player_info
            
            # Convert dictionary to list
            player_data = list(player_dict.values())
    except FileNotFoundError:
        print(f"File not found: {file_path}")
    except Exception as e:
        print(f"Error processing CSV: {e}")
    
    return player_data

def merge_player_data(web_data, csv_data):
    """Merge player data from web scraping and CSV files"""
    print("Merging player data from multiple sources...")
    
    # Create a dictionary to avoid duplicates
    player_dict = {}
    
    # Add web data to dictionary
    for player in web_data:
        key = f"{player['name']}_{player['team']}".lower()
        player_dict[key] = player
    
    # Add/update with CSV data
    for player in csv_data:
        key = f"{player['name']}_{player['team']}".lower()
        if key in player_dict:
            # Update with additional information from CSV if needed
            if 'price' not in player and 'price' in player_dict[key]:
                player['price'] = player_dict[key]['price']
            if 'breakeven' not in player and 'breakeven' in player_dict[key]:
                player['breakeven'] = player_dict[key]['breakeven']
        
        # Either way, store the data
        player_dict[key] = player
    
    # Convert dictionary back to list
    merged_data = list(player_dict.values())
    
    # Sort by average score (descending)
    try:
        merged_data.sort(key=lambda x: float(x.get('avg', 0) or 0), reverse=True)
    except (ValueError, TypeError):
        print("Warning: Could not sort players by average")
    
    return merged_data

def enrich_player_data(player_data):
    """Add additional data fields and calculations"""
    print("Enriching player data with additional information...")
    
    for player in player_data:
        # Convert numeric string values to appropriate types
        try:
            if 'avg' in player and player['avg']:
                player['avg'] = float(player['avg'])
            if 'games' in player and player['games']:
                player['games'] = int(player['games'])
            if 'price' in player and player['price']:
                player['price'] = int(player['price'])
            if 'breakeven' in player and player['breakeven'] and player['breakeven'] != 'N/A':
                player['breakeven'] = float(player['breakeven'])
                
            # Calculate value (points per $1000)
            if 'avg' in player and 'price' in player and player['avg'] and player['price']:
                player['value'] = round(player['avg'] * 1000 / player['price'], 2)
                
        except (ValueError, TypeError) as e:
            print(f"Warning: Could not convert numeric values for {player['name']}: {e}")
            
        # Add timestamp for when the data was collected
        player['scraped_at'] = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    return player_data

def save_to_json(data, filename='player_data.json'):
    """Save the player data to a JSON file"""
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4, ensure_ascii=False)
    print(f"Data successfully saved to {filename}")

def process_excel_data(excel_file, year=None):
    """Process Excel data from Jaiden's spreadsheets"""
    print(f"Processing Excel data from {excel_file}...")
    
    try:
        import pandas as pd
        
        # Read the Excel file
        df = pd.read_excel(excel_file)
        
        # Create a list to store player data
        player_data = []
        
        # Try to identify the column names
        player_col = None
        team_col = None
        price_col = None
        points_col = None
        position_col = None
        
        for col in df.columns:
            col_lower = str(col).lower()
            if 'player' in col_lower or 'name' in col_lower:
                player_col = col
            elif 'team' in col_lower or 'club' in col_lower:
                team_col = col
            elif 'price' in col_lower or '$' in col_lower or 'value' in col_lower:
                price_col = col
            elif 'points' in col_lower or 'score' in col_lower or 'avg' in col_lower:
                points_col = col
            elif 'position' in col_lower or 'pos' in col_lower:
                position_col = col
        
        # Skip if we can't find player and team columns
        if not player_col or not team_col:
            print(f"Could not identify player or team columns in {excel_file}")
            return []
        
        # Process each row
        for _, row in df.iterrows():
            # Skip if player name or team is missing or NaN
            if pd.isna(row[player_col]) or pd.isna(row[team_col]):
                continue
            
            # Extract player data
            player_info = {
                'name': str(row[player_col]).strip(),
                'team': str(row[team_col]).strip(),
                'source': f'jaiden_spreadsheet_{year or "unknown"}'
            }
            
            # Add optional fields if available
            if price_col and not pd.isna(row[price_col]):
                price_str = str(row[price_col])
                # Remove any currency symbols and commas
                price = re.sub(r'[^\d.]', '', price_str)
                if price:
                    player_info['price'] = price
            
            if points_col and not pd.isna(row[points_col]):
                player_info['avg'] = row[points_col]
            
            if position_col and not pd.isna(row[position_col]):
                player_info['position'] = str(row[position_col]).strip()
            
            player_data.append(player_info)
        
        return player_data
        
    except Exception as e:
        print(f"Error processing Excel file {excel_file}: {e}")
        return []

def main():
    import time
    start_time = time.time()
    print("Starting AFL Fantasy stats scraper...")
    
    # Start with local data since web scraping can time out
    all_player_data = []
    
    # Process DFS Australia data (from CSV)
    print(f"[{time.time() - start_time:.2f}s] Processing DFS Australia data...")
    dfs_data = scrape_dfs_australia()
    if dfs_data:
        print(f"Found {len(dfs_data)} players from DFS Australia")
        all_player_data.extend(dfs_data)
    
    # Process Jaiden's spreadsheets (Excel files)
    print(f"[{time.time() - start_time:.2f}s] Processing Excel spreadsheets...")
    excel_files = {
        'attached_assets/afl-fantasy-2023 (1).xlsx': 2023,
        'attached_assets/afl-fantasy-2024 (1).xlsx': 2024,
        'attached_assets/afl-fantasy-2025 (5).xlsx': 2025
    }
    
    excel_data = []
    for excel_file, year in excel_files.items():
        if os.path.exists(excel_file):
            try:
                data = process_excel_data(excel_file, year)
                if data:
                    print(f"Found {len(data)} players from {os.path.basename(excel_file)}")
                    excel_data.extend(data)
            except Exception as e:
                print(f"Failed to process Excel file {excel_file}: {e}")
    
    if excel_data:
        print(f"Adding {len(excel_data)} players from Excel files")
        all_player_data.extend(excel_data)
    
    # Process regular CSV files
    print(f"[{time.time() - start_time:.2f}s] Processing CSV files...")
    csv_files = [
        'attached_assets/data.csv',
        'attached_assets/data (1).csv'
    ]
    
    local_csv_data = []
    for csv_file in csv_files:
        if os.path.exists(csv_file):
            csv_data = process_csv_data(csv_file)
            local_csv_data.extend(csv_data)
    
    if local_csv_data:
        print(f"Adding {len(local_csv_data)} players from CSV files")
        all_player_data.extend(local_csv_data)
    
    # Try web scraping if we have time (with short timeouts)
    try:
        # Set a short timeout for these requests
        print(f"[{time.time() - start_time:.2f}s] Attempting web scraping (limited time)...")
        
        # Try to get breakeven data directly
        try:
            breakeven_url = "https://www.footywire.com/afl/footy/dream_team_breakevens"
            print(f"Fetching breakeven data from Footywire...")
            breakeven_data = scrape_footywire_breakevens(breakeven_url)
            if breakeven_data:
                print(f"Found {len(breakeven_data)} player breakeven values")
                all_player_data.extend(breakeven_data)
        except Exception as e:
            print(f"Breakeven data scraping failed: {e}")
            
        # Try the main Footywire rankings
        try:
            footywire_url = "https://www.footywire.com/afl/footy/ft_player_rankings"
            print(f"Sending request to Footywire stats page: {footywire_url}")
            response = requests.get(footywire_url, timeout=5)
            if response.status_code == 200:
                soup = BeautifulSoup(response.text, 'html.parser')
                player_table = soup.find('table', {'class': 'data'})
                if player_table:
                    print("Found Footywire player table, processing...")
                    # Basic processing for a few players
                    rows = player_table.find_all('tr')
                    if len(rows) > 5:  # Just process a few top players
                        for row in rows[1:6]:  # Get first 5 players
                            cols = row.find_all('td')
                            if len(cols) >= 6:
                                name_col = cols[1].get_text(strip=True)
                                name_parts = name_col.split('(')
                                if len(name_parts) > 1:
                                    name = name_parts[0].strip()
                                    team = name_parts[1].strip().rstrip(')')
                                    print(f"Processed player: {name} ({team})")
        except Exception as e:
            print(f"Footywire stats scraping skipped: {e}")
        
        # Try AFL.com data
        try:
            afl_url = "https://fantasy.afl.com.au/classic/rankings/players"
            print(f"Sending request to AFL.com: {afl_url}")
            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
            }
            response = requests.get(afl_url, headers=headers, timeout=5)
            if response.status_code == 200:
                print("Successfully accessed AFL.com")
        except Exception as e:
            print(f"AFL.com scraping skipped: {e}")
        
    except Exception as e:
        print(f"Web scraping limited due to time constraints: {e}")
    
    # Merge and eliminate duplicates
    print(f"[{time.time() - start_time:.2f}s] Merging player data...")
    merged_data = merge_player_data([], all_player_data)
    
    # Enrich data with additional calculations
    print(f"[{time.time() - start_time:.2f}s] Enriching player data...")
    enriched_data = enrich_player_data(merged_data)
    
    if enriched_data:
        print(f"Successfully processed data for {len(enriched_data)} players")
        save_to_json(enriched_data)
        print(f"Total execution time: {time.time() - start_time:.2f}s")
    else:
        print("Failed to collect player data")

if __name__ == "__main__":
    main()