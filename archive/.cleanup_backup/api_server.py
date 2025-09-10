#!/usr/bin/env python3
"""
AFL Fantasy API Server
Serves scraped DFS Australia data to iOS app
"""

from flask import Flask, jsonify, request
from flask_cors import CORS
import pandas as pd
import glob
import os
from datetime import datetime
import traceback
import json
from pathlib import Path

app = Flask(__name__)
CORS(app)  # Enable CORS for iOS app

# Global cache for performance
players_cache = {}
last_cache_update = None
CACHE_TTL = 3600  # 1 hour cache

def log_info(message):
    """Simple logging"""
    print(f"[{datetime.now().strftime('%H:%M:%S')}] INFO: {message}")

def log_error(message):
    """Error logging"""
    print(f"[{datetime.now().strftime('%H:%M:%S')}] ERROR: {message}")

def load_players_data():
    """Load all player data from Excel files into memory cache"""
    global players_cache, last_cache_update
    
    if last_cache_update and (datetime.now() - last_cache_update).seconds < CACHE_TTL:
        log_info(f"Using cached data ({len(players_cache)} players)")
        return
    
    log_info("Loading player data from Excel files...")
    players_cache = {}
    
    data_folder = Path("dfs_player_summary")
    if not data_folder.exists():
        log_error(f"Data folder not found: {data_folder}")
        return
    
    excel_files = list(data_folder.glob("*.xlsx"))
    log_info(f"Found {len(excel_files)} Excel files")
    
    successful_loads = 0
    for file_path in excel_files:
        try:
            player_id = file_path.stem  # filename without extension
            player_data = parse_player_excel(file_path)
            
            if "error" not in player_data:
                players_cache[player_id] = player_data
                successful_loads += 1
            else:
                log_error(f"Error parsing {file_path.name}: {player_data['error']}")
                
        except Exception as e:
            log_error(f"Failed to load {file_path.name}: {e}")
    
    last_cache_update = datetime.now()
    log_info(f"Successfully loaded {successful_loads}/{len(excel_files)} players into cache")

def parse_player_excel(file_path):
    """Convert Excel sheets to JSON-ready format"""
    try:
        xl_file = pd.ExcelFile(file_path)
        player_data = {
            "player_id": file_path.stem,
            "file_name": file_path.name
        }
        
        sheet_mapping = {
            "Season_Summary": "career_stats",
            "vs_Opposition": "opponent_splits", 
            "Recent_Games": "recent_form",
            "All_Games": "game_history",
            "vs_Venues": "venue_stats",
            "vs_Specific_Opposition": "head_to_head"
        }
        
        for sheet_name in xl_file.sheet_names:
            try:
                df = pd.read_excel(file_path, sheet_name=sheet_name)
                
                # Clean the data
                df = df.fillna(0)  # Replace NaN with 0
                df = df.replace([float('inf'), float('-inf')], 0)  # Replace infinity
                
                # Map sheet names to expected format
                mapped_name = sheet_mapping.get(sheet_name, sheet_name.lower().replace(" ", "_"))
                player_data[mapped_name] = df.to_dict('records')
                
            except Exception as e:
                log_error(f"Error parsing sheet {sheet_name} in {file_path.name}: {e}")
                player_data[mapped_name] = []
        
        return player_data
        
    except Exception as e:
        return {"error": f"Failed to parse {file_path}: {e}"}

def extract_player_info(player_data):
    """Extract basic player info from career stats"""
    if "career_stats" not in player_data or not player_data["career_stats"]:
        return {
            "id": player_data.get("player_id", "unknown"),
            "name": player_data.get("player_id", "Unknown Player"),
            "team": "Unknown",
            "position": "MID",
            "price": 200000,
            "average": 0,
            "projected": 0,
            "breakeven": 0
        }
    
    # Get latest season data
    latest_season = player_data["career_stats"][-1]
    
    return {
        "id": player_data.get("player_id", "unknown"),
        "name": latest_season.get("Player", player_data.get("player_id", "Unknown")),
        "team": latest_season.get("TM", "Unknown"),
        "position": map_position(latest_season.get("POS", "")),
        "price": int(latest_season.get("Price", 200000)),
        "average": float(latest_season.get("FP", 0)),
        "projected": calculate_projected_score(player_data),
        "breakeven": calculate_breakeven(player_data)
    }

def map_position(pos_str):
    """Map position string to enum expected by iOS"""
    if not pos_str:
        return "MID"
    pos_upper = str(pos_str).upper()
    if "DEF" in pos_upper:
        return "DEF"
    elif "FWD" in pos_upper or "FORWARD" in pos_upper:
        return "FWD" 
    elif "RUCK" in pos_upper or "RUC" in pos_upper:
        return "RUC"
    else:
        return "MID"

def calculate_projected_score(player_data):
    """Calculate projected score using recent form and historical data"""
    try:
        recent_form = player_data.get("recent_form", [])
        career_stats = player_data.get("career_stats", [])
        
        if not recent_form and not career_stats:
            return 0.0
            
        # Get recent games average (last 5 games)
        recent_scores = []
        for game in recent_form[-5:]:
            fp_score = game.get("FP", 0)
            if fp_score and fp_score > 0:
                recent_scores.append(float(fp_score))
        
        recent_avg = sum(recent_scores) / len(recent_scores) if recent_scores else 0
        
        # Get season average
        season_avg = 0
        if career_stats:
            latest_season = career_stats[-1]
            season_avg = float(latest_season.get("FP", 0))
        
        # Weighted projection: 70% recent form, 30% season average
        if recent_avg > 0:
            projected = (recent_avg * 0.7) + (season_avg * 0.3)
        else:
            projected = season_avg
            
        return round(projected, 1)
        
    except Exception as e:
        log_error(f"Error calculating projected score: {e}")
        return 0.0

def calculate_breakeven(player_data):
    """Calculate breakeven score (simplified)"""
    try:
        career_stats = player_data.get("career_stats", [])
        if not career_stats:
            return 0
            
        latest = career_stats[-1]
        avg_score = float(latest.get("FP", 0))
        
        # Simplified breakeven calculation
        # Real AFL Fantasy uses magic number, but this gives a reasonable estimate
        if avg_score > 80:
            return -15  # Premium players
        elif avg_score > 60:
            return -10  # Mid-tier players  
        else:
            return -5   # Rookies/cheaper players
            
    except Exception as e:
        return 0

def analyze_cash_cow_potential(player_data):
    """Analyze if player is a cash cow opportunity"""
    try:
        career_stats = player_data.get("career_stats", [])
        if not career_stats:
            return {"is_cash_cow": False}
        
        latest_season = career_stats[-1]
        current_price = int(latest_season.get("Price", 0))
        fp_average = float(latest_season.get("FP", 0))
        games_played = int(latest_season.get("GP", 0))
        
        # Cash cow criteria
        is_cash_cow = (
            current_price < 400000 and     # Under 400k
            fp_average > 45 and            # Decent scoring
            games_played > 3 and           # Has played games
            calculate_price_trend(player_data) > 0  # Trending up
        )
        
        recommendation = "HOLD" if is_cash_cow else "SELL"
        confidence = 0.8 if is_cash_cow else 0.3
        
        return {
            "is_cash_cow": is_cash_cow,
            "name": latest_season.get("Player", "Unknown"),
            "current_price": current_price,
            "projected_price": current_price + calculate_projected_price_rise(player_data),
            "cash_generated": calculate_cash_generated(player_data),
            "recommendation": recommendation,
            "confidence": confidence,
            "fp_average": fp_average,
            "games_played": games_played
        }
        
    except Exception as e:
        log_error(f"Error analyzing cash cow potential: {e}")
        return {"is_cash_cow": False}

def calculate_price_trend(player_data):
    """Calculate price trend (simplified - positive = rising)"""
    # In real implementation, would analyze game-by-game price changes
    # For now, use recent form vs season average as proxy
    try:
        recent_form = player_data.get("recent_form", [])
        career_stats = player_data.get("career_stats", [])
        
        if not recent_form or not career_stats:
            return 0
            
        # Get last 3 games average
        recent_scores = [float(g.get("FP", 0)) for g in recent_form[-3:] if g.get("FP", 0) > 0]
        if not recent_scores:
            return 0
            
        recent_avg = sum(recent_scores) / len(recent_scores)
        season_avg = float(career_stats[-1].get("FP", 0))
        
        # If recent form is better than season average, trending up
        return 1 if recent_avg > season_avg else -1
        
    except Exception as e:
        return 0

def calculate_projected_price_rise(player_data):
    """Project price rise over next few weeks"""
    # Simplified calculation based on current form
    trend = calculate_price_trend(player_data)
    if trend > 0:
        return 25000  # Rising players
    else:
        return -10000  # Falling players

def calculate_cash_generated(player_data):
    """Calculate potential cash generated"""
    # Simplified - would normally be (current_price - paid_price)
    try:
        career_stats = player_data.get("career_stats", [])
        if not career_stats:
            return 0
            
        current_price = int(career_stats[-1].get("Price", 200000))
        
        # Estimate based on price and form
        if current_price < 300000:
            return max(0, current_price - 200000)  # Rookie gains
        else:
            return 0  # Premium players don't generate cash
            
    except Exception as e:
        return 0

def calculate_captain_score(player_data, venue=None, opponent=None):
    """Calculate captain recommendation score"""
    try:
        base_score = 0
        confidence = 0.5
        reasoning_parts = []
        
        # Get player name
        career_stats = player_data.get("career_stats", [])
        player_name = "Unknown"
        if career_stats:
            player_name = career_stats[-1].get("Player", "Unknown")
        
        # Analyze opponent splits if opponent provided
        if opponent:
            opponent_splits = player_data.get("opponent_splits", [])
            for split in opponent_splits:
                if str(split.get("OPP", "")).upper() == str(opponent).upper():
                    opponent_fp = float(split.get("FP", 0))
                    if opponent_fp > base_score:
                        base_score = opponent_fp
                        confidence += 0.3
                        reasoning_parts.append(f"Averages {opponent_fp:.1f} vs {opponent}")
                    break
        
        # Analyze venue performance if venue provided
        if venue:
            venue_stats = player_data.get("venue_stats", [])
            for venue_stat in venue_stats:
                venue_name = str(venue_stat.get("Venue", ""))
                if venue.upper() in venue_name.upper():
                    venue_avg = float(venue_stat.get("AVG", 0))
                    if venue_avg > 0:
                        # Weight venue performance with other factors
                        base_score = (base_score + venue_avg) / 2 if base_score > 0 else venue_avg
                        confidence += 0.2
                        reasoning_parts.append(f"Good record at {venue_name}")
                    break
        
        # Factor in recent form
        recent_form = player_data.get("recent_form", [])
        if recent_form:
            recent_scores = [float(g.get("FP", 0)) for g in recent_form[-3:] if g.get("FP", 0) > 0]
            if recent_scores:
                recent_avg = sum(recent_scores) / len(recent_scores)
                if base_score == 0:
                    base_score = recent_avg
                else:
                    base_score = (base_score + recent_avg) / 2
                confidence += 0.1
                reasoning_parts.append(f"Recent form: {recent_avg:.1f} avg")
        
        # Use season average as fallback
        if base_score == 0 and career_stats:
            base_score = float(career_stats[-1].get("FP", 0))
            reasoning_parts.append("Based on season average")
        
        reasoning = "; ".join(reasoning_parts) if reasoning_parts else "Based on available data"
        
        return {
            "player_id": player_data.get("player_id", "unknown"),
            "player_name": player_name,
            "projected_points": round(base_score, 1),
            "confidence": min(confidence, 1.0),
            "reasoning": reasoning
        }
        
    except Exception as e:
        log_error(f"Error calculating captain score: {e}")
        return {
            "player_id": player_data.get("player_id", "unknown"),
            "player_name": "Unknown",
            "projected_points": 0.0,
            "confidence": 0.0,
            "reasoning": "Error calculating score"
        }

# ================================
# API ENDPOINTS
# ================================

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "players_cached": len(players_cache),
        "last_cache_update": last_cache_update.isoformat() if last_cache_update else None
    })

@app.route('/api/players', methods=['GET'])
def get_all_players():
    """Return list of all players with basic info"""
    try:
        load_players_data()
        
        players = []
        for player_id, data in players_cache.items():
            if "error" not in data:
                player_info = extract_player_info(data)
                players.append(player_info)
        
        log_info(f"Returning {len(players)} players")
        return jsonify(players)
        
    except Exception as e:
        log_error(f"Error in get_all_players: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/api/players/<player_id>', methods=['GET'])
def get_player(player_id):
    """Return detailed player data"""
    try:
        load_players_data()
        
        if player_id not in players_cache:
            return jsonify({"error": "Player not found"}), 404
        
        player_data = players_cache[player_id]
        if "error" in player_data:
            return jsonify(player_data), 400
            
        # Add basic info to the detailed data
        result = player_data.copy()
        result["player_info"] = extract_player_info(player_data)
        
        return jsonify(result)
        
    except Exception as e:
        log_error(f"Error in get_player {player_id}: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/api/stats/cash-cows', methods=['GET'])
def get_cash_cows():
    """Analyze all players for cash cow opportunities"""
    try:
        load_players_data()
        
        cash_cows = []
        for player_id, data in players_cache.items():
            if "error" not in data:
                analysis = analyze_cash_cow_potential(data)
                if analysis["is_cash_cow"]:
                    cash_cows.append({
                        "player_id": player_id,
                        "player_name": analysis["name"],
                        "current_price": analysis["current_price"],
                        "projected_price": analysis["projected_price"],
                        "cash_generated": analysis["cash_generated"],
                        "recommendation": analysis["recommendation"],
                        "confidence": analysis["confidence"],
                        "fp_average": analysis["fp_average"],
                        "games_played": analysis["games_played"]
                    })
        
        # Sort by confidence descending
        cash_cows.sort(key=lambda x: x["confidence"], reverse=True)
        
        log_info(f"Found {len(cash_cows)} cash cow opportunities")
        return jsonify(cash_cows)
        
    except Exception as e:
        log_error(f"Error in get_cash_cows: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/api/captain/suggestions', methods=['POST'])
def get_captain_suggestions():
    """Get captain recommendations based on venue/opponent"""
    try:
        data = request.get_json() if request.is_json else {}
        venue = data.get('venue')
        opponent = data.get('opponent')
        
        log_info(f"Getting captain suggestions for venue='{venue}', opponent='{opponent}'")
        
        load_players_data()
        
        suggestions = []
        for player_id, player_data in players_cache.items():
            if "error" not in player_data:
                suggestion = calculate_captain_score(player_data, venue, opponent)
                # Only include players with decent confidence or score
                if suggestion["confidence"] > 0.4 or suggestion["projected_points"] > 70:
                    suggestions.append(suggestion)
        
        # Sort by projected points descending, then by confidence
        suggestions.sort(key=lambda x: (x["projected_points"], x["confidence"]), reverse=True)
        
        # Return top 15 suggestions
        top_suggestions = suggestions[:15]
        
        log_info(f"Returning {len(top_suggestions)} captain suggestions")
        return jsonify(top_suggestions)
        
    except Exception as e:
        log_error(f"Error in get_captain_suggestions: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/api/stats/summary', methods=['GET'])
def get_stats_summary():
    """Get summary statistics about the data"""
    try:
        load_players_data()
        
        total_players = len(players_cache)
        players_with_data = sum(1 for data in players_cache.values() if "error" not in data)
        
        # Count cash cows
        cash_cows_count = 0
        for data in players_cache.values():
            if "error" not in data:
                analysis = analyze_cash_cow_potential(data)
                if analysis["is_cash_cow"]:
                    cash_cows_count += 1
        
        summary = {
            "total_players": total_players,
            "players_with_data": players_with_data,
            "cash_cows_identified": cash_cows_count,
            "last_updated": last_cache_update.isoformat() if last_cache_update else None,
            "cache_age_minutes": int((datetime.now() - last_cache_update).seconds / 60) if last_cache_update else 0
        }
        
        return jsonify(summary)
        
    except Exception as e:
        log_error(f"Error in get_stats_summary: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/api/refresh', methods=['POST'])
def refresh_cache():
    """Force refresh the player data cache"""
    global last_cache_update
    try:
        last_cache_update = None  # Force refresh
        load_players_data()
        
        return jsonify({
            "status": "success",
            "message": f"Cache refreshed with {len(players_cache)} players",
            "timestamp": datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(f"Error refreshing cache: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    print("=" * 60)
    print("🏈 AFL Fantasy API Server Starting...")
    print("=" * 60)
    print("📁 Loading player data from Excel files...")
    
    # Initial data load
    load_players_data()
    
    if players_cache:
        print(f"✅ Successfully loaded {len(players_cache)} players")
        print("🌐 Server starting on http://localhost:4000")
        print("📋 Available endpoints:")
        print("   GET  /health                    - Health check")
        print("   GET  /api/players              - All players list")
        print("   GET  /api/players/<id>         - Player details")  
        print("   GET  /api/stats/cash-cows      - Cash cow analysis")
        print("   POST /api/captain/suggestions  - Captain recommendations")
        print("   GET  /api/stats/summary        - Data summary")
        print("   POST /api/refresh              - Refresh data cache")
        print("=" * 60)
        
        # Start the server
        app.run(host='0.0.0.0', port=4000, debug=True)
    else:
        print("❌ No player data found! Please check the dfs_player_summary folder exists.")
        print("Expected: ./dfs_player_summary/*.xlsx files")
