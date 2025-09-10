# AFL Fantasy iOS Build System

Enterprise-grade build system with automated quality gates, comprehensive testing, and CI/CD integration.

## 🚀 Quick Start

```bash
# Basic debug build with tests
bash ios/Scripts/build.sh

# Release build without tests  
bash ios/Scripts/build.sh -c Release -t

# Build and archive for distribution
bash ios/Scripts/build.sh -c Release -a --clean
```

## 📋 Prerequisites

### Required Tools

Install the following tools before building:

```bash
# Install Xcode (16.0+) from App Store

# Install SwiftFormat and SwiftLint
brew install swiftformat swiftlint

# Verify installation
swiftformat --version  # Should be 0.57.2+
swiftlint version       # Should be 0.60.0+

# Optional: Install xcpretty for prettier output
gem install xcpretty --user-install
```

### System Requirements

- **macOS**: 14.0+ (Sonoma)
- **Xcode**: 16.0+ 
- **iOS Deployment Target**: 17.0+
- **Swift**: 5.9+
- **Hardware**: Intel or Apple Silicon Mac

## 🏗️ Build Scripts

### Primary Build Script

**Location**: `ios/Scripts/build.sh`

```bash
bash ios/Scripts/build.sh [OPTIONS]
```

#### Options

| Flag | Long Form | Description | Default |
|------|-----------|-------------|---------|
| `-c` | `--configuration` | Build configuration (Debug/Release) | `Debug` |
| `-d` | `--destination` | Build destination | `platform=iOS Simulator,name=iPhone 15` |
| `-s` | `--scheme` | Xcode scheme | `AFLFantasy` |
| `-o` | `--output` | Output path for archives | `./build` |
| `-g` | `--coverage-threshold` | Coverage threshold (0-100) | `80` |
| `-t` | `--skip-tests` | Skip running tests | `false` |
| `-q` | `--skip-quality` | Skip quality gates | `false` |
| `-p` | `--skip-performance` | Skip performance checks | `false` |
| `-a` | `--archive` | Create archive and IPA | `false` |
| `--clean` | | Clean build artifacts first | `false` |
| `--verbose` | | Enable verbose output | `false` |
| `-h` | `--help` | Show help message | - |

### Quality Gates Library

**Location**: `ios/Scripts/lib_quality.sh`

Reusable quality gate functions:

```bash
# Source the library
source ios/Scripts/lib_quality.sh

# Run individual quality gates
check_prerequisites
run_swiftformat
run_swiftlint  
run_tests_with_coverage "AFLFantasy" "platform=iOS Simulator,name=iPhone 15"
enforce_coverage 80

# Run all quality gates
run_all_quality_gates 80 "AFLFantasy" "platform=iOS Simulator,name=iPhone 15"
```

## 📋 Build Examples

### Development Builds

```bash
# Quick development build (skip quality checks for speed)
bash ios/Scripts/build.sh -q -p

# Debug build with full quality gates
bash ios/Scripts/build.sh -c Debug

# Build with custom coverage threshold
bash ios/Scripts/build.sh -g 85
```

### Release Builds

```bash
# Release build for testing
bash ios/Scripts/build.sh -c Release -t

# Full release build with archive
bash ios/Scripts/build.sh -c Release -a --clean

# Release with custom output path
bash ios/Scripts/build.sh -c Release -a -o "./dist"
```

### Device Testing

```bash
# List available destinations
xcrun xctrace list devices

# Build for specific device
bash ios/Scripts/build.sh -d "platform=iOS,name=My iPhone"

# Build for specific simulator
bash ios/Scripts/build.sh -d "platform=iOS Simulator,name=iPhone 15 Pro,OS=17.0"
```

## 🔍 Quality Gates

The build system enforces enterprise-grade quality standards:

### 1. Code Formatting (SwiftFormat)
- Enforces consistent code style
- Uses `.swiftformat` configuration
- **Failure**: Any formatting changes required

### 2. Linting (SwiftLint)
- Enforces coding standards and best practices
- Uses `.swiftlint.yml` configuration  
- **Failure**: Any linting violations

### 3. Unit Testing
- Runs all unit tests with code coverage
- Tests run on iOS Simulator
- **Failure**: Any test failures

### 4. Code Coverage
- Minimum coverage threshold: 80% (configurable)
- Uses `llvm-cov` for accurate reporting
- **Failure**: Coverage below threshold

### 5. Performance Budget
- App size limits: ≤60MB IPA
- Launch time: ≤1.8s cold start
- Memory usage: ≤220MB steady state
- **Warning**: Budget violations logged

### Configuration Files

```
ios/
├── .swiftformat        # SwiftFormat rules
├── .swiftlint.yml      # SwiftLint configuration  
└── Scripts/
    ├── build.sh        # Main build script
    ├── lib_quality.sh  # Quality gates library
    ├── quality.sh      # Legacy quality script
    ├── coverage_gate.sh # Coverage enforcement
    └── performance_budget.sh # Performance checks
```

## 🏗️ Build Artifacts

### Debug Builds
```
build/
├── Debug-iphonesimulator/
│   └── AFLFantasy.app
└── DerivedData/
    └── AFLFantasy-*/
```

### Release Builds
```
build/
├── AFLFantasy.xcarchive/    # Xcode archive
├── AFLFantasy.ipa          # App Store package
├── ExportOptions.plist     # Export configuration
└── DerivedData/
    └── AFLFantasy-*/
```

## 🔄 Continuous Integration

### GitHub Actions Workflow

**Location**: `ios/.github/workflows/ios_build.yml`

The CI pipeline runs automatically on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`

#### Pipeline Stages

1. **Quality Check**: 
   - Code formatting, linting, tests
   - Coverage enforcement (≥80%)
   - Security scanning

2. **Debug Build**: 
   - Fast build for validation
   - Simulator artifacts

3. **Release Build** (main/develop only):
   - Clean release build
   - Archive creation
   - IPA generation

4. **Security Scan**:
   - Dependency vulnerability scan
   - Hardcoded secrets detection
   - Code quality metrics

#### Artifacts

- **Test Results** (30 days)
- **Coverage Reports** (7 days) 
- **Debug Builds** (7 days)
- **Release Archives** (30 days)
- **Performance Reports** (7 days)

### CI Badge

Add to your README.md:

```markdown
[![iOS CI](https://github.com/YOUR_USERNAME/afl_fantasy_ios/workflows/AFL%20Fantasy%20iOS%20CI/badge.svg)](https://github.com/YOUR_USERNAME/afl_fantasy_ios/actions)
```

## 🛠️ Troubleshooting

### Common Build Errors

#### 1. SwiftFormat/SwiftLint Not Found
```bash
# Error: command not found: swiftformat
# Solution:
brew install swiftformat swiftlint
```

#### 2. Coverage Data Not Found  
```bash
# Error: No coverage data found
# Solution: Ensure tests ran with coverage enabled
bash ios/Scripts/build.sh -c Debug  # (don't skip tests)
```

#### 3. Simulator Not Available
```bash
# Error: destination not found
# Solution: List available simulators
xcrun simctl list devices available

# Or use a different destination
bash ios/Scripts/build.sh -d "platform=iOS Simulator,name=iPhone 15"
```

#### 4. Archive Export Failed
```bash
# Error: exportArchive failed
# Solution: Check signing configuration
# 1. Verify team ID in ExportOptions.plist
# 2. Ensure valid provisioning profiles
# 3. Check Xcode project signing settings
```

#### 5. DerivedData Issues
```bash
# Error: build artifacts corrupted
# Solution: Clean DerivedData
bash ios/Scripts/build.sh --clean

# Or manually:
rm -rf ~/Library/Developer/Xcode/DerivedData/AFLFantasy-*
```

### Build Performance

#### Slow Builds
```bash
# Use parallel builds (default)
# Skip quality gates for development
bash ios/Scripts/build.sh -q -p

# Clean only when necessary
bash ios/Scripts/build.sh --clean  # Only when needed
```

#### Large Build Artifacts
```bash  
# Enable bitcode optimization (Release only)
# Check build settings for:
# - Dead code stripping: YES
# - Swift optimization: -O (Release)
# - Asset catalog optimization: space
```

### CI/CD Issues

#### Failed CI Jobs
1. Check workflow logs in GitHub Actions
2. Verify all prerequisites installed
3. Ensure sufficient macOS runner resources
4. Check for flaky tests

#### Missing Artifacts
1. Verify upload paths in workflow
2. Check build script output directories
3. Ensure artifacts created successfully

## 📊 Performance Standards

### Build Times
- **Debug Build**: <2 minutes
- **Release Archive**: <5 minutes  
- **Quality Gates**: <3 minutes
- **Full CI Pipeline**: <10 minutes

### Quality Metrics
- **Code Coverage**: ≥80%
- **SwiftLint**: 0 violations
- **File Size**: ≤500 lines per file
- **Function Length**: ≤40 lines
- **Complexity**: ≤10 cyclomatic complexity

### App Performance
- **Cold Launch**: ≤1.8s
- **Memory Usage**: ≤220MB steady state
- **App Size**: ≤60MB IPA
- **Frame Rate**: 60fps

## 🔐 Security

### Secrets Management
- API keys via environment variables
- Keychain for sensitive data storage
- No hardcoded secrets in source code

### Code Scanning  
- Automated dependency vulnerability scanning
- Hardcoded secrets detection
- Static analysis with SwiftLint security rules

### Build Integrity
- Reproducible builds with locked dependencies
- Signed archives with valid certificates
- Secure CI/CD pipeline with audit logs

## 🆘 Support

### Documentation
- [README.md](README.md) - Project overview
- [CONTRIBUTING.md](CONTRIBUTING.md) - Development guidelines
- [Scripts/README.md](ios/Scripts/README.md) - Build scripts reference

### Getting Help
1. Check troubleshooting section above
2. Review GitHub Actions logs for CI issues
3. Search existing GitHub issues
4. Create new issue with build logs

---

**Built with AFL Fantasy iOS Build System v1.0**  
*Enterprise-grade quality gates for professional iOS development*
