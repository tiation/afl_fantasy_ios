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

## 🎯 Current Implementation State

### ✅ Implemented Features

#### 📊 Dashboard View
- ✅ Live team score simulation (2-3 second updates)
- ✅ Team rank tracking with animations
- ✅ Salary cap progress visualization (85% usage display)
- ✅ Player cards with position colors, prices, scores, breakevens
- ✅ Responsive ScrollView with LazyVStack optimization

#### 🧠 Captain Advisor
- ✅ AI-powered captain recommendations with confidence ratings
- ✅ Top 3 captain suggestions with projected points
- ✅ Visual ranking system with gold/silver indicators
- ✅ Confidence percentage display for each recommendation

#### 🔄 Trade Calculator
- ✅ Trade in/out selection interface
- ✅ Visual trade flow with animated arrows
- ✅ Trade score circular progress (75% example)
- ✅ Color-coded trade recommendations (red out, green in)

#### 💰 Cash Cow Tracker
- ✅ Rookie player optimization display
- ✅ Smart sell signals ("🚀 SELL NOW", "⚠️ HOLD")
- ✅ Breakeven-based recommendations
- ✅ Cash generation tracking

#### ⚙️ Settings View
- ✅ Notification toggles (breakeven, injury, late out alerts)
- ✅ Cache size display and clear functionality
- ✅ App version and legal links (privacy, terms)
- ✅ Form-based settings UI

### 🏗️ Advanced Data Models

#### Enhanced Player Model
- ✅ Comprehensive player data (84 properties)
- ✅ Venue performance analysis
- ✅ Opponent performance tracking
- ✅ Injury risk assessment with historical data
- ✅ Contract status and seasonal trends
- ✅ Multi-round projections (next round + 3-round forecast)

#### Analytics Services
- ✅ `AIAnalysisService` for captain recommendations and trade analysis
- ✅ `AdvancedAnalyticsService` for cash generation, price prediction, consistency scores
- ✅ `AlertService` for smart notifications and alert management
- ✅ Price change prediction algorithms with confidence scoring
- ✅ Injury risk modeling and recommendations

### 🚧 Current Limitations

#### Data Integration
- ⏳ Mock data only - no live AFL API integration
- ⏳ No persistent storage (CoreData/SwiftData)
- ⏳ No user authentication

#### UI Implementation Gaps
- ⏳ Trade calculator player selection not functional
- ⏳ Captain advisor uses mock confidence scores
- ⏳ Settings actions not fully implemented
- ⏳ No search/filtering capabilities

#### Advanced Features Missing
- ⏳ Weather modeling and venue bias calculations
- ⏳ Social features and league comparisons
- ⏳ Push notifications infrastructure
- ⏳ Offline mode and data caching
- ⏳ Advanced analytics dashboards

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

## 📄 Legal Documents

The app includes comprehensive legal documentation:

- **Privacy Policy** (`docs/privacy.md`) - GDPR-compliant, no data collection policy
- **Terms of Use** (`docs/terms.md`) - Fantasy sports disclaimers & gambling help resources
- **Hosting Guide** (`docs/legal/hosting-guide.md`) - Instructions for deploying legal docs

### Key Legal Features:
- ✅ Clear "no gambling" disclaimers
- ✅ Prediction accuracy limitations explained
- ✅ Australian gambling help resources (BetStop, 1800 858 858)
- ✅ No personal data collection policy
- ✅ App Store compliance (§5.1, §5.3)
- ✅ Links accessible from Settings page

### Hosting Legal Documents:
```bash
# Quick setup with GitHub Pages
gh repo create --public
git push origin main
# Enable Pages in repo settings → Pages → /docs folder

# Or deploy to Netlify/Vercel - see docs/legal/hosting-guide.md
```

## 🚢 Deployment

Currently targeting:
- **MVP (v1.0)**: Core dashboard + captain advisor
- **v2.0**: Full trade optimizer + advanced analytics
- **v3.0**: Social features + weather models

---

Built with ⚡ **fast and beautiful** tech stack for optimal user experience.
