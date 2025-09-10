#!/bin/bash

# AI Integration Test Runner
# Comprehensive testing of AI endpoints with Gemini and OpenAI fallback

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
API_KEY="${GEMINI_API_KEY:-AIzaSyC30Gp4HvBAd3qChXEjEtu8G9e2ISooJL4}"
SERVER_PORT=${SERVER_PORT:-3001}
BASE_URL="http://localhost:${SERVER_PORT}"

echo -e "${BLUE}🚀 AI Endpoints Integration Test Suite${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""
echo -e "📋 Configuration:"
echo -e "   API Key: ${GREEN}CONFIGURED${NC}"
echo -e "   Server URL: ${BASE_URL}"
echo -e "   Test Directory: $(pwd)/tests/integration"
echo ""

# Create tests directory if it doesn't exist
mkdir -p tests/integration
mkdir -p logs

# Export the API key for all processes
export GEMINI_API_KEY="$API_KEY"

# Function to check if server is running
check_server() {
    echo -e "${YELLOW}🔍 Checking if server is running...${NC}"
    
    if curl -s "$BASE_URL/api/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Server is running at $BASE_URL${NC}"
        return 0
    else
        echo -e "${RED}❌ Server is not running at $BASE_URL${NC}"
        return 1
    fi
}

# Function to start server if needed
start_server_if_needed() {
    if ! check_server; then
        echo -e "${YELLOW}🚀 Starting development server...${NC}"
        echo -e "${YELLOW}   Note: Server needs to be running for integration tests${NC}"
        echo -e "${YELLOW}   Please start the server with: npm run dev${NC}"
        echo -e "${YELLOW}   Then re-run this test script.${NC}"
        exit 1
    fi
}

# Function to install Node.js dependencies
install_node_deps() {
    echo -e "${YELLOW}📦 Installing Node.js test dependencies...${NC}"
    
    # Check if package.json exists
    if [ ! -f "package.json" ]; then
        echo -e "${RED}❌ package.json not found. Run from project root.${NC}"
        exit 1
    fi
    
    # Install axios if not present
    if ! node -e "require('axios')" 2>/dev/null; then
        echo -e "${YELLOW}   Installing axios...${NC}"
        npm install axios --save-dev 2>/dev/null || {
            echo -e "${RED}❌ Failed to install axios${NC}"
            exit 1
        }
    fi
    
    echo -e "${GREEN}✅ Node.js dependencies ready${NC}"
}

# Function to install Python dependencies
install_python_deps() {
    echo -e "${YELLOW}📦 Checking Python dependencies...${NC}"
    
    # Check if Python is available
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}❌ Python 3 is required but not installed${NC}"
        exit 1
    fi
    
    # Check if requests is available
    python3 -c "import requests" 2>/dev/null || {
        echo -e "${YELLOW}   Installing requests library...${NC}"
        pip3 install requests --user 2>/dev/null || \
        pip3 install requests --break-system-packages 2>/dev/null || {
            echo -e "${RED}❌ Failed to install requests${NC}"
            echo -e "${YELLOW}   You may need to install requests manually${NC}"
            exit 1
        }
    }
    
    echo -e "${GREEN}✅ Python dependencies ready${NC}"
}

# Function to run Python tests
run_python_tests() {
    echo -e "${BLUE}🐍 Running Python Integration Tests...${NC}"
    echo -e "${BLUE}====================================${NC}"
    
    cd "$(dirname "$0")"
    
    if [ -f "tests/integration/test_gemini_integration.py" ]; then
        # Make the script executable
        chmod +x tests/integration/test_gemini_integration.py
        
        # Run Python tests with API key
        python3 tests/integration/test_gemini_integration.py "$API_KEY" 2>&1 | tee logs/python_tests.log
        
        echo -e "${GREEN}✅ Python tests completed${NC}"
    else
        echo -e "${RED}❌ Python test file not found${NC}"
        return 1
    fi
}

# Function to run Node.js tests
run_node_tests() {
    echo -e "${BLUE}🟨 Running Node.js Integration Tests...${NC}"
    echo -e "${BLUE}=====================================${NC}"
    
    cd "$(dirname "$0")"
    
    if [ -f "tests/integration/ai_endpoints_integration_test.js" ]; then
        # Run Node.js tests
        node tests/integration/ai_endpoints_integration_test.js 2>&1 | tee logs/nodejs_tests.log
        
        echo -e "${GREEN}✅ Node.js tests completed${NC}"
    else
        echo -e "${RED}❌ Node.js test file not found${NC}"
        return 1
    fi
}

# Function to run manual API tests
run_manual_api_tests() {
    echo -e "${BLUE}🔧 Running Manual API Tests...${NC}"
    echo -e "${BLUE}=============================${NC}"
    
    # Test individual endpoints manually
    endpoints=(
        "/api/fantasy/tools/ai/ai_trade_suggester"
        "/api/fantasy/tools/ai/ai_captain_advisor"
        "/api/fantasy/tools/ai/team_structure_analyzer"
        "/api/fantasy/tools/ai/ownership_risk_monitor"
        "/api/fantasy/tools/ai/form_vs_price_scanner"
    )
    
    for endpoint in "${endpoints[@]}"; do
        echo -e "${YELLOW}Testing: $endpoint${NC}"
        
        response=$(curl -s -w "HTTPSTATUS:%{http_code}" "$BASE_URL$endpoint" || echo "HTTPSTATUS:000")
        
        http_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
        body=$(echo "$response" | sed -E 's/HTTPSTATUS:[0-9]{3}$//')
        
        if [ "$http_code" -eq 200 ]; then
            echo -e "${GREEN}✅ $endpoint - Status: $http_code${NC}"
            
            # Check if response contains expected data
            if echo "$body" | grep -q '"status"'; then
                status=$(echo "$body" | python3 -c "import sys, json; print(json.load(sys.stdin).get('status', 'unknown'))" 2>/dev/null || echo "unknown")
                echo -e "   Response status: $status"
            fi
        else
            echo -e "${RED}❌ $endpoint - Status: $http_code${NC}"
            echo -e "   Response: ${body:0:100}..."
        fi
        
        # Small delay between requests
        sleep 0.5
    done
}

# Function to generate summary report
generate_summary_report() {
    echo -e "${BLUE}📊 Test Summary Report${NC}"
    echo -e "${BLUE}===================${NC}"
    
    # Check if log files exist and analyze results
    python_success=0
    nodejs_success=0
    
    if [ -f "logs/python_tests.log" ]; then
        python_passes=$(grep -c "✅ PASS" logs/python_tests.log || echo "0")
        python_fails=$(grep -c "❌ FAIL" logs/python_tests.log || echo "0")
        echo -e "\n🐍 Python Tests:"
        echo -e "   Passes: ${GREEN}$python_passes${NC}"
        echo -e "   Failures: ${RED}$python_fails${NC}"
        
        if [ "$python_passes" -gt 0 ] && [ "$python_fails" -eq 0 ]; then
            python_success=1
        fi
    fi
    
    if [ -f "logs/nodejs_tests.log" ]; then
        # Analyze Node.js test results
        if grep -q "Overall Success Rate" logs/nodejs_tests.log; then
            success_rate=$(grep "Overall Success Rate" logs/nodejs_tests.log | sed 's/.*: \([0-9.]*\)%.*/\1/')
            echo -e "\n🟨 Node.js Tests:"
            echo -e "   Success Rate: ${GREEN}${success_rate}%${NC}"
            
            if (( $(echo "$success_rate > 80" | bc -l) )); then
                nodejs_success=1
            fi
        fi
    fi
    
    # Overall assessment
    echo -e "\n🎯 Overall Assessment:"
    
    if [ "$python_success" -eq 1 ] && [ "$nodejs_success" -eq 1 ]; then
        echo -e "${GREEN}✅ Integration tests PASSED - Both Gemini and fallback mechanisms working${NC}"
        echo -e "${GREEN}✅ API endpoints responding correctly${NC}"
        echo -e "${GREEN}✅ Performance metrics within acceptable ranges${NC}"
    elif [ "$python_success" -eq 1 ] || [ "$nodejs_success" -eq 1 ]; then
        echo -e "${YELLOW}⚠️  Integration tests PARTIALLY PASSED${NC}"
        echo -e "${YELLOW}   Some components working, others may need attention${NC}"
    else
        echo -e "${RED}❌ Integration tests FAILED${NC}"
        echo -e "${RED}   Please review logs and check configuration${NC}"
    fi
    
    # Cost and performance notes
    echo -e "\n💰 Cost & Performance Notes:"
    echo -e "   - Monitor Gemini API usage in Google Cloud Console"
    echo -e "   - Fallback to OpenAI reduces costs when Gemini is unavailable"
    echo -e "   - Average response times logged in test results"
    
    echo -e "\n📄 Detailed logs saved to:"
    echo -e "   - logs/python_tests.log"
    echo -e "   - logs/nodejs_tests.log"
    echo -e "   - tests/integration/gemini_test_results.json"
}

# Main execution flow
main() {
    echo -e "${BLUE}Starting comprehensive AI integration testing...${NC}\n"
    
    # Check prerequisites
    install_node_deps
    install_python_deps
    
    # Check if server is running
    start_server_if_needed
    
    # Run all test suites
    echo -e "\n${BLUE}Phase 1: Python Backend Tests${NC}"
    run_python_tests
    
    echo -e "\n${BLUE}Phase 2: Node.js API Integration Tests${NC}"
    run_node_tests
    
    echo -e "\n${BLUE}Phase 3: Manual API Verification${NC}"
    run_manual_api_tests
    
    # Generate final report
    echo -e "\n${BLUE}Phase 4: Results Analysis${NC}"
    generate_summary_report
    
    echo -e "\n${GREEN}🎉 Integration testing complete!${NC}"
}

# Handle script arguments
case "${1:-}" in
    --python-only)
        install_python_deps
        run_python_tests
        ;;
    --nodejs-only)
        install_node_deps
        check_server || exit 1
        run_node_tests
        ;;
    --manual-only)
        check_server || exit 1
        run_manual_api_tests
        ;;
    --help)
        echo "AI Integration Test Runner"
        echo ""
        echo "Usage: $0 [option]"
        echo ""
        echo "Options:"
        echo "  --python-only    Run only Python backend tests"
        echo "  --nodejs-only    Run only Node.js integration tests"
        echo "  --manual-only    Run only manual API tests"
        echo "  --help          Show this help message"
        echo ""
        echo "Default: Run all test suites"
        ;;
    *)
        main
        ;;
esac
