"""
AFL Fantasy API Integration - Development Version
Serves mock data for testing without needing the actual scraper.
"""

from flask import Flask, jsonify, request
from flask_cors import CORS
import json
import os
from datetime import datetime, timedelta

app = Flask(__name__)
CORS(app)  # Enable CORS for iOS app testing

def get_mock_data():
    """Get mock AFL Fantasy data"""
    return {
        'team_value': 12850000,
        'player_count': 22,
        'team_score': 2156,
        'captain_score': 142,
        'captain_name': 'N. Daicos',
        'captain_ownership': 18.7,
        'overall_rank': 42567,
        'score_change': 45,
        'rank_change': -1200,
        'last_updated': datetime.now().isoformat()
    }

@app.route('/api/afl-fantasy/dashboard-data', methods=['GET'])
def get_dashboard_data():
    """Get all dashboard data from AFL Fantasy"""
    try:
        data = get_mock_data()
        
        # Format data for dashboard consumption
        dashboard_data = {
            'team_value': {
                'total': data.get('team_value', 0),
                'player_count': data.get('player_count', 0),
                'remaining_salary': max(0, 13000000 - data.get('team_value', 0)),
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
            'last_updated': data.get('last_updated')
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
        data = get_mock_data()
        
        team_value = data.get('team_value', 0)
        remaining_salary = max(0, 13000000 - team_value)
        
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
        data = get_mock_data()
        
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
        data = get_mock_data()
        
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
        data = get_mock_data()
        
        return jsonify({
            'captain_score': data.get('captain_score', 0),
            'captain_name': data.get('captain_name', 'Unknown'),
            'ownership_percentage': data.get('captain_ownership', 0),
            'formatted_ownership': f"{data.get('captain_ownership', 0):.1f}% of teams"
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/afl-fantasy/players', methods=['GET'])
def get_players():
    """Get player list data"""
    try:
        # Try to read from player_data.json if available
        player_file = '../player_data.json'
        if os.path.exists(player_file):
            with open(player_file, 'r') as f:
                players = json.load(f)
                # Return first 10 players for demo
                return jsonify({
                    'players': players[:10],
                    'total_count': len(players)
                })
        
        # Fallback mock data
        mock_players = [
            {'name': 'N. Daicos', 'team': 'COL', 'avg': 115.2, 'price': 650000},
            {'name': 'M. Bontempelli', 'team': 'WBD', 'avg': 108.7, 'price': 620000},
            {'name': 'C. Rozee', 'team': 'PTA', 'avg': 102.4, 'price': 590000}
        ]
        
        return jsonify({
            'players': mock_players,
            'total_count': len(mock_players)
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'ok',
        'service': 'afl_fantasy_api_dev',
        'timestamp': datetime.now().isoformat()
    })

if __name__ == '__main__':
    print("Starting AFL Fantasy API (Development Mode)")
    print("Available endpoints:")
    print("  GET /api/afl-fantasy/dashboard-data")
    print("  GET /api/afl-fantasy/team-value")
    print("  GET /api/afl-fantasy/team-score")
    print("  GET /api/afl-fantasy/rank")
    print("  GET /api/afl-fantasy/captain")
    print("  GET /api/afl-fantasy/players")
    print("  GET /api/health")
    app.run(debug=True, port=5001, host='0.0.0.0')
