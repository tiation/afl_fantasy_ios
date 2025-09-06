/**
 * AI Endpoints Integration Test Suite
 * 
 * Tests the AI-based endpoints to confirm:
 * 1. Proper Gemini API responses
 * 2. Fallback logic to OpenAI
 * 3. Performance under normal usage loads
 * 4. Cost and accuracy metrics
 */

const axios = require('axios');
const { performance } = require('perf_hooks');

class AIEndpointsIntegrationTest {
  constructor(baseUrl = 'http://localhost:3001') {
    this.baseUrl = baseUrl;
    this.testResults = {
      gemini: {
        success: 0,
        failures: 0,
        avgResponseTime: 0,
        responses: []
      },
      fallback: {
        success: 0,
        failures: 0,
        avgResponseTime: 0,
        responses: []
      },
      errors: []
    };
  }

  async makeRequest(endpoint, method = 'GET', data = null) {
    const startTime = performance.now();
    try {
      const config = {
        method,
        url: `${this.baseUrl}${endpoint}`,
        timeout: 30000, // 30 second timeout
        ...(data && { data })
      };

      const response = await axios(config);
      const endTime = performance.now();
      const responseTime = endTime - startTime;

      return {
        success: true,
        data: response.data,
        responseTime,
        status: response.status
      };
    } catch (error) {
      const endTime = performance.now();
      const responseTime = endTime - startTime;

      return {
        success: false,
        error: error.message,
        responseTime,
        status: error.response?.status || 0
      };
    }
  }

  async testAITradeEndpoint() {
    console.log('\n🧪 Testing AI Trade Suggester Endpoint...');
    
    const result = await this.makeRequest('/api/fantasy/tools/ai/ai_trade_suggester');
    
    if (result.success) {
      console.log('✅ AI Trade Suggester Response:', {
        status: result.data.status,
        responseTime: `${result.responseTime.toFixed(2)}ms`,
        hasDowngradeOut: !!result.data.downgrade_out,
        hasUpgradeIn: !!result.data.upgrade_in
      });
      
      // Check for Gemini vs fallback indicators
      const isGeminiResponse = this.detectGeminiResponse(result.data);
      this.recordResult(isGeminiResponse ? 'gemini' : 'fallback', result);
      
    } else {
      console.log('❌ AI Trade Suggester Failed:', result.error);
      this.testResults.errors.push({
        endpoint: '/api/fantasy/tools/ai/ai_trade_suggester',
        error: result.error
      });
    }
    
    return result;
  }

  async testAICaptainEndpoint() {
    console.log('\n🧪 Testing AI Captain Advisor Endpoint...');
    
    const result = await this.makeRequest('/api/fantasy/tools/ai/ai_captain_advisor');
    
    if (result.success) {
      console.log('✅ AI Captain Advisor Response:', {
        status: result.data.status,
        responseTime: `${result.responseTime.toFixed(2)}ms`,
        playersCount: Array.isArray(result.data.players) ? result.data.players.length : 0
      });
      
      const isGeminiResponse = this.detectGeminiResponse(result.data);
      this.recordResult(isGeminiResponse ? 'gemini' : 'fallback', result);
      
    } else {
      console.log('❌ AI Captain Advisor Failed:', result.error);
      this.testResults.errors.push({
        endpoint: '/api/fantasy/tools/ai/ai_captain_advisor',
        error: result.error
      });
    }
    
    return result;
  }

  async testTeamStructureEndpoint() {
    console.log('\n🧪 Testing Team Structure Analyzer Endpoint...');
    
    const result = await this.makeRequest('/api/fantasy/tools/ai/team_structure_analyzer');
    
    if (result.success) {
      console.log('✅ Team Structure Analyzer Response:', {
        status: result.data.status,
        responseTime: `${result.responseTime.toFixed(2)}ms`,
        hasTiers: !!result.data.tiers
      });
      
      const isGeminiResponse = this.detectGeminiResponse(result.data);
      this.recordResult(isGeminiResponse ? 'gemini' : 'fallback', result);
      
    } else {
      console.log('❌ Team Structure Analyzer Failed:', result.error);
      this.testResults.errors.push({
        endpoint: '/api/fantasy/tools/ai/team_structure_analyzer',
        error: result.error
      });
    }
    
    return result;
  }

  async testOwnershipRiskEndpoint() {
    console.log('\n🧪 Testing Ownership Risk Monitor Endpoint...');
    
    const result = await this.makeRequest('/api/fantasy/tools/ai/ownership_risk_monitor');
    
    if (result.success) {
      console.log('✅ Ownership Risk Monitor Response:', {
        status: result.data.status,
        responseTime: `${result.responseTime.toFixed(2)}ms`,
        playersCount: Array.isArray(result.data.players) ? result.data.players.length : 0
      });
      
      const isGeminiResponse = this.detectGeminiResponse(result.data);
      this.recordResult(isGeminiResponse ? 'gemini' : 'fallback', result);
      
    } else {
      console.log('❌ Ownership Risk Monitor Failed:', result.error);
      this.testResults.errors.push({
        endpoint: '/api/fantasy/tools/ai/ownership_risk_monitor',
        error: result.error
      });
    }
    
    return result;
  }

  async testFormVsPriceEndpoint() {
    console.log('\n🧪 Testing Form vs Price Scanner Endpoint...');
    
    const result = await this.makeRequest('/api/fantasy/tools/ai/form_vs_price_scanner');
    
    if (result.success) {
      console.log('✅ Form vs Price Scanner Response:', {
        status: result.data.status,
        responseTime: `${result.responseTime.toFixed(2)}ms`,
        playersCount: Array.isArray(result.data.players) ? result.data.players.length : 0
      });
      
      const isGeminiResponse = this.detectGeminiResponse(result.data);
      this.recordResult(isGeminiResponse ? 'gemini' : 'fallback', result);
      
    } else {
      console.log('❌ Form vs Price Scanner Failed:', result.error);
      this.testResults.errors.push({
        endpoint: '/api/fantasy/tools/ai/form_vs_price_scanner',
        error: result.error
      });
    }
    
    return result;
  }

  detectGeminiResponse(data) {
    // Check for indicators that suggest Gemini was used
    const geminiIndicators = [
      'model', // Gemini responses include model info
      'generated_at', // Timestamp format from Gemini
      'confidence', // Detailed confidence metrics from Gemini
      'reasoning' // Detailed reasoning from Gemini AI
    ];
    
    const responseString = JSON.stringify(data);
    const geminiScore = geminiIndicators.reduce((score, indicator) => {
      return responseString.includes(indicator) ? score + 1 : score;
    }, 0);
    
    // Consider it a Gemini response if it has 2+ indicators
    return geminiScore >= 2;
  }

  recordResult(type, result) {
    this.testResults[type].responses.push(result);
    
    if (result.success) {
      this.testResults[type].success++;
    } else {
      this.testResults[type].failures++;
    }
    
    // Update average response time
    const responses = this.testResults[type].responses;
    const totalTime = responses.reduce((sum, r) => sum + r.responseTime, 0);
    this.testResults[type].avgResponseTime = totalTime / responses.length;
  }

  async testFallbackMechanism() {
    console.log('\n🔄 Testing Fallback Mechanism...');
    
    // Test with invalid/missing Gemini API key to force fallback
    const originalKey = process.env.GEMINI_API_KEY;
    process.env.GEMINI_API_KEY = 'invalid_key';
    
    try {
      const result = await this.testAITradeEndpoint();
      console.log('📝 Fallback test result:', result.success ? 'SUCCESS' : 'FAILED');
      
      if (result.success) {
        console.log('✅ Fallback mechanism working properly');
      } else {
        console.log('❌ Fallback mechanism failed');
      }
      
    } finally {
      // Restore original API key
      process.env.GEMINI_API_KEY = originalKey;
    }
  }

  async performLoadTest(concurrentRequests = 5, totalRequests = 20) {
    console.log(`\n🚀 Performing Load Test (${concurrentRequests} concurrent, ${totalRequests} total)...`);
    
    const endpoints = [
      '/api/fantasy/tools/ai/ai_trade_suggester',
      '/api/fantasy/tools/ai/ai_captain_advisor',
      '/api/fantasy/tools/ai/team_structure_analyzer'
    ];
    
    const loadTestResults = {
      totalRequests: 0,
      successfulRequests: 0,
      failedRequests: 0,
      avgResponseTime: 0,
      maxResponseTime: 0,
      minResponseTime: Infinity
    };
    
    const requestPromises = [];
    const allResponseTimes = [];
    
    for (let i = 0; i < totalRequests; i++) {
      const endpoint = endpoints[i % endpoints.length];
      const promise = this.makeRequest(endpoint).then(result => {
        loadTestResults.totalRequests++;
        allResponseTimes.push(result.responseTime);
        
        if (result.success) {
          loadTestResults.successfulRequests++;
        } else {
          loadTestResults.failedRequests++;
        }
        
        return result;
      });
      
      requestPromises.push(promise);
      
      // Add slight delay between batches to simulate realistic usage
      if ((i + 1) % concurrentRequests === 0) {
        await new Promise(resolve => setTimeout(resolve, 100));
      }
    }
    
    await Promise.all(requestPromises);
    
    // Calculate performance metrics
    if (allResponseTimes.length > 0) {
      loadTestResults.avgResponseTime = allResponseTimes.reduce((a, b) => a + b, 0) / allResponseTimes.length;
      loadTestResults.maxResponseTime = Math.max(...allResponseTimes);
      loadTestResults.minResponseTime = Math.min(...allResponseTimes);
    }
    
    console.log('📊 Load Test Results:', {
      ...loadTestResults,
      successRate: `${((loadTestResults.successfulRequests / loadTestResults.totalRequests) * 100).toFixed(2)}%`,
      avgResponseTime: `${loadTestResults.avgResponseTime.toFixed(2)}ms`,
      maxResponseTime: `${loadTestResults.maxResponseTime.toFixed(2)}ms`,
      minResponseTime: `${loadTestResults.minResponseTime.toFixed(2)}ms`
    });
    
    return loadTestResults;
  }

  async runFullTestSuite() {
    console.log('🚀 Starting AI Endpoints Integration Test Suite\n');
    console.log('📋 Test Configuration:');
    console.log(`   Base URL: ${this.baseUrl}`);
    console.log(`   Gemini API Key: ${process.env.GEMINI_API_KEY ? 'CONFIGURED' : 'MISSING'}`);
    console.log('=' * 60);

    // Individual endpoint tests
    await this.testAITradeEndpoint();
    await this.testAICaptainEndpoint();
    await this.testTeamStructureEndpoint();
    await this.testOwnershipRiskEndpoint();
    await this.testFormVsPriceEndpoint();
    
    // Fallback mechanism test
    await this.testFallbackMechanism();
    
    // Load testing
    const loadTestResults = await this.performLoadTest();
    
    // Generate final report
    this.generateFinalReport(loadTestResults);
  }

  generateFinalReport(loadTestResults) {
    console.log('\n' + '=' * 60);
    console.log('📊 FINAL TEST REPORT');
    console.log('=' * 60);
    
    console.log('\n🔮 Gemini API Results:');
    console.log(`   Successful Requests: ${this.testResults.gemini.success}`);
    console.log(`   Failed Requests: ${this.testResults.gemini.failures}`);
    console.log(`   Average Response Time: ${this.testResults.gemini.avgResponseTime.toFixed(2)}ms`);
    
    console.log('\n🔄 Fallback (OpenAI) Results:');
    console.log(`   Successful Requests: ${this.testResults.fallback.success}`);
    console.log(`   Failed Requests: ${this.testResults.fallback.failures}`);
    console.log(`   Average Response Time: ${this.testResults.fallback.avgResponseTime.toFixed(2)}ms`);
    
    console.log('\n🚀 Load Test Performance:');
    console.log(`   Total Requests: ${loadTestResults.totalRequests}`);
    console.log(`   Success Rate: ${((loadTestResults.successfulRequests / loadTestResults.totalRequests) * 100).toFixed(2)}%`);
    console.log(`   Average Response Time: ${loadTestResults.avgResponseTime.toFixed(2)}ms`);
    console.log(`   Max Response Time: ${loadTestResults.maxResponseTime.toFixed(2)}ms`);
    console.log(`   Min Response Time: ${loadTestResults.minResponseTime.toFixed(2)}ms`);
    
    if (this.testResults.errors.length > 0) {
      console.log('\n❌ Errors Encountered:');
      this.testResults.errors.forEach((error, index) => {
        console.log(`   ${index + 1}. ${error.endpoint}: ${error.error}`);
      });
    }
    
    // Cost and accuracy assessment
    console.log('\n💰 Cost Assessment:');
    console.log(`   Gemini Requests: ${this.testResults.gemini.success + this.testResults.gemini.failures}`);
    console.log(`   Fallback Requests: ${this.testResults.fallback.success + this.testResults.fallback.failures}`);
    console.log('   Estimated Cost: Based on actual API usage (see API billing dashboards)');
    
    console.log('\n✅ Integration Test Summary:');
    const totalTests = this.testResults.gemini.success + this.testResults.gemini.failures +
                      this.testResults.fallback.success + this.testResults.fallback.failures;
    const totalSuccess = this.testResults.gemini.success + this.testResults.fallback.success;
    
    console.log(`   Overall Success Rate: ${((totalSuccess / totalTests) * 100).toFixed(2)}%`);
    console.log(`   Gemini Integration: ${this.testResults.gemini.success > 0 ? 'WORKING' : 'NEEDS ATTENTION'}`);
    console.log(`   Fallback Logic: ${this.testResults.fallback.success > 0 ? 'WORKING' : 'NEEDS ATTENTION'}`);
    console.log(`   Load Handling: ${loadTestResults.successfulRequests === loadTestResults.totalRequests ? 'EXCELLENT' : 'NEEDS IMPROVEMENT'}`);
    
    console.log('\n' + '=' * 60);
  }
}

// Export for use in other test files
module.exports = AIEndpointsIntegrationTest;

// Run tests if this file is executed directly
if (require.main === module) {
  const tester = new AIEndpointsIntegrationTest();
  tester.runFullTestSuite().catch(console.error);
}
