"""
AFL Fantasy Fixture Tools

This module provides fixture analysis tools to help Fantasy coaches
make strategic decisions based on upcoming match schedules, travel, weather, 
and opponent strengths.
"""

import json
import os
import random
from datetime import datetime, timedelta
import copy
import requests
from bs4 import BeautifulSoup

def get_player_data():
    """Get player data from the JSON file"""
    try:
        with open('player_data.json', 'r') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading player data: {e}")
        return []

def get_fixture_data():
    """
    Get fixture data for the upcoming rounds from scraped data if available,
    or use default data as fallback
    """
    try:
        # Try to load scraped fixture data from fixture_data.json
        if os.path.exists('fixture_data.json'):
            with open('fixture_data.json', 'r') as f:
                fixture_data = json.load(f)
                if 'fixtures' in fixture_data and fixture_data['fixtures']:
                    return process_real_fixture_data(fixture_data)
        
        # If we don't have fixture data yet, try to scrape it
        fixtures = scrape_fixture_data()
        if fixtures and not isinstance(fixtures, dict):
            # Save for future use
            with open('fixture_data.json', 'w') as f:
                json.dump({
                    "fixtures": fixtures,
                    "updated": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                }, f, indent=2)
            return process_real_fixture_data({"fixtures": fixtures})
            
    except Exception as e:
        print(f"Error getting fixture data: {e}")
    
    # Fallback to sample data if we couldn't get real data
    return get_sample_fixture_data()

def scrape_fixture_data(year=2025):
    """
    Scrape fixture data directly from the FootyWire website
    
    Args:
        year (int, optional): Year to scrape fixtures for. Defaults to 2025.
        
    Returns:
        list: Scraped fixture data
    """
    try:
        base_url = f"https://www.footywire.com/afl/footy/ft_match_list?year={year}"
        response = requests.get(base_url)
        soup = BeautifulSoup(response.text, "html.parser")

        table = soup.find("table", {"class": "data"})
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
    except Exception as e:
        print(f"Error scraping fixture data: {e}")
        return {"error": str(e)}

def get_sample_fixture_data():
    """Get sample fixture data as a fallback"""
    teams = [
        "Adelaide", "Brisbane", "Carlton", "Collingwood", 
        "Essendon", "Fremantle", "Geelong", "Gold Coast", 
        "GWS", "Hawthorn", "Melbourne", "North Melbourne", 
        "Port Adelaide", "Richmond", "St Kilda", "Sydney", 
        "West Coast", "Western Bulldogs"
    ]
    
    # Create a dummy fixture for the next 5 rounds
    current_round = 8  # Assume we're in round 8
    fixture = []
    
    for r in range(current_round, current_round + 5):
        # Shuffle teams to create random matchups
        random.shuffle(teams)
        round_matches = []
        
        for i in range(0, len(teams), 2):
            home_team = teams[i]
            away_team = teams[i+1]
            
            # Generate random venue from major stadiums
            venue = random.choice([
                "MCG", "Adelaide Oval", "Optus Stadium", "SCG", "Gabba",
                "Marvel Stadium", "GMHBA Stadium", "Metricon Stadium", "UTAS Stadium"
            ])
            
            # Generate random date within the round's week
            round_start_date = datetime.now() + timedelta(days=(r - current_round) * 7)
            match_date = round_start_date + timedelta(days=random.randint(0, 6))
            date_str = match_date.strftime("%Y-%m-%d")
            
            # Add the match to the round
            round_matches.append({
                "home_team": home_team,
                "away_team": away_team,
                "venue": venue,
                "date": date_str
            })
        
        fixture.append({
            "round": r,
            "matches": round_matches
        })
    
    return fixture

def process_real_fixture_data(fixture_data):
    """Process the real fixture data into the required format"""
    raw_fixtures = fixture_data['fixtures']
    
    # Try to determine current round
    current_round = 1
    for fix in raw_fixtures:
        if 'round' in fix:
            try:
                round_text = fix['round'].replace('Round ', '')
                round_num = int(round_text)
                current_round = max(current_round, round_num)
            except:
                pass
    
    # Process fixtures by round
    rounds_data = {}
    for fix in raw_fixtures:
        if 'round' not in fix or 'home' not in fix or 'away' not in fix:
            continue
            
        round_text = fix['round']
        try:
            round_num = int(round_text.replace('Round ', ''))
        except:
            continue
            
        if round_num not in rounds_data:
            rounds_data[round_num] = []
            
        # Add match to the round
        rounds_data[round_num].append({
            "home_team": fix['home'],
            "away_team": fix['away'],
            "venue": fix.get('venue', 'Unknown'),
            "date": fix.get('date', 'TBD')
        })
    
    # Convert to list format required by the application
    fixture = []
    for round_num, matches in sorted(rounds_data.items()):
        fixture.append({
            "round": round_num,
            "matches": matches
        })
    
    return fixture

def get_team_strength_ratings():
    """
    Get team strength ratings for offense and defense
    In a real implementation, this would be based on historical data
    For this prototype, we'll create some dummy ratings
    """
    teams = [
        "Adelaide", "Brisbane", "Carlton", "Collingwood", 
        "Essendon", "Fremantle", "Geelong", "Gold Coast", 
        "GWS", "Hawthorn", "Melbourne", "North Melbourne", 
        "Port Adelaide", "Richmond", "St Kilda", "Sydney", 
        "West Coast", "Western Bulldogs"
    ]
    
    team_ratings = {}
    
    for team in teams:
        # Generate random strength ratings between 70-100
        offense_rating = random.randint(70, 100)
        defense_rating = random.randint(70, 100)
        
        # Adjust some top teams to have more realistic ratings
        if team in ["Melbourne", "Collingwood", "Carlton", "Brisbane"]:
            offense_rating = random.randint(85, 100)
            defense_rating = random.randint(85, 100)
        
        # Adjust some bottom teams to have more realistic ratings
        if team in ["North Melbourne", "West Coast", "Richmond"]:
            offense_rating = random.randint(70, 85)
            defense_rating = random.randint(70, 85)
        
        team_ratings[team] = {
            "offense": offense_rating,
            "defense": defense_rating,
            "overall": (offense_rating + defense_rating) / 2
        }
    
    return team_ratings

def get_team_position_dvp():
    """
    Get team DVP (Defense vs Position) data from scraped data if available,
    or use sample data as fallback
    """
    try:
        # Try to load scraped DVP data from dvp_matrix.json
        if os.path.exists('dvp_matrix.json'):
            with open('dvp_matrix.json', 'r') as f:
                dvp_data = json.load(f)
                if dvp_data and all(pos in dvp_data for pos in ["DEF", "MID", "RUC", "FWD"]):
                    return process_real_dvp_data(dvp_data)
        
        # Try to scrape DVP data directly
        dvp_data = scrape_dvp_data()
        if dvp_data and all(pos in dvp_data for pos in ["DEF", "MID", "RUC", "FWD"]):
            # Save for future use
            with open('dvp_matrix.json', 'w') as f:
                json.dump(dvp_data, f, indent=2)
            return process_real_dvp_data(dvp_data)
            
    except Exception as e:
        print(f"Error getting DVP data: {e}")
    
    # Fallback to sample data
    return get_sample_dvp_data()

def scrape_dvp_data():
    """
    Scrape DVP data from DFS Australia
    """
    try:
        url = "https://dfsaustralia.com/afl-dvp/"
        response = requests.get(url)
        
        # Use pandas to read HTML tables (if possible)
        try:
            import pandas as pd
            tables = pd.read_html(response.text)
            
            positions = ["DEF", "MID", "RUC", "FWD"]
            dvp_data = {}

            for i, pos in enumerate(positions):
                if i < len(tables):
                    table = tables[i]
                    table.columns = [c if i == 0 else c.split(" ")[0] for i, c in enumerate(table.columns)]
                    table = table.rename(columns={table.columns[0]: "Team", table.columns[1]: "DVP"})
                    dvp_data[pos] = table[["Team", "DVP"]].to_dict(orient="records")
                else:
                    dvp_data[pos] = []
                    
            return dvp_data
            
        except ImportError:
            # If pandas is not available, use BeautifulSoup parsing
            soup = BeautifulSoup(response.text, "html.parser")
            tables = soup.find_all("table")
            
            positions = ["DEF", "MID", "RUC", "FWD"]
            dvp_data = {}
            
            for i, pos in enumerate(positions):
                dvp_data[pos] = []
                if i < len(tables):
                    table = tables[i]
                    rows = table.find_all("tr")[1:]  # Skip header row
                    
                    for row in rows:
                        cols = row.find_all("td")
                        if len(cols) >= 2:
                            team = cols[0].text.strip()
                            dvp = cols[1].text.strip()
                            try:
                                dvp_value = float(dvp.replace("%", ""))
                                dvp_data[pos].append({"Team": team, "DVP": dvp_value})
                            except:
                                pass
            
            return dvp_data
            
    except Exception as e:
        print(f"Error scraping DVP data: {e}")
        return None

def process_real_dvp_data(dvp_data):
    """
    Process the real DVP data into the required format
    """
    teams = [
        "Adelaide", "Brisbane", "Carlton", "Collingwood", 
        "Essendon", "Fremantle", "Geelong", "Gold Coast", 
        "GWS", "Hawthorn", "Melbourne", "North Melbourne", 
        "Port Adelaide", "Richmond", "St Kilda", "Sydney", 
        "West Coast", "Western Bulldogs"
    ]
    
    positions = ["DEF", "MID", "RUC", "FWD"]
    team_dvp = {team: {} for team in teams}
    
    for position in positions:
        if position in dvp_data:
            for team_data in dvp_data[position]:
                if "Team" in team_data and "DVP" in team_data:
                    team_name = team_data["Team"]
                    dvp_value = team_data["DVP"]
                    
                    # Normalize team name (handle slight variations)
                    normalized_team = None
                    for std_team in teams:
                        if std_team.lower() in team_name.lower() or team_name.lower() in std_team.lower():
                            normalized_team = std_team
                            break
                    
                    if normalized_team:
                        # Convert to 1-5 scale if needed
                        if isinstance(dvp_value, (int, float)):
                            if dvp_value > 5:  # If value is on a different scale (like percentage)
                                # Assume DVP values range from about 60-120%
                                scaled_dvp = 1 + (dvp_value - 60) / 15  # Map 60-120 to 1-5
                                dvp_value = round(min(max(scaled_dvp, 1), 5), 1)
                            team_dvp[normalized_team][position] = dvp_value
    
    # Fill in any missing values with reasonable defaults
    for team in teams:
        for position in positions:
            if position not in team_dvp[team]:
                team_dvp[team][position] = 3.0  # Neutral default
    
    return team_dvp

def get_sample_dvp_data():
    """
    Generate sample DVP data as a fallback
    """
    teams = [
        "Adelaide", "Brisbane", "Carlton", "Collingwood", 
        "Essendon", "Fremantle", "Geelong", "Gold Coast", 
        "GWS", "Hawthorn", "Melbourne", "North Melbourne", 
        "Port Adelaide", "Richmond", "St Kilda", "Sydney", 
        "West Coast", "Western Bulldogs"
    ]
    
    positions = ["DEF", "MID", "RUC", "FWD"]
    team_dvp = {}
    
    for team in teams:
        team_dvp[team] = {}
        
        for position in positions:
            # Generate random DVP rating (1-5 scale, higher means more points given up)
            dvp_rating = round(random.uniform(1, 5), 1)
            
            # Adjust some team ratings based on known tendencies
            if team == "Melbourne" and position == "FWD":
                dvp_rating = round(random.uniform(1, 2.5), 1)  # Strong vs forwards
            elif team == "North Melbourne" and position == "MID":
                dvp_rating = round(random.uniform(3.5, 5), 1)  # Weak vs midfielders
                
            team_dvp[team][position] = dvp_rating
    
    return team_dvp

def get_venue_weather_data():
    """
    Get historical weather data for venues
    In a real implementation, this would come from a weather API
    For this prototype, we'll create some dummy weather data
    """
    venues = [
        "MCG", "Adelaide Oval", "Optus Stadium", "SCG", "Gabba",
        "Marvel Stadium", "GMHBA Stadium", "Metricon Stadium", "UTAS Stadium"
    ]
    
    weather_data = {}
    
    for venue in venues:
        # Indoor stadiums have no weather risk
        if venue == "Marvel Stadium":
            rain_chance = 0
            wind_chance = 0
        else:
            # Generate random weather probabilities
            rain_chance = random.randint(5, 40)
            wind_chance = random.randint(10, 50)
            
            # Adjust based on location
            if venue in ["Gabba", "Metricon Stadium"]:
                rain_chance = random.randint(20, 60)  # More rain in QLD
            elif venue in ["MCG", "GMHBA Stadium"]:
                wind_chance = random.randint(30, 70)  # More wind in VIC
        
        weather_data[venue] = {
            "rain_chance": rain_chance,
            "wind_chance": wind_chance,
            "weather_risk": (rain_chance + wind_chance) / 2
        }
    
    return weather_data

def fixture_difficulty_scanner():
    """
    Analyzes fixture difficulty for each team over upcoming rounds
    
    Returns:
        list: Teams with fixture difficulty ratings for next 5 rounds
    """
    fixture = get_fixture_data()
    team_ratings = get_team_strength_ratings()
    
    # Calculate difficulty for each team's upcoming fixtures
    teams = list(team_ratings.keys())
    team_fixtures = {team: [] for team in teams}
    
    # Process fixture data to get each team's opponents
    for round_data in fixture:
        round_num = round_data["round"]
        
        for match in round_data["matches"]:
            home_team = match["home_team"]
            away_team = match["away_team"]
            venue = match["venue"]
            
            # Add opponent to home team's fixtures
            team_fixtures[home_team].append({
                "round": round_num,
                "opponent": away_team,
                "is_home": True,
                "venue": venue
            })
            
            # Add opponent to away team's fixtures
            team_fixtures[away_team].append({
                "round": round_num,
                "opponent": home_team,
                "is_home": False,
                "venue": venue
            })
    
    # Calculate difficulty ratings for each team's fixtures
    team_difficulty = []
    
    for team, fixtures in team_fixtures.items():
        # Sort fixtures by round
        fixtures.sort(key=lambda x: x["round"])
        
        # Calculate difficulty for each fixture
        difficulty_ratings = []
        for fixture in fixtures:
            opponent = fixture["opponent"]
            is_home = fixture["is_home"]
            
            # Base difficulty on opponent's strength
            opponent_rating = team_ratings[opponent]["overall"]
            
            # Adjust for home/away advantage
            difficulty = opponent_rating * (0.9 if is_home else 1.1)
            
            # Scale to 1-10 range and round to 1 decimal
            difficulty = round(((difficulty - 70) / 30) * 9 + 1, 1)
            
            difficulty_ratings.append({
                "round": fixture["round"],
                "opponent": opponent,
                "is_home": is_home,
                "difficulty": difficulty
            })
        
        # Calculate average difficulty
        if difficulty_ratings:
            avg_difficulty = round(sum(f["difficulty"] for f in difficulty_ratings) / len(difficulty_ratings), 1)
        else:
            avg_difficulty = 5.0
        
        team_difficulty.append({
            "team": team,
            "fixtures": difficulty_ratings,
            "avg_difficulty": avg_difficulty
        })
    
    # Sort by average difficulty (hardest first)
    team_difficulty.sort(key=lambda x: x["avg_difficulty"], reverse=True)
    
    return team_difficulty

def matchup_dvp_analyzer():
    """
    Analyzes Defense vs Position (DVP) matchups for upcoming rounds
    
    Returns:
        list: Favorable matchups by position for upcoming rounds
    """
    fixture = get_fixture_data()
    team_dvp = get_team_position_dvp()
    
    # Find favorable matchups for each position
    positions = ["DEF", "MID", "RUC", "FWD"]
    favorable_matchups = {position: [] for position in positions}
    
    # Process fixture data to find favorable matchups
    for round_data in fixture:
        round_num = round_data["round"]
        
        for match in round_data["matches"]:
            home_team = match["home_team"]
            away_team = match["away_team"]
            
            # Check for favorable matchups for home team players
            for position in positions:
                opponent_dvp = team_dvp[away_team][position]
                
                # If opponent has high DVP (gives up points to this position)
                if opponent_dvp >= 3.5:
                    favorable_matchups[position].append({
                        "round": round_num,
                        "team": home_team,
                        "opponent": away_team,
                        "is_home": True,
                        "dvp_rating": opponent_dvp,
                        "matchup_quality": round((opponent_dvp - 3) * 2.5, 1)  # Scale to 1-5
                    })
            
            # Check for favorable matchups for away team players
            for position in positions:
                opponent_dvp = team_dvp[home_team][position]
                
                # If opponent has high DVP (gives up points to this position)
                if opponent_dvp >= 3.5:
                    favorable_matchups[position].append({
                        "round": round_num,
                        "team": away_team,
                        "opponent": home_team,
                        "is_home": False,
                        "dvp_rating": opponent_dvp,
                        "matchup_quality": round((opponent_dvp - 3) * 2.5, 1)  # Scale to 1-5
                    })
    
    # Sort each position's matchups by quality and round
    for position in positions:
        favorable_matchups[position].sort(key=lambda x: (x["round"], -x["matchup_quality"]))
    
    # Restructure data for frontend
    result = []
    for position, matchups in favorable_matchups.items():
        result.append({
            "position": position,
            "matchups": matchups[:10]  # Limit to top 10 matchups per position
        })
    
    return result

def fixture_swing_radar():
    """
    Identifies teams with significant changes in fixture difficulty
    
    Returns:
        list: Teams with significant swings in fixture difficulty
    """
    team_difficulty = fixture_difficulty_scanner()
    
    # Calculate fixture swings for each team
    fixture_swings = []
    
    for team_data in team_difficulty:
        team = team_data["team"]
        fixtures = team_data["fixtures"]
        
        # Need at least 2 fixtures to calculate a swing
        if len(fixtures) < 2:
            continue
        
        # Calculate average difficulty of first 2 rounds vs last 2 rounds
        early_fixtures = fixtures[:2]
        late_fixtures = fixtures[-2:]
        
        early_avg = sum(f["difficulty"] for f in early_fixtures) / len(early_fixtures)
        late_avg = sum(f["difficulty"] for f in late_fixtures) / len(late_fixtures)
        
        # Calculate swing (positive means getting easier, negative means getting harder)
        swing = round(early_avg - late_avg, 1)
        
        # Only include significant swings (>= 1.5 points difference)
        if abs(swing) >= 1.5:
            fixture_swings.append({
                "team": team,
                "early_avg": round(early_avg, 1),
                "late_avg": round(late_avg, 1),
                "swing": swing,
                "direction": "Easier" if swing > 0 else "Harder",
                "fixtures": fixtures
            })
    
    # Sort by absolute swing value (largest swings first)
    fixture_swings.sort(key=lambda x: abs(x["swing"]), reverse=True)
    
    return fixture_swings

def travel_impact_estimator():
    """
    Estimates the impact of travel on team performance
    
    Returns:
        list: Teams with travel impact ratings for upcoming fixtures
    """
    fixture = get_fixture_data()
    
    # Define team home states
    team_states = {
        "Adelaide": "SA",
        "Brisbane": "QLD",
        "Carlton": "VIC",
        "Collingwood": "VIC",
        "Essendon": "VIC",
        "Fremantle": "WA",
        "Geelong": "VIC",
        "Gold Coast": "QLD",
        "GWS": "NSW",
        "Hawthorn": "VIC",
        "Melbourne": "VIC",
        "North Melbourne": "VIC",
        "Port Adelaide": "SA",
        "Richmond": "VIC",
        "St Kilda": "VIC",
        "Sydney": "NSW",
        "West Coast": "WA",
        "Western Bulldogs": "VIC"
    }
    
    # Define venue states
    venue_states = {
        "MCG": "VIC",
        "Marvel Stadium": "VIC",
        "GMHBA Stadium": "VIC",
        "Adelaide Oval": "SA",
        "Optus Stadium": "WA",
        "SCG": "NSW",
        "Gabba": "QLD",
        "Metricon Stadium": "QLD",
        "UTAS Stadium": "TAS",
        "Giants Stadium": "NSW",
        "Blundstone Arena": "TAS"
    }
    
    # Define travel fatigue by distance between states
    # Higher value means more fatigue
    travel_fatigue = {
        ("VIC", "VIC"): 0,
        ("NSW", "NSW"): 0,
        ("QLD", "QLD"): 0,
        ("SA", "SA"): 0,
        ("WA", "WA"): 0,
        ("TAS", "TAS"): 0,
        
        ("VIC", "NSW"): 2,
        ("VIC", "SA"): 2,
        ("VIC", "TAS"): 1,
        ("NSW", "QLD"): 2,
        ("SA", "WA"): 3,
        
        ("VIC", "QLD"): 3,
        ("VIC", "WA"): 4,
        ("NSW", "SA"): 3,
        ("NSW", "WA"): 5,
        ("NSW", "TAS"): 2,
        ("QLD", "SA"): 4,
        ("QLD", "WA"): 5,
        ("QLD", "TAS"): 4,
        ("SA", "TAS"): 3,
        ("WA", "TAS"): 5
    }
    
    # Ensure all state combinations are covered
    for state1 in ["VIC", "NSW", "QLD", "SA", "WA", "TAS"]:
        for state2 in ["VIC", "NSW", "QLD", "SA", "WA", "TAS"]:
            if (state1, state2) not in travel_fatigue and (state2, state1) in travel_fatigue:
                travel_fatigue[(state1, state2)] = travel_fatigue[(state2, state1)]
    
    # Calculate travel impact for each team's upcoming fixtures
    teams = list(team_states.keys())
    team_travel = {team: [] for team in teams}
    
    # Process fixture data to calculate travel impact
    for round_data in fixture:
        round_num = round_data["round"]
        
        for match in round_data["matches"]:
            home_team = match["home_team"]
            away_team = match["away_team"]
            venue = match["venue"]
            
            # Skip matches at unknown venues
            if venue not in venue_states:
                continue
                
            venue_state = venue_states[venue]
            
            # Calculate travel impact for away team
            away_team_state = team_states[away_team]
            away_fatigue = travel_fatigue.get((away_team_state, venue_state), 3)  # Default to 3 if not specified
            
            team_travel[away_team].append({
                "round": round_num,
                "opponent": home_team,
                "is_home": False,
                "venue": venue,
                "travel_distance": away_fatigue,
                "travel_impact": round(away_fatigue * 0.2, 1)  # Scale to 0-1 range
            })
    
    # Calculate average travel impact for each team
    result = []
    for team, travels in team_travel.items():
        if not travels:
            continue
            
        # Only include non-zero travel impacts
        travels = [t for t in travels if t["travel_distance"] > 0]
        if not travels:
            continue
            
        avg_impact = round(sum(t["travel_impact"] for t in travels) / len(travels), 1)
        
        result.append({
            "team": team,
            "avg_travel_impact": avg_impact,
            "travel_fixtures": travels,
            "interstate_games": len(travels)
        })
    
    # Sort by average travel impact (highest first)
    result.sort(key=lambda x: x["avg_travel_impact"], reverse=True)
    
    return result

def weather_forecast_risk_model():
    """
    Analyzes weather risks for upcoming fixtures
    
    Returns:
        list: Fixtures with weather risk ratings
    """
    fixture = get_fixture_data()
    venue_weather = get_venue_weather_data()
    
    # Calculate weather risk for each fixture
    weather_risks = []
    
    # Process fixture data to calculate weather risk
    for round_data in fixture:
        round_num = round_data["round"]
        
        for match in round_data["matches"]:
            home_team = match["home_team"]
            away_team = match["away_team"]
            venue = match["venue"]
            date = match["date"]
            
            # Skip matches at unknown venues
            if venue not in venue_weather:
                continue
                
            venue_data = venue_weather[venue]
            
            # Basic weather risk from venue
            rain_chance = venue_data["rain_chance"]
            wind_chance = venue_data["wind_chance"]
            
            # Adjust based on time of year (dummy algorithm)
            month = datetime.strptime(date, "%Y-%m-%d").month
            if month in [6, 7, 8]:  # Winter months
                rain_chance += random.randint(5, 15)
                wind_chance += random.randint(5, 15)
            
            # Cap at 100%
            rain_chance = min(rain_chance, 100)
            wind_chance = min(wind_chance, 100)
            
            # Calculate overall weather risk
            weather_risk = round((rain_chance + wind_chance) / 20, 1)  # Scale to 0-10
            
            # Determine impact on scoring
            if weather_risk >= 7:
                score_impact = "High (15-30% lower scoring)"
            elif weather_risk >= 4:
                score_impact = "Medium (5-15% lower scoring)"
            else:
                score_impact = "Low (minimal impact)"
            
            weather_risks.append({
                "round": round_num,
                "home_team": home_team,
                "away_team": away_team,
                "venue": venue,
                "date": date,
                "rain_chance": rain_chance,
                "wind_chance": wind_chance,
                "weather_risk": weather_risk,
                "score_impact": score_impact
            })
    
    # Sort by weather risk (highest first)
    weather_risks.sort(key=lambda x: x["weather_risk"], reverse=True)
    
    return weather_risks