"""
Fixture Scraper

This script scrapes the FootyWire website for AFL fixture data
to provide accurate, up-to-date match schedules.
"""

import requests
from bs4 import BeautifulSoup
import json
from datetime import datetime

def get_fixture_matrix(year=2025):
    """
    Scrape the fixture/schedule data from FootyWire
    
    Args:
        year (int, optional): The year to scrape fixtures for. Defaults to 2025.
        
    Returns:
        list: A list of fixture dictionaries containing round, date, teams, and venue info
    """
    base_url = f"https://www.footywire.com/afl/footy/ft_match_list?year={year}"
    response = requests.get(base_url)
    soup = BeautifulSoup(response.text, "html.parser")

    table = soup.find("table", {"class": "data"})  # main fixture table
    if not table:
        return {"error": "Could not find fixture table on the page"}
        
    rows = table.find_all("tr")[1:]  # skip header

    fixtures = []
    for row in rows:
        cols = row.find_all("td")
        if len(cols) >= 6:
            round_text = cols[0].text.strip()
            date = cols[1].text.strip()
            home_team = cols[2].text.strip()
            away_team = cols[4].text.strip()
            venue = cols[5].text.strip()

            fixtures.append({
                "round": round_text,
                "date": date,
                "home": home_team,
                "away": away_team,
                "venue": venue
            })

    return fixtures

def get_current_round(fixtures):
    """
    Determine the current round based on today's date and the fixture list
    
    Args:
        fixtures (list): The list of fixtures from get_fixture_matrix()
        
    Returns:
        str: The current round number
    """
    today = datetime.now().strftime("%d-%b-%Y")
    
    # Convert dates to a comparable format
    for fixture in fixtures:
        try:
            fixture_date = datetime.strptime(fixture["date"], "%d-%b-%Y")
            current_date = datetime.strptime(today, "%d-%b-%Y")
            
            if fixture_date >= current_date:
                return fixture["round"]
        except:
            continue
    
    return "Unknown"

def save_fixture_data(filename="fixture_data.json", year=2025):
    """
    Save the fixture data to a JSON file
    
    Args:
        filename (str, optional): Output filename. Defaults to "fixture_data.json".
        year (int, optional): The year to scrape fixtures for. Defaults to 2025.
    """
    fixtures = get_fixture_matrix(year)
    
    # Add current round information
    data = {
        "fixtures": fixtures,
        "current_round": get_current_round(fixtures),
        "year": year,
        "updated": datetime.now().strftime("%d-%b-%Y %H:%M:%S")
    }
    
    with open(filename, "w") as f:
        json.dump(data, f, indent=2)
    print(f"Fixture data saved to {filename}")

if __name__ == "__main__":
    # When run directly, print the fixture data to console
    from pprint import pprint
    fixtures = get_fixture_matrix()
    
    # Show first 10 matches in a readable format
    print("First 10 matches of the fixture:")
    pprint(fixtures[:10])
    
    # Optionally save the data to a file
    save_fixture_data()