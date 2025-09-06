# 🛠️ AFL Fantasy Platform - Development Workflow & Standards Guide

*Last Updated: September 6, 2024*

## 📋 **Overview**

This guide provides comprehensive development workflows, coding standards, and best practices for the AFL Fantasy Intelligence Platform. It covers all aspects of development across iOS, web, and backend components, ensuring consistent quality and efficient collaboration.

---

## 🏗️ **Platform Setup & Local Development**

### **🍎 iOS Development Environment**

#### **Prerequisites**
```bash
# Required tools
Xcode 15.0+ (latest stable)
iOS 16.0+ SDK
Swift 5.9+
SwiftFormat & SwiftLint (configured)

# Optional but recommended
SF Symbols (for icon consistency)
Simulator runtime for testing
TestFlight access for beta testing
```

#### **Local Setup Steps**
```bash
# 1. Clone repository
git clone <repository-url>
cd afl_fantasy_ios

# 2. Navigate to iOS directory
cd ios/

# 3. Open in Xcode
open AFLFantasy.xcodeproj

# 4. Configure signing (if needed)
# Team: Tiation Technologies
# Bundle ID: com.tiation.aflFantasy

# 5. Build and run
# Target: AFLFantasy
# Destination: iPhone 15 Simulator (or device)
⌘+R to build and run
```

#### **iOS Code Quality Tools**
```bash
# SwiftFormat (run before commit)
swiftformat .

# SwiftLint (continuous checking)
swiftlint

# Combined quality check
./Scripts/ios_quality_check.sh
```

**Quality Standards:**
- ✅ **SwiftLint**: Zero warnings in production code
- ✅ **SwiftFormat**: Consistent code formatting 
- ✅ **Test Coverage**: Minimum 80% for core services
- ✅ **Performance**: Sub-2s cold start, <100MB memory
- ✅ **Accessibility**: VoiceOver labels, Dynamic Type support

---

### **🌐 Web Development Environment**

#### **Prerequisites**
```bash
# Required tools
Node.js 18+ (LTS version)
npm 8+ or pnpm 9 (preferred)
TypeScript 5+
React 18+

# Development tools
VS Code with extensions:
- TypeScript Hero
- ES7+ React/Redux/RN snippets
- Prettier - Code formatter
- ESLint
```

#### **Local Setup Steps**
```bash
# 1. Navigate to project root
cd afl_fantasy_ios/

# 2. Install dependencies (using pnpm)
pnpm install
# or: npm install

# 3. Environment setup
cp .env.example .env
# Edit .env with development API keys

# 4. Start development server
pnpm dev
# or: npm run dev

# 5. Access application
# Web: http://localhost:5173
# API: http://localhost:5173/api
```

#### **Web Code Quality Tools**
```bash
# Formatting and linting
pnpm format       # Prettier formatting
pnpm lint         # ESLint checking  
pnpm typecheck    # TypeScript validation
pnpm test         # Run test suite

# Combined quality check
pnpm check        # All quality checks
```

**Quality Standards:**
- ✅ **ESLint**: Zero errors, minimal warnings
- ✅ **TypeScript**: Strict mode enabled
- ✅ **Prettier**: Consistent code formatting
- ✅ **Bundle Size**: <90KB gzipped per route
- ✅ **Performance**: Lighthouse score >90

---

### **⚙️ Backend Development Environment**

#### **Prerequisites**
```bash
# Required tools
Python 3.9+
Node.js 18+ (for Express.js API)
PostgreSQL 14+
Docker (for containerized services)

# Python environment
python -m venv venv
source venv/bin/activate  # Linux/macOS
# or: venv\Scripts\activate  # Windows

pip install -r requirements.txt
```

#### **Local Setup Steps**
```bash
# 1. Database setup
createdb aflFantasy
psql -d aflFantasy -f init.sql

# 2. Environment configuration
cp .env.example .env
# Configure database URL and API keys

# 3. Install Python dependencies
pip install -r requirements.txt

# 4. Install Node.js dependencies
npm install

# 5. Start backend services
python server.py          # Python ML engine
npm run dev               # Express.js API
```

#### **Backend Code Quality Tools**
```bash
# Python quality checks
black .                   # Code formatting
isort .                   # Import sorting
flake8                    # Linting
mypy .                    # Type checking

# Node.js quality checks
npm run lint              # ESLint
npm run typecheck         # TypeScript

# Combined backend check
./scripts/backend_quality.sh
```

**Quality Standards:**
- ✅ **Black**: Python code formatting
- ✅ **ESLint**: JavaScript/TypeScript linting
- ✅ **Type Safety**: TypeScript strict mode, Python typing
- ✅ **API Response**: <200ms average response time
- ✅ **Test Coverage**: 85%+ for business logic

---

## 🔄 **Git Workflow & Branching Strategy**

### **Branching Model**
```
main (production-ready)
├── develop (integration branch)
├── feature/captain-analysis-v2
├── feature/ios-push-notifications  
├── feature/weather-api-integration
├── hotfix/critical-bug-fix
└── release/v2.1.0
```

### **Branch Types & Naming**
- **`main`**: Production-ready code, protected branch
- **`develop`**: Integration branch for features
- **`feature/`**: New features and enhancements
- **`hotfix/`**: Critical bug fixes for production
- **`release/`**: Release preparation branches
- **`docs/`**: Documentation updates

### **Workflow Steps**
```bash
# 1. Create feature branch from develop
git checkout develop
git pull origin develop
git checkout -b feature/new-analytics-tool

# 2. Development cycle
git add -A
git commit -m "feat: add captain confidence algorithm"
git push origin feature/new-analytics-tool

# 3. Pull request process
gh pr create --title "Add Captain Confidence Algorithm" \
             --body "Implements 7-factor confidence scoring"

# 4. After PR approval and merge
git checkout develop
git pull origin develop
git branch -d feature/new-analytics-tool
```

---

## 📝 **Commit Message Standards**

### **Conventional Commits Format**
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### **Commit Types**
- **`feat:`** New feature or enhancement
- **`fix:`** Bug fix  
- **`docs:`** Documentation changes
- **`style:`** Code formatting (no logic changes)
- **`refactor:`** Code restructuring (no feature changes)
- **`perf:`** Performance improvements
- **`test:`** Adding or updating tests
- **`build:`** Build system or dependency changes
- **`ci:`** CI/CD pipeline changes

### **Examples**
```bash
# Good commit messages
feat(ios): add push notification support
fix(api): resolve player data parsing error
docs: update deployment guide with new steps
perf(web): optimize player list rendering
test(backend): add unit tests for AI analysis

# Commit with body
feat(captain): implement 7-factor confidence algorithm

- Add venue performance bias calculation
- Include opponent difficulty (DVP) analysis  
- Factor in recent form and consistency
- Weather impact assessment
- Price value consideration
- Injury risk evaluation

Closes #123
```

---

## 🧪 **Testing Standards & Practices**

### **iOS Testing Strategy**
```swift
// Unit Tests (80%+ coverage)
class AFLFantasyDataServiceTests: XCTestCase {
    func testDataFetchingSuccess() async {
        // Given, When, Then pattern
        let expectedData = DashboardData.mock
        mockAPIClient.result = .success(expectedData)
        
        await dataService.refreshData()
        
        XCTAssertEqual(dataService.dashboardData, expectedData)
    }
}

// Integration Tests
class AFLFantasyIntegrationTests: XCTestCase {
    func testFullAuthenticationFlow() async {
        // Test complete user flow
    }
}

// UI Tests (critical paths only)
class AFLFantasyUITests: XCTestCase {
    func testDashboardLoadingFlow() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Test UI interactions
    }
}
```

### **Web Testing Strategy**
```typescript
// Unit Tests (Vitest)
describe('PlayerCard', () => {
  it('displays player information correctly', () => {
    const player = mockPlayer();
    render(<PlayerCard player={player} />);
    
    expect(screen.getByText(player.name)).toBeInTheDocument();
    expect(screen.getByText(`$${player.price}`)).toBeInTheDocument();
  });
});

// Integration Tests
describe('Captain Analysis API', () => {
  it('fetches and displays captain recommendations', async () => {
    mockAPI.getCaptainAnalysis.mockResolvedValue(mockRecommendations);
    
    render(<CaptainAnalysis />);
    
    await waitFor(() => {
      expect(screen.getByText('Captain Recommendations')).toBeInTheDocument();
    });
  });
});

// E2E Tests (Playwright)
test('complete captain selection flow', async ({ page }) => {
  await page.goto('/captain-analysis');
  await page.click('[data-testid="analyze-captain"]');
  await expect(page.locator('.captain-recommendation')).toBeVisible();
});
```

### **Backend Testing Strategy**
```python
# Unit Tests (pytest)
def test_captain_analysis_algorithm():
    player = create_mock_player()
    analysis = captain_analyzer.analyze(player)
    
    assert analysis.confidence >= 0
    assert analysis.confidence <= 100
    assert analysis.factors is not None

# Integration Tests  
def test_api_captain_endpoint():
    response = client.post('/api/captain/analyze', json={
        'player_id': '12345',
        'round': 20
    })
    
    assert response.status_code == 200
    assert 'confidence' in response.json()

# Load Tests
def test_api_performance():
    # Test API under load
    pass
```

### **Testing Commands**
```bash
# iOS Testing
xcodebuild test -scheme AFLFantasy -destination 'platform=iOS Simulator,name=iPhone 15'

# Web Testing
pnpm test              # Unit tests
pnpm test:integration  # Integration tests
pnpm test:e2e          # End-to-end tests

# Backend Testing
pytest                 # Python tests
npm test              # Node.js tests
```

---

## 🔒 **Security & Secrets Management**

### **Environment Variables**
```bash
# .env.example (checked into git)
GEMINI_API_KEY=your_gemini_api_key_here
OPENAI_API_KEY=your_openai_api_key_here
DATABASE_URL=postgresql://localhost/aflFantasy
AFL_FANTASY_BASE_URL=https://api.aflFantasy.com

# .env (never checked into git)
GEMINI_API_KEY=actual_production_key
OPENAI_API_KEY=actual_openai_key
DATABASE_URL=postgresql://user:pass@prod-db/db
```

### **Secrets in CI/CD**
```yaml
# GitHub Actions
env:
  GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
  OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
  DATABASE_URL: ${{ secrets.DATABASE_URL }}
```

### **iOS Keychain Usage**
```swift
// Always use Keychain for sensitive data
class KeychainManager {
    func storeCredentials(_ credentials: AFLFantasyCredentials) throws {
        let data = try JSONEncoder().encode(credentials)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            kSecValueData as String: data
        ]
        // Store securely
    }
}
```

---

## 🚀 **Build & Deployment Process**

### **iOS App Deployment**
```bash
# 1. Archive build
xcodebuild archive -scheme AFLFantasy \
                   -archivePath AFLFantasy.xcarchive

# 2. Export for distribution
xcodebuild -exportArchive -archivePath AFLFantasy.xcarchive \
                         -exportPath AFLFantasy \
                         -exportOptionsPlist ExportOptions.plist

# 3. Upload to App Store Connect
xcrun altool --upload-app -f AFLFantasy.ipa \
            -u developer@tiation.com \
            -p @keychain:AC_PASSWORD
```

### **Web Deployment**
```bash
# 1. Build production bundle
pnpm build

# 2. Test production build locally
pnpm preview

# 3. Deploy to production (example: Netlify)
netlify deploy --prod --dir=dist

# 4. Verify deployment
curl -I https://afl-fantasy.tiation.com
```

### **Backend Deployment**
```bash
# 1. Docker build
docker build -t afl-fantasy-backend .

# 2. Tag for registry
docker tag afl-fantasy-backend registry.tiation.com/afl-fantasy:latest

# 3. Push to registry
docker push registry.tiation.com/afl-fantasy:latest

# 4. Deploy to production
kubectl apply -f k8s/production/
```

---

## 📊 **Code Review Guidelines**

### **Pull Request Checklist**
#### **Author Checklist**
- [ ] Code follows project style guidelines
- [ ] All tests pass (unit, integration, e2e)  
- [ ] Documentation updated if needed
- [ ] Performance impact assessed
- [ ] Security implications considered
- [ ] Breaking changes documented

#### **Reviewer Checklist**
- [ ] Code logic is correct and efficient
- [ ] Tests adequately cover new functionality
- [ ] Security best practices followed
- [ ] Performance implications acceptable
- [ ] Documentation is clear and complete
- [ ] UI/UX changes meet design requirements

### **Review Process**
1. **Author**: Create PR with detailed description
2. **CI/CD**: Automated checks must pass
3. **Reviewers**: Minimum 2 approvals for main branch
4. **Author**: Address feedback and update PR
5. **Merge**: Squash and merge to maintain clean history

### **PR Description Template**
```markdown
## 🎯 Purpose
Brief description of what this PR accomplishes.

## 🔧 Changes Made
- Specific change 1
- Specific change 2
- Specific change 3

## 🧪 Testing
- [ ] Unit tests added/updated
- [ ] Integration tests verified  
- [ ] Manual testing completed

## 📸 Screenshots (if UI changes)
Before/after screenshots or demo videos

## ⚠️ Breaking Changes
Any breaking changes and migration steps

## 📋 Checklist
- [ ] Tests pass
- [ ] Documentation updated
- [ ] Performance reviewed
- [ ] Security reviewed
```

---

## 🔧 **Debugging & Troubleshooting**

### **iOS Debugging**
```swift
// Logging with categorization
import os.log

extension Logger {
    static let networking = Logger(subsystem: "com.tiation.aflFantasy", category: "networking")
    static let dataService = Logger(subsystem: "com.tiation.aflFantasy", category: "dataService")
    static let ui = Logger(subsystem: "com.tiation.aflFantasy", category: "ui")
}

// Usage
Logger.networking.info("API request started: \\(url)")
Logger.dataService.error("Failed to parse data: \\(error)")
```

### **Web Debugging**
```typescript
// Development logging
const logger = {
  info: (message: string, data?: any) => {
    if (process.env.NODE_ENV === 'development') {
      console.log(`ℹ️ [INFO] ${message}`, data);
    }
  },
  error: (message: string, error?: Error) => {
    console.error(`❌ [ERROR] ${message}`, error);
  }
};

// Usage
logger.info('Fetching captain analysis', { playerId: '12345' });
logger.error('API request failed', error);
```

### **Backend Debugging**
```python
# Structured logging
import logging
import structlog

logger = structlog.get_logger()

# Usage
logger.info("Processing captain analysis", player_id="12345", round=20)
logger.error("API request failed", error=str(error))
```

### **Common Issues & Solutions**
```bash
# iOS build issues
rm -rf ~/Library/Developer/Xcode/DerivedData
xcodebuild clean

# Web dependency issues  
rm -rf node_modules pnpm-lock.yaml
pnpm install

# Backend Python issues
pip install --upgrade pip
pip install -r requirements.txt --force-reinstall

# Database connection issues
psql -d aflFantasy -c "SELECT version();"
```

---

## 📈 **Performance Monitoring**

### **iOS Performance**
```swift
class PerformanceTracker {
    static func trackViewLoad(_ viewName: String) {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            Analytics.track(.viewLoad, properties: [
                "view": viewName,
                "duration": duration
            ])
        }
    }
}
```

### **Web Performance**
```typescript
// Web Vitals monitoring
import { getCLS, getFID, getFCP, getLCP, getTTFB } from 'web-vitals';

getCLS(metric => console.log('CLS:', metric));
getFID(metric => console.log('FID:', metric));
getFCP(metric => console.log('FCP:', metric));
getLCP(metric => console.log('LCP:', metric));
getTTFB(metric => console.log('TTFB:', metric));
```

### **Performance Budgets**
```yaml
# Performance thresholds
ios:
  cold_start: <2000ms
  memory_usage: <100MB
  battery_drain: <5%/hour

web:
  first_contentful_paint: <1500ms
  largest_contentful_paint: <2500ms
  bundle_size: <90KB (gzipped)

backend:
  api_response: <200ms
  database_query: <50ms
  memory_usage: <512MB
```

---

## 🤝 **Team Collaboration**

### **Communication Channels**
- **Technical Discussions**: GitHub Discussions
- **Bug Reports**: GitHub Issues  
- **Feature Requests**: GitHub Issues with `enhancement` label
- **Code Review**: GitHub Pull Requests
- **Documentation**: `/docs` directory in repository

### **Meeting Cadence**
- **Daily Standups**: Quick progress updates (15 minutes)
- **Weekly Planning**: Sprint planning and retrospectives (60 minutes)  
- **Monthly Reviews**: Architecture reviews and technical debt assessment
- **Quarterly Planning**: Roadmap planning and goal setting

### **Documentation Standards**
- **Code Comments**: Explain why, not what
- **API Documentation**: OpenAPI/Swagger specifications
- **Architecture Decisions**: ADR (Architecture Decision Records)
- **User Guides**: Clear setup and usage instructions
- **Changelog**: Keep updated with each release

---

## ⚡ **Productivity Tips**

### **IDE Configuration**
#### **VS Code (Web/Backend)**
```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "typescript.preferences.importModuleSpecifier": "relative"
}
```

#### **Xcode (iOS)**
```bash
# Useful Xcode shortcuts
⌘+R          # Build and run
⌘+U          # Run tests  
⌘+I          # Profile with Instruments
⌘+Shift+K    # Clean build folder
⌘+Option+/   # Documentation lookup
```

### **Automation Scripts**
```bash
# Quality check script
#!/bin/bash
echo "🔍 Running quality checks..."

# iOS
cd ios/ && swiftlint && swiftformat . --lint
echo "✅ iOS quality check complete"

# Web  
cd ../ && pnpm lint && pnpm typecheck
echo "✅ Web quality check complete"

# Backend
python -m black . --check && python -m isort . --check
echo "✅ Backend quality check complete"

echo "🎉 All quality checks passed!"
```

---

## 📚 **Learning Resources**

### **iOS Development**
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [iOS App Dev Tutorials](https://developer.apple.com/tutorials/app-dev-training)
- [Advanced SwiftUI](https://www.hackingwithswift.com/plus)

### **Web Development**
- [React Documentation](https://reactjs.org/docs/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Web.dev Performance Guide](https://web.dev/learn-web-vitals/)
- [MDN Web Docs](https://developer.mozilla.org/)

### **Backend Development**
- [Python Best Practices](https://realpython.com/python-code-quality/)
- [Express.js Guide](https://expressjs.com/en/guide/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [API Design Guide](https://restfulapi.net/)

---

## 🎯 **Success Metrics**

### **Development Velocity**
- **Commit Frequency**: Daily commits from active developers
- **PR Cycle Time**: <48 hours from creation to merge
- **Bug Resolution**: <24 hours for critical, <1 week for normal
- **Feature Delivery**: On-time delivery of sprint commitments

### **Code Quality**
- **Test Coverage**: Maintain 80%+ across all platforms
- **Code Review**: 100% of code reviewed before merge
- **Technical Debt**: Address debt items monthly
- **Documentation**: Keep docs up-to-date with code changes

### **Performance**
- **Build Times**: <5 minutes for full platform builds
- **Test Execution**: <10 minutes for complete test suite
- **Deployment Time**: <15 minutes for production deployment
- **Issue Resolution**: Mean time to resolution <2 hours

---

*This development guide serves as the foundation for maintaining high-quality, consistent development practices across the AFL Fantasy Intelligence Platform. It should be reviewed and updated quarterly to reflect evolving best practices and team needs.*
