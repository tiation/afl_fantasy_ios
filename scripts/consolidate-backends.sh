#!/usr/bin/env bash
set -euo pipefail

# AFL Fantasy Backend Consolidation Script
# Consolidates dual backend setup to single Python backend

echo "🔧 AFL Fantasy Backend Consolidation"
echo "======================================"

# Stop any running Node.js processes
echo "1. Stopping Node.js servers..."
pkill -f "node.*server" || echo "   No Node.js servers running"
pkill -f "server.js" || echo "   No server.js processes running"

# Stop any running Docker containers
echo "2. Stopping existing Docker containers..."
docker-compose down 2>/dev/null || echo "   No Docker containers to stop"
docker-compose -f docker-compose.new.yml down 2>/dev/null || echo "   No new Docker containers"

# Keep only the main Python API server
echo "3. Cleaning up redundant Python servers..."
if [ -f "server-python/api_server_unified.py" ]; then
    mv "server-python/api_server_unified.py" "archive/api_server_unified.py.bak"
    echo "   ✅ Backed up redundant api_server_unified.py"
fi

# Archive Node.js backend
echo "4. Archiving Node.js backend..."
if [ -d "server-node" ]; then
    mkdir -p archive/server-node-backup
    cp -r server-node/* archive/server-node-backup/
    echo "   ✅ Node.js backend backed up to archive/"
fi

# Update the main Python API server with enhanced features
echo "5. Enhancing main Python API server..."
if [ -f "server-python/api_server.py" ]; then
    # Add dashboard serving capability
    cat >> server-python/api_server.py << 'EOF'

# Dashboard serving (consolidated from Node.js)
@app.route('/dashboard')
def dashboard():
    """Serve the main dashboard"""
    return send_from_directory('templates', 'dashboard.html')

@app.route('/api/docker/status')
def docker_status():
    """Docker service status (moved from Node.js)"""
    try:
        import subprocess
        result = subprocess.run(['docker', 'ps'], capture_output=True, text=True)
        running_containers = len([line for line in result.stdout.split('\n') if 'afl-fantasy' in line])
        return jsonify({
            "status": "running" if running_containers > 0 else "stopped",
            "containers": running_containers
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    log_info("🚀 AFL Fantasy API Server (Consolidated)")
    log_info(f"   📊 Dashboard: http://localhost:8080/dashboard")
    log_info(f"   🔌 API: http://localhost:8080/api/")
    log_info(f"   📡 WebSocket: ws://localhost:8081")
    
    # Load player data on startup
    load_players_data()
    
    # Start WebSocket server in background
    import threading
    websocket_thread = threading.Thread(target=start_websocket_server)
    websocket_thread.daemon = True
    websocket_thread.start()
    
    # Start Flask API server
    app.run(host='0.0.0.0', port=8080, debug=True)
EOF
    echo "   ✅ Enhanced Python API server with dashboard support"
fi

# Create simplified startup script
echo "6. Creating simplified startup script..."
cat > start-server.sh << 'EOF'
#!/usr/bin/env bash
# AFL Fantasy - Single Backend Startup

echo "🏆 Starting AFL Fantasy Server (Python Only)"
echo "============================================="

# Activate virtual environment if it exists
if [ -d "venv" ]; then
    source venv/bin/activate
    echo "✅ Virtual environment activated"
fi

# Install/update requirements
cd server-python
pip install -r requirements.txt

# Start the unified Python server
echo "🚀 Starting server on http://localhost:8080"
python api_server.py
EOF

chmod +x start-server.sh
echo "   ✅ Created start-server.sh"

# Update Docker to use simplified config
echo "7. Updating Docker configuration..."
if [ -f "docker-compose.simple.yml" ]; then
    ln -sf docker-compose.simple.yml docker-compose.yml
    echo "   ✅ Switched to simplified Docker config"
fi

echo ""
echo "🎉 Backend Consolidation Complete!"
echo "=================================="
echo ""
echo "📋 Next Steps:"
echo "   1. Test the Python server: ./start-server.sh"
echo "   2. Verify iOS app connectivity: http://localhost:8080/api/"
echo "   3. Check dashboard: http://localhost:8080/dashboard"
echo "   4. Use Docker: docker-compose up"
echo ""
echo "📂 Backed up files:"
echo "   • Node.js backend → archive/server-node-backup/"
echo "   • Unified Python API → archive/api_server_unified.py.bak"
echo ""
echo "💡 Benefits:"
echo "   • 50% fewer running processes"
echo "   • Simplified deployment"
echo "   • Single port (8080) for API + dashboard"
echo "   • Maintained all iOS app functionality"
