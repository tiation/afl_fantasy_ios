# 📁 AFL Fantasy iOS Project Structure

## Overview

The AFL Fantasy iOS app follows a modular architecture with clear separation of concerns. This document outlines the complete project structure after the Core integration improvements completed on September 6, 2025.

## 🏗️ Directory Structure

```
afl_fantasy_ios/
├── ios/
│   └── AFLFantasy/           # Main iOS app target
│       ├── AFLFantasyApp.swift                    # App entry point with Core services
│       ├── ContentView.swift                      # Main UI navigation
│       │
│       ├── Core/                                  # Original Core files (not in target)
│       │   ├── DesignSystem.swift                 # Full design system
│       │   ├── ReachabilityService.swift          # Network monitoring
│       │   ├── BackgroundSyncService.swift        # Background sync
│       │   ├── NetworkClient.swift               # API client
│       │   ├── CoreDataManager.swift             # Data persistence
│       │   └── ... (other core services)
│       │
│       ├── DesignSystemCore.swift                 # ✅ Integrated design system
│       ├── ReachabilityServiceCore.swift          # ✅ Integrated reachability
│       ├── BackgroundSyncServiceCore.swift        # ✅ Integrated background sync
│       ├── EnhancedViewsCore.swift                # ✅ Enhanced UI components
│       ├── ConnectionStatusBarCore.swift          # ✅ Status bar component
│       │
│       ├── Views/
│       │   ├── Enhanced/                          # Advanced view implementations
│       │   │   ├── EnhancedSettingsView.swift    # Full settings with AI controls
│       │   │   ├── AISettingsView.swift          # AI-specific settings
│       │   │   ├── DataManagementView.swift      # Data export/import
│       │   │   └── NotificationSettingsView.swift # Alert preferences
│       │   └── ... (other views)
│       │
│       ├── Models/                                # Data models and extensions
│       └── ... (other app files)
│
├── docs/                     # Documentation
├── scripts/                  # Build and utility scripts
└── README.md                 # Project overview
```

## 🔄 Core Integration Status

### ✅ **Successfully Integrated**
- **DesignSystemCore.swift**: Complete design system with spacing, typography, colors, shadows, and view extensions
- **ReachabilityServiceCore.swift**: Network monitoring with offline banner and connectivity status
- **BackgroundSyncServiceCore.swift**: Background sync with task scheduling and retry logic
- **EnhancedViewsCore.swift**: Enhanced settings view with AI controls and alert management
- **ConnectionStatusBarCore.swift**: Network status indicator component

### 🔄 **Integration Method**
Since the Core directory files weren't included in the Xcode project target, we created integrated versions:

1. **Core files copied into main target**: Each Core service was copied and integrated as `*Core.swift` files
2. **Full functionality preserved**: All original features and implementations maintained
3. **View modifiers working**: `.reachabilityStatus()` and `.backgroundSync()` now functional
4. **Enhanced UI active**: Using `SimpleEnhancedSettingsView` instead of basic settings

### 📝 **TODO: Future Improvements**
- **Proper Xcode integration**: Add original Core files to Xcode project target
- **Remove integrated copies**: Once Core files are in target, remove `*Core.swift` versions
- **Module structure**: Consider creating a separate Core framework/package

## 🎯 Key Components

### 1. App Entry Point (`AFLFantasyApp.swift`)
- Uses full Core service implementations via integrated files
- Background sync and reachability monitoring enabled
- Notification system with demo alerts

### 2. Design System (`DesignSystemCore.swift`)
- **Spacing**: 8-point grid system (4, 8, 12, 16, 20, 24, 32, 40)
- **Typography**: Complete type scale with view extensions
- **Colors**: AFL-themed palette with semantic colors
- **Motion**: Reduced-motion aware animations
- **Shadows & Radius**: Consistent elevation system

### 3. Network Services
- **ReachabilityServiceCore**: Real-time network monitoring with offline banner
- **BackgroundSyncServiceCore**: Automated data synchronization with background tasks
- **ConnectionStatusBarCore**: Visual network status indicator

### 4. Enhanced Views
- **SimpleEnhancedSettingsView**: Feature-rich settings with AI controls
- **AlertService**: Manages player alerts and notifications
- **SettingsRow**: Reusable settings row component

## 🛠️ Development Workflow

### Building the App
```bash
cd ios/
xcodebuild -scheme AFLFantasy -configuration Debug -sdk iphonesimulator build
```

### Running Tests
```bash
xcodebuild -scheme AFLFantasy -configuration Debug -sdk iphonesimulator test
```

### Code Quality
- SwiftFormat and SwiftLint configured (see `.swiftformat` and `.swiftlint.yml`)
- Performance monitoring with background sync statistics
- Accessibility support with VoiceOver labels and reduce motion

## 🔧 Build Status

✅ **Current Status**: Build successful with full Core integration  
⚠️ **Minor Warnings**: Unused variables in notification setup (non-blocking)  
🚀 **Performance**: All Core services functional with real-time monitoring

## 📋 Team Guidelines

### When adding new Core functionality:
1. Create the service in the appropriate `*Core.swift` file
2. Follow the existing patterns for view modifiers and service integration
3. Ensure proper error handling and logging
4. Test thoroughly on device and simulator

### When modifying existing views:
1. Use the integrated `DesignSystemCore` for consistent styling
2. Leverage `typography()`, `padding()`, and other view extensions
3. Follow the established spacing and color patterns
4. Test with dynamic type and accessibility features

## 🎯 Next Steps

1. **Core File Integration**: Add original Core directory files to Xcode target
2. **Cleanup**: Remove integrated `*Core.swift` files once originals are in target  
3. **Testing**: Add comprehensive unit tests for Core services
4. **Documentation**: Add inline documentation for all public APIs

---

**Last Updated**: September 6, 2025  
**Integration Status**: ✅ Complete and functional  
**Build Status**: ✅ Passing with minor warnings
