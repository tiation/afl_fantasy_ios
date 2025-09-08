"""
Team Uploader Utility

This module allows users to upload their team and processes it with accurate player data
from FootyWire and DFS Australia.
"""

import json
import os
import sys
from player_data_integrator import process_user_team, normalize_player_name

def parse_team_string(team_text):
    """
    Parse a text representation of a team into a structured format
    
    Args:
        team_text (str): Text representation of the team
        
    Returns:
        dict: Structured team data
    """
    team_data = {
        "defenders": [],
        "midfielders": [],
        "rucks": [],
        "forwards": [],
        "bench": {
            "defenders": [],
            "midfielders": [],
            "rucks": [],
            "forwards": [],
            "utility": []
        }
    }
    
    current_section = None
    bench_section = None
    
    # Split by lines and process each line
    lines = team_text.strip().split('\n')
    
    for line in lines:
        line = line.strip()
        if not line:
            continue
            
        line_lower = line.lower()
        
        # Check if this is a section header
        if "defender" in line_lower and not bench_section:
            current_section = "defenders"
            bench_section = False
        elif "midfielder" in line_lower and not bench_section:
            current_section = "midfielders"
            bench_section = False
        elif "ruck" in line_lower and not bench_section:
            current_section = "rucks"
            bench_section = False
        elif "forward" in line_lower and not bench_section:
            current_section = "forwards"
            bench_section = False
        elif "bench" in line_lower and "defender" in line_lower:
            current_section = "defenders"
            bench_section = True
        elif "bench" in line_lower and "midfielder" in line_lower:
            current_section = "midfielders"
            bench_section = True
        elif "bench" in line_lower and "ruck" in line_lower:
            current_section = "rucks"
            bench_section = True
        elif "bench" in line_lower and "forward" in line_lower:
            current_section = "forwards"
            bench_section = True
        elif "bench" in line_lower and "utility" in line_lower:
            current_section = "utility"
            bench_section = True
        elif current_section and not line_lower.startswith(("defender", "midfielder", "ruck", "forward", "bench")):
            # This is a player line
            player = {"name": line}
            
            if bench_section:
                team_data["bench"][current_section].append(player)
            else:
                team_data[current_section].append(player)
    
    return team_data

def ensure_file_exists(filename, default_content=None):
    """Ensure a file exists, creating it with default content if needed"""
    if not os.path.exists(filename):
        with open(filename, 'w') as f:
            if default_content is not None:
                json.dump(default_content, f, indent=2)
            else:
                json.dump([], f, indent=2)

def get_team_data():
    """Get the user's team data"""
    ensure_file_exists('user_team.json', {})
    
    try:
        with open('user_team.json', 'r') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading team data: {e}")
        return {}

def save_team_data(team_data):
    """Save the user's team data"""
    try:
        with open('user_team.json', 'w') as f:
            json.dump(team_data, f, indent=2)
        print("Team data saved to user_team.json")
    except Exception as e:
        print(f"Error saving team data: {e}")

def upload_team(team_text):
    """
    Upload a team from text and process it with accurate player data
    
    Args:
        team_text (str): Text representation of the team
        
    Returns:
        dict: Processed team data with accurate stats
    """
    try:
        # Parse the team text
        team_data = parse_team_string(team_text)
        
        # Process the team with accurate player data
        processed_team = process_user_team(team_data)
        
        # Remove any None values or empty elements that might cause JSON serialization issues
        for position, players in processed_team.items():
            if position != "bench" and isinstance(players, list):
                # Filter out any None or empty players
                processed_team[position] = [
                    player for player in players
                    if player and isinstance(player, dict) and 'name' in player
                ]

        # Process bench separately because of its nested structure
        if "bench" in processed_team and isinstance(processed_team["bench"], dict):
            for bench_position, bench_players in processed_team["bench"].items():
                if isinstance(bench_players, list):
                    # Filter out any None or empty players
                    processed_team["bench"][bench_position] = [
                        player for player in bench_players
                        if player and isinstance(player, dict) and 'name' in player
                    ]
                    
        # Save the processed team
        save_team_data(processed_team)
        
        # Format for API response
        response = {
            "status": "ok",
            "message": "Team uploaded and processed successfully",
            "data": processed_team
        }
        
        return response
    except Exception as e:
        print(f"Error in upload_team: {e}")
        # Return a valid JSON response even on error
        return {
            "status": "error",
            "message": f"Failed to process team: {str(e)}",
            "data": {
                "defenders": [],
                "midfielders": [],
                "rucks": [],
                "forwards": [],
                "bench": {
                    "defenders": [],
                    "midfielders": [],
                    "rucks": [],
                    "forwards": [],
                    "utility": []
                }
            }
        }

def update_player_data_with_team(team_name="My AFL Team"):
    """
    Update the player_data.json file to include the user's team information
    
    This allows the tools to work with the user's actual team
    """
    team_data = get_team_data()
    if not team_data:
        return {"status": "error", "message": "No team data found"}
    
    # Load the player data
    ensure_file_exists('player_data.json', [])
    try:
        with open('player_data.json', 'r') as f:
            player_data = json.load(f)
    except:
        player_data = []
    
    # Create a map for faster lookups
    player_map = {}
    for i, player in enumerate(player_data):
        if 'name' in player:
            player_map[normalize_player_name(player['name'])] = i
    
    # Flatten the team structure
    all_team_players = []
    
    # Add on-field players
    for position, players in team_data.items():
        if position != "bench":
            for player in players:
                player["position"] = position.rstrip("s")  # Convert "defenders" to "defender"
                all_team_players.append(player)
    
    # Add bench players
    if "bench" in team_data:
        for position, players in team_data["bench"].items():
            if position != "utility":
                for player in players:
                    player["position"] = position.rstrip("s")  # Convert "defenders" to "defender"
                    player["is_bench"] = True
                    all_team_players.append(player)
            else:
                for player in players:
                    player["position"] = "utility"
                    player["is_bench"] = True
                    all_team_players.append(player)
    
    # Update player data with team membership
    for team_player in all_team_players:
        if 'name' not in team_player:
            continue
            
        normalized_name = normalize_player_name(team_player['name'])
        
        if normalized_name in player_map:
            # Update existing player
            idx = player_map[normalized_name]
            player_data[idx]["in_user_team"] = True
            player_data[idx]["user_team_name"] = team_name
            
            # Copy accurate data from team player
            for key, value in team_player.items():
                if key not in ["name", "team", "normalized_name"]:
                    player_data[idx][key] = value
        else:
            # Add new player
            new_player = team_player.copy()
            new_player["in_user_team"] = True
            new_player["user_team_name"] = team_name
            player_data.append(new_player)
    
    # Save the updated player data
    try:
        with open('player_data.json', 'w') as f:
            json.dump(player_data, f, indent=2)
        print("Player data updated with team information")
    except Exception as e:
        print(f"Error saving updated player data: {e}")
    
    return {
        "status": "ok",
        "message": "Player data updated with team information",
        "team_name": team_name,
        "player_count": len(all_team_players)
    }

# Existing get_team_data function is already defined above, no need for a duplicate

if __name__ == "__main__":
    # When run directly, update player data with team information
    result = update_player_data_with_team()
    print(json.dumps(result, indent=2))