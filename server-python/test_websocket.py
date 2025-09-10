#!/usr/bin/env python3
"""
Test script for WebSocket functionality
"""

import socketio
import time
import json
from datetime import datetime

# Create a Socket.IO client
sio = socketio.Client()

# Event handlers
@sio.event
def connect():
    print(f"✅ Connected to WebSocket server at {datetime.now().strftime('%H:%M:%S')}")

@sio.event
def disconnect():
    print(f"❌ Disconnected from WebSocket server at {datetime.now().strftime('%H:%M:%S')}")

@sio.event
def connection_status(data):
    print(f"📡 Connection Status: {json.dumps(data, indent=2)}")

@sio.event
def subscription_confirmed(data):
    print(f"✅ Subscription Confirmed: {json.dumps(data, indent=2)}")

@sio.event
def live_update(data):
    print(f"\n🔄 Live Update Received at {datetime.now().strftime('%H:%M:%S')}:")
    print(json.dumps(data, indent=2))
    
    if data.get('type') == 'live_stats':
        stats = data.get('liveStats', {})
        print(f"  📊 Score: {stats.get('currentScore')} | Rank: {stats.get('rank')}")
        print(f"  👥 Playing: {stats.get('playersPlaying')}/{22} | Remaining: {stats.get('playersRemaining')}")
        print(f"  📈 Average: {stats.get('averageScore', 0):.1f}")
    
    elif data.get('type') == 'alert':
        alert = data.get('alert', {})
        print(f"  ⚠️ {alert.get('type')}: {alert.get('title')}")
        print(f"  📝 {alert.get('message')}")
        if alert.get('playerId'):
            print(f"  👤 Player ID: {alert.get('playerId')}")

def main():
    print("=" * 60)
    print("🧪 AFL Fantasy WebSocket Test Client")
    print("=" * 60)
    
    server_url = 'http://localhost:8081'  # WebSocket server port
    print(f"🔌 Attempting to connect to {server_url}")
    
    try:
        # Connect to the server
        sio.connect(server_url)
        
        # Subscribe to live updates
        print("📡 Subscribing to live updates...")
        sio.emit('subscribe_live_updates')
        
        # Keep the connection alive for 2 minutes to see updates
        print("\n⏱️ Listening for live updates for 2 minutes...")
        print("   (Live updates occur every 30 seconds when simulation is enabled)")
        print("-" * 60)
        
        time.sleep(120)  # Listen for 2 minutes
        
        # Disconnect
        print("\n🔌 Disconnecting...")
        sio.disconnect()
        
    except Exception as e:
        print(f"❌ Error: {e}")
        print("Make sure the WebSocket server is running on port 8081")
        print("Run: python api_server_ws.py")
    
    print("\n✅ Test completed")

if __name__ == '__main__':
    main()
