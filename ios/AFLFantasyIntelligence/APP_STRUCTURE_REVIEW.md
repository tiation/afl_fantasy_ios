# AFL Fantasy Intelligence - App Structure Review

## Current Directory Structure

```
AFLFantasyIntelligence/
├── AFL Fantasy Intelligence.xcodeproj   # Xcode project file
├── Sources/                              # Main source code directory
│   ├── AFLFantasyIntelligenceApp.swift  # App entry point
│   ├── Core/                             # Core services and infrastructure
│   │   ├── AI/                          # AI integration services
│   │   │   └── OpenAIService.swift
│   │   ├── Alerts/                      # Alert management system
│   │   │   ├── AlertManager.swift
│   │   │   └── AlertsViewModel.swift   # Should be moved to Features/Alerts
│   │   ├── Auth/                        # Authentication services
│   │   │   └── AuthenticationService.swift
│   │   ├── Authentication/              # DUPLICATE - should be removed
│   │   │   └── AuthenticationService.swift
│   │   ├── Camera/                      # Camera utilities
│   │   │   └── BarcodeScanner.swift
│   │   ├── Components/                  # Reusable UI components
│   │   │   └── Charts.swift
│   │   ├── DesignSystem/                # Design system implementation
│   │   │   ├── APIStatusChip.swift
│   │   │   ├── DesignSystem.swift
│   │   │   ├── DSAnimations.swift
│   │   │   └── DSComponents.swift
│   │   ├── Network/                     # Network layer
│   │   │   └── WebSocketManager.swift
│   │   ├── Networking/                  # DUPLICATE - should be merged with Network
│   │   │   └── APIService.swift
│   │   ├── Preferences/                 # User preferences
│   │   │   └── UserPreferencesService.swift
│   │   ├── Security/                    # Security services
│   │   │   └── KeychainService.swift
│   │   └── Team/                        # Team management
│   │       └── TeamManager.swift
│   ├── Features/                        # Feature modules
│   │   ├── AI/                          # AI features
│   │   │   ├── AIRecommendationDetailView.swift
│   │   │   ├── AISettingsView.swift
│   │   │   ├── AIToolsView.swift
│   │   │   └── TradeAnalyzerView.swift
│   │   ├── Alerts/                      # Alert features
│   │   │   ├── AlertDetailView.swift
│   │   │   ├── AlertSettingsView.swift
│   │   │   ├── AlertsView.swift
│   │   │   └── AlertsViewModel.swift
│   │   ├── Authentication/              # Auth UI
│   │   │   └── LoginView.swift
│   │   ├── CashCows/                    # Cash cows feature
│   │   │   └── CashCowsView.swift
│   │   ├── Dashboard/                   # Main dashboard
│   │   │   └── DashboardView.swift
│   │   ├── Players/                     # Player management
│   │   │   ├── AdvancedFiltersView.swift
│   │   │   ├── PlayerDetailComponents.swift
│   │   │   ├── PlayerDetailViewModel.swift
│   │   │   └── PlayersView.swift
│   │   ├── Profile/                     # User profile
│   │   │   └── ProfileView.swift
│   │   └── Teams/                       # Team features
│   │       ├── BarcodeScannerView.swift
│   │       ├── TeamsSupportingViews.swift
│   │       └── TeamsView.swift
│   ├── Models/                          # Data models
│   │   └── Analytics/
│   │       └── AnalyticsModels.swift
│   ├── Services/                        # Additional services
│   │   ├── AnalyticsService.swift
│   │   └── WebSocketManager.swift      # DUPLICATE - already in Core/Network
│   └── Shared/                          # Shared utilities
│       ├── Models/                      # Shared models
│       │   ├── Player.swift
│       │   └── Team.swift
│       ├── Services/                    # Shared services (empty after cleanup)
│       └── Utilities/                   # Utility functions
├── Tests/                               # Test files
│   ├── UI/                              # UI tests
│   └── Unit/                            # Unit tests
│       └── Mocks/                       # Mock objects
├── Resources/                           # App resources (images, etc.)
└── Scripts/                             # Build scripts

```

## Issues Found

### 1. Duplicate Directories
- **Auth vs Authentication**: Both exist in Core/, should use only one (recommend: Auth)
- **Network vs Networking**: Both exist in Core/, should merge into Network/

### 2. Misplaced Files
- **AlertsViewModel.swift**: Currently in Core/Alerts, should be in Features/Alerts
- **WebSocketManager.swift**: Exists in multiple locations (Core/Network, Services)

### 3. Duplicate Files (Already Cleaned)
- ✅ Removed duplicate AlertManager.swift from Shared/Services
- ✅ Removed duplicate AuthenticationService.swift from Core/Authentication
- ✅ Removed duplicate TeamManager.swift from Core/Teams
- ✅ Removed duplicate UserPreferencesService.swift from Shared/Services
- ✅ Removed duplicate WebSocketManager.swift from Shared/Services and Services

## Recommended Actions

### Immediate Fixes
1. **Consolidate Auth directories**
   - Keep Core/Auth/
   - Remove Core/Authentication/ (already empty)

2. **Consolidate Network directories**
   - Move APIService.swift from Core/Networking/ to Core/Network/
   - Remove Core/Networking/ directory

3. **Move ViewModels to Features**
   - Move Core/Alerts/AlertsViewModel.swift to Features/Alerts/

4. **Remove remaining duplicates**
   - Remove Services/WebSocketManager.swift (keep Core/Network version)

### Architecture Improvements
1. **Clear separation of concerns**
   - Core/: Infrastructure, services, design system
   - Features/: Feature-specific views and view models
   - Models/: Data structures
   - Shared/: Cross-cutting utilities

2. **Consistent naming**
   - Use singular names for service directories (Network, not Networking)
   - Use consistent suffixes (Service, Manager, ViewModel)

## Build Configuration

### Package.swift Status
- ✅ Updated to use correct paths
- ✅ Added macOS platform support
- ✅ Configured for library target

### Xcode Project
- Located at: `ios/AFLFantasyIntelligence/AFL Fantasy Intelligence.xcodeproj`
- Needs to be synchronized with file structure changes

## Next Steps

1. Complete the directory consolidation
2. Update all import statements
3. Rebuild Xcode project file references
4. Run tests to ensure everything works
5. Document the final architecture
