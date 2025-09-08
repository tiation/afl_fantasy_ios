#!/usr/bin/env bash
set -euo pipefail

# AFL Fantasy Project Consolidation Script
# Following iOS standards from rules

echo "🏆 Starting AFL Fantasy Project Consolidation..."

# Check prerequisites
command -v xcodebuild >/dev/null 2>&1 || { echo "❌ Xcode command line tools required"; exit 1; }

# Create backup
BACKUP_DIR="backups/consolidation_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo "📦 Creating backup in $BACKUP_DIR..."

# Backup existing projects
cp -R "AFL Fantasy.xcodeproj" "$BACKUP_DIR/" 2>/dev/null || true
cp -R "ios/" "$BACKUP_DIR/" 2>/dev/null || true
cp -R "AFLFantasyProWidget/" "$BACKUP_DIR/" 2>/dev/null || true

echo "✅ Backup complete"

# Create new unified structure
echo "🏗️ Creating unified project structure..."

# Create new consolidated directory structure
mkdir -p "AFL_Fantasy_Unified/"{Sources,Tests,Resources,Scripts,Widget}
mkdir -p "AFL_Fantasy_Unified/Sources/"{Free,Pro,Shared}
mkdir -p "AFL_Fantasy_Unified/Sources/Shared/"{Views,Models,Services,Network,Theme,Extensions}
mkdir -p "AFL_Fantasy_Unified/Tests/"{Unit,Integration,UI}

echo "📁 Directory structure created"

# This script sets up the framework - actual migration happens in next steps
echo "✅ Consolidation framework ready"
echo "Next: Run Swift migration and project setup"
