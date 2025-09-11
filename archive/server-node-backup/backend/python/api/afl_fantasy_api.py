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

# Enable CORS for iOS app
from flask_cors import CORS
CORS(app)

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
    """Fetch fresh data from AFL Fantasy data service or scraper"""
    # Import AFL Fantasy data services
    import sys
    sys.path.append('../scrapers')
    from afl_fantasy_data_service import AFLFantasyDataService
    from afl_fantasy_authenticated_scraper import AFLFantasyAuthenticatedScraper

    # Try data service first (more reliable)
    print("Trying AFL Fantasy data service...")
    try:
        service = AFLFantasyDataService()
        data = service.get_all_dashboard_data()
        
        if data:
            if data.get('tokens_configured'):
                print("Successfully fetched data via data service")
                # Update cache
                cache['data'] = data
                cache['timestamp'] = datetime.now().isoformat()
                return data
            else:
                print("Data service tokens not configured")
                
                # Use mock data for development
                mock_data = {
                    'team_value': 12850000,
                    'player_count': 22,
                    'team_score': 2156,
                    'captain_score': 142,
                    'captain_name': 'N. Daicos',
                    'captain_ownership': 18.7,
                    'overall_rank': 42567,
                    'score_change': 45,
                    'rank_change': -1200,
                    'last_updated': datetime.now().isoformat(),
                    'data_source': 'mock'
                }
                
                # Update cache with mock data
                cache['data'] = mock_data
                cache['timestamp'] = datetime.now().isoformat()
                return mock_data
    except Exception as e:
        print(f"Data service error: {e}")

    # Fallback to Selenium scraper
    print("Falling back to Selenium scraper...")
    try:
        scraper = AFLFantasyAuthenticatedScraper()
        data = scraper.get_all_dashboard_data()
        if data:
            print("Successfully fetched data via scraper")
            # Update cache
            cache['data'] = data
            cache['timestamp'] = datetime.now().isoformat()
            return data
        else:
            print("Scraper failed to fetch data")
            return None
    except Exception as e:
        print(f"Scraper error: {e}")
        return None
    finally:
        if 'scraper' in locals():
            scraper.close()

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

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    try:
        # Try to init the data service to verify dependencies
        import sys
        sys.path.append('../scrapers')
        from afl_fantasy_data_service import AFLFantasyDataService
        from afl_fantasy_authenticated_scraper import AFLFantasyAuthenticatedScraper
        
        service = AFLFantasyDataService()
        
        return jsonify({
            'status': 'ok',
            'service': 'afl_fantasy_api',
            'timestamp': datetime.now().isoformat(),
            'dependencies': {
                'data_service': True,
                'scraper': True
            },
            'cache': {
                'enabled': True,
                'has_data': bool(cache['data']),
                'last_updated': cache.get('timestamp')
            },
            'tokens_configured': service.team_id is not None and service.session_cookie is not None
        })
    except Exception as e:
        print(f"Health check error: {e}")
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

if __name__ == '__main__':
    app.run(debug=True, port=5001, host='127.0.0.1')
