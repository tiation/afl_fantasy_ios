"""
AFL Fantasy Price Tools

This module provides price analysis tools to help Fantasy coaches
monitor player price changes and make strategic decisions on trades.
"""

import json
import os
from datetime import datetime
import random
import copy

def get_player_data():
    """Get player data from the JSON file"""
    try:
        with open('player_data.json', 'r') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading player data: {e}")
        return []

def price_projection_calculator():
    """
    Calculates projected price changes based on player's breakeven and recent
    scoring form (L3 average)
    
    Returns:
        list: Players with their current price and projected prices
    """
    player_data = get_player_data()
    projections = []
    
    for player in player_data:
        # Check if player has required data
        if not all(key in player for key in ['name', 'price', 'l3_avg', 'breakeven']):
            continue
            
        # Calculate projected price change
        # Formula: (L3 average - breakeven) * magic number / 100
        # Magic number is around 9750, slight adjustment for premium players
        l3_avg = player.get('l3_avg', 0)
        breakeven = player.get('breakeven', 0)
        price = player.get('price', 0)
        
        # Adjust magic number based on player price
        magic_number = 9750
        if price > 1000000:  # Premium player
            magic_number = 9850
        elif price < 300000:  # Rookie
            magic_number = 9650
            
        # Calculate projected price change
        price_change = (l3_avg - breakeven) * (magic_number / 100)
        projected_price = max(price + price_change, 150000)  # Minimum price floor
        
        projections.append({
            'player': player.get('name', 'Unknown'),
            'team': player.get('team', 'Unknown'),
            'position': player.get('position', 'Unknown'),
            'price_now': price,
            'l3_avg': l3_avg,
            'breakeven': breakeven,
            'projected_price_next': int(projected_price)
        })
    
    # Sort by projected price change (descending)
    projections.sort(key=lambda x: (x['projected_price_next'] - x['price_now']), reverse=True)
    return projections[:50]  # Return top 50 players

def breakeven_trend_analyzer():
    """
    Analyzes trends in player breakevens over recent rounds
    
    Returns:
        list: Players with their breakeven trends over past rounds
    """
    player_data = get_player_data()
    trends = []
    
    # Dummy BE history data (in a real implementation, this would come from historical data)
    rounds_completed = 7  # Example: we're in round 8
    
    for player in player_data:
        # Only include premium players (price > 800k)
        if player.get('price', 0) < 800000:
            continue
            
        # Generate historical BE data (in a real implementation, we'd use actual historical data)
        # For this example, we'll create trends based on current BE with some random variation
        current_be = player.get('breakeven', 0)
        
        # Create a trend - either consistently rising, falling, or fluctuating
        be_trend = []
        trend_type = random.choice(['rising', 'falling', 'fluctuating'])
        
        if trend_type == 'rising':
            for i in range(rounds_completed, max(rounds_completed-4, 0), -1):
                be_trend.append(int(current_be - (i * random.uniform(5, 15))))
                
        elif trend_type == 'falling':
            for i in range(rounds_completed, max(rounds_completed-4, 0), -1):
                be_trend.append(int(current_be + (i * random.uniform(5, 15))))
                
        else:  # fluctuating
            for i in range(rounds_completed, max(rounds_completed-4, 0), -1):
                variation = random.uniform(-15, 15)
                be_trend.append(int(current_be + variation))
        
        # Append current BE
        be_trend.append(current_be)
        
        # Determine trend direction (looking at last 2 data points)
        direction = "Rising" if be_trend[-1] > be_trend[-2] else "Falling"
        
        trends.append({
            'player': player.get('name', 'Unknown'),
            'team': player.get('team', 'Unknown'),
            'position': player.get('position', 'Unknown'),
            'current_be': current_be,
            'BE_trend': be_trend,
            'direction': direction
        })
    
    # Sort by trend direction (falling first) and then by current BE
    trends.sort(key=lambda x: (0 if x['direction'] == 'Falling' else 1, x['current_be']))
    return trends[:30]  # Return top 30 players

def price_drop_recovery_predictor():
    """
    Identifies premium players who have recently dropped in price but may recover
    
    Returns:
        list: Players with price drop details and recovery predictions
    """
    player_data = get_player_data()
    recoveries = []
    
    for player in player_data:
        # Only include players with price > 600k
        if player.get('price', 0) < 600000:
            continue
            
        price = player.get('price', 0)
        # In a real implementation, we'd have historical price data
        # For this example, we'll simulate players who have dropped from a peak price
        
        # Create a random price drop between 5-15% for some premium players
        if random.random() < 0.4:  # 40% of premium players have had a price drop
            price_drop_pct = random.uniform(0.05, 0.15)
            price_peak = int(price / (1 - price_drop_pct))
            price_drop = price_peak - price
            
            # Calculate recovery chance based on L3 average vs breakeven
            l3_avg = player.get('l3_avg', 0)
            breakeven = player.get('breakeven', 0)
            
            # Recovery chance formula: how much L3 exceeds BE, normalized to 0-1
            recovery_chance = max(0, min(1, (l3_avg - breakeven) / max(breakeven * 0.3, 1)))
            
            # Recovery time in rounds - how many rounds to get back to peak price
            magic_number = 9750
            if l3_avg > breakeven:
                points_above_be = l3_avg - breakeven
                price_change_per_round = points_above_be * (magic_number / 100)
                recovery_time = price_drop / price_change_per_round if price_change_per_round > 0 else 10
            else:
                recovery_time = 10  # Default to 10+ rounds if BE > L3
            
            recoveries.append({
                'player': player.get('name', 'Unknown'),
                'team': player.get('team', 'Unknown'),
                'position': player.get('position', 'Unknown'),
                'price_now': price,
                'price_peak': price_peak,
                'price_drop': -price_drop,  # Negative to show it's a drop
                'l3_avg': l3_avg,
                'breakeven': breakeven,
                'recovery_chance': recovery_chance,
                'recovery_time': min(recovery_time, 10)  # Cap at 10 rounds
            })
    
    # Sort by recovery chance (descending)
    recoveries.sort(key=lambda x: x['recovery_chance'], reverse=True)
    return recoveries[:25]  # Return top 25 players

def price_vs_score_scatter():
    """
    Provides data for a price vs score scatter plot to identify value
    
    Returns:
        list: Coordinate pairs for plotting price vs average score
    """
    player_data = get_player_data()
    scatter_data = []
    
    for player in player_data:
        # Only include players with adequate data
        if not all(key in player for key in ['name', 'price', 'avg', 'position']):
            continue
            
        # Only include players who have played games
        avg_score = player.get('avg', 0)
        if isinstance(avg_score, str):
            try:
                avg_score = float(avg_score)
            except (ValueError, TypeError):
                avg_score = 0
        
        if avg_score <= 0:
            continue
            
        price = player.get('price', 0)
        avg_score = player.get('avg', 0)
        
        # Z value determines dot size in scatter plot
        # Use TOG (time on ground) or games played if available, otherwise fixed
        z_value = player.get('TOG', player.get('games_played', 50))
        
        scatter_data.append({
            'player': player.get('name', 'Unknown'),
            'position': player.get('position', 'Unknown'),
            'x': price,  # X-axis: price
            'y': avg_score,  # Y-axis: average score
            'label': f"{player.get('name', 'Unknown')} ({player.get('team', 'Unknown')})",
            'z': z_value  # Z-axis: determines dot size
        })
    
    return scatter_data

def value_ranker_by_position():
    """
    Ranks players by value (points per dollar) within each position
    
    Returns:
        list: Players ranked by value score within their position
    """
    player_data = get_player_data()
    
    # Group players by position
    players_by_position = {
        'DEF': [],
        'MID': [],
        'RUC': [],
        'FWD': []
    }
    
    for player in player_data:
        position = player.get('position', '')
        # Skip players with missing data
        if not all(key in player for key in ['name', 'price', 'avg']):
            continue
            
        # Skip players with no games or irrelevant positions
        avg_score = player.get('avg', 0)
        if isinstance(avg_score, str):
            try:
                avg_score = float(avg_score)
            except (ValueError, TypeError):
                avg_score = 0
                
        if avg_score <= 0 or position not in players_by_position:
            continue
            
        price = player.get('price', 0)
        avg = avg_score  # Use the already converted avg_score
        
        # Calculate value score: points per $10,000
        if price > 0:
            value_score = (avg * 10000) / price
        else:
            value_score = 0
            
        players_by_position[position].append({
            'player': player.get('name', 'Unknown'),
            'team': player.get('team', 'Unknown'),
            'position': position,
            'price': price,
            'avg': avg,
            'value_score': value_score
        })
    
    # Sort each position group by value score and add rank
    rankings = []
    for position, players in players_by_position.items():
        players.sort(key=lambda x: x['value_score'], reverse=True)
        
        for i, player in enumerate(players):
            player_copy = copy.deepcopy(player)
            player_copy['rank'] = i + 1
            rankings.append(player_copy)
    
    # Sort final list by value score (descending)
    rankings.sort(key=lambda x: x['value_score'], reverse=True)
    return rankings