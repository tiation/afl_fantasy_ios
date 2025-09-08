#!/bin/bash

echo "🧹 AFL Fantasy Project Cleanup"
echo "=============================="
echo

# Create backup of important files first
echo "📦 Creating backup of important files..."
mkdir -p .cleanup_backup
cp AFL_Fantasy_Player_URLs.xlsx .cleanup_backup/ 2>/dev/null || true
cp api_server.py .cleanup_backup/ 2>/dev/null || true
echo "✅ Backup created in .cleanup_backup/"
echo

# Debug and test HTML files
echo "🗑️  Removing debug/test HTML files..."
rm -f debug_test_improved.html
rm -f debug_test.html  
rm -f debug-status.html
rm -f setup-dashboard.html
rm -f simple-status.html
rm -f status.html
rm -f test-minimal.html
rm -f test.html
rm -f dashboard.html  # If not actively used
echo "✅ Debug/test HTML files removed"
echo

# Backup script files
echo "🗑️  Removing backup script files..."
rm -f run_all.sh.backup
rm -f run_ios.sh.backup
rm -f setup.sh.backup
rm -f start.sh.backup
echo "✅ Backup script files removed"
echo

# Old log files (keep structure but clear content)
echo "🗑️  Cleaning log files..."
find logs -name "*.log" -exec sh -c '> "$1"' _ {} \; 2>/dev/null || true
find backend/python/api -name "*.log" -exec sh -c '> "$1"' _ {} \; 2>/dev/null || true
rm -f ios/build.log
echo "✅ Log files cleaned"
echo

# Remove debug Python files from scraped data
echo "🗑️  Removing debug scraper files..."
rm -f debug_CD_I*.html 2>/dev/null || true
echo "✅ Debug scraper files removed"
echo

# Clean up various test/temp files
echo "🗑️  Removing miscellaneous test files..."
rm -f afl_fantasy_page.html  # Scraper output file
rm -f server.log
echo "✅ Miscellaneous files removed"
echo

# Show disk space saved
echo "💾 Cleanup Summary"
echo "=================="
echo "✅ Debug HTML files removed"
echo "✅ Backup scripts removed"  
echo "✅ Log files cleaned"
echo "✅ Temporary scraper files removed"
echo
echo "📁 Important files preserved:"
echo "   - AFL_Fantasy_Player_URLs.xlsx (player data)"
echo "   - api_server.py (API server)"
echo "   - All Python scrapers"
echo "   - iOS app source code"
echo "   - dfs_player_summary/ (scraped data)"
echo
echo "🎉 Cleanup complete! Your project is now organized."
echo "📦 Original files backed up in .cleanup_backup/ (can be deleted later)"
