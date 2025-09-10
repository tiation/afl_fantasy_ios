# 🎨 AFL Fantasy Intelligence - User Personalization Features

## Overview

The AFL Fantasy Intelligence app now includes comprehensive user personalization features that allow users to customize their experience with profile information, team preferences, theme settings, and AI-powered recommendations tailored to their preferences.

## 🚀 New Features

### 1. Enhanced User Profile
- **Avatar Upload**: Users can upload and manage profile photos with automatic resizing and optimization
- **Personal Bio**: Custom bio text to personalize the profile
- **Favorite Team Selection**: Choose from all 18 AFL teams with team colors and branding
- **Profile Statistics**: Display member since date, best rank, and total points

### 2. Team Personalization
- **18 AFL Teams Supported**: Complete roster including team colors and logos
- **Team-Based Theming**: Optional team color integration throughout the app
- **Personalized Recommendations**: AI suggestions weighted by favorite team preference
- **Team Badge Display**: Elegant team badges with official colors

### 3. Advanced Theme System
- **Theme Options**: System, Light, Dark with optional team colors
- **Team Color Integration**: Use favorite team's colors as accent colors
- **Dynamic Color Preview**: Real-time preview of theme changes
- **Persistent Preferences**: Theme settings saved securely in Keychain

### 4. Comprehensive Notification Preferences
- **Granular Control**: 8 different notification categories
  - Price Change Alerts
  - Injury News Updates
  - Trade Deadline Reminders
  - Captain Selection Reminders
  - Team News (favorite team focused)
  - Milestone Achievements
  - Weekly Performance Reports
  - AI Recommendation Alerts

### 5. AI Personalization Settings
- **Risk Tolerance**: Conservative, Balanced, or Aggressive strategies
- **Trade Frequency**: Minimal (1-2), Moderate (2-4), or Active (3+) trades per round
- **Focus Areas**: Customizable AI focus on:
  - Captain Selection Optimization
  - Cash Generation Strategies
  - Points Maximization
  - Risk Management
  - Break-even Targets
- **Confidence Threshold**: Adjustable AI recommendation confidence level (0-100%)

### 6. Personalized Dashboard
- **Dynamic Greeting**: Time-based personalized greetings (Good morning/afternoon/evening)
- **User Avatar Display**: Profile photo or generated initials avatar
- **Favorite Team Integration**: Team badge and supporter status display
- **Personalized Statistics**: User-specific performance metrics

## 🏗️ Technical Implementation

### Data Models

#### Enhanced UserProfile
```swift
struct UserProfile: Codable {
    let id: String
    let username: String
    let teamName: String
    let email: String
    let joinDate: Date
    let preferences: UserPreferences
    let avatarURL: String?
    let bio: String?
    let favoriteTeam: AFLTeam?
    let notificationPrefs: DetailedNotificationPreferences?
    let themePreference: ThemePreference?
}
```

#### AFL Team Model
```swift
struct AFLTeam: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let shortName: String
    let primaryColor: String // Hex color
    let secondaryColor: String // Hex color
    let logoURL: String?
}
```

### Secure Storage

All personalization data is stored securely using:
- **iOS Keychain**: For sensitive user data and preferences
- **Local File System**: For avatar images (cached, optimized)
- **UserDefaults**: For non-sensitive UI preferences (theme, etc.)

### Services Architecture

#### UserService Protocol
- `getEnhancedProfile()` - Fetch complete user profile
- `uploadAvatar(data:)` - Secure avatar upload with compression
- `updateBio(_:)` - Update user biography
- `updateFavoriteTeam(_:)` - Set favorite AFL team
- `updateNotificationPreferences(_:)` - Configure notification settings
- `updateThemePreference(_:)` - Set theme preferences
- `updateAIPersonalizationSettings(_:)` - Configure AI behavior

#### AvatarLoader
- Automatic image compression (max 200KB)
- Placeholder generation with user initials
- Caching and optimization
- Background loading and updates

## 🎯 User Experience Features

### Profile Management
1. **Easy Access**: Profile button prominently displayed in Settings
2. **Intuitive Editing**: Inline editing with real-time previews
3. **Team Selection**: Visual team picker with official colors
4. **Avatar Management**: PhotosPicker integration with automatic optimization

### Onboarding Flow (Coming Soon)
Planned comprehensive onboarding experience:
1. Welcome screen
2. Favorite team selection
3. Theme preference setup
4. Notification preferences
5. Profile photo and bio setup
6. AI personalization configuration

### Dashboard Integration
- Personalized greeting with user's name
- Avatar display (photo or generated initials)
- Favorite team badge and colors
- Team-aware statistics and recommendations

## 🔒 Security & Privacy

### Data Protection
- All sensitive data encrypted in iOS Keychain
- Avatar images stored locally, not transmitted
- User preferences respect iOS privacy guidelines
- Optional analytics with user consent

### Privacy Features
- Granular notification control
- Local-first approach for sensitive data
- Secure avatar storage and handling
- Optional data export functionality

## 📱 Accessibility

### Built-in Support
- **Dynamic Type**: Full support for accessibility font sizes
- **VoiceOver**: Comprehensive screen reader support
- **High Contrast**: Accessible color combinations
- **Reduce Motion**: Respectful animation handling
- **Large Text**: Scalable UI components

### Implementation
- Semantic accessibility labels on all interactive elements
- Proper focus management and navigation order
- Alternative text for images and icons
- Keyboard navigation support

## 🧪 Testing Strategy

### Test Coverage
- **Unit Tests**: 90%+ coverage on core personalization components
- **UI Tests**: Complete user flows for profile management
- **Snapshot Tests**: Theme variations and team color integrations
- **Performance Tests**: Avatar loading and cache management

### Quality Gates
- Accessibility audit via Xcode Accessibility Inspector
- SwiftLint rules for accessibility compliance
- Performance monitoring for avatar operations
- Memory usage optimization validation

## 🚀 Future Enhancements

### Planned Features
1. **Advanced Onboarding**: Complete personalization setup flow
2. **Team Statistics**: Detailed favorite team performance metrics
3. **Social Features**: Share profiles and compare with friends
4. **Advanced Themes**: Seasonal and event-based theme options
5. **AI Learning**: Personalization based on user behavior patterns

### Technical Improvements
1. **Cloud Sync**: Optional profile synchronization across devices
2. **Offline Support**: Enhanced offline-first capabilities
3. **Performance**: Further optimization of avatar loading and caching
4. **Analytics**: Privacy-focused usage analytics for feature improvement

## 🔧 Developer Guide

### Adding New Personalization Features

1. **Extend Data Models**: Add fields to relevant models in `Models.swift`
2. **Update KeychainManager**: Add secure storage methods
3. **Modify Services**: Extend service protocols and implementations
4. **Update UI**: Add SwiftUI views and view models
5. **Add Tests**: Comprehensive test coverage

### Configuration

All personalization features are configured through:
- `KeychainManager` for secure storage
- `UserService` for API interactions
- `AvatarLoader` for image management
- `Theme` system for visual customization

## 📖 API Documentation

### KeychainManager Methods
```swift
// Avatar management
func storeAvatarURL(_ url: String)
func getAvatarURL() -> String?

// User preferences
func storeBio(_ bio: String)
func getBio() -> String?
func storeFavoriteTeamId(_ teamId: String)
func getFavoriteTeamId() -> String?

// Theme and notifications
func storeThemePreference(_ preference: ThemePreference)
func getThemePreference() -> ThemePreference
func storeDetailedNotificationPreferences(_ preferences: DetailedNotificationPreferences)
func getDetailedNotificationPreferences() -> DetailedNotificationPreferences
```

### AvatarLoader Methods
```swift
func saveAvatarLocally(data: Data) async throws -> String
func loadAvatar(from url: String) async throws -> UIImage
func getPlaceholderImage(for initials: String) -> UIImage
func clearAvatar()
```

## 🎉 Summary

The new personalization features transform the AFL Fantasy Intelligence app into a truly personalized experience. Users can now:

- Express their AFL team loyalty with team colors and branding
- Customize their profile with photos and personal information
- Fine-tune AI recommendations to match their strategy
- Control notifications with granular precision
- Enjoy a personalized dashboard experience

These features maintain the highest standards of privacy, security, and accessibility while providing a delightful and highly personalized user experience.

---

*For technical support or feature requests, please refer to the main README or contact the development team.*
