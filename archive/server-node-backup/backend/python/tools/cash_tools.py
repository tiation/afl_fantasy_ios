"""
AFL Fantasy Cash Tools

This module provides tools for analyzing cash generation and managing
rookie/low-price players in your fantasy team.
"""

from scraper import get_player_data


# Tool 1: Cash Generation Tracker
def cash_generation_tracker():
    """
    Track potential cash generation from players
    
    Returns:
        list: List of players with price change estimates
    """
    data = get_player_data()
    return [
        {
            "player": p["name"],
            "team": p["team"],
            "price": p["price"],
            "breakeven": p["breakeven"],
            "3_game_avg": p["l3_avg"],
            "price_change_est": round((p["l3_avg"] - p["breakeven"]) * 150),  # Scaled estimate
        }
        for p in data if p["games"] >= 2
    ]


# Tool 2: Rookie Price Curve Model
def rookie_price_curve_model():
    """
    Model the price curve for rookies
    
    Returns:
        list: List of rookies with price projections
    """
    data = get_player_data()
    rookies = [p for p in data if p["price"] < 500000 and p["games"] >= 2]
    return [
        {
            "player": r["name"],
            "price": r["price"],
            "l3_avg": r["l3_avg"],
            "price_projection_next_3": round(r["price"] + ((r["l3_avg"] - r["breakeven"]) * 150 * 3))
        }
        for r in rookies
    ]


# Tool 3: Downgrade Target Finder
def downgrade_target_finder():
    """
    Find potential downgrade targets based on rookies with low breakevens
    
    Returns:
        list: List of rookies with low breakevens, sorted by breakeven
    """
    data = get_player_data()
    return sorted(
        [p for p in data if p["price"] < 500000 and p["breakeven"] < 40],
        key=lambda x: x["breakeven"]
    )


# Tool 4: Cash Gen Ceiling/Floor
def cash_gen_ceiling_floor():
    """
    Calculate ceiling and floor price changes for players
    
    Returns:
        list: List of players with ceiling and floor price changes
    """
    data = get_player_data()
    result = []
    for p in data:
        if "l3_avg" in p and p["l3_avg"] > 0 and "breakeven" in p:
            diff = p["l3_avg"] - p["breakeven"]
            est_change = round(diff * 150)
            result.append({
                "player": p["name"],
                "team": p["team"],
                "price": p["price"],
                "floor": est_change - 3000,  # simulating bad games
                "ceiling": est_change + 3000,  # simulating breakout games
            })
    return result


# Tool 5: Price Predictor Calculator
def price_predictor_calculator(player_name=None, scores=None):
    """
    Calculate predicted price based on future scores
    
    Parameters:
        player_name (str, optional): Name of the player to predict price for
        scores (list, optional): List of predicted scores for next rounds
    
    Returns:
        dict: Price prediction data
    """
    if not player_name or not scores:
        return {"error": "Player name and scores are required"}
    
    data = get_player_data()
    
    # Find the player
    player = None
    for p in data:
        if p["name"].lower() == player_name.lower():
            player = p
            break
    
    if not player:
        return {"error": f"Player '{player_name}' not found"}
    
    # Calculate the price changes
    current_price = player["price"]
    breakeven = player["breakeven"]
    
    price_changes = []
    
    for i, score in enumerate(scores):
        # Calculate price change
        diff = score - breakeven
        price_change = round(diff * 150)
        new_price = current_price + price_change
        
        price_changes.append({
            "round": i + 1,
            "score": score,
            "price_change": price_change,
            "new_price": new_price
        })
        
        # Update for next round
        current_price = new_price
        # Adjust breakeven (simplified model)
        breakeven = round(breakeven + (diff * 0.1))
    
    return {
        "player": player_name,
        "starting_price": player["price"],
        "starting_breakeven": player["breakeven"],
        "price_changes": price_changes,
        "final_price": price_changes[-1]["new_price"] if price_changes else player["price"]
    }


# Tool 6: Price Ceiling/Floor Estimator
def price_ceiling_floor_estimator():
    """
    Estimate ceiling and floor prices for players
    
    Returns:
        list: List of players with ceiling and floor price estimates
    """
    data = get_player_data()
    result = []
    
    for p in data:
        if p["games"] >= 3:  # Only include players with enough games
            current_price = p["price"]
            avg = p["avg"]
            be = p["breakeven"]
            
            # Calculate ceiling (assuming 25% above average)
            ceiling_avg = avg * 1.25
            ceiling_diff = ceiling_avg - be
            ceiling_price = current_price + round(ceiling_diff * 150 * 6)  # Project 6 rounds ahead
            
            # Calculate floor (assuming 25% below average)
            floor_avg = avg * 0.75
            floor_diff = floor_avg - be
            floor_price = current_price + round(floor_diff * 150 * 6)  # Project 6 rounds ahead
            
            # Cap the floor price at minimum
            floor_price = max(floor_price, 102000)  # Minimum player price
            
            result.append({
                "player": p["name"],
                "team": p["team"],
                "position": p["position"],
                "current_price": current_price,
                "ceiling_price": ceiling_price,
                "floor_price": floor_price,
                "ceiling_gain": ceiling_price - current_price,
                "floor_loss": current_price - floor_price
            })
    
    # Sort by ceiling gain (highest first)
    return sorted(result, key=lambda x: x["ceiling_gain"], reverse=True)


if __name__ == "__main__":
    # Simple test to show the cash generation tracker when run directly
    print("Cash Generation Tracker:")
    cash_gen = cash_generation_tracker()
    # Show the top 5 players by price change estimate
    for player in sorted(cash_gen, key=lambda x: x["price_change_est"], reverse=True)[:5]:
        print(f"{player['player']} (${player['price']:,}): BE {player['breakeven']}, " +
              f"3-Game Avg {player['3_game_avg']}, Est. Change ${player['price_change_est']:+,}")
    
    print("\nDowngrade Target Finder:")
    # Show the top 5 downgrade targets
    for player in downgrade_target_finder()[:5]:
        print(f"{player['name']} (${player['price']:,}): BE {player['breakeven']}")