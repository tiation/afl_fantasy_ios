#!/usr/bin/env python3
"""
AFL Fantasy Platform - Health Monitor API
Simple health monitoring service for system and service status
"""

import json
import time
import psutil
import requests
import subprocess
from flask import Flask, jsonify, request
from threading import Thread
import sys
import os

app = Flask(__name__)

class HealthMonitor:
    def __init__(self):
        self.last_check = time.time()
        self.services_status = {}
        self.system_metrics = {}
        
    def check_service_health(self, service, url, timeout=5):
        """Check if a service is responding"""
        try:
            response = requests.get(url, timeout=timeout)
            return {
                'status': 'healthy' if response.status_code == 200 else 'unhealthy',
                'response_time': response.elapsed.total_seconds(),
                'status_code': response.status_code,
                'last_check': time.time()
            }
        except Exception as e:
            return {
                'status': 'unhealthy',
                'error': str(e),
                'last_check': time.time()
            }
    
    def get_system_metrics(self):
        """Get system resource metrics"""
        try:
            cpu_percent = psutil.cpu_percent(interval=1)
            memory = psutil.virtual_memory()
            disk = psutil.disk_usage('/')
            
            return {
                'cpu': {
                    'percent': cpu_percent,
                    'count': psutil.cpu_count()
                },
                'memory': {
                    'total': memory.total,
                    'available': memory.available,
                    'percent': memory.percent,
                    'used': memory.used
                },
                'disk': {
                    'total': disk.total,
                    'used': disk.used,
                    'free': disk.free,
                    'percent': (disk.used / disk.total) * 100
                }
            }
        except Exception as e:
            return {'error': str(e)}
    
    def check_docker_services(self):
        """Check Docker container status"""
        try:
            result = subprocess.run(['docker', 'ps', '--format', 'json'], 
                                  capture_output=True, text=True, timeout=10)
            if result.returncode == 0:
                containers = []
                for line in result.stdout.strip().split('\n'):
                    if line:
                        containers.append(json.loads(line))
                return {
                    'status': 'healthy',
                    'containers': containers,
                    'count': len(containers)
                }
            else:
                return {'status': 'unhealthy', 'error': 'Docker not accessible'}
        except Exception as e:
            return {'status': 'unhealthy', 'error': str(e)}
    
    def update_status(self):
        """Update all service statuses"""
        # Check main Express server
        self.services_status['express'] = self.check_service_health(
            'express', 'http://localhost:5002/api/health'
        )
        
        # Check Docker services
        self.services_status['docker'] = self.check_docker_services()
        
        # Get system metrics
        self.system_metrics = self.get_system_metrics()
        
        self.last_check = time.time()

monitor = HealthMonitor()

@app.route('/health')
def health_check():
    """Main health check endpoint"""
    monitor.update_status()
    
    return jsonify({
        'status': 'healthy',
        'timestamp': time.time(),
        'uptime': time.time() - app.start_time,
        'last_check': monitor.last_check,
        'services': monitor.services_status,
        'system': monitor.system_metrics
    })

@app.route('/services')
def services_status():
    """Detailed services status"""
    monitor.update_status()
    return jsonify(monitor.services_status)

@app.route('/system')
def system_metrics():
    """System resource metrics"""
    monitor.update_status()
    return jsonify(monitor.system_metrics)

@app.route('/ping')
def ping():
    """Simple ping endpoint"""
    return jsonify({'status': 'pong', 'timestamp': time.time()})

if __name__ == '__main__':
    app.start_time = time.time()
    
    # Initial status update
    monitor.update_status()
    
    # Run Flask app
    port = int(os.environ.get('HEALTH_PORT', 5005))
    print(f"🔍 Health Monitor API starting on port {port}")
    
    try:
        app.run(host='0.0.0.0', port=port, debug=False)
    except KeyboardInterrupt:
        print("\n🛑 Health Monitor API stopped")
    except Exception as e:
        print(f"❌ Health Monitor API error: {e}")
        sys.exit(1)
