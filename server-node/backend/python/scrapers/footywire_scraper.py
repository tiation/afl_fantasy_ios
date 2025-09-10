#!/usr/bin/env python3
"""
FootyWire AFL Fantasy Scraper

This script scrapes AFL Fantasy player data from FootyWire.com
and stores the data in a clean JSON format for use in the frontend.
"""

import json
import requests
from bs4 import BeautifulSoup
from datetime import datetime
import re
import os
import time

# Constants for position mapping
POSITION_MAPPING = {
    'DEF': 'DEF',
    'FWD': 'FWD',
    'MID': 'MID',
    'RK': 'RUCK',
    'RUC': 'RUCK',
    'RUCK': 'RUCK',
    'MID/FWD': 'MID',  # Use primary position if multi-position
    'DEF/MID': 'DEF',
    'FWD/MID': 'FWD',
}

# Constants for team mapping
TEAM_MAPPING = {
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
    'POR': 'Port Adelaide',
    'RIC': 'Richmond',
    'STK': 'St Kilda',
    'SYD': 'Sydney',
    'WCE': 'West Coast',
    'WBD': 'Western Bulldogs',
    # Add short name variations
    'Brisbane': 'Brisbane Lions',
    'Gold Coast': 'Gold Coast',
    'Port Adelaide': 'Port Adelaide',
    'Western Bulldogs': 'Western Bulldogs',
    'North Melbourne': 'North Melbourne',
    'West Coast': 'West Coast',
    'Greater Western Sydney': 'Greater Western Sydney',
}

def normalize_team_name(team_str):
    """Convert team name to standard format"""
    if not team_str:
        return "Unknown"
    
    # Remove any non-alphabetic characters
    team = re.sub(r'[^a-zA-Z\s]', '', team_str).strip()
    
    # Check if it's a known abbreviation or team name
    return TEAM_MAPPING.get(team, team)

def normalize_position(pos):
    """Convert position to standard format"""
    if not pos:
        return "MID"  # Default position
        
    # Clean and standardize position
    pos = pos.strip().upper()
    return POSITION_MAPPING.get(pos, 'MID')  # Default to MID if unknown

def parse_price(price_str):
    """Convert price string to integer"""
    # Remove $ symbol and commas
    if not price_str:
        return 0
        
    try:
        # Remove non-numeric characters except decimal point
        clean_price = re.sub(r'[^\d.]', '', price_str)
        
        # Convert to integer, handling both $650,000 and $650K formats
        if 'K' in price_str:
            return int(float(clean_price) * 1000)
        else:
            return int(float(clean_price))
    except ValueError:
        return 0

def scrape_footywire_rankings():
    """Scrape AFL Fantasy player rankings from FootyWire"""
    # Using the original dream_team endpoints which are accessible
    url = "https://www.footywire.com/afl/footy/dream_team_round"
    print(f"Scraping AFL Fantasy player data from {url} for 2025 season...")
    
    # We need to provide proper headers to avoid being blocked
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
        'Cache-Control': 'max-age=0'
    }
    
    player_data = []
    
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        
        soup = BeautifulSoup(response.text, 'html.parser')
        
        # Find the main stats table
        tables = soup.find_all('table', class_='data')
        if not tables:
            print("No data tables found on the page.")
            return []
        
        # Get the main player stats table (typically the first one with player data)
        main_table = None
        for table in tables:
            headers = table.find_all('th')
            if headers and any('Player' in th.text for th in headers):
                main_table = table
                break
                
        if not main_table:
            print("Could not find player stats table.")
            return []
            
        # Extract table headers for column positions
        headers = []
        header_row = main_table.find('tr')
        if header_row:
            headers = [header.text.strip() for header in header_row.find_all('th')]
        
        if not headers:
            print("Could not find table headers.")
            return []
            
        print(f"Found headers: {headers}")
        
        # Find indices for required columns
        name_idx = None
        team_idx = None
        position_idx = None
        price_idx = None
        avg_idx = None
        be_idx = None
        
        for i, header in enumerate(headers):
            if 'Player' in header:
                name_idx = i
            elif any(x in header for x in ['Team', 'Club']):
                team_idx = i
            elif 'Pos' in header:
                position_idx = i
            elif any(x in header for x in ['Price', 'Value', '$']):
                price_idx = i
            elif 'Avg' in header:
                avg_idx = i
            elif any(x in header for x in ['BE', 'Break']):
                be_idx = i
        
        # Check if we have the minimum required columns
        if name_idx is None or team_idx is None:
            print(f"Could not find required columns. Name index: {name_idx}, Team index: {team_idx}")
            return []
            
        # Process rows in the table (skip header row)
        rows = main_table.find_all('tr')[1:]  # Skip header row
        
        for row in rows:
            cells = row.find_all(['td', 'th'])
            
            # Skip rows with insufficient cells - calculate max safely
            req_idx_max = max(name_idx or 0, team_idx or 0)
            if len(cells) <= req_idx_max:
                continue
                
            try:
                # Extract player name - handle case where it might be in an anchor tag
                name_cell = cells[name_idx]
                name_link = name_cell.find('a')
                name = name_link.text.strip() if name_link else name_cell.text.strip()
                
                # Skip empty rows or header rows
                if not name or name.lower() == 'player':
                    continue
                    
                # Extract other data
                team = cells[team_idx].text.strip()
                team = normalize_team_name(team)
                
                # Extract position if available
                position = "MID"  # Default position
                if position_idx is not None and position_idx < len(cells):
                    pos_text = cells[position_idx].text.strip()
                    position = normalize_position(pos_text)
                    
                # Extract price if available
                price = 0
                if price_idx is not None and price_idx < len(cells):
                    price_text = cells[price_idx].text.strip()
                    price = parse_price(price_text)
                    
                # Extract average points if available
                avg_points = 0
                if avg_idx is not None and avg_idx < len(cells):
                    avg_text = cells[avg_idx].text.strip()
                    try:
                        avg_points = float(avg_text)
                    except ValueError:
                        avg_points = 0
                        
                # Extract breakeven if available
                breakeven = None
                if be_idx is not None and be_idx < len(cells):
                    be_text = cells[be_idx].text.strip()
                    try:
                        breakeven = int(be_text)
                    except ValueError:
                        breakeven = int(avg_points * 0.9)  # Estimate breakeven as 90% of average
                else:
                    breakeven = int(avg_points * 0.9)  # Estimate breakeven if not available
                    
                # Calculate other missing values
                projected_score = int(avg_points + 5)  # Project future score as average + 5
                games = 1  # Default if not available
                
                # Create player object
                player = {
                    "name": name,
                    "team": team,
                    "position": position,
                    "price": price,
                    "avg": round(avg_points, 1),
                    "games": games,
                    "breakeven": breakeven,
                    "projected_score": projected_score,
                    "status": "fit",  # Default status
                    "source": "footywire_rankings",
                    "timestamp": int(datetime.now().timestamp())
                }
                
                player_data.append(player)
            
            except Exception as e:
                print(f"Error processing row: {e}")
                continue
            
        # Sort by average points (highest first)
        player_data.sort(key=lambda x: x['avg'], reverse=True)
        
        print(f"Successfully scraped {len(player_data)} players from FootyWire rankings.")
        return player_data
        
    except requests.exceptions.RequestException as e:
        print(f"Error scraping FootyWire data: {e}")
        return []

def scrape_footywire_breakevens():
    """Scrape breakeven values from FootyWire"""
    # Using the original dream_team breakeven endpoint
    url = "https://www.footywire.com/afl/footy/dream_team_breakevens"
    print(f"Scraping AFL Fantasy breakeven data from {url} for 2025 season...")
    
    breakeven_data = {}
    
    try:
        # Using same robust headers to avoid being blocked
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.5',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
            'Cache-Control': 'max-age=0'
        }
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        
        soup = BeautifulSoup(response.text, 'html.parser')
        
        # Find the breakeven table
        tables = soup.find_all('table', class_='data')
        if not tables:
            print("No breakeven tables found on the page.")
            return {}
        
        # Get the main breakeven table
        breakeven_table = None
        for table in tables:
            headers = table.find_all('th')
            if headers and any('Break' in th.text for th in headers):
                breakeven_table = table
                break
                
        if not breakeven_table:
            print("Could not find breakeven table.")
            return {}
            
        # Extract table headers for column positions
        headers = []
        header_row = breakeven_table.find('tr')
        if header_row:
            headers = [header.text.strip() for header in header_row.find_all('th')]
        
        if not headers:
            print("Could not find breakeven table headers.")
            return {}
        
        # Find indices for required columns
        name_idx = None
        be_idx = None
        
        for i, header in enumerate(headers):
            if 'Player' in header:
                name_idx = i
            elif any(x in header for x in ['BE', 'Break']):
                be_idx = i
        
        if name_idx is None or be_idx is None:
            print(f"Could not find name or breakeven columns. Name index: {name_idx}, BE index: {be_idx}")
            return {}
            
        # Process rows in the table (skip header row)
        rows = breakeven_table.find_all('tr')[1:]  # Skip header row
        
        for row in rows:
            try:
                cells = row.find_all(['td', 'th'])
                
                # Calculate safe max with null protection
                req_idx_max = max(name_idx or 0, be_idx or 0)
                if len(cells) <= req_idx_max:
                    continue
                    
                # Extract player name
                name_cell = cells[name_idx]
                name_link = name_cell.find('a')
                name = name_link.text.strip() if name_link else name_cell.text.strip()
                
                if not name:
                    continue
                    
                # Extract breakeven
                be_text = cells[be_idx].text.strip()
                try:
                    breakeven = int(be_text)
                    breakeven_data[name] = breakeven
                except ValueError:
                    continue
            except Exception as e:
                print(f"Error processing breakeven row: {e}")
                continue
                
        print(f"Successfully scraped {len(breakeven_data)} breakevens.")
        return breakeven_data
        
    except requests.exceptions.RequestException as e:
        print(f"Error scraping breakeven data: {e}")
        return {}

def scrape_footywire_player_stats(player_name, min_matches=3):
    """Scrape detailed stats for a specific player"""
    # This could be expanded in the future to get more detailed player stats
    pass

def enrich_with_breakevens(players, breakevens):
    """Add breakeven values to player data"""
    if not breakevens:
        return players
        
    for player in players:
        name = player['name']
        if name in breakevens:
            player['breakeven'] = breakevens[name]
            
    return players

def save_to_json(data, filename='player_data.json'):
    """Save the player data to a JSON file."""
    with open(filename, 'w') as f:
        json.dump(data, f, indent=2)
    print(f"Saved {len(data)} players to {filename}")

def main():
    """Main function to run the FootyWire scraper"""
    print("Starting FootyWire AFL Fantasy scraper...")
    
    try:
        # Try to fetch from FootyWire first
        print("Attempting to scrape data from FootyWire...")
        players = scrape_footywire_rankings()
        
        if players:
            print("Successfully scraped player rankings from FootyWire.")
            print(f"Found {len(players)} players.")
            
            # Try to enrich with breakevens
            print("Fetching breakeven data...")
            time.sleep(1)  # Small delay to avoid rate limiting
            breakevens = scrape_footywire_breakevens()
            
            if breakevens:
                print(f"Successfully scraped {len(breakevens)} breakevens.")
                players = enrich_with_breakevens(players, breakevens)
            else:
                print("Could not scrape breakeven data. Using estimated breakevens.")
                
            # Save to JSON
            save_to_json(players)
            print("FootyWire data saved successfully.")
            print(f"Total players processed: {len(players)}")
            return
    except Exception as e:
        print(f"Error in FootyWire scraping process: {e}")
    
    # If we get here, FootyWire scraping failed or returned no data
    print("\n")
    print("==========================================================")
    print("FOOTYWIRE DATA UNAVAILABLE - USING LOCAL AFL STATS DATA")
    print("==========================================================")
    print("FootyWire may be experiencing server issues or has changed their website structure.")
    print("Falling back to processing local AFL stats files...")
    
    import process_afl_data
    process_afl_data.main()

if __name__ == "__main__":
    main()