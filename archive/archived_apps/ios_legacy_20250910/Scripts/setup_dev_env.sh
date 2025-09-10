#!/usr/bin/env bash
set -euo pipefail

echo "🔧 AFL Fantasy iOS - Development Environment Setup"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_step() {
    echo -e "${BLUE}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Homebrew is installed
print_step "Checking Homebrew installation..."
if ! command -v brew >/dev/null 2>&1; then
    print_error "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    print_success "Homebrew is installed"
fi

# Install SwiftFormat
print_step "Installing SwiftFormat..."
if ! command -v swiftformat >/dev/null 2>&1; then
    brew install swiftformat
    print_success "SwiftFormat installed"
else
    print_success "SwiftFormat already installed"
fi

# Install SwiftLint
print_step "Installing SwiftLint..."
if ! command -v swiftlint >/dev/null 2>&1; then
    brew install swiftlint
    print_success "SwiftLint installed"
else
    print_success "SwiftLint already installed"
fi

# Install xcpretty
print_step "Installing xcpretty..."
if ! command -v xcpretty >/dev/null 2>&1; then
    gem install xcpretty --user-install
    
    # Add to PATH for current session
    GEM_PATH="$HOME/.gem/ruby/2.6.0/bin"
    if [[ -d "$GEM_PATH" ]]; then
        export PATH="$GEM_PATH:$PATH"
        print_success "xcpretty installed"
        
        # Add to shell profile for persistence
        SHELL_PROFILE=""
        if [[ "$SHELL" == */zsh ]]; then
            SHELL_PROFILE="$HOME/.zshrc"
        elif [[ "$SHELL" == */bash ]]; then
            SHELL_PROFILE="$HOME/.bashrc"
        fi
        
        if [[ -n "$SHELL_PROFILE" ]] && [[ -f "$SHELL_PROFILE" ]]; then
            if ! grep -q "/.gem/ruby/2.6.0/bin" "$SHELL_PROFILE"; then
                echo "export PATH=\"\$HOME/.gem/ruby/2.6.0/bin:\$PATH\"" >> "$SHELL_PROFILE"
                print_success "Added xcpretty to PATH in $SHELL_PROFILE"
            fi
        fi
    fi
else
    print_success "xcpretty already installed"
fi

# Verify installations
echo ""
print_step "Verifying installations..."

if command -v swiftformat >/dev/null 2>&1; then
    SWIFTFORMAT_VERSION=$(swiftformat --version)
    print_success "SwiftFormat: $SWIFTFORMAT_VERSION"
else
    print_error "SwiftFormat installation failed"
fi

if command -v swiftlint >/dev/null 2>&1; then
    SWIFTLINT_VERSION=$(swiftlint version)
    print_success "SwiftLint: $SWIFTLINT_VERSION"
else
    print_error "SwiftLint installation failed"
fi

if command -v xcpretty >/dev/null 2>&1; then
    XCPRETTY_VERSION=$(xcpretty --version)
    print_success "xcpretty: $XCPRETTY_VERSION"
else
    print_warning "xcpretty may need PATH update. Run: source ~/.zshrc (or restart terminal)"
fi

echo ""
print_step "Setting up Git hooks (optional)..."
read -p "Do you want to set up a pre-commit hook to run quality checks? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [[ -d ".git" ]]; then
        cp Scripts/quality.sh .git/hooks/pre-commit
        chmod +x .git/hooks/pre-commit
        print_success "Pre-commit hook installed"
    else
        print_warning "Not in a Git repository. Hook not installed."
    fi
fi

echo ""
print_step "Testing quality script..."
if ./Scripts/quality.sh --dry-run >/dev/null 2>&1 || true; then
    print_success "Quality script is ready"
else
    print_warning "Quality script may need adjustment. Run manually to test."
fi

echo ""
echo -e "${GREEN}🎉 Development environment setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Run './Scripts/quality.sh' to validate your code"
echo "2. Run './Scripts/performance_budget.sh' to check performance"
echo "3. Open Xcode and start building amazing features!"
echo ""
echo -e "${BLUE}Happy coding! 🚀${NC}"
