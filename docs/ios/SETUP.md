# 📱 iOS App Setup Guide

This guide covers everything you need to know to set up and run the AFL Fantasy iOS app.

## 📋 Prerequisites

### Required Tools
- **Xcode 15.0+** (latest version recommended)
- **macOS 13.0+** (required for Xcode 15)
- **iOS 16.0+** SDK (included with Xcode)
- **Git** (for cloning the repository)

### Optional but Recommended
- **SF Symbols 5** (for icon consistency)
- **iOS Simulator runtimes** (for testing different iOS versions)
- **Physical iOS device** (for real device testing)

## 🔧 Xcode Project Setup

### 1. Clone and Open Project
```bash
# Clone the repository (if you haven't already)
git clone <repository-url>
cd afl_fantasy_ios

# Navigate to iOS directory
cd ios/

# Open the project in Xcode
open AFLFantasy.xcodeproj
```

### 2. Configure Project Settings

#### **Team and Signing:**
1. Select the **AFLFantasy** project in the navigator
2. Go to **Signing & Capabilities** tab
3. Set your **Team** (use your Apple Developer account)
4. **Bundle Identifier**: `com.yourteam.aflFantasy` (change as needed)
5. Ensure **Automatically manage signing** is checked

#### **Deployment Target:**
1. In **General** tab, set **iOS Deployment Target** to **16.0**
2. This ensures compatibility with modern iOS features

#### **Build Configuration:**
1. Go to **Build Settings**
2. Set **Swift Language Version** to **Swift 5**
3. Ensure **Enable Bitcode** is set to **No** (for development)

### 3. Verify Dependencies

The project uses only native iOS frameworks, so no external dependency management (like CocoaPods or SPM) is required:

- **SwiftUI** - UI framework
- **Foundation** - Core functionality
- **Combine** - Reactive programming
- **UserNotifications** - Push notifications (future feature)
- **Security** - Keychain access

## 🏃‍♂️ Running the App

### 1. Select Target and Device
1. In Xcode toolbar, select **AFLFantasy** as the target
2. Choose a simulator or device:
   - **Recommended**: iPhone 15 Simulator
   - **Alternative**: Any iOS 16+ device or simulator

### 2. Build and Run
```bash
# In Xcode: Press ⌘+R
# Or use menu: Product → Run
```

The app should build successfully and launch in the simulator/device.

### 3. First Launch
On first launch you'll see:
- **Dashboard** with sample data
- **Captain Advisor** placeholder
- **Trades** section
- **Cash Cows** tracking
- **Settings** for configuration

## 🔧 Development Configuration

### Code Formatting (SwiftFormat)
If you have SwiftFormat installed:
```bash
# Install SwiftFormat (if not already installed)
brew install swiftformat

# Navigate to iOS directory
cd ios/

# Format all Swift files
swiftformat .
```

### Linting (SwiftLint)
If you have SwiftLint installed:
```bash
# Install SwiftLint (if not already installed)
brew install swiftlint

# Navigate to iOS directory
cd ios/

# Run linting
swiftlint
```

### Build Phases
The project includes these automated build phases:
1. **Compile Sources** - Builds Swift files
2. **Link Binary** - Links frameworks
3. **Copy Bundle Resources** - Includes assets and data

## 🐛 Troubleshooting

### Common Build Issues

**Issue**: "Developer cannot be verified" error
**Solution**: 
1. Go to **System Preferences → Security & Privacy**
2. Click **Allow** when prompted about the developer
3. Or run: `sudo xcode-select --install`

**Issue**: Simulator not loading
**Solution**:
1. **Xcode → Preferences → Components**
2. Download the iOS simulator runtime you need
3. Restart Xcode

**Issue**: Signing errors
**Solution**:
1. Check your Apple Developer account status
2. Try **Product → Clean Build Folder** (⌘+⇧+K)
3. Delete derived data: **Xcode → Preferences → Locations → Derived Data → Delete**

**Issue**: "Swift Compiler Error"
**Solution**:
1. Ensure you're using Xcode 15+
2. Check Swift language version in Build Settings
3. Clean and rebuild the project

### Runtime Issues

**Issue**: App crashes on launch
**Solution**:
1. Check the debug console for error messages
2. Ensure iOS deployment target matches your test device
3. Try running on a different simulator version

**Issue**: API connection failures
**Solution**:
1. Make sure the backend server is running (if needed)
2. Check network permissions in simulator
3. Verify API endpoints are reachable

## 📱 Device Testing

### Running on Physical Device
1. Connect your iOS device via USB
2. Select your device in Xcode
3. Build and run (⌘+R)
4. Trust the developer certificate when prompted on device

### TestFlight Distribution (Future)
For beta testing:
1. Archive the app (Product → Archive)
2. Upload to App Store Connect
3. Create TestFlight build
4. Distribute to internal testers

## 🧪 Testing

### Unit Tests
```bash
# Run unit tests in Xcode
# Test Navigator → Select test → Run (or ⌘+U for all tests)
```

### UI Tests
```bash
# Run UI tests
# Test Navigator → Select UI test target → Run
```

### Manual Testing Checklist
- [ ] App launches without crashes
- [ ] All tab views are accessible
- [ ] Dashboard displays data correctly
- [ ] Settings can be accessed and modified
- [ ] App handles network errors gracefully
- [ ] Dark mode works correctly
- [ ] VoiceOver accessibility functions properly

## 🎯 Next Steps

Once you have the app running:

1. **Explore the codebase** - Check out the project structure
2. **Review the architecture** - Understand MVVM pattern implementation  
3. **Connect to backend** - Set up the full platform for AI features
4. **Make your first change** - Try modifying a UI component
5. **Run the tests** - Ensure everything works after changes

## 📚 Additional Resources

- **[iOS App Architecture](./ARCHITECTURE.md)** - Understand the code structure
- **[Feature Guide](./FEATURES.md)** - Learn about each app feature
- **[Contributing](../../CONTRIBUTING.md)** - How to contribute code
- **[Apple Developer Documentation](https://developer.apple.com/documentation/)**

---

**Need help?** Open an issue or check the main documentation index.
