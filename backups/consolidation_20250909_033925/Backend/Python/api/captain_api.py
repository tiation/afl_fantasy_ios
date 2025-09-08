"""
Captain Tools API

This module provides a Flask API for the captain tools,
allowing them to be called from the NodeJS server.
"""

from flask import Flask, jsonify
from captain_tools import (
    captain_score_predictor,
    vice_captain_optimizer,
    loophole_detector,
    form_based_captain_analyzer,
    matchup_based_captain_advisor
)

app = Flask(__name__)

@app.route('/api/captain/score-predictor', methods=['GET'])
def api_captain_score_predictor():
    """API endpoint for Captain Score Predictor"""
    try:
        results = captain_score_predictor()
        return jsonify({"status": "ok", "players": results})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)})

@app.route('/api/captain/vice-captain-optimizer', methods=['GET'])
def api_vice_captain_optimizer():
    """API endpoint for Vice-Captain Optimizer"""
    try:
        results = vice_captain_optimizer()
        return jsonify({"status": "ok", "combinations": results})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)})

@app.route('/api/captain/loophole-detector', methods=['GET'])
def api_loophole_detector():
    """API endpoint for Loophole Detector"""
    try:
        results = loophole_detector()
        return jsonify({"status": "ok", "data": results})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)})

@app.route('/api/captain/form-based-analyzer', methods=['GET'])
def api_form_based_captain_analyzer():
    """API endpoint for Form-based Captain Analyzer"""
    try:
        results = form_based_captain_analyzer()
        return jsonify({"status": "ok", "players": results})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)})

@app.route('/api/captain/matchup-based-advisor', methods=['GET'])
def api_matchup_based_captain_advisor():
    """API endpoint for Matchup-based Captain Advisor"""
    try:
        results = matchup_based_captain_advisor()
        return jsonify({"status": "ok", "players": results})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)