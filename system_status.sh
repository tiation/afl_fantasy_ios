#!/bin/bash

echo "🏈 AFL Fantasy System Status"
echo "============================"
echo

# Check Python environment
echo "🐍 Python Environment:"
if [[ -d "venv" ]]; then
    echo "   ✅ Virtual environment exists"
    source venv/bin/activate
    echo "   📦 Python version: $(python --version)"
    echo "   📦 Pip version: $(pip --version | cut -d' ' -f1-2)"
    
    # Check key packages
    echo "   📋 Key packages:"
    pip show selenium webdriver-manager pandas openpyxl flask beautifulsoup4 2>/dev/null | grep -E "Name:|Version:" | paste - - | sed 's/Name: /   ✅ /' | sed 's/ Version: / v/'
else
    echo "   ❌ Virtual environment not found"
fi
echo

# Check scraped data
echo "📊 Scraped Data:"
if [[ -d "dfs_player_summary" ]]; then
    player_count=$(ls -1 dfs_player_summary/*.xlsx 2>/dev/null | wc -l | xargs)
    echo "   ✅ Player files: $player_count"
    
    # Check for recent files (last 7 days)
    recent_files=$(find dfs_player_summary -name "*.xlsx" -mtime -7 2>/dev/null | wc -l | xargs)
    echo "   📅 Recent files (7 days): $recent_files"
    
    # Estimate total size
    if [[ "$player_count" -gt 0 ]]; then
        size=$(du -sh dfs_player_summary 2>/dev/null | cut -f1)
        echo "   💾 Total size: $size"
    fi
else
    echo "   ❌ No scraped data found"
fi
echo

# Check API server status
echo "🔗 API Server:"
if [[ -f "api_server.py" ]]; then
    echo "   ✅ API server file exists"
    if curl -s http://localhost:4000/health > /dev/null 2>&1; then
        echo "   🟢 Server is running (http://localhost:4000)"
        # Get server stats
        health_info=$(curl -s http://localhost:4000/health 2>/dev/null)
        if [[ $? -eq 0 ]] && [[ -n "$health_info" ]]; then
            echo "   📊 Server status: $health_info"
        fi
    else
        echo "   🔴 Server is not running"
        echo "   💡 To start: ./start_api.sh"
    fi
else
    echo "   ❌ API server file not found"
fi
echo

# Check iOS project
echo "📱 iOS Project:"
if [[ -f "AFL Fantasy.xcodeproj/project.pbxproj" ]]; then
    echo "   ✅ Xcode project exists"
    if [[ -d "AFL Fantasy" ]]; then
        swift_files=$(find "AFL Fantasy" -name "*.swift" 2>/dev/null | wc -l | xargs)
        echo "   📝 Swift files: $swift_files"
    fi
else
    echo "   ❌ Xcode project not found"
fi
echo

# Check key scripts
echo "🔧 Available Scripts:"
scripts=("dfs_australia_scraper_full.py" "basic_afl_scraper.py" "analyze_scraped_data.py" "rename_player_files.py" "test_setup.py")
for script in "${scripts[@]}"; do
    if [[ -f "$script" ]]; then
        echo "   ✅ $script"
    else
        echo "   ❌ $script"
    fi
done
echo

# Quick commands reference
echo "⚡ Quick Commands:"
echo "   🚀 Start API server:     ./start_api.sh"
echo "   🔍 Test setup:          source venv/bin/activate && python test_setup.py"
echo "   📊 Run scraper:         source venv/bin/activate && python dfs_australia_scraper_full.py"
echo "   📈 Analyze data:        source venv/bin/activate && python analyze_scraped_data.py"
echo "   🏗️  Build iOS:           open 'AFL Fantasy.xcodeproj'"
echo
echo "🌐 API Endpoints (when server running):"
echo "   • Health:       http://localhost:4000/health"
echo "   • Players:      http://localhost:4000/api/players"
echo "   • Cash Cows:    http://localhost:4000/api/stats/cash-cows"
echo
echo "System check complete! 🎉"
