# 📱 AFL Fantasy Intelligence Platform (iOS)

A next-gen coaching assistant that turns raw AFL Fantasy data into **actionable insights**. Built with SwiftUI and modern iOS architecture patterns.

## 🚀 Quick Start

```bash
# Build and run in simulator
./scripts/build.sh && open ios/AFLFantasy.xcodeproj

# Or use Warp workflows (if configured)
# ⌘K → "🚀 AFL Fantasy iOS Build"
```

## 📁 Project Structure

```
.
├── ios/          # Xcode project & SwiftUI source
├── scripts/      # Build & deployment scripts  
├── docs/         # Architecture & API specs
├── design/       # Figma exports & screenshots
└── README.md
```

## 🛠️ Tech Stack

- **Frontend**: SwiftUI + Combine
- **State Management**: SwiftData/CoreData (offline caching)
- **Backend API**: REST + WebSockets (live scores)
- **ML Models**: CoreML integration
- **Authentication**: Sign in with Apple + OAuth
- **Analytics**: Custom event tracking

## 🎯 Core Features (MVP)

### ✅ Live Dashboard
- Team projected score + real-time rank updates
- Team structure view with salary cap visualization
- Weekly projection summary

### ✅ AI-Powered Tools
- Captain Advisor (C/VC recommendations)
- Trade Suggester with projections
- Team Structure Analyzer

### ✅ Cash Generation Tools
- Cash Cow Tracker (rookie analysis)
- Price Change Predictor
- Breakeven Analyzer

### ✅ Smart Alerts
- Price/BE alerts
- News alerts (late outs, injuries)
- Central notification feed

## 🏗️ Architecture

Following MVVM + Repository pattern:

```
Features/
  ├── Dashboard/
  ├── Captain/
  ├── Trades/
  ├── CashCow/
  └── Settings/

Core/
  ├── Models/
  ├── Services/
  ├── Persistence/
  └── Networking/
```

## 🔧 Development

### Requirements
- Xcode 15+ with iOS 17 SDK
- macOS Ventura or later
- Developer account for device testing

### Build Scripts
- `scripts/build.sh` - Clean build + test
- `scripts/run-simulator.sh` - Launch in iPhone 15 simulator
- `scripts/run-tests.sh` - Unit + UI tests

## 📊 Performance Targets

- App launch: < 2 seconds cold start
- Live score updates: < 500ms latency
- Battery impact: Background refresh < 5%
- Memory footprint: < 100MB active usage

## 🔐 Security & Privacy

- All API keys stored in Keychain
- User data encrypted at rest
- Optional telemetry (can be disabled)
- Sign in with Apple for privacy

## 🚢 Deployment

Currently targeting:
- **MVP (v1.0)**: Core dashboard + captain advisor
- **v2.0**: Full trade optimizer + advanced analytics
- **v3.0**: Social features + weather models

---

Built with ⚡ **fast and beautiful** tech stack for optimal user experience.
