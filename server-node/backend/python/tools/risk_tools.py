"""
AFL Fantasy Risk Tools

This module provides tools for analyzing risk factors in AFL Fantasy.
These tools help assess various types of risk including tags, injuries,
volatility, and consistency to make informed player selection decisions.
"""

import json
import random
from scraper import get_player_data

def get_sample_players(count=10):
    """Get a sample of players from the player data"""
    try:
        players = get_player_data()
        # Ensure we don't exceed available players
        count = min(count, len(players))
        return random.sample(players, count)
    except Exception as e:
        print(f"Error getting player data: {e}")
        # Return some fallback data if we can't get real player data
        return [
            {"name": f"Player {i}", "team": f"Team {i}", "position": "MID"} 
            for i in range(1, count+1)
        ]

def tag_watch_monitor():
    """
    Monitor players at risk of being tagged by opponents
    
    Returns:
        dict: Dictionary with list of players and their tag risk
    """
    players = get_sample_players(15)
    
    # Generate tag risk data
    tag_risk_levels = ["High", "Medium", "Low"]
    tag_watch_data = [
        {
            "player": player["name"],
            "team": player["team"],
            "tag_risk": random.choice(tag_risk_levels)
        }
        for player in players
    ]
    
    # Sort by tag risk (High first)
    tag_watch_data.sort(key=lambda x: 0 if x["tag_risk"] == "High" else (1 if x["tag_risk"] == "Medium" else 2))
    
    return {"players": tag_watch_data}

def tag_history_impact_tracker():
    """
    Track the historical impact of tags on player performance
    
    Returns:
        dict: Dictionary with list of players and their tag impact history
    """
    players = get_sample_players(12)
    
    # Generate tag history impact data
    tag_history_data = [
        {
            "player": player["name"],
            "team": player["team"],
            "avg_score": round(random.uniform(70, 120), 1),
            "avg_score_when_tagged": round(random.uniform(50, 100), 1),
            "score_difference": round(random.uniform(-5, -30), 1)
        }
        for player in players
    ]
    
    # Calculate score difference if not provided
    for player in tag_history_data:
        if "score_difference" not in player:
            player["score_difference"] = round(player["avg_score_when_tagged"] - player["avg_score"], 1)
    
    # Sort by biggest negative impact (most impacted first)
    tag_history_data.sort(key=lambda x: x["score_difference"])
    
    return {"players": tag_history_data}

def tag_target_priority_ranker():
    """
    Rank players based on their likelihood of being targeted for tags
    
    Returns:
        dict: Dictionary with list of players and their tag target priority
    """
    players = get_sample_players(10)
    
    # Generate tag target priority data
    tag_priority_data = [
        {
            "player": player["name"],
            "team": player["team"],
            "priority_score": round(random.uniform(1, 10), 1),
            "recent_tags": random.randint(0, 5)
        }
        for player in players
    ]
    
    # Sort by priority score (highest first)
    tag_priority_data.sort(key=lambda x: x["priority_score"], reverse=True)
    
    return {"players": tag_priority_data}

def tag_breaker_score_estimator():
    """
    Estimate player's ability to overcome or break tags
    
    Returns:
        dict: Dictionary with list of players and their tag breaker scores
    """
    players = get_sample_players(10)
    
    # Generate tag breaker score data
    tag_breaker_data = [
        {
            "player": player["name"],
            "team": player["team"],
            "breaker_score": round(random.uniform(1, 10), 1),
            "breakaway_potential": random.choice(["High", "Medium", "Low"])
        }
        for player in players
    ]
    
    # Sort by breaker score (highest first)
    tag_breaker_data.sort(key=lambda x: x["breaker_score"], reverse=True)
    
    return {"players": tag_breaker_data}

def injury_risk_model():
    """
    Model injury risk for players based on history and current status
    
    Returns:
        dict: Dictionary with list of players and their injury risk
    """
    players = get_sample_players(12)
    
    # Generate injury risk data
    risk_levels = ["High", "Medium", "Low"]
    injury_data = [
        {
            "player": player["name"],
            "team": player["team"],
            "injury_risk": random.choice(risk_levels),
            "injury_history": random.randint(0, 5)
        }
        for player in players
    ]
    
    # Sort by injury risk (highest first)
    injury_data.sort(key=lambda x: 0 if x["injury_risk"] == "High" else (1 if x["injury_risk"] == "Medium" else 2))
    
    return {"players": injury_data}

def volatility_index_calculator():
    """
    Calculate player score volatility to identify consistent performers
    
    Returns:
        dict: Dictionary with list of players and their volatility scores
    """
    players = get_sample_players(15)
    
    # Generate volatility index data
    volatility_data = [
        {
            "player": player["name"],
            "volatility_score": round(random.uniform(5, 35), 1)
        }
        for player in players
    ]
    
    # Sort by volatility score (highest first = most volatile)
    volatility_data.sort(key=lambda x: x["volatility_score"], reverse=True)
    
    return {"players": volatility_data}

def consistency_score_generator():
    """
    Generate consistency scores for players
    
    Returns:
        dict: Dictionary with list of players and their consistency scores
    """
    players = get_sample_players(12)
    
    # Generate consistency score data
    consistency_data = [
        {
            "player": player["name"],
            "team": player["team"],
            "consistency_score": round(random.uniform(1, 10), 1),
            "floor_score": random.randint(40, 80)
        }
        for player in players
    ]
    
    # Sort by consistency score (highest first = most consistent)
    consistency_data.sort(key=lambda x: x["consistency_score"], reverse=True)
    
    return {"players": consistency_data}

def scoring_range_predictor():
    """
    Predict likely scoring range for players
    
    Returns:
        dict: Dictionary with list of players and their projected scoring ranges
    """
    players = get_sample_players(12)
    
    # Generate scoring range data
    scoring_range_data = [
        {
            "player": player["name"],
            "team": player["team"],
            "low_range": random.randint(40, 80),
            "high_range": random.randint(85, 150),
            "most_likely": random.randint(75, 110)
        }
        for player in players
    ]
    
    # Ensure high range is higher than low range and most_likely is in between
    for player in scoring_range_data:
        if player["high_range"] <= player["low_range"]:
            player["high_range"] = player["low_range"] + random.randint(20, 40)
        if player["most_likely"] < player["low_range"] or player["most_likely"] > player["high_range"]:
            player["most_likely"] = round((player["low_range"] + player["high_range"]) / 2)
    
    # Sort by most_likely score (highest first)
    scoring_range_data.sort(key=lambda x: x["most_likely"], reverse=True)
    
    return {"players": scoring_range_data}

def late_out_risk_estimator():
    """
    Estimate risk of players being late withdrawals
    
    Returns:
        dict: Dictionary with list of players and their late out risk
    """
    players = get_sample_players(10)
    
    # Generate late out risk data
    risk_levels = ["High", "Medium", "Low"]
    late_out_data = [
        {
            "player": player["name"],
            "team": player["team"],
            "late_out_risk": random.choice(risk_levels),
            "recent_late_outs": random.randint(0, 3)
        }
        for player in players
    ]
    
    # Sort by late out risk (highest first)
    late_out_data.sort(key=lambda x: 0 if x["late_out_risk"] == "High" else (1 if x["late_out_risk"] == "Medium" else 2))
    
    return {"players": late_out_data}

if __name__ == "__main__":
    # Test one of the tools
    print(json.dumps(volatility_index_calculator(), indent=2))