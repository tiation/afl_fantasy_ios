from flask import Flask, request, jsonify
from flask_cors import CORS
import logging
import numpy as np
from typing import Dict, List, Any, Tuple
import subprocess
import json
import os
from datetime import datetime, timedelta
import sys
from pathlib import Path

# Add scrapers directory to path
sys.path.append(str(Path(__file__).parent.parent / 'scrapers'))

# Import the player scraper (conditional to avoid breaking if not available)
try:
    from afl_player_scraper import AFLPlayerScraper, integrate_with_api
    SCRAPER_AVAILABLE = True
except ImportError:
    SCRAPER_AVAILABLE = False
    logging.warning("Player scraper not available - some endpoints will return mock data")

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def classify_player_by_price(price: int) -> str:
    """
    Classify a player based on their price:
    - rookie: < 450000
    - midpricer: 450000–799999
    - underpriced_premium: 800000–999999
    - premium: 1000000+
    
    Args:
        price: The player's price in dollars
        
    Returns:
        Classification string
    """
    if price < 450000:
        return "rookie"
    elif price < 800000:
        return "midpricer"
    elif price < 1000000:
        return "underpriced_premium"
    else:
        return "premium"

def is_player_peaked(proj_scores: List[float], breakeven: int) -> bool:
    """
    Check if a player has peaked in value.
    A player is considered peaked if their average projected score
    is less than their breakeven value.
    
    Args:
        proj_scores: List of projected scores
        breakeven: Breakeven score
        
    Returns:
        True if player has peaked, False otherwise
    """
    if not proj_scores:
        return False
        
    avg_proj = sum(proj_scores) / len(proj_scores)
    return avg_proj < breakeven

# Create the Flask app
app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

def trade_score_calculator(player_in: Dict[str, Any] = None, player_out: Dict[str, Any] = None, 
                          round_number: int = 13, team_value: int = 15800000, league_avg_value: int = 15200000) -> Dict[str, Any]:
    """
    Calculate a trade score based on various factors.
    
    The trade score is a value between 0-100 representing how good the trade is,
    with 100 being excellent and 0 being terrible.
    
    The calculation takes into account:
    1. Projected score difference
    2. Price difference and value
    3. Breakeven difference
    4. Injury/suspension risk (red dot)
    5. Timing in the season
    6. Team value relative to league average
    
    Returns a dictionary with score and explanation.
    """
    # Handle default values if not provided
    if player_in is None:
        player_in = {
            'price': 1100000,
            'breakeven': 114,
            'proj_scores': [125, 122, 118, 130, 120],
            'is_red_dot': False
        }
    
    if player_out is None:
        player_out = {
            'price': 930000,
            'breakeven': 120,
            'proj_scores': [105, 110, 102, 108, 104],
            'is_red_dot': False
        }
    
    # Extract player data
    price_in = player_in['price']
    price_out = player_out['price']
    be_in = player_in['breakeven']
    be_out = player_out['breakeven']
    proj_scores_in = player_in['proj_scores']
    proj_scores_out = player_out['proj_scores']
    is_red_dot_in = player_in['is_red_dot']
    is_red_dot_out = player_out['is_red_dot']
    
    # 1. Calculate scoring_score = sum of projected scores difference
    total_proj_in = sum(proj_scores_in)
    total_proj_out = sum(proj_scores_out)
    scoring_score = total_proj_in - total_proj_out
    
    # 2. Calculate price trends for both players
    # Magic number for price changes
    magic_number = 9750
    
    # Simulate 5-round price trends
    price_changes_in = []
    price_changes_out = []
    
    for i in range(5):
        # For player_in: (score - breakeven) * (magic_number / 100)
        # Use projected score for the round or the average if index out of range
        if i < len(proj_scores_in):
            round_score_in = proj_scores_in[i]
        else:
            round_score_in = sum(proj_scores_in) / len(proj_scores_in)
        
        price_change_in = (round_score_in - be_in) * (magic_number / 100)
        price_changes_in.append(price_change_in)
        
        # For player_out
        if i < len(proj_scores_out):
            round_score_out = proj_scores_out[i]
        else:
            round_score_out = sum(proj_scores_out) / len(proj_scores_out)
            
        price_change_out = (round_score_out - be_out) * (magic_number / 100)
        price_changes_out.append(price_change_out)
    
    # Calculate cash_score
    cash_score = sum(price_changes_in) - sum(price_changes_out)
    

    
    # 3. Determine round weighting based on current round
    # Initialize weights
    scoring_weight = 0.5
    cash_weight = 0.5
    
    # Set weights based on round number
    if round_number <= 2:  # Round 1-2
        scoring_weight = 0.5
        cash_weight = 0.5
    elif round_number <= 7:  # Round 3-7
        scoring_weight = 0.3
        cash_weight = 0.7
    elif round_number <= 11:  # Round 8-11
        scoring_weight = 0.5
        cash_weight = 0.5
    elif round_number <= 14:  # Round 12-14
        scoring_weight = 0.7
        cash_weight = 0.3
    elif round_number <= 17:  # Round 15-17
        scoring_weight = 0.6
        cash_weight = 0.4
    else:  # Round 18+
        scoring_weight = 1.0
        cash_weight = 0.0
    
    # 4. Adjust weights based on team value vs league average
    value_ratio = team_value / league_avg_value if league_avg_value > 0 else 1
    
    # If team_value < league_avg_value, reduce scoring weight (focus more on cash)
    # If team_value > league_avg_value, increase scoring weight (focus more on points)
    if value_ratio < 0.95:  # Below average team value
        # Reduce scoring weight by up to 0.2, but not below 0.1
        adjustment = min(0.2, scoring_weight * 0.3)
        scoring_weight = max(0.1, scoring_weight - adjustment)
        cash_weight = 1.0 - scoring_weight
    elif value_ratio > 1.05:  # Above average team value
        # Increase scoring weight by up to 0.2, but not above 0.9 (unless already 1.0)
        if scoring_weight < 1.0:
            adjustment = min(0.2, cash_weight * 0.3)
            scoring_weight = min(0.9, scoring_weight + adjustment)
            cash_weight = 1.0 - scoring_weight
    
    # 5. Calculate overall score
    # Normalize cash_score by dividing by 10000 for comparison with points
    cash_score_normalized = cash_score / 10000
    overall_score = (scoring_score * scoring_weight) + (cash_score_normalized * cash_weight)
    
    # 6. Traditional metrics for compatibility
    avg_proj_in = total_proj_in / len(proj_scores_in)
    avg_proj_out = total_proj_out / len(proj_scores_out)
    score_diff = avg_proj_in - avg_proj_out
    
    # Normalize score difference to a 0-30 scale
    # A difference of 20+ points is considered excellent
    score_factor = min(30, max(0, 15 + score_diff * 0.75))
    
    # Price and value assessment
    price_diff = price_in - price_out
    # Calculate points per $10k for each player
    value_in = avg_proj_in / (price_in / 10000)
    value_out = avg_proj_out / (price_out / 10000)
    value_diff = value_in - value_out
    
    # Normalize value to a 0-25 scale
    value_factor = min(25, max(0, 12.5 + value_diff * 2.5 - (price_diff / 1000000) * 5))
    
    # Breakeven assessment
    be_diff = be_out - be_in  # Positive if player_in has a lower breakeven (good)
    be_to_avg_in = be_in / avg_proj_in if avg_proj_in > 0 else 2
    be_to_avg_out = be_out / avg_proj_out if avg_proj_out > 0 else 2
    
    # Normalize BE to a 0-15 scale
    be_factor = min(15, max(0, 7.5 + (be_to_avg_out - be_to_avg_in) * 5 + be_diff * 0.1))
    
    # Injury/suspension risk assessment
    risk_factor = 0
    if is_red_dot_out and not is_red_dot_in:
        risk_factor = 10  # Trading out an injured/suspended player is good
    elif is_red_dot_in and not is_red_dot_out:
        risk_factor = 0   # Trading for an injured/suspended player is bad
    else:
        risk_factor = 5   # Neutral if both or neither have red dots
    
    # Generate explanation
    explanations = []
    
    if score_diff > 0:
        explanations.append(f"Player coming in projected to score {score_diff:.1f} points more per game")
    else:
        explanations.append(f"Player coming in projected to score {-score_diff:.1f} points less per game")
    
    total_cash_impact = sum(price_changes_in) - sum(price_changes_out)
    if total_cash_impact > 0:
        explanations.append(f"Projected to gain ${total_cash_impact/1000:.1f}k in value over 5 rounds")
    else:
        explanations.append(f"Projected to lose ${-total_cash_impact/1000:.1f}k in value over 5 rounds")
    
    if be_diff > 0:
        explanations.append(f"Trading for a player with {be_diff} lower breakeven")
    else:
        explanations.append(f"Trading for a player with {-be_diff} higher breakeven")
    
    if price_diff > 0:
        explanations.append(f"This trade costs ${price_diff/1000:.1f}k immediately")
    else:
        explanations.append(f"This trade frees up ${-price_diff/1000:.1f}k immediately")
    
    # Round-specific context
    if round_number <= 7:
        explanations.append(f"Round {round_number}: Cash gain is weighted more heavily than scoring")
    elif round_number >= 18:
        explanations.append(f"Round {round_number}: Only scoring matters at this stage of the season")
    
    if value_ratio < 0.95:
        explanations.append(f"Your team value is below league average: Cash gain is prioritized")
    elif value_ratio > 1.05:
        explanations.append(f"Your team value is above league average: Scoring is prioritized")
    
    # Scale overall_score to 0-100 range
    # The scaling factor might need adjustment based on testing
    scaling_factor = 5.0  # Assuming most overall_scores are in range -10 to +10
    normalized_score = 50 + (overall_score * scaling_factor)
    final_score = max(0, min(100, normalized_score))
    
    # Add recommendations based on score
    recommendation = ""
    if final_score >= 80:
        recommendation = "Highly recommend this trade"
    elif final_score >= 60:
        recommendation = "Good trade opportunity"
    elif final_score >= 40:
        recommendation = "Neutral trade, consider other options"
    else:
        recommendation = "Not recommended, look for better trades"
    
    # Determine verdict based on raw overall_score
    verdict = "Poor Choice"
    if overall_score > 15:
        verdict = "Perfect Timing"
    elif overall_score > 5:
        verdict = "Solid Structure Trade"
    elif overall_score > 0:
        verdict = "Risky Move"
    
    # Calculate projected prices for both players
    projected_prices_in = []
    projected_prices_out = []
    
    # Start with current prices
    current_price_in = price_in
    current_price_out = price_out
    
    # Calculate projected prices over 5 rounds
    for i in range(5):
        current_price_in += round(price_changes_in[i])
        current_price_out += round(price_changes_out[i])
        projected_prices_in.append(round(current_price_in))
        projected_prices_out.append(round(current_price_out))
    
    # Determine upgrade path flag
    upgrade_path = "neutral"
    if price_in > price_out and avg_proj_in > avg_proj_out:
        upgrade_path = "upgrade"
    elif price_in < price_out and avg_proj_in < avg_proj_out:
        upgrade_path = "downgrade"
    
    # Determine if this is good timing based on the season
    season_match = False
    if (round_number <= 7 and cash_score > 0) or (round_number >= 18 and scoring_score > 0):
        season_match = True
    
    return {
        "trade_score": round(final_score, 1),
        "scoring_score": round(scoring_score, 1),
        "cash_score": round(cash_score, 0),
        "overall_score": round(overall_score, 1),
        "score_breakdown": {
            "projected_score": round(score_factor, 1),
            "value": round(value_factor, 1),
            "breakeven": round(be_factor, 1),
            "risk": round(risk_factor, 1),
            "scoring_weight": round(scoring_weight * 100, 1),
            "cash_weight": round(cash_weight * 100, 1)
        },
        "price_projections": {
            "player_in": [round(change, 0) for change in price_changes_in],
            "player_out": [round(change, 0) for change in price_changes_out],
            "net_gain": round(cash_score, 0)
        },
        "projected_prices": {
            "player_in": projected_prices_in,
            "player_out": projected_prices_out
        },
        "projected_scores": {
            "player_in": proj_scores_in,
            "player_out": proj_scores_out
        },
        "flags": {
            "peaked_rookie": (classify_player_by_price(price_in) == "rookie" and is_player_peaked(proj_scores_in, be_in)) or
                            (classify_player_by_price(price_out) == "rookie" and is_player_peaked(proj_scores_out, be_out)),
            "upgrade_path": upgrade_path,
            "season_match": season_match
        },
        "verdict": verdict,
        "explanations": explanations,
        "recommendation": recommendation
    }

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({"status": "healthy", "service": "AFL Fantasy Trade API"})

@app.route('/api/trade_score', methods=['POST'])
def evaluate_trade():
    """
    Endpoint to evaluate a fantasy trade decision.
    
    Expected JSON input:
    {
        "player_in": {
            "price": int,
            "breakeven": int,
            "proj_scores": [float, float, float, float, float],
            "is_red_dot": bool
        },
        "player_out": {
            "price": int,
            "breakeven": int,
            "proj_scores": [float, float, float, float, float],
            "is_red_dot": bool
        },
        "round_number": int,
        "team_value": int,
        "league_avg_value": int
    }
    
    Returns:
    {
        "status": "ok",
        "trade_score": float,
        "score_breakdown": {...},
        "explanations": [...],
        "recommendation": string
    }
    """
    try:
        # Get the JSON data from the request
        data = request.get_json()
        logger.info(f"Received trade evaluation request: {data}")
        
        # Validate that all required fields are present
        if not all(key in data for key in ['player_in', 'player_out', 'round_number', 'team_value', 'league_avg_value']):
            return jsonify({"status": "error", "message": "Missing required fields"}), 400
        
        # Check player data
        for player_key in ['player_in', 'player_out']:
            player = data[player_key]
            if not all(key in player for key in ['price', 'breakeven', 'proj_scores', 'is_red_dot']):
                return jsonify({"status": "error", "message": f"Missing required fields in {player_key}"}), 400
            
            # Validate proj_scores is a list of 5 floats
            if not isinstance(player['proj_scores'], list) or len(player['proj_scores']) != 5:
                return jsonify({"status": "error", "message": f"{player_key} proj_scores must be a list of 5 values"}), 400
        
        # Calculate the trade score
        trade_analysis = trade_score_calculator(
            data['player_in'],
            data['player_out'],
            data['round_number'],
            data['team_value'],
            data['league_avg_value']
        )
        
        # Classify players and check if they're peaked
        player_in_class = classify_player_by_price(data['player_in']['price'])
        player_out_class = classify_player_by_price(data['player_out']['price'])
        
        player_in_peaked = is_player_peaked(data['player_in']['proj_scores'], data['player_in']['breakeven'])
        player_out_peaked = is_player_peaked(data['player_out']['proj_scores'], data['player_out']['breakeven'])
        
        # Add flags to the response
        flags = {
            "peaked_rookie": (player_in_class == "rookie" and player_in_peaked) or 
                             (player_out_class == "rookie" and player_out_peaked),
            "trading_peaked_player": player_out_peaked,
            "getting_peaked_player": player_in_peaked,
            "player_in_class": player_in_class,
            "player_out_class": player_out_class
        }
        
        # Add additional explanations based on flags
        if flags["peaked_rookie"]:
            if player_in_class == "rookie" and player_in_peaked:
                trade_analysis["explanations"].append("Warning: You are trading for a rookie who may have peaked in value")
            if player_out_class == "rookie" and player_out_peaked:
                trade_analysis["explanations"].append("Good: You are trading away a rookie who may have peaked in value")
        
        if flags["getting_peaked_player"]:
            trade_analysis["explanations"].append(f"Warning: {player_in_class.capitalize()} player coming in may have peaked (avg proj < breakeven)")
        
        if flags["trading_peaked_player"]:
            trade_analysis["explanations"].append(f"Good: {player_out_class.capitalize()} player going out may have peaked (avg proj < breakeven)")
        
        # Return the result with flags
        return jsonify({
            "status": "ok",
            "flags": flags,
            **trade_analysis
        })
    
    except Exception as e:
        logger.error(f"Error processing trade request: {str(e)}")
        return jsonify({"status": "error", "message": str(e)}), 500

# AFL Fantasy Data Cache
cache = {
    'data': None,
    'timestamp': None,
    'cache_duration': 300  # 5 minutes cache
}

def is_cache_valid():
    """Check if cached data is still valid"""
    if not cache['data'] or not cache['timestamp']:
        return False
    
    now = datetime.now()
    cache_time = datetime.fromisoformat(cache['timestamp'])
    return (now - cache_time).seconds < cache['cache_duration']

def get_cached_data():
    """Get cached data if valid, otherwise fetch new data"""
    if is_cache_valid():
        print("Using cached AFL Fantasy data")
        return cache['data']
    
    print("Cache expired or empty, fetching fresh AFL Fantasy data...")
    return fetch_fresh_afl_data()

def fetch_fresh_afl_data():
    """Fetch fresh data from AFL Fantasy scraper"""
    try:
        # Run the AFL Fantasy scraper
        result = subprocess.run([
            'python', '../scrapers/afl_fantasy_authenticated_scraper.py'
        ], capture_output=True, text=True, timeout=120)
        
        if result.returncode == 0:
            print("AFL Fantasy scraper executed successfully")
            
            # Try to load the saved data file
            try:
                with open('../scrapers/afl_fantasy_team_data.json', 'r') as f:
                    data = json.load(f)
                
                # Update cache
                cache['data'] = data
                cache['timestamp'] = datetime.now().isoformat()
                
                print(f"Loaded AFL Fantasy data: {data}")
                return data
                
            except FileNotFoundError:
                print("AFL Fantasy data file not found")
                return None
            except json.JSONDecodeError:
                print("Invalid JSON in AFL Fantasy data file")
                return None
        else:
            print(f"AFL Fantasy scraper failed with code {result.returncode}")
            print(f"Stderr: {result.stderr}")
            return None
            
    except subprocess.TimeoutExpired:
        print("AFL Fantasy scraper timed out")
        return None
    except Exception as e:
        print(f"Error running AFL Fantasy scraper: {e}")
        return None

def validate_afl_credentials(team_id: str, session_cookie: str) -> Dict[str, Any]:
    """
    Validate AFL Fantasy credentials by attempting to fetch basic data.
    
    Args:
        team_id: The AFL Fantasy team ID
        session_cookie: The session cookie for authentication
        
    Returns:
        Dictionary with validation results
    """
    try:
        import requests
        from bs4 import BeautifulSoup
        
        # Basic validation URL - try to access team page
        url = f"https://fantasy.afl.com.au/classic/team/view/{team_id}"
        
        headers = {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36',
            'Cookie': f'sessionid={session_cookie}'
        }
        
        # Make request with timeout
        response = requests.get(url, headers=headers, timeout=10)
        
        # Check response status
        if response.status_code == 200:
            soup = BeautifulSoup(response.content, 'html.parser')
            
            # Look for team name or other indicators of valid access
            team_name_element = soup.find('h1', class_='team-name') or soup.find('title')
            if team_name_element:
                team_name = team_name_element.get_text(strip=True)
                return {
                    'valid': True,
                    'team_name': team_name,
                    'team_id': team_id,
                    'message': 'Credentials validated successfully'
                }
            else:
                return {
                    'valid': False,
                    'error': 'Could not find team information. Please check your team ID.'
                }
        elif response.status_code == 403:
            return {
                'valid': False,
                'error': 'Access denied. Please check your session cookie.'
            }
        elif response.status_code == 404:
            return {
                'valid': False,
                'error': 'Team not found. Please check your team ID.'
            }
        else:
            return {
                'valid': False,
                'error': f'Server error (Status: {response.status_code})'
            }
            
    except requests.exceptions.Timeout:
        return {
            'valid': False,
            'error': 'Request timed out. Please try again.'
        }
    except requests.exceptions.ConnectionError:
        return {
            'valid': False,
            'error': 'Connection failed. Please check your internet connection.'
        }
    except ImportError:
        return {
            'valid': False,
            'error': 'Missing required packages (requests, beautifulsoup4)'
        }
    except Exception as e:
        return {
            'valid': False,
            'error': f'Validation error: {str(e)}'
        }

@app.route('/api/afl-fantasy/validate-credentials', methods=['POST'])
def validate_credentials():
    """
    Validate AFL Fantasy credentials.
    
    Expected JSON input:
    {
        "team_id": "string",
        "session_cookie": "string"
    }
    
    Returns:
    {
        "valid": bool,
        "team_name": "string" (if valid),
        "team_id": "string",
        "message": "string",
        "error": "string" (if invalid)
    }
    """
    try:
        data = request.get_json()
        logger.info("Received credential validation request")
        
        # Validate required fields
        if not data or 'team_id' not in data or 'session_cookie' not in data:
            return jsonify({
                'valid': False,
                'error': 'Missing required fields: team_id and session_cookie'
            }), 400
        
        team_id = data['team_id'].strip()
        session_cookie = data['session_cookie'].strip()
        
        # Basic validation
        if not team_id:
            return jsonify({
                'valid': False,
                'error': 'Team ID cannot be empty'
            }), 400
            
        if not session_cookie:
            return jsonify({
                'valid': False,
                'error': 'Session cookie cannot be empty'
            }), 400
        
        # Validate credentials
        result = validate_afl_credentials(team_id, session_cookie)
        
        if result['valid']:
            logger.info(f"Credentials validated successfully for team: {result.get('team_name', 'Unknown')}")
            return jsonify(result)
        else:
            logger.warning(f"Credential validation failed: {result.get('error', 'Unknown error')}")
            return jsonify(result), 401
            
    except Exception as e:
        logger.error(f"Error validating credentials: {str(e)}")
        return jsonify({
            'valid': False,
            'error': f'Server error: {str(e)}'
        }), 500

@app.route('/api/afl-fantasy/dashboard-data', methods=['GET'])
def get_dashboard_data():
    """Get all dashboard data from AFL Fantasy"""
    try:
        data = get_cached_data()
        
        if not data:
            return jsonify({
                'error': 'Failed to fetch AFL Fantasy data',
                'message': 'Could not authenticate or extract data from AFL Fantasy website'
            }), 500
        
        # Format data for dashboard consumption
        dashboard_data = {
            'team_value': {
                'total': data.get('team_value', 0),
                'player_count': data.get('player_count', 0),
                'remaining_salary': max(0, 13000000 - data.get('team_value', 0)),  # $13M salary cap
                'formatted': f"${data.get('team_value', 0) / 1000000:.1f}M"
            },
            'team_score': {
                'total': data.get('team_score', 0),
                'captain_score': data.get('captain_score', 0),
                'change_from_last_round': data.get('score_change', 0)
            },
            'overall_rank': {
                'current': data.get('overall_rank', 0),
                'formatted': f"{data.get('overall_rank', 0):,}",
                'change_from_last_round': data.get('rank_change', 0)
            },
            'captain': {
                'score': data.get('captain_score', 0),
                'ownership_percentage': data.get('captain_ownership', 0),
                'player_name': data.get('captain_name', 'Unknown')
            },
            'last_updated': cache.get('timestamp')
        }
        
        return jsonify(dashboard_data)
        
    except Exception as e:
        print(f"Error in dashboard data endpoint: {e}")
        return jsonify({
            'error': 'Internal server error',
            'message': str(e)
        }), 500

@app.route('/api/afl-fantasy/team-value', methods=['GET'])
def get_team_value():
    """Get team value data specifically"""
    try:
        data = get_cached_data()
        
        if not data:
            return jsonify({'error': 'No AFL Fantasy data available'}), 500
        
        team_value = data.get('team_value', 0)
        remaining_salary = max(0, 13000000 - team_value)  # $13M salary cap
        
        return jsonify({
            'total_value': team_value,
            'remaining_salary': remaining_salary,
            'formatted_value': f"${team_value / 1000000:.1f}M",
            'formatted_remaining': f"${remaining_salary / 1000:.0f}K",
            'player_count': data.get('player_count', 0)
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/afl-fantasy/team-score', methods=['GET'])
def get_team_score():
    """Get team score data specifically"""
    try:
        data = get_cached_data()
        
        if not data:
            return jsonify({'error': 'No AFL Fantasy data available'}), 500
        
        return jsonify({
            'total_score': data.get('team_score', 0),
            'captain_score': data.get('captain_score', 0),
            'score_change': data.get('score_change', 0)
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/afl-fantasy/rank', methods=['GET'])
def get_rank():
    """Get overall rank data specifically"""
    try:
        data = get_cached_data()
        
        if not data:
            return jsonify({'error': 'No AFL Fantasy data available'}), 500
        
        rank = data.get('overall_rank', 0)
        
        return jsonify({
            'overall_rank': rank,
            'formatted_rank': f"{rank:,}",
            'rank_change': data.get('rank_change', 0)
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/afl-fantasy/captain', methods=['GET'])
def get_captain():
    """Get captain data specifically"""
    try:
        data = get_cached_data()
        
        if not data:
            return jsonify({'error': 'No AFL Fantasy data available'}), 500
        
        return jsonify({
            'captain_score': data.get('captain_score', 0),
            'captain_name': data.get('captain_name', 'Unknown'),
            'ownership_percentage': data.get('captain_ownership', 0),
            'formatted_ownership': f"{data.get('captain_ownership', 0):.1f}% of teams"
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/afl-fantasy/refresh', methods=['POST'])
def refresh_data():
    """Force refresh of AFL Fantasy data"""
    try:
        # Clear cache to force refresh
        cache['data'] = None
        cache['timestamp'] = None
        
        # Fetch fresh data
        data = fetch_fresh_afl_data()
        
        if data:
            return jsonify({
                'message': 'AFL Fantasy data refreshed successfully',
                'data': data,
                'timestamp': cache['timestamp']
            })
        else:
            return jsonify({
                'error': 'Failed to refresh AFL Fantasy data'
            }), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ===== NEW ENDPOINTS FOR IOS APP INTEGRATION =====

# Initialize player scraper if available
player_scraper = None
if SCRAPER_AVAILABLE:
    try:
        player_scraper = AFLPlayerScraper()
        logger.info("✅ Player scraper initialized")
    except Exception as e:
        logger.error(f"❌ Failed to initialize player scraper: {e}")
        SCRAPER_AVAILABLE = False

@app.route('/api/players', methods=['GET'])
def get_all_players():
    """Get all players summary - iOS app endpoint"""
    try:
        if player_scraper and SCRAPER_AVAILABLE:
            players = player_scraper.get_all_players_summary()
            if players:
                return jsonify({
                    'status': 'ok',
                    'players': players,
                    'count': len(players)
                })
        
        # Mock data for when scraper is not available
        mock_players = [
            {
                'player_id': 'player_001',
                'name': 'Max Gawn',
                'position': 'RUCK',
                'team': 'MEL',
                'price': 650000,
                'average_score': 105.2,
                'breakeven': 98,
                'last_score': 112,
                'ownership': 65.4,
                'is_cash_cow': False,
                'is_captain_candidate': True
            },
            {
                'player_id': 'player_002', 
                'name': 'Sam Walsh',
                'position': 'MID',
                'team': 'CAR',
                'price': 780000,
                'average_score': 118.7,
                'breakeven': 105,
                'last_score': 125,
                'ownership': 78.2,
                'is_cash_cow': False,
                'is_captain_candidate': True
            },
            {
                'player_id': 'player_003',
                'name': 'Rookie Player',
                'position': 'DEF', 
                'team': 'SYD',
                'price': 350000,
                'average_score': 65.8,
                'breakeven': 45,
                'last_score': 78,
                'ownership': 15.3,
                'is_cash_cow': True,
                'is_captain_candidate': False
            }
        ]
        
        return jsonify({
            'status': 'ok',
            'players': mock_players,
            'count': len(mock_players),
            'note': 'Mock data - player scraper not available'
        })
        
    except Exception as e:
        logger.error(f"Error in get_all_players: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@app.route('/api/players/<player_id>', methods=['GET'])
def get_player_details(player_id):
    """Get detailed player information - iOS app endpoint"""
    try:
        if player_scraper and SCRAPER_AVAILABLE:
            player_data = player_scraper.get_player_data(player_id)
            if player_data:
                return jsonify({
                    'status': 'ok',
                    'player': player_data
                })
        
        # Mock detailed player data
        mock_player = {
            'player_id': player_id,
            'name': f'Player {player_id[-3:]}',
            'position': 'MID',
            'team': 'CAR',
            'price': 650000,
            'average_score': 105.2,
            'total_score': 1578,
            'games_played': 15,
            'breakeven': 98,
            'last_score': 112,
            'form': [95, 108, 112, 89, 118],
            'ownership': 45.6,
            'consistency': 85.2,
            'ceiling': 145,
            'floor': 68,
            'injury_risk': 'Low',
            'projected_scores': [108, 102, 115, 98, 107],
            'venue_performance': [
                {'venue': 'MCG', 'average': 110.5, 'games': 3},
                {'venue': 'Marvel Stadium', 'average': 98.2, 'games': 2}
            ]
        }
        
        return jsonify({
            'status': 'ok', 
            'player': mock_player,
            'note': 'Mock data - player scraper not available'
        })
        
    except Exception as e:
        logger.error(f"Error in get_player_details: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@app.route('/api/cash-cows', methods=['GET'])
def get_cash_cows():
    """Get cash cow analysis - iOS app endpoint"""
    try:
        # Mock cash cow data for now
        cash_cows = [
            {
                'player_name': 'Rookie Defender',
                'player_id': 'rook_001',
                'position': 'DEF',
                'team': 'SYD',
                'current_price': 350000,
                'target_price': 480000,
                'cash_generated': 130000,
                'projected_weeks': 4,
                'confidence': 0.85,
                'sell_urgency': 'Medium',
                'reasoning': 'Strong recent form with favorable upcoming fixtures. Price rise expected.',
                'breakeven': 45,
                'average_score': 68.5,
                'last_scores': [72, 65, 78, 61, 85]
            },
            {
                'player_name': 'Young Mid',
                'player_id': 'rook_002', 
                'position': 'MID',
                'team': 'GEE',
                'current_price': 420000,
                'target_price': 580000,
                'cash_generated': 160000,
                'projected_weeks': 6,
                'confidence': 0.78,
                'sell_urgency': 'Low',
                'reasoning': 'Established role, consistent scoring. Longer-term cash generation play.',
                'breakeven': 52,
                'average_score': 75.2,
                'last_scores': [82, 68, 79, 71, 88]
            }
        ]
        
        return jsonify({
            'status': 'ok',
            'cash_cows': cash_cows,
            'total_generated': sum(cow['cash_generated'] for cow in cash_cows),
            'total_projected': sum(cow['target_price'] for cow in cash_cows),
            'count': len(cash_cows)
        })
        
    except Exception as e:
        logger.error(f"Error in get_cash_cows: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@app.route('/api/captain-recommendations', methods=['GET'])
def get_captain_recommendations():
    """Get captain recommendations - iOS app endpoint"""
    try:
        round_number = request.args.get('round', 1, type=int)
        
        # Mock captain recommendations
        recommendations = [
            {
                'player_id': 'cap_001',
                'name': 'Max Gawn',
                'position': 'RUCK',
                'team': 'MEL',
                'projected_score': 125.5,
                'confidence': 0.92,
                'ownership': 45.2,
                'captaincy_rate': 18.7,
                'differential_score': 8.2,
                'matchup_rating': 'Excellent',
                'venue': 'MCG',
                'opponent': 'COL',
                'weather_impact': 'None',
                'reasoning': 'Dominant ruck with excellent record against Collingwood. Home advantage at MCG.',
                'risks': ['Minor ankle concern'],
                'ceiling': 150,
                'floor': 95
            },
            {
                'player_id': 'cap_002',
                'name': 'Sam Walsh',
                'position': 'MID',
                'team': 'CAR',
                'projected_score': 118.3,
                'confidence': 0.88,
                'ownership': 78.9,
                'captaincy_rate': 25.4,
                'differential_score': 2.1,
                'matchup_rating': 'Good',
                'venue': 'Marvel Stadium',
                'opponent': 'ESS',
                'weather_impact': 'Indoor',
                'reasoning': 'Consistent performer with high floor. Good matchup against Essendon midfield.',
                'risks': ['High ownership limits upside'],
                'ceiling': 140,
                'floor': 85
            },
            {
                'player_id': 'cap_003',
                'name': 'Jeremy Cameron',
                'position': 'FWD',
                'team': 'GEE',
                'projected_score': 110.8,
                'confidence': 0.75,
                'ownership': 32.1,
                'captaincy_rate': 8.9,
                'differential_score': 15.3,
                'matchup_rating': 'Very Good',
                'venue': 'GMHBA Stadium',
                'opponent': 'NTH',
                'weather_impact': 'Clear',
                'reasoning': 'Low ownership differential play. North defense has been poor recently.',
                'risks': ['Forward volatility', 'Weather dependent'],
                'ceiling': 165,
                'floor': 60
            }
        ]
        
        return jsonify({
            'status': 'ok',
            'round': round_number,
            'recommendations': recommendations,
            'last_updated': datetime.now().isoformat(),
            'summary': {
                'safe_pick': recommendations[1]['name'],
                'differential_pick': recommendations[2]['name'],
                'premium_pick': recommendations[0]['name']
            }
        })
        
    except Exception as e:
        logger.error(f"Error in get_captain_recommendations: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@app.route('/api/ai-insights', methods=['GET'])
def get_ai_insights():
    """Get AI insights for dashboard - iOS app endpoint"""
    try:
        # Mock AI insights
        insights = [
            {
                'id': 'insight_001',
                'type': 'trade_opportunity',
                'title': 'Premium Upgrade Available',
                'description': 'Consider upgrading your mid-price defender to a premium option. Market conditions favor this move.',
                'priority': 'high',
                'confidence': 0.87,
                'action_required': True,
                'icon': 'arrow.up.circle.fill',
                'color': 'green'
            },
            {
                'id': 'insight_002', 
                'type': 'injury_alert',
                'title': 'Injury Risk Detected',
                'description': 'Player in your team has elevated injury risk based on recent match data and load management.',
                'priority': 'medium',
                'confidence': 0.72,
                'action_required': False,
                'icon': 'exclamationmark.triangle.fill',
                'color': 'orange'
            },
            {
                'id': 'insight_003',
                'type': 'captain_suggestion',
                'title': 'Captain Differential Opportunity', 
                'description': 'Low ownership premium player with excellent matchup this week - consider for captaincy.',
                'priority': 'medium',
                'confidence': 0.81,
                'action_required': False,
                'icon': 'crown.fill',
                'color': 'purple'
            }
        ]
        
        return jsonify({
            'status': 'ok',
            'insights': insights,
            'count': len(insights),
            'generated_at': datetime.now().isoformat()
        })
        
    except Exception as e:
        logger.error(f"Error in get_ai_insights: {str(e)}")
        return jsonify({
            'status': 'error', 
            'message': str(e)
        }), 500

@app.route('/api/price-projections', methods=['POST'])
def get_price_projections():
    """Get price projections for specific players - iOS app endpoint"""
    try:
        data = request.get_json()
        player_ids = data.get('player_ids', [])
        
        if not player_ids:
            return jsonify({
                'status': 'error',
                'message': 'No player IDs provided'
            }), 400
        
        # Mock price projections
        projections = []
        for player_id in player_ids:
            projection = {
                'player_id': player_id,
                'current_price': 650000,
                'projected_prices': {
                    'week_1': 665000,
                    'week_2': 672000, 
                    'week_3': 681000,
                    'week_4': 695000,
                    'week_5': 708000
                },
                'price_changes': [15000, 7000, 9000, 14000, 13000],
                'total_change': 58000,
                'confidence': 0.79,
                'factors': [
                    'Recent form trending up',
                    'Favorable fixture run',
                    'Low breakeven relative to average'
                ]
            }
            projections.append(projection)
        
        return jsonify({
            'status': 'ok',
            'projections': projections,
            'count': len(projections)
        })
        
    except Exception as e:
        logger.error(f"Error in get_price_projections: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

# ===== END NEW ENDPOINTS =====

if __name__ == '__main__':
    print("Starting AFL Fantasy Trade API server...")
    print("Server will be available at: http://127.0.0.1:9001")
    print("\n📋 Available Endpoints:")
    print("• GET  /health - Health check")
    print("• POST /api/trade_score - Trade analysis")
    print("• GET  /api/players - All players")
    print("• GET  /api/players/<id> - Player details") 
    print("• GET  /api/cash-cows - Cash cow analysis")
    print("• GET  /api/captain-recommendations - Captain suggestions")
    print("• GET  /api/ai-insights - AI insights for dashboard")
    print("• POST /api/price-projections - Price projections")
    print("• GET  /api/afl-fantasy/dashboard-data - Dashboard data")
    print("• POST /api/afl-fantasy/validate-credentials - Credential validation")
    print("\n🚀 Starting server on http://127.0.0.1:9001...\n")
    app.run(host='127.0.0.1', port=9001, debug=False, threaded=True)
