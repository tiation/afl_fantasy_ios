from flask import Flask, request, jsonify
from flask_cors import CORS
import logging
import numpy as np
from typing import Dict, List, Any, Tuple

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

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
