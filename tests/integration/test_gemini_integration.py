#!/usr/bin/env python3
"""
Gemini Integration Test Suite

Direct testing of Gemini API integration and fallback mechanisms.
Tests the Python backend components directly.
"""

import os
import sys
import json
import time
import asyncio
from datetime import datetime
from typing import Dict, List, Any

# Add the backend directory to the Python path
sys.path.append('backend/python/tools')

try:
    import gemini_tools
    import ai_tools
    GEMINI_AVAILABLE = True
except ImportError as e:
    print(f"Warning: Could not import tools: {e}")
    GEMINI_AVAILABLE = False


class GeminiIntegrationTest:
    """Test suite for Gemini API integration"""
    
    def __init__(self):
        self.results = {
            'gemini_tests': [],
            'fallback_tests': [],
            'performance_metrics': {},
            'errors': []
        }
        
        # Set the API key from the environment
        self.api_key = os.getenv('GEMINI_API_KEY')
        if not self.api_key:
            print("⚠️  Warning: GEMINI_API_KEY not set in environment")
    
    def log_test_result(self, test_name: str, success: bool, response_time: float, details: Dict[str, Any]):
        """Log test result with metrics"""
        result = {
            'test_name': test_name,
            'success': success,
            'response_time': response_time,
            'timestamp': datetime.now().isoformat(),
            'details': details
        }
        
        if 'gemini' in test_name.lower():
            self.results['gemini_tests'].append(result)
        else:
            self.results['fallback_tests'].append(result)
        
        status = "✅ PASS" if success else "❌ FAIL"
        print(f"{status} {test_name} ({response_time:.2f}ms)")
        if not success and 'error' in details:
            print(f"     Error: {details['error']}")
    
    def test_gemini_connection(self):
        """Test basic Gemini API connectivity"""
        print("\n🧪 Testing Gemini API Connection...")
        
        start_time = time.time()
        try:
            result = gemini_tools.test_gemini_connection()
            response_time = (time.time() - start_time) * 1000
            
            success = result.get('status') == 'success'
            self.log_test_result(
                'Gemini API Connection',
                success,
                response_time,
                {'response': result}
            )
            
            if success:
                print(f"     Model: {result.get('model', 'unknown')}")
                print(f"     Response: {result.get('response', '')[:100]}...")
            
            return success
            
        except Exception as e:
            response_time = (time.time() - start_time) * 1000
            self.log_test_result(
                'Gemini API Connection',
                False,
                response_time,
                {'error': str(e)}
            )
            return False
    
    def test_gemini_trade_analysis(self):
        """Test Gemini trade analysis functionality"""
        print("\n🧪 Testing Gemini Trade Analysis...")
        
        # Sample player data for testing
        sample_players = [
            {"name": "Marcus Bontempelli", "team": "Western Bulldogs", "position": "MID", "price": 750000, "average": 110},
            {"name": "Clayton Oliver", "team": "Melbourne", "position": "MID", "price": 720000, "average": 105},
            {"name": "Sam Docherty", "team": "Carlton", "position": "DEF", "price": 650000, "average": 95}
        ]
        
        current_team = ["Marcus Bontempelli", "Clayton Oliver"]
        
        start_time = time.time()
        try:
            result = gemini_tools.get_gemini_trade_analysis(sample_players, current_team)
            response_time = (time.time() - start_time) * 1000
            
            success = result.get('status') == 'success'
            self.log_test_result(
                'Gemini Trade Analysis',
                success,
                response_time,
                {'response': result}
            )
            
            if success and 'data' in result:
                data = result['data']
                if isinstance(data, dict) and 'trade_recommendations' in data:
                    print(f"     Generated {len(data['trade_recommendations'])} trade recommendations")
                elif 'analysis' in data:
                    print(f"     Analysis length: {len(data['analysis'])} characters")
            
            return success
            
        except Exception as e:
            response_time = (time.time() - start_time) * 1000
            self.log_test_result(
                'Gemini Trade Analysis',
                False,
                response_time,
                {'error': str(e)}
            )
            return False
    
    def test_gemini_captain_selection(self):
        """Test Gemini captain selection functionality"""
        print("\n🧪 Testing Gemini Captain Selection...")
        
        sample_players = [
            {"name": "Touk Miller", "team": "Gold Coast", "position": "MID", "average": 115, "ownership": 45},
            {"name": "Daicos", "team": "Collingwood", "position": "MID", "average": 108, "ownership": 65},
            {"name": "Grundy", "team": "Melbourne", "position": "RUC", "average": 95, "ownership": 35}
        ]
        
        round_info = {"round": 12, "weather": "fine", "venue": "MCG"}
        
        start_time = time.time()
        try:
            result = gemini_tools.get_gemini_captain_advice(sample_players, round_info)
            response_time = (time.time() - start_time) * 1000
            
            success = result.get('status') == 'success'
            self.log_test_result(
                'Gemini Captain Selection',
                success,
                response_time,
                {'response': result}
            )
            
            if success and 'data' in result:
                data = result['data']
                if isinstance(data, dict) and 'captain_recommendations' in data:
                    print(f"     Generated {len(data['captain_recommendations'])} captain recommendations")
                elif 'analysis' in data:
                    print(f"     Analysis length: {len(data['analysis'])} characters")
            
            return success
            
        except Exception as e:
            response_time = (time.time() - start_time) * 1000
            self.log_test_result(
                'Gemini Captain Selection',
                False,
                response_time,
                {'error': str(e)}
            )
            return False
    
    def test_fallback_mechanisms(self):
        """Test OpenAI fallback functionality"""
        print("\n🧪 Testing Fallback Mechanisms...")
        
        # Test AI tools fallback functions
        fallback_functions = [
            ('ai_trade_suggester', ai_tools.ai_trade_suggester),
            ('ai_captain_advisor', ai_tools.ai_captain_advisor),
            ('team_structure_analyzer', ai_tools.team_structure_analyzer),
            ('ownership_risk_monitor', ai_tools.ownership_risk_monitor),
            ('form_vs_price_scanner', ai_tools.form_vs_price_scanner)
        ]
        
        fallback_results = []
        
        for func_name, func in fallback_functions:
            start_time = time.time()
            try:
                result = func()
                response_time = (time.time() - start_time) * 1000
                
                success = result.get('status') == 'ok'
                self.log_test_result(
                    f'Fallback {func_name}',
                    success,
                    response_time,
                    {'response': result}
                )
                
                fallback_results.append(success)
                
            except Exception as e:
                response_time = (time.time() - start_time) * 1000
                self.log_test_result(
                    f'Fallback {func_name}',
                    False,
                    response_time,
                    {'error': str(e)}
                )
                fallback_results.append(False)
        
        return all(fallback_results)
    
    def test_gemini_with_invalid_key(self):
        """Test Gemini behavior with invalid API key"""
        print("\n🧪 Testing Gemini with Invalid API Key...")
        
        # Temporarily set invalid API key
        original_key = os.environ.get('GEMINI_API_KEY')
        os.environ['GEMINI_API_KEY'] = 'invalid_key_for_testing'
        
        start_time = time.time()
        try:
            result = gemini_tools.test_gemini_connection()
            response_time = (time.time() - start_time) * 1000
            
            # We expect this to fail gracefully
            success = result.get('status') == 'error'
            self.log_test_result(
                'Gemini Invalid Key Handling',
                success,
                response_time,
                {'response': result}
            )
            
            if success:
                print("     ✅ Correctly handled invalid API key")
            
        except Exception as e:
            response_time = (time.time() - start_time) * 1000
            # Exception handling is also acceptable
            success = True
            self.log_test_result(
                'Gemini Invalid Key Handling',
                success,
                response_time,
                {'error': str(e), 'note': 'Exception handling acceptable'}
            )
        
        finally:
            # Restore original API key
            if original_key:
                os.environ['GEMINI_API_KEY'] = original_key
            elif 'GEMINI_API_KEY' in os.environ:
                del os.environ['GEMINI_API_KEY']
        
        return True
    
    def performance_benchmark(self):
        """Run performance benchmarks"""
        print("\n🚀 Running Performance Benchmarks...")
        
        # Test multiple rapid requests
        benchmark_tests = [
            ('Gemini Trade Analysis', lambda: gemini_tools.get_gemini_trade_analysis([], [])),
            ('AI Trade Fallback', ai_tools.ai_trade_suggester),
            ('AI Captain Fallback', ai_tools.ai_captain_advisor)
        ]
        
        for test_name, test_func in benchmark_tests:
            times = []
            successes = 0
            
            print(f"   Running {test_name} benchmark (5 iterations)...")
            
            for i in range(5):
                start_time = time.time()
                try:
                    result = test_func()
                    response_time = (time.time() - start_time) * 1000
                    times.append(response_time)
                    
                    if result.get('status') in ['success', 'ok']:
                        successes += 1
                        
                except Exception as e:
                    response_time = (time.time() - start_time) * 1000
                    times.append(response_time)
                    print(f"     Iteration {i+1} failed: {e}")
            
            if times:
                avg_time = sum(times) / len(times)
                min_time = min(times)
                max_time = max(times)
                
                self.results['performance_metrics'][test_name] = {
                    'avg_response_time': avg_time,
                    'min_response_time': min_time,
                    'max_response_time': max_time,
                    'success_rate': (successes / 5) * 100,
                    'total_iterations': 5
                }
                
                print(f"     Avg: {avg_time:.2f}ms, Min: {min_time:.2f}ms, Max: {max_time:.2f}ms")
                print(f"     Success Rate: {(successes / 5) * 100:.1f}%")
    
    def generate_report(self):
        """Generate comprehensive test report"""
        print("\n" + "="*80)
        print("📊 GEMINI INTEGRATION TEST REPORT")
        print("="*80)
        
        # Test summary
        gemini_successes = sum(1 for test in self.results['gemini_tests'] if test['success'])
        gemini_total = len(self.results['gemini_tests'])
        fallback_successes = sum(1 for test in self.results['fallback_tests'] if test['success'])
        fallback_total = len(self.results['fallback_tests'])
        
        print(f"\n🔮 Gemini API Tests: {gemini_successes}/{gemini_total} passed")
        if gemini_total > 0:
            gemini_avg_time = sum(test['response_time'] for test in self.results['gemini_tests']) / gemini_total
            print(f"   Average Response Time: {gemini_avg_time:.2f}ms")
        
        print(f"\n🔄 Fallback Tests: {fallback_successes}/{fallback_total} passed")
        if fallback_total > 0:
            fallback_avg_time = sum(test['response_time'] for test in self.results['fallback_tests']) / fallback_total
            print(f"   Average Response Time: {fallback_avg_time:.2f}ms")
        
        # Performance metrics
        if self.results['performance_metrics']:
            print(f"\n🚀 Performance Benchmarks:")
            for test_name, metrics in self.results['performance_metrics'].items():
                print(f"   {test_name}:")
                print(f"     Average: {metrics['avg_response_time']:.2f}ms")
                print(f"     Range: {metrics['min_response_time']:.2f}ms - {metrics['max_response_time']:.2f}ms")
                print(f"     Success Rate: {metrics['success_rate']:.1f}%")
        
        # Overall assessment
        total_tests = gemini_total + fallback_total
        total_successes = gemini_successes + fallback_successes
        
        print(f"\n✅ Overall Results:")
        print(f"   Total Tests: {total_tests}")
        print(f"   Success Rate: {(total_successes/total_tests*100):.1f}%" if total_tests > 0 else "   No tests completed")
        print(f"   Gemini Integration: {'✅ WORKING' if gemini_successes > 0 else '❌ NEEDS ATTENTION'}")
        print(f"   Fallback Logic: {'✅ WORKING' if fallback_successes > 0 else '❌ NEEDS ATTENTION'}")
        
        # Recommendations
        print(f"\n💡 Recommendations:")
        if gemini_successes == 0 and gemini_total > 0:
            print("   - Check Gemini API key configuration")
            print("   - Verify network connectivity to Google's servers")
        if fallback_successes == 0 and fallback_total > 0:
            print("   - Review fallback implementation")
            print("   - Check Python dependencies")
        if gemini_successes > 0 and fallback_successes > 0:
            print("   - Integration is working well!")
            print("   - Consider monitoring costs and usage patterns")
        
        print("\n" + "="*80)
        
        # Save detailed results to file
        with open('tests/integration/gemini_test_results.json', 'w') as f:
            json.dump(self.results, f, indent=2, default=str)
        print("📄 Detailed results saved to tests/integration/gemini_test_results.json")
    
    def run_full_test_suite(self):
        """Run the complete test suite"""
        print("🚀 Starting Gemini Integration Test Suite")
        print(f"📋 Configuration:")
        print(f"   API Key: {'✅ SET' if self.api_key else '❌ MISSING'}")
        print(f"   Gemini Tools: {'✅ AVAILABLE' if GEMINI_AVAILABLE else '❌ UNAVAILABLE'}")
        
        if not GEMINI_AVAILABLE:
            print("❌ Cannot run tests - Gemini tools not available")
            return
        
        # Core functionality tests
        self.test_gemini_connection()
        self.test_gemini_trade_analysis()
        self.test_gemini_captain_selection()
        
        # Fallback mechanism tests
        self.test_fallback_mechanisms()
        
        # Error handling tests
        self.test_gemini_with_invalid_key()
        
        # Performance benchmarks
        self.performance_benchmark()
        
        # Generate comprehensive report
        self.generate_report()


if __name__ == "__main__":
    # Set the API key from command line argument or environment
    if len(sys.argv) > 1:
        os.environ['GEMINI_API_KEY'] = sys.argv[1]
    
    tester = GeminiIntegrationTest()
    tester.run_full_test_suite()
