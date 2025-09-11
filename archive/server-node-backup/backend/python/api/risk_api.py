"""
Risk Tools API

This module provides a Flask API for the risk evaluation tools,
allowing them to be called from the NodeJS server.
"""

from flask import Flask, jsonify, request
import risk_tools

# Create the Flask app
app = Flask(__name__)
app.json.sort_keys = False  # Preserve the order of keys in JSON responses

# API endpoints for risk tools

@app.route('/api/tag_watch_monitor', methods=['GET'])
def api_tag_watch_monitor():
    """API endpoint for Tag Watch Monitor"""
    try:
        data = risk_tools.tag_watch_monitor()
        return jsonify({'status': 'ok', 'data': data})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/api/tag_history_impact_tracker', methods=['GET'])
def api_tag_history_impact_tracker():
    """API endpoint for Tag History Impact Tracker"""
    try:
        data = risk_tools.tag_history_impact_tracker()
        return jsonify({'status': 'ok', 'data': data})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/api/tag_target_priority_ranker', methods=['GET'])
def api_tag_target_priority_ranker():
    """API endpoint for Tag Target Priority Ranker"""
    try:
        data = risk_tools.tag_target_priority_ranker()
        return jsonify({'status': 'ok', 'data': data})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/api/tag_breaker_score_estimator', methods=['GET'])
def api_tag_breaker_score_estimator():
    """API endpoint for Tag Breaker Score Estimator"""
    try:
        data = risk_tools.tag_breaker_score_estimator()
        return jsonify({'status': 'ok', 'data': data})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/api/injury_risk_model', methods=['GET'])
def api_injury_risk_model():
    """API endpoint for Injury Risk Model"""
    try:
        data = risk_tools.injury_risk_model()
        return jsonify({'status': 'ok', 'data': data})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/api/volatility_index_calculator', methods=['GET'])
def api_volatility_index_calculator():
    """API endpoint for Volatility Index Calculator"""
    try:
        data = risk_tools.volatility_index_calculator()
        return jsonify({'status': 'ok', 'data': data})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/api/consistency_score_generator', methods=['GET'])
def api_consistency_score_generator():
    """API endpoint for Consistency Score Generator"""
    try:
        data = risk_tools.consistency_score_generator()
        return jsonify({'status': 'ok', 'data': data})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/api/scoring_range_predictor', methods=['GET'])
def api_scoring_range_predictor():
    """API endpoint for Scoring Range Predictor"""
    try:
        data = risk_tools.scoring_range_predictor()
        return jsonify({'status': 'ok', 'data': data})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/api/late_out_risk_estimator', methods=['GET'])
def api_late_out_risk_estimator():
    """API endpoint for Late Out Risk Estimator"""
    try:
        data = risk_tools.late_out_risk_estimator()
        return jsonify({'status': 'ok', 'data': data})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

# Main entry point
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)