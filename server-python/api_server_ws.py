#!/usr/bin/env python3
"""
AFL Fantasy API Server with WebSocket Support
Serves scraped DFS Australia data to iOS app with real-time updates
"""

from flask import Flask, jsonify, request
from flask_cors import CORS
from flask_socketio import SocketIO, emit
import pandas as pd
import glob
import os
from datetime import datetime
import traceback
import json
from pathlib import Path
import random
import threading
import time
import hashlib

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})  # Enable CORS for iOS app

# Initialize SocketIO with CORS support
socketio = SocketIO(app, cors_allowed_origins="*", async_mode='threading')

# Global cache for performance
players_cache = {}
last_cache_update = None
CACHE_TTL = 3600  # 1 hour cache

# ETag support for caching
etag_cache = {}

# Live simulation data
live_simulation = {
    "enabled": False,
    "current_score": 1247,
    "rank": 12543,
    "players_playing": 15,
    "players_remaining": 7,
    "average_score": 1156.8
}

def log_info(message):
    """Simple logging"""
    print(f"[{datetime.now().strftime('%H:%M:%S')}] INFO: {message}")

def log_error(message):
    """Error logging"""
    print(f"[{datetime.now().strftime('%H:%M:%S')}] ERROR: {message}")

def generate_etag(data):
    """Generate ETag for response data"""
    return hashlib.md5(json.dumps(data, sort_keys=True).encode()).hexdigest()

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
    trend = calculate_price_trend(player_data)
    if trend > 0:
        return 25000  # Rising players
    else:
        return -10000  # Falling players

def calculate_cash_generated(player_data):
    """Calculate potential cash generated"""
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
# WEBSOCKET HANDLERS
# ================================

@socketio.on('connect')
def handle_connect():
    """Handle WebSocket connection"""
    log_info(f"WebSocket client connected: {request.sid}")
    emit('connection_status', {'status': 'connected', 'timestamp': datetime.now().isoformat()})

@socketio.on('disconnect')
def handle_disconnect():
    """Handle WebSocket disconnection"""
    log_info(f"WebSocket client disconnected: {request.sid}")

@socketio.on('subscribe_live_updates')
def handle_subscribe_live_updates():
    """Subscribe client to live score updates"""
    log_info(f"Client {request.sid} subscribed to live updates")
    emit('subscription_confirmed', {'type': 'live_updates', 'status': 'subscribed'})
    
    # Send initial live stats
    emit_live_stats()

def emit_live_stats():
    """Emit current live stats to connected clients"""
    live_update = {
        "type": "live_stats",
        "liveStats": {
            "currentScore": live_simulation["current_score"],
            "rank": live_simulation["rank"],
            "playersPlaying": live_simulation["players_playing"],
            "playersRemaining": live_simulation["players_remaining"],
            "averageScore": live_simulation["average_score"]
        },
        "timestamp": datetime.now().isoformat()
    }
    socketio.emit('live_update', live_update)

def emit_alert(alert_type, title, message, player_id=None):
    """Emit an alert to connected clients"""
    alert_update = {
        "type": "alert",
        "alert": {
            "id": str(datetime.now().timestamp()),
            "title": title,
            "message": message,
            "type": alert_type,
            "timestamp": datetime.now().isoformat(),
            "isRead": False,
            "playerId": player_id
        }
    }
    socketio.emit('live_update', alert_update)

def simulate_live_updates():
    """Background thread to simulate live score updates"""
    while True:
        time.sleep(30)  # Update every 30 seconds
        
        if not live_simulation["enabled"]:
            continue
            
        # Simulate score changes
        score_change = random.randint(-5, 25)
        live_simulation["current_score"] += score_change
        
        # Simulate rank changes
        if score_change > 0:
            live_simulation["rank"] -= random.randint(0, 100)
        else:
            live_simulation["rank"] += random.randint(0, 200)
        
        # Simulate players playing
        if live_simulation["players_playing"] < 22 and random.random() > 0.5:
            live_simulation["players_playing"] += 1
            live_simulation["players_remaining"] = max(0, live_simulation["players_remaining"] - 1)
        
        # Update average score
        live_simulation["average_score"] += random.uniform(-2, 5)
        
        # Emit live stats update
        emit_live_stats()
        
        # Occasionally emit alerts
        if random.random() > 0.7:
            alert_types = ["PRICE_CHANGE", "INJURY", "LATE_OUT", "ROLE_CHANGE"]
            alert_type = random.choice(alert_types)
            
            if alert_type == "PRICE_CHANGE":
                emit_alert(
                    "PRICE_CHANGE",
                    "Price Movement Alert",
                    f"Marcus Bontempelli has increased by $12,500",
                    "bontempelli_marcus"
                )
            elif alert_type == "INJURY":
                emit_alert(
                    "INJURY",
                    "Injury Update",
                    "Clayton Oliver questionable for next match",
                    "oliver_clayton"
                )
            elif alert_type == "LATE_OUT":
                emit_alert(
                    "LATE_OUT",
                    "Late Out Alert",
                    "Nick Daicos withdrawn from team",
                    "daicos_nick"
                )
            else:
                emit_alert(
                    "ROLE_CHANGE",
                    "Role Change",
                    "Jordan Dawson moved to midfield",
                    "dawson_jordan"
                )

# ================================
# API ENDPOINTS
# ================================

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    response_data = {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "playersLoaded": len(players_cache),
        "lastCacheUpdate": last_cache_update.isoformat() if last_cache_update else None,
        "websocketEnabled": True
    }
    
    # Add ETag header
    etag = generate_etag(response_data)
    if request.headers.get('If-None-Match') == etag:
        return '', 304
    
    response = jsonify(response_data)
    response.headers['ETag'] = etag
    return response

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
        
        # Generate ETag
        etag = generate_etag(players)
        if request.headers.get('If-None-Match') == etag:
            log_info("Returning 304 Not Modified for /api/players")
            return '', 304
        
        log_info(f"Returning {len(players)} players")
        response = jsonify(players)
        response.headers['ETag'] = etag
        return response
        
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
                        "playerId": player_id,
                        "playerName": analysis["name"],
                        "currentPrice": analysis["current_price"],
                        "projectedPrice": analysis["projected_price"],
                        "cashGenerated": analysis["cash_generated"],
                        "recommendation": analysis["recommendation"],
                        "confidence": analysis["confidence"],
                        "fpAverage": analysis["fp_average"],
                        "gamesPlayed": analysis["games_played"]
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
                    # Convert to camelCase for iOS
                    suggestions.append({
                        "playerId": suggestion["player_id"],
                        "playerName": suggestion["player_name"],
                        "projectedPoints": suggestion["projected_points"],
                        "confidence": suggestion["confidence"],
                        "reasoning": suggestion["reasoning"]
                    })
        
        # Sort by projected points descending, then by confidence
        suggestions.sort(key=lambda x: (x["projectedPoints"], x["confidence"]), reverse=True)
        
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
            "totalPlayers": total_players,
            "playersWithData": players_with_data,
            "cashCowsIdentified": cash_cows_count,
            "lastUpdated": last_cache_update.isoformat() if last_cache_update else None,
            "cacheAgeMinutes": int((datetime.now() - last_cache_update).seconds / 60) if last_cache_update else 0
        }
        
        # Generate ETag
        etag = generate_etag(summary)
        if request.headers.get('If-None-Match') == etag:
            log_info("Returning 304 Not Modified for /api/stats/summary")
            return '', 304
        
        response = jsonify(summary)
        response.headers['ETag'] = etag
        return response
        
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

@app.route('/api/live/toggle', methods=['POST'])
def toggle_live_simulation():
    """Toggle live simulation on/off"""
    data = request.get_json() if request.is_json else {}
    enabled = data.get('enabled', not live_simulation["enabled"])
    
    live_simulation["enabled"] = enabled
    log_info(f"Live simulation {'enabled' if enabled else 'disabled'}")
    
    if enabled:
        emit_live_stats()
    
    return jsonify({
        "status": "success",
        "live_simulation_enabled": enabled,
        "timestamp": datetime.now().isoformat()
    })

if __name__ == '__main__':
    print("=" * 60)
    print("🏈 AFL Fantasy API Server with WebSocket Support")
    print("=" * 60)
    print("📁 Loading player data from Excel files...")
    
    # Initial data load
    load_players_data()
    
    if players_cache:
        print(f"✅ Successfully loaded {len(players_cache)} players")
        
        # Start background thread for live updates
        simulation_thread = threading.Thread(target=simulate_live_updates, daemon=True)
        simulation_thread.start()
        print("🔄 Live update simulation thread started")
        
        # Use PORT environment variable or default to 8080
        port = int(os.environ.get('PORT', 8080))
        print(f"🌐 Server starting on http://localhost:{port}")
        print(f"🔌 WebSocket endpoint: ws://localhost:{port}/socket.io/")
        print("📋 Available endpoints:")
        print("   GET  /health                    - Health check (ETag support)")
        print("   GET  /api/players               - All players list (ETag support)")
        print("   GET  /api/players/<id>          - Player details")  
        print("   GET  /api/stats/cash-cows       - Cash cow analysis")
        print("   POST /api/captain/suggestions   - Captain recommendations")
        print("   GET  /api/stats/summary         - Data summary (ETag support)")
        print("   POST /api/refresh               - Refresh data cache")
        print("   POST /api/live/toggle           - Toggle live simulation")
        print("")
        print("🔌 WebSocket Events:")
        print("   connect                         - Client connection")
        print("   subscribe_live_updates          - Subscribe to live score updates")
        print("   live_update                     - Receive live stats/alerts")
        print("=" * 60)
        
        # Start the server with SocketIO
        socketio.run(app, host='0.0.0.0', port=port, debug=True)
    else:
        print("❌ No player data found! Please check the dfs_player_summary folder exists.")
        print("Expected: ./dfs_player_summary/*.xlsx files")
