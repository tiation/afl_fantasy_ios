# AFL Fantasy iOS - Project Structure

## 🏗️ Project Organization (Updated September 2025)

This project has been reorganized for better maintainability and clearer separation of concerns. The primary focus is on the **AFL Fantasy Intelligence** iOS app with supporting backend services.

## 📂 Directory Structure

```
afl_fantasy_ios/
├── ios/                          # 🍏 iOS Applications
│   ├── AFLFantasyIntelligence/   # Primary iOS app (SwiftUI)
│   │   ├── AFL Fantasy Intelligence.xcodeproj
│   │   ├── Sources/
│   │   ├── Resources/
│   │   └── Scripts/
│   ├── Sources/                  # Alternative iOS app structure
│   └── DerivedData/             # Xcode build artifacts
│
├── server-python/               # 🐍 Python Backend Services
│   ├── api_server.py           # Main Flask API server with WebSocket
│   ├── api_server_unified.py   # Alternative unified server
│   ├── api_server_ws.py        # WebSocket-focused server
│   ├── requirements.txt        # Python dependencies
│   ├── scrapers/               # Data scraping modules
│   ├── api/                    # API route modules
│   └── utils/                  # Python utilities
│
├── server-node/                # 🟢 Node.js/TypeScript Services
│   ├── server/                 # Main Node backend
│   └── backend/                # Additional backend services
│
├── web-client/                 # 🌐 Web Frontend
│   ├── client/                 # Main React/Vue web client
│   ├── admin-dashboard/        # Admin dashboard
│   ├── dashboards/            # Additional dashboards
│   └── public/                # Static web assets
│
├── data/                       # 📊 Data & Assets
│   ├── dfs_player_summary/    # Player Excel data files
│   ├── database/              # Database schemas & scripts
│   ├── assets/                # Static assets
│   ├── player_data.json       # Player data exports
│   ├── user_team.json        # User team configurations
│   └── dvp_matrix.json       # DvP (Defense vs Position) matrix
│
├── infra/                      # 🏭 Infrastructure & DevOps
│   ├── docker-compose*.yml    # Docker orchestration
│   ├── Dockerfile*            # Container definitions
│   ├── k8s/                   # Kubernetes manifests
│   ├── helm/                  # Helm charts
│   ├── terraform/             # Infrastructure as Code
│   ├── monitoring/            # Monitoring configs
│   └── nginx.conf             # Reverse proxy config
│
├── scripts/                    # 🛠️ Development Scripts
│   ├── advanced_startup.sh    # Advanced setup
│   ├── build.sh              # Build scripts
│   ├── deploy.sh             # Deployment
│   ├── quality.sh            # Code quality checks
│   ├── setup/                # Setup utilities
│   └── utilities/            # Data processing scripts
│
├── docs/                       # 📚 Documentation
│   ├── README.md              # Main documentation
│   ├── API_DOCUMENTATION.md   # API docs
│   ├── ios/                   # iOS-specific docs
│   ├── screenshots/           # App screenshots
│   └── archive/               # Archived docs
│
├── tests/                      # 🧪 Test Suites
│   ├── AFLFantasyAppTests/    # iOS app tests
│   ├── integration/           # Integration tests
│   └── fixtures/              # Test data
│
├── archive/                    # 📦 Archived/Legacy Code
│   ├── archived_apps/         # Legacy app versions
│   ├── backups/               # Project backups
│   ├── .cleanup_backup/       # Cleanup backups
│   └── .transformation_backup/ # Migration backups
│
├── .github/                    # ⚙️ GitHub Configuration
│   └── workflows/             # CI/CD workflows
│
├── Package.swift              # 🍏 Swift Package Manager (root level)
├── .swiftformat              # Swift formatting config
├── .swiftlint.yml            # Swift linting config
├── .editorconfig             # Editor configuration
├── package.json              # Node.js dependencies
├── pnpm-lock.yaml           # Node.js lockfile
├── tsconfig.json            # TypeScript configuration
├── vite.config.ts           # Vite configuration
├── tailwind.config.ts       # Tailwind CSS config
└── README.md                # Project overview
```

## 🚀 Quick Start Commands

### Updated Commands for Reorganized Structure

#### Start Python API Server
```bash
# Old way:
cd /Users/tiaastor/workspace/10_projects/afl_fantasy_ios
python api_server.py

# New way:
./start-api-server.sh
# or manually:
cd server-python && python api_server.py
```

#### Start WebSocket Server (Separate)
```bash
# Start dedicated WebSocket server:
./start-websocket-server.sh
# or manually:
cd server-python && python api_server_ws.py
```

#### Build iOS App
```bash
# Old way:
xcodebuild -project "AFL Fantasy Intelligence.xcodeproj" -scheme "AFL Fantasy Intelligence" -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build

# New way:
./build-ios-app.sh
# or manually:
cd ios/AFLFantasyIntelligence && xcodebuild -project "AFL Fantasy Intelligence.xcodeproj" -scheme "AFL Fantasy Intelligence" -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
```

## 🎯 Primary Applications

### 1. AFL Fantasy Intelligence (iOS)
- **Location**: `ios/AFLFantasyIntelligence/`
- **Technology**: SwiftUI, iOS 16+
- **Purpose**: Primary mobile app for AFL Fantasy analysis
- **Features**: Live scores, player analysis, team management

### 2. Python API Server
- **Location**: `server-python/api_server.py`
- **Technology**: Flask, WebSocket, Pandas
- **Purpose**: Backend API serving player data and live updates
- **Features**: RESTful API, WebSocket live updates, data caching

### 3. Web Dashboard
- **Location**: `web-client/client/`
- **Technology**: React/Vue, TypeScript
- **Purpose**: Web-based dashboard for analysis
- **Features**: Player stats, team builder, analytics

## 🔧 Development Workflow

### Prerequisites
- Xcode 15+ (for iOS development)
- Python 3.9+ (for backend)
- Node.js 18+ (for web client)
- Docker (for containerized deployment)

### Environment Setup
```bash
# Clone and setup
git clone <repository>
cd afl_fantasy_ios

# iOS Development
cd ios/AFLFantasyIntelligence
open "AFL Fantasy Intelligence.xcodeproj"

# Python Backend
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
cd server-python
pip install -r requirements.txt

# Web Client
cd web-client/client
npm install  # or pnpm install
```

## 📊 Data Flow

1. **Data Sources**: Web scrapers collect AFL player data
2. **Storage**: Data stored in Excel files (`data/dfs_player_summary/`)
3. **Processing**: Python backend processes and serves data via API
4. **Clients**: iOS app and web dashboard consume API data
5. **Real-time**: WebSocket updates provide live score tracking

## 🚢 Deployment

### Development
```bash
./start-api-server.sh  # Start Python backend
cd web-client/client && npm run dev  # Start web client
# Open iOS app in Xcode
```

### Production (Docker)
```bash
# Using new reorganized structure:
docker-compose -f docker-compose.new.yml up -d

# Or using existing infra structure:
cd infra
docker-compose up -d  # Start all services

# Start specific services:
docker-compose -f docker-compose.new.yml --profile api up -d    # Python API only
docker-compose -f docker-compose.new.yml --profile web up -d    # Web client only
docker-compose -f docker-compose.new.yml --profile all up -d    # Everything
```

## 📝 Key Configuration Files

- **iOS**: `ios/AFLFantasyIntelligence/AFL Fantasy Intelligence.xcodeproj`
- **Python Backend**: `server-python/requirements.txt`
- **Web Client**: `web-client/client/package.json`
- **Infrastructure**: `infra/docker-compose.yml`
- **CI/CD**: `.github/workflows/`

## 🔍 Migration Notes

This reorganization maintains all functionality while improving:
- **Clarity**: Clear separation between iOS, backend, web, and infrastructure
- **Maintainability**: Related files grouped together
- **Scalability**: Room for additional services and clients
- **Development Experience**: Clearer entry points and scripts

### Breaking Changes
- **API Server**: Now located at `server-python/api_server.py`
- **iOS App**: Now located at `ios/AFLFantasyIntelligence/`
- **Data Files**: Now located at `data/`
- **Docker Configs**: Now located at `infra/`

### Helper Scripts
- `start-api-server.sh`: Starts Python backend from any directory
- `start-websocket-server.sh`: Starts WebSocket server (port 8081)
- `build-ios-app.sh`: Builds iOS app from any directory
- `docker-compose.new.yml`: Updated Docker setup for reorganized structure
- Scripts automatically handle path changes and virtual environments

## 🤝 Contributing

When adding new features:
1. **iOS features**: Add to `ios/AFLFantasyIntelligence/`
2. **API endpoints**: Add to `server-python/api/`
3. **Web features**: Add to `web-client/client/`
4. **Data processing**: Add to `server-python/scrapers/` or `scripts/utilities/`
5. **Infrastructure**: Add to `infra/`
6. **Documentation**: Update relevant docs in `docs/`

## 📞 Support

For questions about the new structure:
1. Check helper scripts: `start-api-server.sh`, `build-ios-app.sh`
2. Review documentation in `docs/`
3. Check archived structure in `archive/` for reference

---

**Last Updated**: September 10, 2025  
**Reorganization Status**: ✅ Complete  
**Primary App**: AFL Fantasy Intelligence iOS
