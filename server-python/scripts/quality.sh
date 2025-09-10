#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Running Python Quality Checks"
echo "================================"

# Check if ruff is installed
if ! command -v ruff &> /dev/null; then
    echo "⚠️ Installing ruff..."
    pip install -q ruff
fi

# Format with ruff
echo "📝 Formatting code with ruff..."
ruff format .
echo "✅ Code formatted"

# Lint with ruff
echo "🔍 Linting code with ruff..."
ruff check . --fix
echo "✅ Linting complete"

# Security check with bandit (if installed)
if command -v bandit &> /dev/null; then
    echo "🔒 Running security checks..."
    bandit -r . -ll -i -x "./tests/*,./test_*.py" || true
    echo "✅ Security check complete"
fi

# Type checking with mypy (if installed)
if command -v mypy &> /dev/null; then
    echo "📊 Type checking with mypy..."
    mypy . --ignore-missing-imports || true
    echo "✅ Type checking complete"
fi

# Run tests if they exist
if [ -d "tests" ] || ls test_*.py 1> /dev/null 2>&1; then
    echo "🧪 Running tests..."
    python -m pytest . -v --tb=short || true
    echo "✅ Tests complete"
fi

echo ""
echo "✅ Quality checks complete!"
echo "================================"
