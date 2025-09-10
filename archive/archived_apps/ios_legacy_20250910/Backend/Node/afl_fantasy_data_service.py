"""
AFL Fantasy Data Service

Service to fetch authentic AFL Fantasy data using manual tokens.
Provides all dashboard card data as specified by user requirements.
"""

import requests
import json
import os
from datetime import datetime

class AFLFantasyDataService:
    def __init__(self):
        self.base_url = "https://fantasy.afl.com.au"
        self.session = requests.Session()
        
        # Set headers for API requests
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'application/json, text/plain, */*',
            'Accept-Language': 'en-US,en;q=0.9',
            'Content-Type': 'application/json',
            'X-Requested-With': 'XMLHttpRequest'
        })
        
        # Load tokens if available
        self.load_tokens()

    def load_tokens(self):
        """Load authentication tokens from environment or file"""
        # Try environment variables first
        self.team_id = os.getenv('AFL_FANTASY_TEAM_ID')
        self.session_cookie = os.getenv('AFL_FANTASY_SESSION_COOKIE')
        self.api_token = os.getenv('AFL_FANTASY_API_TOKEN')
        
        # Try loading from file if env vars not set
        if not all([self.team_id, self.session_cookie]):
            try:
                with open('afl_fantasy_tokens.json', 'r') as f:
                    tokens = json.load(f)
                    self.team_id = tokens.get('team_id')
                    self.session_cookie = tokens.get('session_cookie')
                    self.api_token = tokens.get('api_token')
            except FileNotFoundError:
                pass
        
        # Set session cookie if available
        if self.session_cookie:
            self.session.headers['Cookie'] = self.session_cookie
        
        # Set API token if available
        if self.api_token:
            self.session.headers['Authorization'] = f'Bearer {self.api_token}'

    def get_team_value_data(self):
        """Get team value: sum of all player prices + remaining salary"""
        try:
            if not self.team_id:
                return None
                
            # Try multiple endpoints for team data
            endpoints = [
                f'/api/teams/{self.team_id}',
                f'/api/teams/{self.team_id}/players',
                f'/api/user/teams/{self.team_id}',
                f'/api/teams/{self.team_id}/squad'
            ]
            
            for endpoint in endpoints:
                url = self.base_url + endpoint
                response = self.session.get(url)
                
                if response.status_code == 200:
                    data = response.json()
                    
                    # Extract team value from response
                    team_value = self.extract_team_value_from_data(data)
                    if team_value:
                        return {
                            'total_value': team_value,
                            'remaining_salary': max(0, 13000000 - team_value),
                            'source': endpoint
                        }
            
            return None
            
        except Exception as e:
            print(f"Error getting team value: {e}")
            return None

    def get_team_score_data(self):
        """Get team score: sum of on-field players' scores (captain doubled)"""
        try:
            if not self.team_id:
                return None
                
            # Try endpoints for current round scores
            endpoints = [
                f'/api/teams/{self.team_id}/scores/current',
                f'/api/teams/{self.team_id}/performance/latest',
                f'/api/teams/{self.team_id}/round/current'
            ]
            
            for endpoint in endpoints:
                url = self.base_url + endpoint
                response = self.session.get(url)
                
                if response.status_code == 200:
                    data = response.json()
                    
                    # Extract team score from response
                    team_score = self.extract_team_score_from_data(data)
                    if team_score:
                        return team_score
            
            return None
            
        except Exception as e:
            print(f"Error getting team score: {e}")
            return None

    def get_overall_rank_data(self):
        """Get overall rank among all AFL Fantasy players"""
        try:
            if not self.team_id:
                return None
                
            # Try endpoints for ranking data
            endpoints = [
                f'/api/teams/{self.team_id}/rank',
                f'/api/rankings/team/{self.team_id}',
                f'/api/leaderboard/position/{self.team_id}'
            ]
            
            for endpoint in endpoints:
                url = self.base_url + endpoint
                response = self.session.get(url)
                
                if response.status_code == 200:
                    data = response.json()
                    
                    # Extract rank from response
                    rank = self.extract_rank_from_data(data)
                    if rank:
                        return rank
            
            return None
            
        except Exception as e:
            print(f"Error getting rank: {e}")
            return None

    def get_captain_data(self):
        """Get captain score and ownership percentage"""
        try:
            if not self.team_id:
                return None
                
            # Try endpoints for captain data
            endpoints = [
                f'/api/teams/{self.team_id}/captain',
                f'/api/teams/{self.team_id}/selection/captain',
                f'/api/captains/ownership'
            ]
            
            for endpoint in endpoints:
                url = self.base_url + endpoint
                response = self.session.get(url)
                
                if response.status_code == 200:
                    data = response.json()
                    
                    # Extract captain data from response
                    captain_data = self.extract_captain_from_data(data)
                    if captain_data:
                        return captain_data
            
            return None
            
        except Exception as e:
            print(f"Error getting captain data: {e}")
            return None

    def extract_team_value_from_data(self, data):
        """Extract team value from API response"""
        try:
            # Look for team value in various response structures
            if isinstance(data, dict):
                # Direct value fields
                for key in ['team_value', 'total_value', 'value', 'squad_value']:
                    if key in data and isinstance(data[key], (int, float)):
                        value = data[key]
                        if 10000000 <= value <= 15000000:  # Valid AFL Fantasy range
                            return value
                
                # Calculate from players array
                if 'players' in data and isinstance(data['players'], list):
                    total_value = 0
                    for player in data['players']:
                        if isinstance(player, dict) and 'price' in player:
                            total_value += player['price']
                    
                    if 10000000 <= total_value <= 15000000:
                        return total_value
                
                # Look in nested objects
                for key, value in data.items():
                    if isinstance(value, dict):
                        nested_value = self.extract_team_value_from_data(value)
                        if nested_value:
                            return nested_value
            
            return None
            
        except Exception as e:
            print(f"Error extracting team value: {e}")
            return None

    def extract_team_score_from_data(self, data):
        """Extract team score from API response"""
        try:
            if isinstance(data, dict):
                # Direct score fields
                for key in ['team_score', 'total_score', 'score', 'points']:
                    if key in data and isinstance(data[key], (int, float)):
                        score = data[key]
                        if 500 <= score <= 4000:  # Valid AFL Fantasy range
                            return {
                                'total_score': score,
                                'source': 'direct_field'
                            }
                
                # Calculate from player scores
                if 'players' in data and isinstance(data['players'], list):
                    total_score = 0
                    captain_score = 0
                    
                    for player in data['players']:
                        if isinstance(player, dict):
                            player_score = player.get('score', 0)
                            is_captain = player.get('is_captain', False)
                            is_on_field = not player.get('is_bench', True)
                            
                            if is_on_field and player_score > 0:
                                total_score += player_score
                                if is_captain:
                                    captain_score = player_score
                                    total_score += player_score  # Double captain score
                    
                    if total_score > 0:
                        return {
                            'total_score': total_score,
                            'captain_score': captain_score,
                            'source': 'calculated'
                        }
            
            return None
            
        except Exception as e:
            print(f"Error extracting team score: {e}")
            return None

    def extract_rank_from_data(self, data):
        """Extract rank from API response"""
        try:
            if isinstance(data, dict):
                # Direct rank fields
                for key in ['rank', 'overall_rank', 'position', 'league_position']:
                    if key in data and isinstance(data[key], (int, float)):
                        rank = data[key]
                        if 1 <= rank <= 1000000:  # Valid rank range
                            return {
                                'current_rank': rank,
                                'source': 'direct_field'
                            }
            
            return None
            
        except Exception as e:
            print(f"Error extracting rank: {e}")
            return None

    def extract_captain_from_data(self, data):
        """Extract captain data from API response"""
        try:
            captain_data = {}
            
            if isinstance(data, dict):
                # Look for captain information
                if 'captain' in data:
                    captain_info = data['captain']
                    if isinstance(captain_info, dict):
                        captain_data['name'] = captain_info.get('name', 'Unknown')
                        captain_data['score'] = captain_info.get('score', 0)
                        captain_data['ownership'] = captain_info.get('ownership_percentage', 0)
                
                # Direct fields
                for key in ['captain_score', 'score']:
                    if key in data and isinstance(data[key], (int, float)):
                        captain_data['score'] = data[key]
                
                for key in ['ownership_percentage', 'ownership', 'percentage']:
                    if key in data and isinstance(data[key], (int, float)):
                        captain_data['ownership'] = data[key]
            
            return captain_data if captain_data else None
            
        except Exception as e:
            print(f"Error extracting captain data: {e}")
            return None

    def get_all_dashboard_data(self):
        """Get all dashboard data as specified by user requirements"""
        try:
            dashboard_data = {}
            
            print("Fetching team value data...")
            team_value = self.get_team_value_data()
            if team_value:
                dashboard_data['team_value'] = team_value
            
            print("Fetching team score data...")
            team_score = self.get_team_score_data()
            if team_score:
                dashboard_data['team_score'] = team_score
            
            print("Fetching rank data...")
            rank_data = self.get_overall_rank_data()
            if rank_data:
                dashboard_data['overall_rank'] = rank_data
            
            print("Fetching captain data...")
            captain_data = self.get_captain_data()
            if captain_data:
                dashboard_data['captain'] = captain_data
            
            # Add metadata
            dashboard_data['last_updated'] = datetime.now().isoformat()
            dashboard_data['tokens_configured'] = bool(self.team_id and self.session_cookie)
            
            return dashboard_data
            
        except Exception as e:
            print(f"Error getting dashboard data: {e}")
            return None

    def save_dashboard_data(self, data):
        """Save dashboard data to file"""
        try:
            with open('afl_fantasy_dashboard_data.json', 'w') as f:
                json.dump(data, f, indent=2)
            return True
        except Exception as e:
            print(f"Error saving dashboard data: {e}")
            return False

def main():
    """Test the service"""
    service = AFLFantasyDataService()
    
    print("AFL Fantasy Data Service Test")
    print(f"Team ID configured: {bool(service.team_id)}")
    print(f"Session cookie configured: {bool(service.session_cookie)}")
    
    if service.team_id and service.session_cookie:
        data = service.get_all_dashboard_data()
        if data:
            service.save_dashboard_data(data)
            print("Dashboard data retrieved successfully")
            return data
        else:
            print("Failed to retrieve dashboard data")
    else:
        print("Tokens not configured. Please provide:")
        print("- AFL_FANTASY_TEAM_ID")
        print("- AFL_FANTASY_SESSION_COOKIE")
    
    return None

if __name__ == "__main__":
    main()