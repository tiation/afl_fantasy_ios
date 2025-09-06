# 🏆 Enterprise iOS App Standards - AFL Fantasy

This document outlines the comprehensive coding standards and best practices for the AFL Fantasy Intelligence Platform iOS app.

## 📋 Table of Contents

1. [Repository Standards](#repository-standards)
2. [Code Style & Linting](#code-style--linting)
3. [Architecture & Module Boundaries](#architecture--module-boundaries)
4. [Build Settings](#build-settings)
5. [Testing Standards](#testing-standards)
6. [Performance Budgets](#performance-budgets)
7. [Accessibility & Localization](#accessibility--localization)
8. [Security & Privacy](#security--privacy)
9. [Telemetry & Logging](#telemetry--logging)
10. [CI/CD](#cicd)
11. [File Size Policy](#file-size-policy)
12. [Release Checklist](#release-checklist)

---

## 📚 Repository Standards

### Dependency Management
- **SPM only** - No CocoaPods/Carthage
- Third-party dependencies must be:
  - Permissive license (MIT, Apache 2.0, BSD)
  - <2 transitive dependencies
  - Maintained within last 12 months
  - Active GitHub repository with >100 stars

### Branching Strategy
```
main (release) ← develop (integration) ← feature branches (feat/*)
                                      ← hotfix branches (hotfix/*)
```

### Commit Standards
- **Conventional Commits** required
- PR limit: ≤ 400 changed lines (split if larger)
- **Required PR approvals**: 1 (working alone currently)

### Git Configuration
```bash
# .gitattributes for pbxproj conflicts
*.pbxproj merge=union
```

---

## 🎨 Code Style & Linting

### SwiftFormat Configuration
- **Indentation**: 4 spaces
- **Line width**: 120 characters
- **Import grouping**: testable-first
- **Self removal**: enabled
- **Trailing whitespace**: always trim

### SwiftLint Rules
- **File length**: 400 lines (warning), 500 lines (error)
- **Function length**: 40 lines (warning), 60 lines (error)
- **Cyclomatic complexity**: 10 (warning), 12 (error)
- **Force unwrapping**: error
- **Force cast/try**: error
- **TODO tracking**: warnings (track in GitHub issues)

### Custom Rules
```yaml
no_print_in_release:
  message: "Use proper logging instead of print() statements"
  
no_hardcoded_strings:
  message: "Use localized strings for user-facing text"
  
proper_mvvm_structure:
  message: "Views should follow MVVM pattern"
```

### Editor Configuration
```ini
[*.swift]
indent_style = space
indent_size = 4
max_line_length = 120
```

---

## 🏗️ Architecture & Module Boundaries

### Project Structure
```
AFL Fantasy/
├─ Features/
│  ├─ Dashboard/
│  ├─ Captain/
│  ├─ Trades/
│  ├─ CashCow/
│  └─ Settings/
├─ Core/
│  ├─ DesignSystem/
│  ├─ Analytics/
│  ├─ Networking/
│  ├─ Persistence/
│  └─ Services/
└─ Shared/
   ├─ Models/
   ├─ Utilities/
   └─ Extensions/
```

### Architectural Principles
- **No cyclic dependencies**
- Features depend only on Core + Shared
- Never feature-to-feature dependencies
- MVVM pattern: View → ViewModel → UseCases → Repository

### Dependency Injection
- Constructor injection preferred
- `@Environment` for SwiftUI
- Lightweight container for complex scenarios

### Concurrency
- `async/await` for all async operations
- `Task` cancellation on view disappear
- `@MainActor` for UI updates
- No `DispatchQueue` usage (legacy)

### Error Handling
- Typed `DomainError` enums
- Never swallow errors
- Map infrastructure errors to domain errors
- Proper error boundaries

---

## ⚙️ Build Settings

### Release Configuration
```
SWIFT_TREAT_WARNINGS_AS_ERRORS = YES
DEAD_CODE_STRIPPING = YES  
ENABLE_TESTABILITY = NO (Release only)
ONLY_ACTIVE_ARCH = NO
STRIP_INSTALLED_PRODUCT = YES
```

### Security Settings
- No global `NSAllowsArbitraryLoads`
- Specific ATS exceptions only
- Certificate pinning for critical endpoints
- Keychain access: `kSecAttrAccessibleAfterFirstUnlock`

### Concurrency Settings
- **Strict Concurrency**: Complete
- **Swift Concurrency**: Enabled

---

## 🧪 Testing Standards

### Coverage Requirements
- **Overall coverage**: ≥80%
- **Critical paths**: ≥90% (payment, data sync)
- **ViewModels**: ≥85%
- **Services**: ≥90%

### Test Pyramid
```
Unit Tests (80%) >> Integration Tests (15%) >> UI Tests (5%)
```

### Testing Principles
- **Deterministic**: No flaky tests
- **Fast**: Unit tests complete <60s
- **Isolated**: No shared state
- **Injectable dependencies**: Time, networking, randomness

### Naming Convention
```swift
func test_<UnitOfWork>_<Scenario>_<Expected>()
```

### Test Categories
```swift
// Unit Tests
func test_playerPriceCalculator_whenBreakevenNegative_returnsPositiveTrend()

// Integration Tests  
func test_apiService_whenFetchingPlayers_returnsCorrectData()

// UI Tests
func test_dashboardView_whenLaunched_displaysPlayerCards()
```

---

## ⚡ Performance Budgets

### App Performance (iPhone 12+ minimum)
- **Cold launch**: ≤1.8 seconds
- **Frame rate**: ≥58 FPS on scroll
- **Memory usage**: ≤220 MB steady state
- **Jank percentage**: <1%

### Network Performance
- **API response time**: <500ms (P95)
- **Payload compression**: gzip enabled
- **Max payload size**: 1MB (pagination required)
- **Image caching**: enabled with size limits

### Bundle Size
- **IPA size**: ≤60 MB (App Store)
- **Asset optimization**: enabled
- **On-demand resources**: for large assets

### Performance Monitoring
```swift
// Example performance tracking
@MainActor
class PerformanceMonitor {
    static func trackViewLoad(screen: String, duration: TimeInterval)
    static func trackAPICall(endpoint: String, duration: TimeInterval)
    static func trackMemoryUsage()
}
```

---

## ♿ Accessibility & Localization

### Accessibility Requirements
- **All interactive elements**: accessibility labels
- **Dynamic Type**: support up to XXL
- **Contrast ratio**: ≥4.5:1 for normal text
- **VoiceOver**: complete navigation support

### Localization
- **No hardcoded strings** in user-facing UI
- **Strings.swift** + `.stringsdict` for plurals
- **RTL language support** for Arabic markets
- **Date/number formatting**: locale-aware

### Implementation Example
```swift
// ✅ Correct
Text(L10n.Dashboard.teamScore)
    .accessibilityLabel(L10n.Accessibility.teamScoreLabel)

// ❌ Incorrect  
Text("Team Score")
```

---

## 🔒 Security & Privacy

### Secrets Management
- **No secrets in repository**
- **Keychain storage** for tokens
- **Environment variables** for CI/CD
- **Configuration files** excluded from VCS

### Privacy Requirements
- **Minimal PII collection**
- **Analytics opt-in required**
- **AppTrackingTransparency** compliance
- **Data retention policies** enforced

### Security Measures
```swift
// API Key management
struct SecureStorage {
    static func store(apiKey: String, for service: String)
    static func retrieve(for service: String) -> String?
    static func delete(for service: String)
}

// Logging with redaction
Logger.info("User authenticated", metadata: [
    "userID": .string(userID.redacted)
])
```

---

## 📊 Telemetry & Logging

### Logging Framework
- **Unified Logger** (os.log wrapper)
- **Log levels**: debug/info/warn/error
- **Structured logging** with metadata
- **No PII in logs**

### Analytics Events
- **Schema versioned** event definitions
- **Feature flags** for all events
- **User consent** required
- **Crash reporting** with symbolication

### Implementation
```swift
// Logging
Logger.analytics.info("Captain selected", metadata: [
    "playerID": .string(player.id),
    "confidence": .double(confidence),
    "timestamp": .double(Date().timeIntervalSince1970)
])

// Analytics
Analytics.track(.captainSelected(
    playerID: player.id,
    confidence: confidence,
    metadata: ["screen": "dashboard"]
))
```

---

## 🚀 CI/CD

### Pipeline Stages
1. **Quality**: SwiftFormat, SwiftLint, security scan
2. **Build**: Multi-destination builds
3. **Test**: Unit + Integration + UI tests
4. **Analysis**: Coverage, performance, security
5. **Release**: Archive + IPA generation

### Quality Gates
- **All lint checks**: must pass
- **Test coverage**: ≥80%
- **Build success**: all destinations
- **No TODO/FIXME**: in production code
- **Security scan**: no vulnerabilities

### Branch Protection
- **Require PR reviews**: 1 minimum
- **Require status checks**: CI must pass
- **No direct commits** to main/develop
- **Dismiss stale reviews** on new commits

---

## 📏 File Size Policy

### File Limits
- **Target**: ≤400 lines per file
- **Hard limit**: 500 lines (SwiftLint error)
- **Function limit**: 40 lines
- **Type body**: 300 lines maximum

### Splitting Guidelines
```swift
// ✅ Correct: Split by logical sections
extension PlayerView {
    // MARK: - UI Components
}

extension PlayerView {
    // MARK: - Data Handling  
}

extension PlayerView {
    // MARK: - Actions
}

// ✅ Correct: Extract view models
class PlayerViewModel: ObservableObject {
    // Business logic here
}
```

### Complexity Limits
- **Cyclomatic complexity**: ≤10 per function
- **Nested levels**: ≤3 levels deep
- **Parameter count**: ≤5 per function

---

## ✅ Release Checklist

### Pre-Release Validation
- [ ] **All lint/format checks** passing
- [ ] **Unit/UI tests** green (≥80% coverage)
- [ ] **No `print` statements** in Release builds
- [ ] **No `fatalError`** in Release builds
- [ ] **Performance budgets** met on test device
- [ ] **Memory leaks** checked with Instruments

### Accessibility Review
- [ ] **VoiceOver navigation** tested
- [ ] **Dynamic Type scaling** verified
- [ ] **High contrast mode** tested
- [ ] **Voice Control** compatibility

### Security Review
- [ ] **Privacy strings** in Info.plist
- [ ] **ATS exceptions** documented & justified
- [ ] **Keychain usage** reviewed
- [ ] **No hardcoded secrets** verified

### Performance Review
- [ ] **Launch time** <1.8s measured
- [ ] **Memory usage** <220MB verified
- [ ] **Frame drops** <1% on test content
- [ ] **Bundle size** within 60MB limit

### Final Steps
- [ ] **Crash reporting** enabled & tested
- [ ] **Analytics events** firing correctly
- [ ] **Feature flags** configured
- [ ] **TestFlight** build uploaded & tested

---

## 🛠️ Development Tools

### Required Tools
```bash
# Install via Homebrew
brew install swiftlint swiftformat xcpretty

# Verify installation
swiftlint version
swiftformat --version
xcpretty --version
```

### IDE Configuration
- **Xcode**: Latest stable version
- **SwiftLint plugin**: enabled
- **SwiftFormat on save**: recommended
- **Build phases**: lint integration

### Local Quality Check
```bash
# Run complete quality gate
./scripts/quality.sh

# Individual checks
swiftformat --lint .
swiftlint --strict
./scripts/coverage_gate.sh 80
```

---

## 📞 Support & Questions

For questions about these standards:
1. Check existing [GitHub Issues](../../issues)
2. Review [Architecture Documentation](architecture.md)
3. Consult [API Documentation](api-contracts.md)
4. Create new issue if needed

---

**Last Updated**: January 2025  
**Version**: 1.0  
**Owner**: AFL Fantasy iOS Team
