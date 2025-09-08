# 🛠️ Development Tools Installation Guide

## 📋 Required Tools for AFL Fantasy iOS Development

Your AFL Fantasy iOS project uses enterprise-grade development tools to ensure code quality, performance, and consistency. Here's how to install them:

---

## 🚀 **Option 1: Easy One-Command Setup (Recommended)**

```bash
./Scripts/setup_dev_env.sh
```

This script will:
- ✅ Check and install Homebrew (if needed)
- ✅ Install SwiftFormat and SwiftLint via Homebrew  
- ✅ Install xcpretty via Ruby gems (user-local)
- ✅ Configure your shell PATH automatically
- ✅ Offer to set up pre-commit hooks
- ✅ Verify all installations are working

---

## 🔧 **Option 2: Manual Installation**

### **SwiftFormat & SwiftLint (via Homebrew)**
```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install quality tools
brew install swiftformat swiftlint
```

### **xcpretty (via Ruby Gems)**
```bash
# Install xcpretty to user directory (no sudo required)
gem install xcpretty --user-install

# Add to PATH (choose your shell)
# For Zsh (default on macOS):
echo 'export PATH="$HOME/.gem/ruby/2.6.0/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# For Bash:
echo 'export PATH="$HOME/.gem/ruby/2.6.0/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## 🔍 **Option 3: Alternative xcpretty Installation Methods**

### **Method 1: System-wide (requires sudo)**
```bash
sudo gem install xcpretty
```

### **Method 2: Using rbenv (if you have Ruby version management)**
```bash
rbenv exec gem install xcpretty
```

### **Method 3: Using Bundler (for project-specific)**
Create a `Gemfile`:
```ruby
# Gemfile
source 'https://rubygems.org'
gem 'xcpretty'
```
Then run:
```bash
bundle install
bundle exec xcpretty --version
```

### **Method 4: Using Mint (Swift-based package manager)**
```bash
brew install mint
mint install JohnSundell/xcpretty
```

---

## ✅ **Verification**

After installation, verify all tools are working:

```bash
# Check versions
swiftformat --version
swiftlint version  
xcpretty --version

# Test the quality script
./Scripts/quality.sh --help
```

**Expected output:**
```
SwiftFormat: 0.54.5 or later
SwiftLint: 0.57.0 or later  
xcpretty: 0.4.1 or later
```

---

## 🚨 **Troubleshooting**

### **xcpretty not found after installation**
```bash
# Check if xcpretty is installed but not in PATH
ls ~/.gem/ruby/2.6.0/bin/xcpretty

# If it exists, add to PATH manually:
export PATH="$HOME/.gem/ruby/2.6.0/bin:$PATH"

# Make it permanent by adding to your shell profile
echo 'export PATH="$HOME/.gem/ruby/2.6.0/bin:$PATH"' >> ~/.zshrc
```

### **Ruby version issues**
```bash
# Check Ruby version
ruby --version

# If you have a different Ruby version, adjust the path:
ls ~/.gem/ruby/*/bin/xcpretty
# Use the correct version path in your exports
```

### **Permission errors with system gems**
```bash
# Always use --user-install to avoid permission issues
gem install xcpretty --user-install

# If you must use system gems (not recommended):
sudo gem install xcpretty
```

### **Homebrew not working**
```bash
# Ensure Homebrew is in PATH (Apple Silicon Macs)
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Intel Macs should use /usr/local/bin by default
```

---

## 🔄 **Updating Tools**

Keep your development tools up to date:

```bash
# Update Homebrew packages
brew update && brew upgrade swiftformat swiftlint

# Update xcpretty
gem update xcpretty --user-install

# Or run the setup script again
./Scripts/setup_dev_env.sh
```

---

## 🏗️ **CI/CD Compatibility**

Our GitHub Actions workflow uses these exact installation methods:
- **Homebrew** for SwiftFormat and SwiftLint
- **Ruby gems with user-install** for xcpretty
- **Automatic PATH configuration** in the CI environment

This ensures your local environment matches the CI environment perfectly.

---

## 🎯 **Next Steps**

After installing the tools:

1. **Run quality check**: `./Scripts/quality.sh`
2. **Run performance validation**: `./Scripts/performance_budget.sh`  
3. **Set up pre-commit hook** (optional): Copy `Scripts/quality.sh` to `.git/hooks/pre-commit`
4. **Start coding** with confidence! 🚀

---

## 📞 **Need Help?**

If you encounter any installation issues:

1. **Check the tool versions** - ensure you have the latest versions
2. **Verify your PATH** - make sure all tools are accessible
3. **Run the setup script** - it handles most edge cases automatically
4. **Check Ruby/gem environment** - ensure you have a working Ruby installation

The setup script (`./Scripts/setup_dev_env.sh`) handles most common installation scenarios and provides helpful error messages.

---

*Professional development tools for professional results! 💼✨*
