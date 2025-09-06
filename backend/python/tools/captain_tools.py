"""
AFL Fantasy Captain Tools

This module provides captain selection tools to help Fantasy coaches
optimize their captain choices for maximum point returns.
"""

import json
import os
import random
from datetime import datetime

def get_player_data():
    """Get player data from the JSON file"""
    try:
        with open('player_data.json', 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        # Return sample data if file not found
        return []

def captain_score_predictor():
    """
    Identifies top 5 players based on their L3 (last 3 rounds) average scores
    and predicts their captain-worthy performance
    
    Returns:
        list: Top 5 players with their L3 average and breakeven
    """
    players = get_player_data()
    
    # Filter players with L3 data
    valid_players = [p for p in players if p.get('last_3_avg') and float(p.get('last_3_avg', 0)) > 0]
    
    # Sort by L3 average descending
    valid_players.sort(key=lambda p: float(p.get('last_3_avg', 0)), reverse=True)
    
    # Take top 5 players
    top_players = valid_players[:5]
    
    # Prepare result with formatted data
    result = []
    for player in top_players:
        l3_avg = float(player.get('last_3_avg', 0))
        breakeven = float(player.get('breakeven', 0))
        
        result.append({
            'player': player.get('name', ''),
            'team': player.get('team', ''),
            'position': player.get('position', ''),
            'l3_avg': round(l3_avg, 1),
            'breakeven': round(breakeven),
            'captain_ceiling': round(l3_avg * 1.2),  # Estimate ceiling as 20% above L3
            'captain_floor': round(l3_avg * 0.8),    # Estimate floor as 20% below L3
        })
    
    return {"players": result}

def vice_captain_optimizer():
    """
    Recommends optimal Vice-Captain and Captain combinations
    based on player schedules and scoring patterns
    
    Returns:
        list: Combinations of VC/C with expected point outcomes
    """
    players = get_player_data()
    
    # Filter players with average data
    valid_players = [p for p in players if p.get('avg', 0) and float(p.get('avg', 0)) > 90]
    
    # Get current round fixtures (mock data)
    fixtures = [
        {"team": "Adelaide", "opponent": "Essendon", "day": "Friday"},
        {"team": "Brisbane", "opponent": "Geelong", "day": "Saturday"},
        {"team": "Carlton", "opponent": "Sydney", "day": "Saturday"},
        {"team": "Collingwood", "opponent": "Western Bulldogs", "day": "Sunday"},
        {"team": "Fremantle", "opponent": "Port Adelaide", "day": "Saturday"},
        {"team": "Gold Coast", "opponent": "West Coast", "day": "Saturday"},
        {"team": "Greater Western Sydney", "opponent": "Richmond", "day": "Saturday"},
        {"team": "Hawthorn", "opponent": "Melbourne", "day": "Saturday"},
        {"team": "North Melbourne", "opponent": "St Kilda", "day": "Sunday"}
    ]
    
    # Helper function to get the match day for a team
    def get_match_day(team_name):
        for fixture in fixtures:
            if fixture["team"] == team_name or fixture["opponent"] == team_name:
                return fixture["day"]
        return "Unknown"
    
    # Create combinations of Vice-Captain (VC) and Captain (C)
    combinations = []
    
    # Friday/Saturday players for VC, Sunday players for C
    vc_candidates = [p for p in valid_players 
                    if get_match_day(p.get('team', '')) in ["Friday", "Saturday"]]
    c_candidates = [p for p in valid_players 
                   if get_match_day(p.get('team', '')) == "Sunday"]
    
    # Sort candidates by average score
    vc_candidates.sort(key=lambda p: float(p.get('avg', 0)), reverse=True)
    c_candidates.sort(key=lambda p: float(p.get('avg', 0)), reverse=True)
    
    # Take top 5 VC and C candidates
    vc_candidates = vc_candidates[:5]
    c_candidates = c_candidates[:5]
    
    # Generate combinations
    for vc in vc_candidates:
        for c in c_candidates:
            if vc.get('id') != c.get('id'):  # Ensure they're different players
                vc_avg = float(vc.get('avg', 0))
                c_avg = float(c.get('avg', 0))
                
                # Calculate expected outcomes:
                # 1. VC performs well (top 25% - use as captain) - 25% chance
                # 2. VC performs average (use actual captain) - 50% chance
                # 3. VC performs poorly (bottom 25% - use actual captain) - 25% chance
                
                vc_ceiling = vc_avg * 1.15
                vc_floor = vc_avg * 0.85
                
                expected_pts = (vc_ceiling * 2 * 0.25) + (c_avg * 2 * 0.75)
                
                combinations.append({
                    'vice_captain': vc.get('name', ''),
                    'vc_team': vc.get('team', ''),
                    'vc_position': vc.get('position', ''),
                    'vc_avg': round(vc_avg, 1),
                    'vc_day': get_match_day(vc.get('team', '')),
                    'captain': c.get('name', ''),
                    'c_team': c.get('team', ''),
                    'c_position': c.get('position', ''),
                    'c_avg': round(c_avg, 1),
                    'c_day': get_match_day(c.get('team', '')),
                    'expected_pts': round(expected_pts, 1),
                })
    
    # Sort by expected points
    combinations.sort(key=lambda x: x['expected_pts'], reverse=True)
    
    return {"combinations": combinations[:8]}  # Return top 8 combinations

def loophole_detector():
    """
    Identifies loophole opportunities based on player schedules
    
    Returns:
        dict: Information about loophole opportunities and strategies
    """
    # Fixture data (mock)
    fixtures = [
        {"round": 10, "match_id": 1, "home": "Adelaide", "away": "Essendon", "start_time": "2025-05-03T19:30:00+10:00"},
        {"round": 10, "match_id": 2, "home": "Brisbane", "away": "Geelong", "start_time": "2025-05-04T13:10:00+10:00"},
        {"round": 10, "match_id": 3, "home": "Carlton", "away": "Sydney", "start_time": "2025-05-04T15:20:00+10:00"},
        {"round": 10, "match_id": 4, "home": "Collingwood", "away": "Western Bulldogs", "start_time": "2025-05-05T14:10:00+10:00"},
        {"round": 10, "match_id": 5, "home": "Fremantle", "away": "Port Adelaide", "start_time": "2025-05-04T16:40:00+08:00"},
        {"round": 10, "match_id": 6, "home": "Gold Coast", "away": "West Coast", "start_time": "2025-05-04T13:10:00+10:00"},
        {"round": 10, "match_id": 7, "home": "GWS", "away": "Richmond", "start_time": "2025-05-04T15:20:00+10:00"},
        {"round": 10, "match_id": 8, "home": "Hawthorn", "away": "Melbourne", "start_time": "2025-05-04T13:10:00+10:00"},
        {"round": 10, "match_id": 9, "home": "North Melbourne", "away": "St Kilda", "start_time": "2025-05-05T15:20:00+10:00"}
    ]
    
    # Determine which teams play first and last
    fixtures.sort(key=lambda x: x["start_time"])
    first_teams = [fixtures[0]["home"], fixtures[0]["away"]]
    last_teams = [fixtures[-1]["home"], fixtures[-1]["away"]]
    
    # Convert to datetime for display
    first_match_time = datetime.fromisoformat(fixtures[0]["start_time"].replace("+10:00", "+1000"))
    last_match_time = datetime.fromisoformat(fixtures[-1]["start_time"].replace("+10:00", "+1000"))
    
    # Calculate time difference in hours
    time_diff = (last_match_time - first_match_time).total_seconds() / 3600
    
    # Get the actual loophole opportunity information
    loophole_info = {
        "has_loophole": time_diff >= 24,  # Only true if first and last games are > 24h apart
        "first_match_teams": first_teams,
        "first_match_time": first_match_time.strftime("%A %d %B, %I:%M %p"),
        "last_match_teams": last_teams,
        "last_match_time": last_match_time.strftime("%A %d %B, %I:%M %p"),
        "time_difference_hours": round(time_diff, 1),
        "strategy_notes": [],
        "recommended_bench_players": []
    }
    
    # Add appropriate strategy notes
    if loophole_info["has_loophole"]:
        loophole_info["strategy_notes"] = [
            "Place an emergency (E) on the bench from first game teams",
            "Place Vice-Captain (VC) on a player from first game teams",
            "If VC scores well, don't play bench player and use C on a non-playing player",
            "If VC scores poorly, play bench player and use C normally"
        ]
        
        players = get_player_data()
        first_team_players = [p for p in players if p.get('team') in first_teams 
                            and float(p.get('price', 0)) < 300000]
        
        # Get 3 cheap players from first teams for bench options
        if first_team_players:
            first_team_players.sort(key=lambda p: float(p.get('price', 0)))
            for player in first_team_players[:3]:
                loophole_info["recommended_bench_players"].append({
                    "name": player.get('name', ''),
                    "team": player.get('team', ''),
                    "position": player.get('position', ''),
                    "price": int(float(player.get('price', 0))),
                    "avg": round(float(player.get('avg', 0)), 1)
                })
    else:
        loophole_info["strategy_notes"] = [
            "No viable loophole opportunity this round",
            "Games are too close together time-wise",
            "Use regular VC/C strategy this round"
        ]
    
    return loophole_info

def form_based_captain_analyzer():
    """
    Analyzes player form over various timeframes to recommend captains
    
    Returns:
        list: Players with form analysis across different timeframes
    """
    players = get_player_data()
    
    # Filter premium players
    premium_players = [p for p in players if float(p.get('price', 0)) > 800000]
    
    # Create analysis for each player
    form_analysis = []
    
    for player in premium_players:
        # Get form metrics (some might be missing)
        name = player.get('name', '')
        team = player.get('team', '')
        position = player.get('position', '')
        last_3 = float(player.get('last_3_avg', 0))
        last_5 = float(player.get('last_5_avg', 0)) if player.get('last_5_avg') else 0
        season_avg = float(player.get('avg', 0))
        
        # Skip players with incomplete data
        if not last_3 or not season_avg:
            continue
            
        # Calculate trend
        if last_5:
            if last_3 > last_5 and last_3 > season_avg:
                trend = "Strong upward"
            elif last_3 > last_5:
                trend = "Slight upward"
            elif last_3 < last_5 and last_3 < season_avg:
                trend = "Strong downward"
            elif last_3 < last_5:
                trend = "Slight downward"
            else:
                trend = "Steady"
        else:
            if last_3 > season_avg:
                trend = "Above average"
            elif last_3 < season_avg:
                trend = "Below average"
            else:
                trend = "Average"
                
        # Create recommendation
        if last_3 > season_avg * 1.1:
            recommendation = "Highly recommended"
        elif last_3 > season_avg:
            recommendation = "Recommended"
        elif last_3 > season_avg * 0.9:
            recommendation = "Consider alternatives"
        else:
            recommendation = "Not recommended"
            
        # Add to analysis
        form_analysis.append({
            "player": name,
            "team": team,
            "position": position,
            "last_3_form": round(last_3, 1),
            "last_5_form": round(last_5, 1) if last_5 else "N/A",
            "season_form": round(season_avg, 1),
            "trend": trend,
            "recommendation": recommendation
        })
    
    # Sort by recommendation priority
    def recommendation_priority(rec):
        if rec == "Highly recommended":
            return 0
        elif rec == "Recommended":
            return 1
        elif rec == "Consider alternatives":
            return 2
        else:
            return 3
            
    form_analysis.sort(key=lambda x: (recommendation_priority(x["recommendation"]), -x["last_3_form"]))
    
    return {"players": form_analysis[:10]}  # Return top 10 players

def matchup_based_captain_advisor():
    """
    Recommends captains based on favorable matchups against opponents
    
    Returns:
        list: Players with favorable matchups for captain selection
    """
    players = get_player_data()
    
    # Filter players to those with good averages
    valid_players = [p for p in players if float(p.get('avg', 0)) > 90]
    
    # Current round fixtures (mock data)
    fixtures = [
        {"home": "Adelaide", "away": "Essendon", "home_dvp_rating": 3, "away_dvp_rating": 7},
        {"home": "Brisbane", "away": "Geelong", "home_dvp_rating": 8, "away_dvp_rating": 4},
        {"home": "Carlton", "away": "Sydney", "home_dvp_rating": 6, "away_dvp_rating": 5},
        {"home": "Collingwood", "away": "Western Bulldogs", "home_dvp_rating": 9, "away_dvp_rating": 8},
        {"home": "Fremantle", "away": "Port Adelaide", "home_dvp_rating": 5, "away_dvp_rating": 7},
        {"home": "Gold Coast", "away": "West Coast", "home_dvp_rating": 6, "away_dvp_rating": 10},
        {"home": "GWS", "away": "Richmond", "home_dvp_rating": 7, "away_dvp_rating": 4},
        {"home": "Hawthorn", "away": "Melbourne", "home_dvp_rating": 4, "away_dvp_rating": 2},
        {"home": "North Melbourne", "away": "St Kilda", "home_dvp_rating": 10, "away_dvp_rating": 6}
    ]
    
    # Team name mappings
    team_mappings = {
        "GWS": "Greater Western Sydney",
        "Western Bulldogs": "Bulldogs"
    }
    
    # Helper function to standardize team names
    def standardize_team(team):
        return team_mappings.get(team, team)
    
    # Helper function to get opponent and DVP rating
    def get_opponent_and_dvp(team):
        std_team = standardize_team(team)
        
        for fixture in fixtures:
            if standardize_team(fixture["home"]) == std_team:
                return standardize_team(fixture["away"]), fixture["away_dvp_rating"]
            elif standardize_team(fixture["away"]) == std_team:
                return standardize_team(fixture["home"]), fixture["home_dvp_rating"]
                
        return "Unknown", 5  # Default values
    
    # Analyze matchups
    matchup_analysis = []
    
    for player in valid_players:
        name = player.get('name', '')
        team = player.get('team', '')
        position = player.get('position', '')
        avg = float(player.get('avg', 0))
        
        # Get opponent and DvP rating
        opponent, dvp_rating = get_opponent_and_dvp(team)
        
        # Calculate expected score based on DvP
        # DVP 10 = Gives up 20% more points, DVP 1 = Gives up 20% fewer points
        expected_score = avg * (0.8 + (dvp_rating * 0.04))
        
        # Calculate matchup favorability
        if dvp_rating >= 8:
            favorability = "Very favorable"
        elif dvp_rating >= 6:
            favorability = "Favorable"
        elif dvp_rating >= 4:
            favorability = "Neutral"
        else:
            favorability = "Unfavorable"
            
        # Create recommendation
        if favorability == "Very favorable" and avg > 100:
            recommendation = "Strong captain choice"
        elif favorability == "Favorable" and avg > 100:
            recommendation = "Good captain option"
        elif favorability == "Very favorable" or (favorability == "Favorable" and avg > 90):
            recommendation = "Consider as captain"
        else:
            recommendation = "Look elsewhere"
            
        matchup_analysis.append({
            "player": name,
            "team": team,
            "position": position,
            "avg": round(avg, 1),
            "opponent": opponent,
            "dvp_rating": dvp_rating,
            "expected_score": round(expected_score, 1),
            "favorability": favorability,
            "recommendation": recommendation
        })
    
    # Sort by expected score
    matchup_analysis.sort(key=lambda x: x["expected_score"], reverse=True)
    
    return {"players": matchup_analysis[:12]}  # Return top 12 matchups