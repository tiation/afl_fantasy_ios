#!/bin/bash
set -eo pipefail

# AFL Fantasy Environment Security Audit Script
# Similar to Hostinger workflow - ensures secrets are properly managed

echo "🔒 AFL Fantasy Environment Security Audit"
echo "=" $(printf '%*s' 50 '' | tr ' ' '=')

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASS=0
WARN=0
FAIL=0

# Helper functions
pass() {
    echo -e "   ${GREEN}✅ $1${NC}"
    ((PASS++))
}

warn() {
    echo -e "   ${YELLOW}⚠️  $1${NC}"
    ((WARN++))
}

fail() {
    echo -e "   ${RED}❌ $1${NC}"
    ((FAIL++))
}

echo
echo "📋 Checking Git repository configuration..."

# Check if .env is in .gitignore
if git check-ignore .env >/dev/null 2>&1; then
    pass ".env file is properly ignored by git"
else
    if [ -f .env ]; then
        fail ".env file exists but is NOT ignored by git - SECURITY RISK!"
        echo "      💡 Add '.env' to .gitignore immediately"
    else
        warn ".env file doesn't exist (using .env.example only)"
    fi
fi

# Check if any .env files are tracked
if git ls-files | grep -E '\.env$|\.env\.' | grep -v '\.env\.example' >/dev/null 2>&1; then
    fail "Found .env files tracked by git:"
    git ls-files | grep -E '\.env$|\.env\.' | grep -v '\.env\.example' | sed 's/^/      /'
else
    pass "No .env files are tracked by git"
fi

# Check for secrets in git history (recent commits)
echo
echo "🔍 Scanning recent commits for potential secrets..."
secret_patterns=(
    "password.*="
    "secret.*="
    "key.*="
    "token.*="
    "api.*key"
    "[A-Za-z0-9]{32,}"  # Long strings that might be keys
)

found_secrets=0
for pattern in "${secret_patterns[@]}"; do
    if git log --oneline -10 --grep="$pattern" -i | head -3 | grep -q .; then
        warn "Found potential secrets pattern '$pattern' in recent commit messages"
        ((found_secrets++))
    fi
done

if [ $found_secrets -eq 0 ]; then
    pass "No obvious secret patterns found in recent commit messages"
fi

echo
echo "📁 Checking environment file structure..."

# Check .env.example exists
if [ -f .env.example ]; then
    pass ".env.example template exists"
    
    # Count variables in .env.example
    env_vars=$(grep -c "^[A-Z_].*=" .env.example || echo "0")
    echo "      📊 Template contains $env_vars environment variables"
else
    warn ".env.example template file is missing"
fi

# Check actual .env file
if [ -f .env ]; then
    pass ".env file exists"
    
    # Check permissions
    env_perms=$(stat -f "%A" .env 2>/dev/null || stat -c "%a" .env 2>/dev/null || echo "unknown")
    if [ "$env_perms" = "600" ] || [ "$env_perms" = "644" ]; then
        pass ".env file has appropriate permissions ($env_perms)"
    else
        warn ".env file permissions: $env_perms (consider 600 for better security)"
    fi
    
    # Check for placeholder values
    if grep -E "(your_|placeholder|example|changeme)" .env >/dev/null 2>&1; then
        warn "Found placeholder values in .env - ensure all secrets are real:"
        grep -E "(your_|placeholder|example|changeme)" .env | sed 's/^/      /'
    else
        pass "No obvious placeholder values found in .env"
    fi
    
    # Check for empty values
    empty_vars=$(grep -E "^[A-Z_].*=$" .env | wc -l || echo "0")
    if [ "$empty_vars" -gt 0 ]; then
        warn "$empty_vars environment variables have empty values"
        grep -E "^[A-Z_].*=$" .env | cut -d'=' -f1 | sed 's/^/      - /'
    else
        pass "All environment variables have values"
    fi
    
else
    fail ".env file is missing - copy from .env.example and configure"
fi

echo
echo "🔐 Checking for sensitive data patterns..."

# Check for common secrets that shouldn't be in plaintext
sensitive_files=(
    ".env"
    "*.json"
    "*.yaml" 
    "*.yml"
    "*.js"
    "*.ts"
    "*.py"
)

for file_pattern in "${sensitive_files[@]}"; do
    if find . -name "$file_pattern" -type f -not -path './node_modules/*' -not -path './.git/*' -exec grep -l "sk-[a-zA-Z0-9]" {} \; 2>/dev/null | head -1 | grep -q .; then
        fail "Found OpenAI API key pattern in: $(find . -name "$file_pattern" -type f -not -path './node_modules/*' -not -path './.git/*' -exec grep -l "sk-[a-zA-Z0-9]" {} \; 2>/dev/null | head -1)"
    fi
done

# Check for hardcoded database URLs with credentials
if find . -name "*.js" -o -name "*.ts" -o -name "*.py" | xargs grep -l "postgresql://.*:.*@" 2>/dev/null | grep -v node_modules | head -1 | grep -q .; then
    warn "Found hardcoded database URLs with credentials in source code"
    find . -name "*.js" -o -name "*.ts" -o -name "*.py" | xargs grep -l "postgresql://.*:.*@" 2>/dev/null | grep -v node_modules | head -3 | sed 's/^/      /'
else
    pass "No hardcoded database credentials found in source code"
fi

echo
echo "📦 Checking CI/CD configuration..."

# Check GitHub Actions
if [ -d .github/workflows ]; then
    pass "GitHub Actions workflows directory exists"
    
    # Check for OP_CONNECT_TOKEN references
    if find .github/workflows -name "*.yml" -exec grep -l "OP_CONNECT_TOKEN" {} \; 2>/dev/null | head -1 | grep -q .; then
        pass "Found 1Password Connect token references in CI"
    else
        warn "No 1Password Connect token (OP_CONNECT_TOKEN) found in CI workflows"
    fi
    
    # Check for secrets in workflow files
    if find .github/workflows -name "*.yml" -exec grep -l "\${{.*secrets\." {} \; 2>/dev/null | head -1 | grep -q .; then
        pass "GitHub Actions using GitHub secrets (good practice)"
    else
        warn "No GitHub secrets usage found in workflows"
    fi
else
    warn "No GitHub Actions workflows found"
fi

echo
echo "🛡️  Security recommendations..."

if [ -f .env ]; then
    # Check for common security issues
    if grep -q "localhost" .env && grep -q "password" .env; then
        warn "Using localhost with password - ensure this is only for development"
    fi
    
    if grep -q "admin" .env; then
        warn "Found 'admin' in .env - avoid default usernames in production"
    fi
fi

echo
echo "📊 Audit Summary"
echo "=================="
echo -e "${GREEN}✅ Passed: $PASS${NC}"
echo -e "${YELLOW}⚠️  Warnings: $WARN${NC}" 
echo -e "${RED}❌ Failed: $FAIL${NC}"

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
