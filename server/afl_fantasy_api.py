"""
AFL Fantasy API Integration

Flask API endpoints to serve authentic AFL Fantasy data for dashboard cards.
"""

from flask import Flask, jsonify, request
from flask_socketio import SocketIO, emit
import subprocess
import json
import os
from datetime import datetime, timedelta
import threading
import time
import random
from dataclasses import dataclass
from typing import Optional, Dict, Any

app = Flask(__name__)
socketio = SocketIO(app, cors_allowed_origins="*", logger=True, engineio_logger=True)

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

# WebSocket Alert System
@dataclass
class Alert:
    id: str
    alert_type: str
    title: str
    message: str
    timestamp: str
    player_id: Optional[str] = None
    data: Optional[Dict[str, Any]] = None

# Connected clients tracking
connected_clients = set()
alert_simulation_active = False

@socketio.on('connect')
def handle_connect():
    print(f'Client connected: {request.sid}')
    connected_clients.add(request.sid)
    emit('connection_confirmed', {'status': 'connected', 'client_id': request.sid})

@socketio.on('disconnect')
def handle_disconnect():
    print(f'Client disconnected: {request.sid}')
    connected_clients.discard(request.sid)

@socketio.on('subscribe')
def handle_subscribe(data):
    channels = data.get('channels', [])
    print(f'Client {request.sid} subscribed to channels: {channels}')
    emit('subscribed', {'channels': channels, 'status': 'success'})

def broadcast_alert(alert: Alert):
    """Broadcast alert to all connected clients"""
    alert_data = {
        'type': 'alert',
        'alert': {
            'id': alert.id,
            'type': alert.alert_type,
            'title': alert.title,
            'message': alert.message,
            'timestamp': alert.timestamp,
            'player_id': alert.player_id,
            'data': alert.data
        }
    }
    
    print(f'Broadcasting alert to {len(connected_clients)} clients: {alert.title}')
    socketio.emit('alert', alert_data)

def simulate_live_alerts():
    """Simulate realistic AFL Fantasy alerts"""
    global alert_simulation_active
    
    # Sample AFL players and scenarios
    players = [
        {'id': 'player_1', 'name': 'Marcus Bontempelli', 'price': 745000},
        {'id': 'player_2', 'name': 'Christian Petracca', 'price': 680000},
        {'id': 'player_3', 'name': 'Sam Walsh', 'price': 590000},
        {'id': 'player_4', 'name': 'Max Gawn', 'price': 820000},
        {'id': 'player_5', 'name': 'Lachie Neale', 'price': 715000},
        {'id': 'player_6', 'name': 'Clayton Oliver', 'price': 695000}
    ]
    
    alert_templates = [
        {
            'type': 'price_change',
            'title_template': 'Price {direction}',
            'message_template': '{player} has {direction} by ${change}k',
            'probability': 0.3
        },
        {
            'type': 'injury',
            'title_template': 'Injury Update',
            'message_template': '{player} listed as {status} for Round {round}',
            'probability': 0.15
        },
        {
            'type': 'breaking_news',
            'title_template': 'Breaking News',
            'message_template': '{player} named as emergency for this weekend',
            'probability': 0.1
        },
        {
            'type': 'ai_recommendation',
            'title_template': 'AI Recommendation',
            'message_template': 'Based on recent form, consider trading in {player} (confidence: {confidence}%)',
            'probability': 0.25
        },
        {
            'type': 'trade_deadline',
            'title_template': 'Trade Deadline Warning',
            'message_template': 'Round {round} trades lock in {hours} hours',
            'probability': 0.1
        },
        {
            'type': 'form_alert',
            'title_template': 'Form Alert',
            'message_template': '{player} has scored {trend} in last 3 games',
            'probability': 0.1
        }
    ]
    
    while alert_simulation_active and len(connected_clients) > 0:
        try:
            # Random delay between alerts (30s to 5 minutes)
            delay = random.randint(30, 300)
            time.sleep(delay)
            
            if not alert_simulation_active or len(connected_clients) == 0:
                break
                
            # Pick random alert template
            template = random.choice(alert_templates)
            player = random.choice(players)
            
            # Generate alert based on type
            alert_id = f"alert_{int(time.time())}"
            timestamp = datetime.now().isoformat()
            
            if template['type'] == 'price_change':
                direction = random.choice(['increased', 'decreased'])
                change = random.choice([5, 8, 12, 15, 20, 25])
                
                alert = Alert(
                    id=alert_id,
                    alert_type=template['type'],
                    title=template['title_template'].format(direction=direction.title()),
                    message=template['message_template'].format(
                        player=player['name'],
                        direction=direction,
                        change=change
                    ),
                    timestamp=timestamp,
                    player_id=player['id'],
                    data={
                        'old_price': str(player['price']),
                        'new_price': str(player['price'] + (change * 1000 if direction == 'increased' else -change * 1000)),
                        'change': str(change * 1000 if direction == 'increased' else -change * 1000)
                    }
                )
                
            elif template['type'] == 'injury':
                status = random.choice(['Test', 'Doubtful', 'Out'])
                round_num = random.randint(14, 18)
                
                alert = Alert(
                    id=alert_id,
                    alert_type=template['type'],
                    title=template['title_template'],
                    message=template['message_template'].format(
                        player=player['name'],
                        status=status,
                        round=round_num
                    ),
                    timestamp=timestamp,
                    player_id=player['id'],
                    data={'status': status, 'round': str(round_num)}
                )
                
            elif template['type'] == 'ai_recommendation':
                confidence = random.randint(75, 95)
                
                alert = Alert(
                    id=alert_id,
                    alert_type=template['type'],
                    title=template['title_template'],
                    message=template['message_template'].format(
                        player=player['name'],
                        confidence=confidence
                    ),
                    timestamp=timestamp,
                    player_id=player['id'],
                    data={'confidence': str(confidence), 'reason': 'recent_form'}
                )
                
            elif template['type'] == 'trade_deadline':
                hours = random.choice([2, 6, 12, 24])
                round_num = random.randint(14, 18)
                
                alert = Alert(
                    id=alert_id,
                    alert_type=template['type'],
                    title=template['title_template'],
                    message=template['message_template'].format(
                        round=round_num,
                        hours=hours
                    ),
                    timestamp=timestamp,
                    data={'round': str(round_num), 'hours_remaining': str(hours)}
                )
                
            elif template['type'] == 'form_alert':
                trend = random.choice(['below 80', 'above 100', 'inconsistent scores'])
                
                alert = Alert(
                    id=alert_id,
                    alert_type=template['type'],
                    title=template['title_template'],
                    message=template['message_template'].format(
                        player=player['name'],
                        trend=trend
                    ),
                    timestamp=timestamp,
                    player_id=player['id'],
                    data={'trend': trend}
                )
                
            else:  # breaking_news
                alert = Alert(
                    id=alert_id,
                    alert_type=template['type'],
                    title=template['title_template'],
                    message=template['message_template'].format(player=player['name']),
                    timestamp=timestamp,
                    player_id=player['id']
                )
            
            # Broadcast the alert
            broadcast_alert(alert)
            
        except Exception as e:
            print(f'Error in alert simulation: {e}')
            time.sleep(30)  # Wait before retrying

# API endpoint to trigger manual alerts
@app.route('/api/alerts/trigger', methods=['POST'])
def trigger_alert():
    """Manually trigger an alert"""
    data = request.get_json()
    
    alert = Alert(
        id=data.get('id', f"manual_{int(time.time())}"),
        alert_type=data.get('type', 'system'),
        title=data.get('title', 'Manual Alert'),
        message=data.get('message', 'This is a manual alert'),
        timestamp=datetime.now().isoformat(),
        player_id=data.get('player_id'),
        data=data.get('data')
    )
    
    broadcast_alert(alert)
    
    return jsonify({
        'success': True,
        'alert_id': alert.id,
        'broadcasted_to': len(connected_clients)
    })

# Start alert simulation in background
def start_alert_simulation():
    global alert_simulation_active
    alert_simulation_active = True
    
    # Start simulation thread
    simulation_thread = threading.Thread(target=simulate_live_alerts, daemon=True)
    simulation_thread.start()
    print('Alert simulation started')

if __name__ == '__main__':
    print('Starting AFL Fantasy API with WebSocket support...')
    print('WebSocket endpoint: ws://localhost:4000')
    print('REST API endpoints:')
    print('  GET /api/afl-fantasy/dashboard-data')
    print('  POST /api/alerts/trigger')
    
    # Start alert simulation
    start_alert_simulation()
    
    # Run with SocketIO support
    socketio.run(app, host='0.0.0.0', port=4000, debug=True)
