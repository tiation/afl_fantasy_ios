#!/usr/bin/env bash
set -euo pipefail

echo "📦 Starting Swift source migration..."

UNIFIED_DIR="AFL_Fantasy_Unified"
SHARED_DIR="$UNIFIED_DIR/Sources/Shared"

# Migrate main project source files to shared
echo "🔄 Migrating main project sources..."

# Copy Views
cp -R "AFL Fantasy/Views/" "$SHARED_DIR/Views/"
echo "✅ Views migrated"

# Copy Models  
cp "AFL Fantasy/Models/Models.swift" "$SHARED_DIR/Models/"
echo "✅ Models migrated"

# Copy Services
cp -R "AFL Fantasy/Services/" "$SHARED_DIR/Services/"
echo "✅ Services migrated"

# Copy Network
cp -R "AFL Fantasy/Network/" "$SHARED_DIR/Network/"
echo "✅ Network migrated"

# Copy Theme
cp -R "AFL Fantasy/Theme/" "$SHARED_DIR/Theme/"
echo "✅ Theme migrated"

# Copy Extensions
cp -R "AFL Fantasy/Extensions/" "$SHARED_DIR/Extensions/"
echo "✅ Extensions migrated"

# Copy main app file
cp "AFL Fantasy/AFLFantasyApp.swift" "$SHARED_DIR/"
cp "AFL Fantasy/ContentView.swift" "$SHARED_DIR/" 2>/dev/null || true

# Copy resources
mkdir -p "$UNIFIED_DIR/Resources"
cp -R "AFL Fantasy/Resources/" "$UNIFIED_DIR/Resources/" 2>/dev/null || true

# Copy Widget extension
cp -R "AFLFantasyProWidget/" "$UNIFIED_DIR/Widget/" 2>/dev/null || true

# Copy tests
cp -R "AFL Fantasy Tests/" "$UNIFIED_DIR/Tests/Unit/" 2>/dev/null || true

echo "✅ Source migration complete"
echo "📁 All files copied to $UNIFIED_DIR"
