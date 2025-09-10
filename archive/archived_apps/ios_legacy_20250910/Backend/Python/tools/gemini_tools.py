"""
AFL Fantasy Google Gemini Tools

This module provides Google Gemini AI-powered analysis tools for AFL Fantasy.
It handles API calls to Google's Gemini API endpoints and provides intelligent
recommendations for trades, captaincy, team structure, and player analysis.
"""

import json
import os
import requests
from datetime import datetime
from typing import Dict, List, Optional, Any


class GeminiAPIError(Exception):
    """Custom exception for Gemini API related errors"""
    pass


class GeminiTools:
    """
    Google Gemini API integration class for AFL Fantasy analysis
    """
    
    def __init__(self, api_key: Optional[str] = None):
        """
        Initialize Gemini Tools with API key
        
        Args:
            api_key (str, optional): Gemini API key. If not provided, will try to get from environment
        """
        self.api_key = api_key or os.getenv('GEMINI_API_KEY')
        if not self.api_key:
            raise GeminiAPIError("Gemini API key not provided. Set GEMINI_API_KEY environment variable.")
        
        self.base_url = "https://generativelanguage.googleapis.com/v1beta"
        self.model_name = "gemini-1.5-flash"
        self.headers = {
            "Content-Type": "application/json"
        }
    
    def _make_request(self, prompt: str, max_tokens: int = 1000, temperature: float = 0.7) -> Dict[str, Any]:
        """
        Make a request to the Gemini API
        
        Args:
            prompt (str): The prompt to send to Gemini
            max_tokens (int): Maximum tokens in response
            temperature (float): Temperature for response generation
            
        Returns:
            dict: Parsed response from Gemini API
            
        Raises:
            GeminiAPIError: If API call fails
        """
        url = f"{self.base_url}/models/{self.model_name}:generateContent"
        
        payload = {
            "contents": [{
                "parts": [{
                    "text": prompt
                }]
            }],
            "generationConfig": {
                "temperature": temperature,
                "topK": 40,
                "topP": 0.95,
                "maxOutputTokens": max_tokens
            }
        }
        
        try:
            response = requests.post(
                f"{url}?key={self.api_key}",
                headers=self.headers,
                json=payload,
                timeout=30
            )
            response.raise_for_status()
            
            data = response.json()
            
            if 'candidates' not in data or not data['candidates']:
                raise GeminiAPIError("No response generated from Gemini API")
            
            # Extract text from the response
            candidate = data['candidates'][0]
            if 'content' not in candidate or 'parts' not in candidate['content']:
                raise GeminiAPIError("Invalid response format from Gemini API")
            
            text_response = candidate['content']['parts'][0]['text']
            
            return {
                "status": "success",
                "response": text_response,
                "model": self.model_name,
                "timestamp": datetime.now().isoformat()
            }
            
        except requests.exceptions.RequestException as e:
            raise GeminiAPIError(f"Request failed: {str(e)}")
        except KeyError as e:
            raise GeminiAPIError(f"Unexpected response format: {str(e)}")
        except Exception as e:
            raise GeminiAPIError(f"Unexpected error: {str(e)}")
    
    def _parse_json_response(self, response_text: str) -> Dict[str, Any]:
        """
        Attempt to parse JSON from Gemini response text
        
        Args:
            response_text (str): Raw response text from Gemini
            
        Returns:
            dict: Parsed JSON or structured fallback
        """
        try:
            # Try to find JSON in the response
            json_start = response_text.find('{')
            json_end = response_text.rfind('}') + 1
            
            if json_start != -1 and json_end > json_start:
                json_str = response_text[json_start:json_end]
                return json.loads(json_str)
            else:
                # If no JSON found, return as structured text
                return {
                    "analysis": response_text,
                    "format": "text"
                }
        except json.JSONDecodeError:
            return {
                "analysis": response_text,
                "format": "text"
            }
    
    def trade_analysis(self, player_data: List[Dict], current_team: List[str] = None) -> Dict[str, Any]:
        """
        AI-powered trade analysis using Gemini
        
        Args:
            player_data (list): List of player dictionaries with stats
            current_team (list, optional): List of current team player names
            
        Returns:
            dict: Trade recommendations from Gemini AI
        """
        prompt = f"""
        As an AFL Fantasy expert, analyze the following player data and provide trade recommendations.
        
        Player Data:
        {json.dumps(player_data[:10], indent=2)}
        
        Current Team (if provided):
        {json.dumps(current_team, indent=2) if current_team else "Not provided"}
        
        Please provide a JSON response with the following structure:
        {{
            "trade_recommendations": [
                {{
                    "trade_in": "Player Name",
                    "trade_out": "Player Name",
                    "confidence": 85,
                    "reasoning": "Detailed reasoning for this trade",
                    "projected_gain": 12.5,
                    "risk_level": "Medium",
                    "priority": "High"
                }}
            ],
            "market_insights": "Overall market analysis",
            "timing_advice": "When to make these trades"
        }}
        
        Focus on value, form, fixtures, and injury risks. Limit to top 5 recommendations.
        """
        
        try:
            response = self._make_request(prompt, max_tokens=1500, temperature=0.6)
            parsed_data = self._parse_json_response(response['response'])
            
            return {
                "status": "success",
                "data": parsed_data,
                "generated_at": response['timestamp'],
                "model": response['model']
            }
        except GeminiAPIError as e:
            return {
                "status": "error",
                "error": str(e),
                "generated_at": datetime.now().isoformat()
            }
    
    def captain_selection(self, available_players: List[Dict], round_info: Dict = None) -> Dict[str, Any]:
        """
        AI-powered captain selection advice using Gemini
        
        Args:
            available_players (list): List of potential captain options
            round_info (dict, optional): Information about the current round
            
        Returns:
            dict: Captain recommendations from Gemini AI
        """
        prompt = f"""
        As an AFL Fantasy expert, analyze these potential captain options for this round.
        
        Potential Captains:
        {json.dumps(available_players[:12], indent=2)}
        
        Round Information:
        {json.dumps(round_info, indent=2) if round_info else "Standard round"}
        
        Please provide a JSON response with this structure:
        {{
            "captain_recommendations": [
                {{
                    "player": "Player Name",
                    "team": "Team",
                    "confidence": 92,
                    "projected_score": 120,
                    "reasoning": "Why this player is a good captain choice",
                    "ownership": 45.2,
                    "risk_level": "Low",
                    "ceiling": 150,
                    "floor": 90
                }}
            ],
            "captaincy_strategy": "Overall strategy for this round",
            "differential_options": "Lower ownership high-upside options"
        }}
        
        Consider matchups, form, weather, venue, and tactical situations. Rank by confidence.
        """
        
        try:
            response = self._make_request(prompt, max_tokens=1200, temperature=0.5)
            parsed_data = self._parse_json_response(response['response'])
            
            return {
                "status": "success",
                "data": parsed_data,
                "generated_at": response['timestamp'],
                "model": response['model']
            }
        except GeminiAPIError as e:
            return {
                "status": "error",
                "error": str(e),
                "generated_at": datetime.now().isoformat()
            }
    
    def team_structure_analysis(self, current_team: List[Dict], budget: float = None) -> Dict[str, Any]:
        """
        Analyze team structure and provide optimization suggestions
        
        Args:
            current_team (list): Current team player data
            budget (float, optional): Available budget for changes
            
        Returns:
            dict: Team structure analysis from Gemini AI
        """
        prompt = f"""
        As an AFL Fantasy expert, analyze this team structure and provide optimization advice.
        
        Current Team:
        {json.dumps(current_team, indent=2)}
        
        Available Budget: ${budget:,.0f}" if budget else "Not specified"
        
        Please provide a JSON response with this structure:
        {{
            "structure_analysis": {{
                "defense": {{
                    "strength": "Strong/Average/Weak",
                    "recommendations": "Specific advice",
                    "player_count": 6
                }},
                "midfield": {{
                    "strength": "Strong/Average/Weak", 
                    "recommendations": "Specific advice",
                    "player_count": 8
                }},
                "forward": {{
                    "strength": "Strong/Average/Weak",
                    "recommendations": "Specific advice", 
                    "player_count": 6
                }},
                "rucks": {{
                    "strength": "Strong/Average/Weak",
                    "recommendations": "Specific advice",
                    "player_count": 2
                }}
            }},
            "overall_score": 8.2,
            "key_weaknesses": ["Weakness 1", "Weakness 2"],
            "improvement_priority": "Defense needs premium upgrade",
            "budget_allocation": "How to best use available budget"
        }}
        
        Focus on balance, value, and upgrade paths.
        """
        
        try:
            response = self._make_request(prompt, max_tokens=1500, temperature=0.6)
            parsed_data = self._parse_json_response(response['response'])
            
            return {
                "status": "success",
                "data": parsed_data,
                "generated_at": response['timestamp'],
                "model": response['model']
            }
        except GeminiAPIError as e:
            return {
                "status": "error",
                "error": str(e),
                "generated_at": datetime.now().isoformat()
            }
    
    def player_breakout_prediction(self, player_data: List[Dict], season_context: Dict = None) -> Dict[str, Any]:
        """
        Predict potential breakout players using Gemini AI
        
        Args:
            player_data (list): Player statistics and information
            season_context (dict, optional): Current season context
            
        Returns:
            dict: Breakout predictions from Gemini AI
        """
        prompt = f"""
        As an AFL Fantasy expert, identify potential breakout players from this data.
        
        Player Data:
        {json.dumps(player_data[:20], indent=2)}
        
        Season Context:
        {json.dumps(season_context, indent=2) if season_context else "Standard season analysis"}
        
        Please provide a JSON response with this structure:
        {{
            "breakout_candidates": [
                {{
                    "player": "Player Name",
                    "team": "Team",
                    "current_price": 450000,
                    "breakout_probability": 75,
                    "projected_average": 85,
                    "reasoning": "Why this player might break out",
                    "catalysts": ["Role change", "Injury return", "etc"],
                    "risk_factors": ["What could go wrong"],
                    "timeline": "When breakout expected",
                    "value_rating": 8.5
                }}
            ],
            "market_opportunities": "Overall breakout trends",
            "timing_strategy": "When to target these players"
        }}
        
        Focus on role changes, opportunity, value, and upside potential.
        """
        
        try:
            response = self._make_request(prompt, max_tokens=1500, temperature=0.7)
            parsed_data = self._parse_json_response(response['response'])
            
            return {
                "status": "success",
                "data": parsed_data,
                "generated_at": response['timestamp'],
                "model": response['model']
            }
        except GeminiAPIError as e:
            return {
                "status": "error",
                "error": str(e),
                "generated_at": datetime.now().isoformat()
            }
    
    def injury_impact_assessment(self, injury_reports: List[Dict], affected_players: List[str] = None) -> Dict[str, Any]:
        """
        Assess fantasy impact of injuries using Gemini AI
        
        Args:
            injury_reports (list): Current injury reports and news
            affected_players (list, optional): Specific players to analyze
            
        Returns:
            dict: Injury impact analysis from Gemini AI
        """
        prompt = f"""
        As an AFL Fantasy expert, analyze these injury reports and their fantasy impact.
        
        Injury Reports:
        {json.dumps(injury_reports, indent=2)}
        
        Specific Players of Interest:
        {json.dumps(affected_players, indent=2) if affected_players else "All relevant players"}
        
        Please provide a JSON response with this structure:
        {{
            "injury_impacts": [
                {{
                    "player": "Injured Player",
                    "injury": "Injury type",
                    "severity": "Minor/Moderate/Major",
                    "expected_return": "Round X or date",
                    "fantasy_impact": "How it affects fantasy value",
                    "trade_recommendation": "Hold/Trade/Target",
                    "backup_targets": ["Player 1", "Player 2"]
                }}
            ],
            "opportunity_players": [
                {{
                    "player": "Replacement Player",
                    "opportunity": "What role they take",
                    "value_rating": 7.5,
                    "short_term_viability": "Good/Average/Poor"
                }}
            ],
            "market_strategy": "How to navigate these injuries"
        }}
        
        Focus on timeline, replacement values, and strategic opportunities.
        """
        
        try:
            response = self._make_request(prompt, max_tokens=1200, temperature=0.6)
            parsed_data = self._parse_json_response(response['response'])
            
            return {
                "status": "success",
                "data": parsed_data,
                "generated_at": response['timestamp'],
                "model": response['model']
            }
        except GeminiAPIError as e:
            return {
                "status": "error",
                "error": str(e),
                "generated_at": datetime.now().isoformat()
            }


# Convenience functions for easy integration
def get_gemini_trade_analysis(player_data: List[Dict], current_team: List[str] = None) -> Dict[str, Any]:
    """
    Convenience function for trade analysis
    """
    try:
        gemini = GeminiTools()
        return gemini.trade_analysis(player_data, current_team)
    except GeminiAPIError as e:
        return {
            "status": "error",
            "error": f"Gemini API not configured: {str(e)}",
            "generated_at": datetime.now().isoformat()
        }


def get_gemini_captain_advice(available_players: List[Dict], round_info: Dict = None) -> Dict[str, Any]:
    """
    Convenience function for captain selection
    """
    try:
        gemini = GeminiTools()
        return gemini.captain_selection(available_players, round_info)
    except GeminiAPIError as e:
        return {
            "status": "error",
            "error": f"Gemini API not configured: {str(e)}",
            "generated_at": datetime.now().isoformat()
        }


def get_gemini_team_analysis(current_team: List[Dict], budget: float = None) -> Dict[str, Any]:
    """
    Convenience function for team structure analysis
    """
    try:
        gemini = GeminiTools()
        return gemini.team_structure_analysis(current_team, budget)
    except GeminiAPIError as e:
        return {
            "status": "error",
            "error": f"Gemini API not configured: {str(e)}",
            "generated_at": datetime.now().isoformat()
        }


def get_gemini_breakout_predictions(player_data: List[Dict], season_context: Dict = None) -> Dict[str, Any]:
    """
    Convenience function for breakout predictions
    """
    try:
        gemini = GeminiTools()
        return gemini.player_breakout_prediction(player_data, season_context)
    except GeminiAPIError as e:
        return {
            "status": "error",
            "error": f"Gemini API not configured: {str(e)}",
            "generated_at": datetime.now().isoformat()
        }


def get_gemini_injury_analysis(injury_reports: List[Dict], affected_players: List[str] = None) -> Dict[str, Any]:
    """
    Convenience function for injury impact analysis
    """
    try:
        gemini = GeminiTools()
        return gemini.injury_impact_assessment(injury_reports, affected_players)
    except GeminiAPIError as e:
        return {
            "status": "error",
            "error": f"Gemini API not configured: {str(e)}",
            "generated_at": datetime.now().isoformat()
        }


# Test function to verify API connectivity
def test_gemini_connection() -> Dict[str, Any]:
    """
    Test Gemini API connection
    
    Returns:
        dict: Connection test results
    """
    try:
        gemini = GeminiTools()
        response = gemini._make_request("Hello, please respond with 'API connection successful'", max_tokens=50)
        return {
            "status": "success",
            "message": "Gemini API connection successful",
            "response": response['response'],
            "model": response['model']
        }
    except GeminiAPIError as e:
        return {
            "status": "error",
            "message": f"Gemini API connection failed: {str(e)}"
        }
