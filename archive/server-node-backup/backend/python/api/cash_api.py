"""
Cash Tools API

This module provides a Flask API for the cash generation tools,
allowing them to be called from the NodeJS server.
"""

import json
from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime, timedelta
from cash_tools import (
    cash_generation_tracker,
    rookie_price_curve_model,
    downgrade_target_finder,
    cash_gen_ceiling_floor,
    price_predictor_calculator,
    price_ceiling_floor_estimator
)

app = Flask(__name__)
CORS(app)  # Enable CORS for iOS app

# Cache for cash intelligence data
cache = {
    'data': None,
    'timestamp': None,
    'cache_duration': 300  # 5 minutes cache
}

def get_cash_intelligence_data():
    """Get current cash intelligence data"""
    # Check cache first
    if cache['data'] and cache['timestamp']:
        age = (datetime.now() - datetime.fromisoformat(cache['timestamp'])).seconds
        if age < cache['cache_duration']:
            return cache['data']
    
    # Get live data from tools
    try:
        tracker_data = cash_generation_tracker()
        ceiling_floor = cash_gen_ceiling_floor()
        price_predictions = price_predictor_calculator()
        
        data = {
            'bank_balance': tracker_data.get('bank_balance', 300000),
            'projected_cash': tracker_data.get('projected_cash', 481000),
            'active_cash_cows': len(tracker_data.get('active_cows', [])),
            'total_available': tracker_data.get('total_available', 781000),
            'analysis_timeframe': {
                'now': True,
                'two_weeks': False,
                'four_weeks': False,
                'optimal': True
            },
            'cash_cows': [
                {
                    'name': cow['name'],
                    'team': cow['team'],
                    'position': cow['position'],
                    'price': cow['current_price'],
                    'generated': cow['cash_generated'],
                    'sell_week': cow['optimal_sell_week'],
                    'confidence': cow['ai_confidence'],
                    'projected': cow['projected_price'],
                    'sell_soon': cow['sell_flag']
                } for cow in tracker_data.get('active_cows', [])
            ],
            'ai_settings': {
                'confidence_threshold': 70,
                'target_round': ceiling_floor.get('target_round', 15),
                'analysis_factors': {
                    'recent_form': True,
                    'opponent_dvp': True,
                    'venue_bias': True,
                    'weather': True,
                    'consistency': True,
                    'injury_risk': True,
                    'ownership': True,
                    'ceiling_floor': True
                }
            },
            'last_updated': datetime.now().isoformat()
        }
        
        # Update cache
        cache['data'] = data
        cache['timestamp'] = data['last_updated']
        
        return data
        
    except Exception as e:
        print(f"Error getting cash intelligence data: {e}")
        
        # Return mock data for development
        mock_data = {
            'bank_balance': 300000,
            'projected_cash': 481000,
            'active_cash_cows': 1,
            'total_available': 781000,
            'analysis_timeframe': {
                'now': True,
                'two_weeks': False,
                'four_weeks': False,
                'optimal': True
            },
            'cash_cows': [
                {
                    'name': 'Hayden Young',
                    'team': 'Sydney',
                    'position': 'DEF',
                    'price': 550000,
                    'generated': 120000,
                    'sell_week': 6,
                    'confidence': 93,
                    'projected': 481000,
                    'sell_soon': True
                }
            ],
            'ai_settings': {
                'confidence_threshold': 70,
                'target_round': 15,
                'analysis_factors': {
                    'recent_form': True,
                    'opponent_dvp': True,
                    'venue_bias': True,
                    'weather': True,
                    'consistency': True,
                    'injury_risk': True,
                    'ownership': True,
                    'ceiling_floor': True
                }
            },
            'last_updated': datetime.now().isoformat()
        }
        
        # Update cache with mock data
        cache['data'] = mock_data
        cache['timestamp'] = mock_data['last_updated']
        
        return mock_data

@app.route('/api/cash/generation_tracker', methods=['GET'])
def api_cash_generation_tracker():
    """API endpoint for Cash Generation Tracker"""
    try:
        results = cash_generation_tracker()
        return jsonify({
            "status": "ok",
            "data": results
        })
    except Exception as e:
        return jsonify({
            "status": "error",
            "error": str(e)
        }), 500

@app.route('/api/cash/rookie_price_curve', methods=['GET'])
def api_rookie_price_curve():
    """API endpoint for Rookie Price Curve Model"""
    try:
        results = rookie_price_curve_model()
        return jsonify({
            "status": "ok",
            "data": results
        })
    except Exception as e:
        return jsonify({
            "status": "error",
            "error": str(e)
        }), 500

@app.route('/api/cash/downgrade_targets', methods=['GET'])
def api_downgrade_targets():
    """API endpoint for Downgrade Target Finder"""
    try:
        results = downgrade_target_finder()
        return jsonify({
            "status": "ok",
            "data": results
        })
    except Exception as e:
        return jsonify({
            "status": "error",
            "error": str(e)
        }), 500

@app.route('/api/cash/ceiling_floor', methods=['GET'])
def api_ceiling_floor():
    """API endpoint for Cash Gen Ceiling/Floor"""
    try:
        results = cash_gen_ceiling_floor()
        return jsonify({
            "status": "ok",
            "data": results
        })
    except Exception as e:
        return jsonify({
            "status": "error",
            "error": str(e)
        }), 500

@app.route('/api/cash/price_predictor', methods=['POST'])
def api_price_predictor():
    """API endpoint for Price Predictor Calculator"""
    try:
        data = request.json
        if not data or 'player_name' not in data or 'scores' not in data:
            return jsonify({
                "status": "error",
                "error": "Missing required fields: player_name and scores"
            }), 400
            
        results = price_predictor_calculator(
            player_name=data['player_name'],
            scores=data['scores']
        )
        
        return jsonify({
            "status": "ok",
            "data": results
        })
    except Exception as e:
        return jsonify({
            "status": "error",
            "error": str(e)
        }), 500

@app.route('/api/cash/price_ceiling_floor', methods=['GET'])
def api_price_ceiling_floor():
    """API endpoint for Price Ceiling/Floor Estimator"""
    try:
        results = price_ceiling_floor_estimator()
        return jsonify({
            "status": "ok",
            "data": results
        })
    except Exception as e:
        return jsonify({
            "status": "error",
            "error": str(e)
        }), 500

@app.route('/api/cash/dashboard', methods=['GET'])
def get_dashboard():
    """Get cash intelligence dashboard data"""
    try:
        data = get_cash_intelligence_data()
        if not data:
            return jsonify({'error': 'No cash data available'}), 500
            
        return jsonify({
            'bank_balance': data['bank_balance'],
            'projected_cash': data['projected_cash'],
            'active_cash_cows': data['active_cash_cows'],
            'total_available': data['total_available'],
            'analysis_timeframe': data['analysis_timeframe'],
            'last_updated': data['last_updated']
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/cash/recommendations', methods=['GET'])
def get_recommendations():
    """Get cash cow recommendations"""
    try:
        data = get_cash_intelligence_data()
        if not data:
            return jsonify({'error': 'No cash data available'}), 500
            
        return jsonify({
            'cash_cows': data['cash_cows'],
            'last_updated': data['last_updated']
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/cash/settings', methods=['GET'])
def get_settings():
    """Get AI settings for cash intelligence"""
    try:
        data = get_cash_intelligence_data()
        if not data:
            return jsonify({'error': 'No settings available'}), 500
            
        return jsonify(data['ai_settings'])
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/cash/settings', methods=['POST'])
def update_settings():
    """Update AI settings"""
    try:
        settings = request.get_json()
        if not settings:
            return jsonify({'error': 'No settings provided'}), 400
            
        # Update settings in cache
        data = get_cash_intelligence_data()
        if data and 'ai_settings' in data:
            data['ai_settings'].update(settings)
            cache['data'] = data
            
        return jsonify({
            'message': 'Settings updated successfully',
            'settings': data['ai_settings']
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/cash/analysis/timeframe', methods=['POST'])
def update_timeframe():
    """Update analysis timeframe"""
    try:
        timeframe = request.get_json()
        if not timeframe:
            return jsonify({'error': 'No timeframe provided'}), 400
            
        # Update timeframe in cache
        data = get_cash_intelligence_data()
        if data and 'timeframe' in timeframe:
            data['analysis_timeframe'] = {
                'now': timeframe['timeframe'] == 'now',
                'two_weeks': timeframe['timeframe'] == '2_weeks',
                'four_weeks': timeframe['timeframe'] == '4_weeks',
                'optimal': timeframe['timeframe'] == 'optimal'
            }
            cache['data'] = data
            
        return jsonify({
            'message': 'Timeframe updated successfully',
            'analysis_timeframe': data['analysis_timeframe']
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/cash/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'ok',
        'service': 'cash_intelligence_api',
        'timestamp': datetime.now().isoformat(),
        'cache': {
            'enabled': True,
            'has_data': bool(cache['data']),
            'last_updated': cache.get('timestamp')
        }
    })

if __name__ == '__main__':
    # Run the API on port 5002 to avoid conflicts
    print("Starting Cash Intelligence API on port 5002...")
    app.run(debug=True, port=5002, host='127.0.0.1')
