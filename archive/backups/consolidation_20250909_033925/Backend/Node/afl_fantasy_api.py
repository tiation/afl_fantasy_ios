"""
AFL Fantasy API Integration

Flask API endpoints to serve authentic AFL Fantasy data for dashboard cards.
"""

from flask import Flask, jsonify, request
import subprocess
import json
import os
from datetime import datetime, timedelta

app = Flask(__name__)

# Cache for AFL Fantasy data to avoid excessive scraping
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
            'python', 'afl_fantasy_authenticated_scraper.py'
        ], capture_output=True, text=True, timeout=120)
        
        if result.returncode == 0:
            print("AFL Fantasy scraper executed successfully")
            
            # Try to load the saved data file
            try:
                with open('afl_fantasy_team_data.json', 'r') as f:
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

if __name__ == '__main__':
    app.run(debug=True, port=5001)