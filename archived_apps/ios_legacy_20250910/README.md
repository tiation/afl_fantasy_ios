# AFL Fantasy iOS Integration

## Overview

This iOS app integrates with the AFL Fantasy backend services to provide advanced analytics and insights. The app includes secure credential management, real-time data synchronization, and a comprehensive dashboard view.

## Architecture

### Data Layer

1. **AFLFantasyAPIClient** (`Services/AFLFantasyAPIClient.swift`)
   - Handles all API communication with AFL Fantasy backend
   - Manages concurrent network requests
   - Implements retry logic and error handling
   - Uses URLSession with proper configuration

2. **KeychainManager** (`Services/KeychainManager.swift`)
   - Secure storage of AFL Fantasy credentials
   - Uses iOS Keychain for sensitive data
   - Supports credential lifecycle management
   - Debug support for testing

3. **AFLFantasyDataService** (`Services/AFLFantasyDataService.swift`)
   - Main orchestration service
   - Handles authentication flow
   - Manages data caching (5-minute expiry)
   - Automatic refresh timers
   - Combines API client and keychain manager

### UI Layer

4. **LoginView** (`Views/LoginView.swift`)
   - User authentication interface
   - Team ID and session cookie input
   - Help documentation for credential retrieval
   - Security information display

5. **DashboardView** (`Views/DashboardView.swift`)
   - Main data display interface
   - Key metrics (team value, score, rank, captain)
   - Status indicators and error handling
   - Pull-to-refresh functionality

6. **AFLFantasyApp** (`AFLFantasyApp.swift`)
   - Main app entry point
   - Environment object management
   - Tab navigation structure
   - Integrates both new and existing functionality

## Data Models

The app uses the following data models for AFL Fantasy integration:

```swift
struct DashboardData {
    let teamValue: TeamValueData
    let teamScore: TeamScoreData
    let rank: RankData
    let captain: CaptainData
}
```

### Key Features

- **Secure Authentication**: Credentials stored in iOS Keychain
- **Real-time Data**: Automatic refresh every 5 minutes
- **Error Handling**: Comprehensive error states with user feedback
- **Offline Support**: Graceful handling when backend is unavailable
- **Pull-to-Refresh**: Manual data refresh capability
- **Dark Mode**: AFL-themed interface with dark mode support

## Setup Instructions

1. **Backend Configuration**
   - Ensure the Python backend is running on expected endpoints
   - Configure environment variables in `.env` file
   - Start the Flask API server

2. **iOS App Setup**
   - Open project in Xcode
   - No additional dependencies required (uses native iOS frameworks)
   - Build and run on iOS Simulator or device

3. **Authentication**
   - Navigate to Settings → Sign In
   - Obtain Team ID from AFL Fantasy URL
   - Extract session cookie from browser developer tools
   - Enter credentials in the login form

## Integration Status

### ✅ Completed
- [x] API client with concurrent request handling
- [x] Secure keychain credential storage
- [x] Data service with caching and auto-refresh
- [x] Login/authentication flow
- [x] Dashboard with key metrics display
- [x] Error handling and status indicators
- [x] Settings and logout functionality

### 🚧 Next Steps
- [ ] Integration with Python backend tools (captain analysis, trade tools)
- [ ] Player detail views
- [ ] Advanced analytics screens
- [ ] Push notifications for price changes
- [ ] Offline data persistence
- [ ] Unit and integration testing

## Backend Integration

The iOS app communicates with these backend endpoints:

```
GET /api/afl-fantasy/dashboard-data
GET /api/afl-fantasy/team-value
GET /api/afl-fantasy/team-score  
GET /api/afl-fantasy/rank
GET /api/afl-fantasy/captain
POST /api/afl-fantasy/refresh
```

## Security Considerations

- Credentials never stored in UserDefaults or plain text
- All API communication over HTTPS
- Session tokens automatically cleared on logout
- No sensitive data in app logs (production builds)
- Keychain access restricted to app bundle

## Testing

For development and testing:

```swift
#if DEBUG
// Test credentials can be stored via KeychainManager
keychainManager.storeTestCredentials()
#endif
```

## Dependencies

The app uses only native iOS frameworks:
- SwiftUI for UI
- Foundation for networking and data handling
- Security framework for Keychain access
- UserNotifications for future notification features

No external dependencies are required, keeping the app lightweight and secure.
