#!/bin/bash

# AFL Fantasy Environment Security Audit Script
echo "🔒 AFL Fantasy Environment Security Audit"
echo "=================================================="

PASS=0
WARN=0
FAIL=0

# Check if .env is in .gitignore
echo
echo "📋 Checking Git repository configuration..."

if git check-ignore .env >/dev/null 2>&1; then
    echo "   ✅ .env file is properly ignored by git"
    PASS=$((PASS + 1))
else
    if [ -f .env ]; then
        echo "   ❌ .env file exists but is NOT ignored by git - SECURITY RISK!"
        echo "      💡 Add '.env' to .gitignore immediately"
        FAIL=$((FAIL + 1))
    else
        echo "   ⚠️  .env file doesn't exist (using .env.example only)"
        WARN=$((WARN + 1))
    fi
fi

# Check if any .env files are tracked
if git ls-files | grep -E '\.env$|\.env\.' | grep -v '\.env\.example' >/dev/null 2>&1; then
    echo "   ❌ Found .env files tracked by git:"
    git ls-files | grep -E '\.env$|\.env\.' | grep -v '\.env\.example' | sed 's/^/      /'
    FAIL=$((FAIL + 1))
else
    echo "   ✅ No .env files are tracked by git"
    PASS=$((PASS + 1))
fi

echo
echo "📁 Checking environment file structure..."

# Check .env.example exists
if [ -f .env.example ]; then
    echo "   ✅ .env.example template exists"
    PASS=$((PASS + 1))
    
    # Count variables in .env.example
    env_vars=$(grep -c "^[A-Z_].*=" .env.example 2>/dev/null || echo "0")
    echo "      📊 Template contains $env_vars environment variables"
else
    echo "   ⚠️  .env.example template file is missing"
    WARN=$((WARN + 1))
fi

# Check actual .env file
if [ -f .env ]; then
    echo "   ✅ .env file exists"
    PASS=$((PASS + 1))
    
    # Check for placeholder values
    if grep -E "(your_|placeholder|example|changeme)" .env >/dev/null 2>&1; then
        echo "   ⚠️  Found placeholder values in .env - ensure all secrets are real:"
        grep -E "(your_|placeholder|example|changeme)" .env | sed 's/^/      /'
        WARN=$((WARN + 1))
    else
        echo "   ✅ No obvious placeholder values found in .env"
        PASS=$((PASS + 1))
    fi
    
    # Check for empty values
    empty_vars=$(grep -E "^[A-Z_].*=$" .env 2>/dev/null | wc -l)
    if [ "$empty_vars" -gt 0 ]; then
        echo "   ⚠️  $empty_vars environment variables have empty values"
        grep -E "^[A-Z_].*=$" .env | cut -d'=' -f1 | sed 's/^/      - /'
        WARN=$((WARN + 1))
    else
        echo "   ✅ All environment variables have values"
        PASS=$((PASS + 1))
    fi
    
else
    echo "   ❌ .env file is missing - copy from .env.example and configure"
    FAIL=$((FAIL + 1))
fi

echo
echo "🔐 Checking for sensitive data patterns..."

# Check for hardcoded database URLs with credentials
if find . -name "*.js" -o -name "*.ts" -o -name "*.py" 2>/dev/null | xargs grep -l "postgresql://.*:.*@" 2>/dev/null | grep -v node_modules | head -1 >/dev/null 2>&1; then
    echo "   ⚠️  Found hardcoded database URLs with credentials in source code"
    find . -name "*.js" -o -name "*.ts" -o -name "*.py" 2>/dev/null | xargs grep -l "postgresql://.*:.*@" 2>/dev/null | grep -v node_modules | head -3 | sed 's/^/      /'
    WARN=$((WARN + 1))
else
    echo "   ✅ No hardcoded database credentials found in source code"
    PASS=$((PASS + 1))
fi

echo
echo "📦 Checking CI/CD configuration..."

# Check GitHub Actions
if [ -d .github/workflows ]; then
    echo "   ✅ GitHub Actions workflows directory exists"
    PASS=$((PASS + 1))
    
    # Check for OP_CONNECT_TOKEN references
    if find .github/workflows -name "*.yml" -exec grep -l "OP_CONNECT_TOKEN" {} \; 2>/dev/null | head -1 >/dev/null 2>&1; then
        echo "   ✅ Found 1Password Connect token references in CI"
        PASS=$((PASS + 1))
    else
        echo "   ⚠️  No 1Password Connect token (OP_CONNECT_TOKEN) found in CI workflows"
        WARN=$((WARN + 1))
    fi
    
    # Check for secrets in workflow files
    if find .github/workflows -name "*.yml" -exec grep -l "\${{.*secrets\." {} \; 2>/dev/null | head -1 >/dev/null 2>&1; then
        echo "   ✅ GitHub Actions using GitHub secrets (good practice)"
        PASS=$((PASS + 1))
    else
        echo "   ⚠️  No GitHub secrets usage found in workflows"
        WARN=$((WARN + 1))
    fi
else
    echo "   ⚠️  No GitHub Actions workflows found"
    WARN=$((WARN + 1))
fi

echo
echo "🛡️  Security recommendations..."

if [ -f .env ]; then
    # Check for common security issues
    if grep -q "localhost" .env && grep -q "password" .env; then
        echo "   ⚠️  Using localhost with password - ensure this is only for development"
        WARN=$((WARN + 1))
    fi
    
    if grep -q "admin" .env; then
        echo "   ⚠️  Found 'admin' in .env - avoid default usernames in production"
        WARN=$((WARN + 1))
    fi
fi

echo
echo "📊 Audit Summary"
echo "=================="
echo "✅ Passed: $PASS"
echo "⚠️  Warnings: $WARN" 
echo "❌ Failed: $FAIL"

# Recommendations
echo
echo "💡 Security Recommendations:"
echo "• Use 1Password or similar for secret management"
echo "• Rotate API keys and database passwords regularly"
echo "• Use environment-specific secrets (dev/staging/prod)"
echo "• Enable GitHub secret scanning alerts"
echo "• Consider using encrypted secrets for CI/CD"

# Exit codes
if [ $FAIL -gt 0 ]; then
    echo
    echo "🚨 CRITICAL: Security issues found - address before deployment"
    exit 1
elif [ $WARN -gt 0 ]; then
    echo
    echo "⚠️  Warning: Security improvements recommended"
    exit 2
else
    echo
    echo "🎉 Security audit passed - good practices followed"
    exit 0
fi
