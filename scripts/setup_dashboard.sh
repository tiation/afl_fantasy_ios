#!/usr/bin/env bash
set -euo pipefail

# Directory setup
DASHBOARD_DIR="../afl_fantasy_dashboard"
IOS_APP_DIR="."

# Create dashboard project structure
echo "🏗 Creating AFL Fantasy Dashboard..."
mkdir -p "$DASHBOARD_DIR"/{src/{components,api},server,public}

# Install dependencies (both web and API)
echo "📦 Installing dashboard dependencies..."
cd "$DASHBOARD_DIR"
npm install

# Build and start services
echo "🚀 Starting development servers..."

# Start API server
echo "Starting API server on port 5001..."
npm run dev:api &

# Start web dashboard
echo "Starting web dashboard on port 5000..."
npm run dev &

# Update iOS app configuration
echo "🔄 Updating iOS app configuration..."
cd "$IOS_APP_DIR"

# Create Config directory if it doesn't exist
mkdir -p ios/AFLFantasy/Core/Config

# Create configuration file
cat > ios/AFLFantasy/Core/Config/DashboardConfig.swift << EOL
//
//  DashboardConfig.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by script on $(date +%Y-%m-%d)
//

import Foundation

enum DashboardConfig {
    static let baseURL = "http://localhost:5001/api/v2"
    static let webDashboardURL = "http://localhost:5000"
    
    static var headers: [String: String] {
        ["Content-Type": "application/json"]
    }
}
