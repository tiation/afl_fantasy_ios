"""
Cash Tools API

This module provides a Flask API for the cash generation tools,
allowing them to be called from the NodeJS server.
"""

import json
from flask import Flask, request, jsonify
from flask_cors import CORS
from cash_tools import (
    cash_generation_tracker,
    rookie_price_curve_model,
    downgrade_target_finder,
    cash_gen_ceiling_floor,
    price_predictor_calculator,
    price_ceiling_floor_estimator
)

app = Flask(__name__)
CORS(app)  # Enable CORS to allow requests from NodeJS

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

if __name__ == '__main__':
    # Run the API on port 5001 so it doesn't conflict with the main NodeJS server
    # In Replit, we need to bind to 0.0.0.0 to make the API accessible
    print("Starting Cash Tools API on port 5001...")
    app.run(host='0.0.0.0', port=5001, debug=True)