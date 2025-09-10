"""
AFL Fantasy Context Tools

This module provides contextual analysis tools to help Fantasy coaches
understand player performance patterns, seasonal trends, and contextual factors.
"""

# 1. Bye Round Optimizer – team load balance
def bye_round_optimizer():
    """
    Analyzes team bye round distribution to help balance player availability
    
    Returns:
        list: Bye round distribution with risk levels
    """
    return [
        {"round": "R12", "player_count": 8, "risk_level": "High"},
        {"round": "R13", "player_count": 5, "risk_level": "Medium"},
        {"round": "R14", "player_count": 7, "risk_level": "High"},
        {"round": "R15", "player_count": 3, "risk_level": "Low"}
    ]

# 2. Late Season Taper Flagger – mock historical dropoffs
def late_season_taper_flagger():
    """
    Identifies players with historical late-season performance drops
    
    Returns:
        list: Players with history of performance drops late in season
    """
    return [
        {"player": "Rory Laird", "warning": "History of taper after Round 18"},
        {"player": "Tim Taranto", "warning": "Avg drop of 12 points post R17 in 3 years"},
        {"player": "Jack Crisp", "warning": "Significant drop in TOG after R19 historically"},
        {"player": "Sam Walsh", "warning": "Managed more heavily late season, avg -8 pts"},
        {"player": "Patrick Cripps", "warning": "Body management risk after R20"},
        {"player": "Toby Greene", "warning": "Often rested once finals position secured"}
    ]

# 3. Fast Start Profile Scanner – early-season scorers
def fast_start_profile_scanner():
    """
    Identifies players who historically start seasons strongly
    
    Returns:
        list: Players with early-season performance trends
    """
    return [
        {"player": "Christian Petracca", "trend": "Fast starter – avg 110 in R1–5"},
        {"player": "Josh Dunkley", "trend": "Historically slow start, then builds"},
        {"player": "Clayton Oliver", "trend": "Typically starts season with 115+ avg first month"},
        {"player": "Nick Daicos", "trend": "Early season ceiling games historically"},
        {"player": "Zach Merrett", "trend": "Consistent performer regardless of season stage"},
        {"player": "Marcus Bontempelli", "trend": "Higher TOG% early season, before management"}
    ]

# 4. Venue Bias Detector – performance change by ground
def venue_bias_detector():
    """
    Analyzes player performance variations across different venues
    
    Returns:
        list: Players with significant venue performance biases
    """
    return [
        {"player": "Luke Ryan", "venue": "Optus Stadium", "bias": "+10 avg"},
        {"player": "Jordan Dawson", "venue": "Marvel Stadium", "bias": "-6 avg"},
        {"player": "Andrew Brayshaw", "venue": "MCG", "bias": "-8 avg"},
        {"player": "Tom Stewart", "venue": "GMHBA Stadium", "bias": "+12 avg"},
        {"player": "Errol Gulden", "venue": "SCG", "bias": "+15 avg"},
        {"player": "Jack Sinclair", "venue": "Marvel Stadium", "bias": "+7 avg"},
        {"player": "Darcy Parish", "venue": "MCG", "bias": "+9 avg"},
        {"player": "Lachie Neale", "venue": "Gabba", "bias": "+11 avg"}
    ]

# 5. Contract Year Motivation Checker – flagged players
def contract_year_motivation_checker():
    """
    Identifies players in contract years who may have extra motivation
    
    Returns:
        list: Players in contract years with motivation assessment
    """
    return [
        {"player": "Jack Lukosius", "status": "Out of contract – 2025"},
        {"player": "Tom Doedee", "status": "Free agent – contract year motivation"},
        {"player": "Bailey Smith", "status": "Restricted free agent - seeking big contract"},
        {"player": "Sam Taylor", "status": "Contract up for renewal - Brownlow darkhorse"},
        {"player": "Noah Anderson", "status": "Looking for elite-tier contract upgrade"},
        {"player": "Josh Treacy", "status": "Proving worth for first significant contract"}
    ]