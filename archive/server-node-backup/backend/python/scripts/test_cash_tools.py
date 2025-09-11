"""
Test the cash tools module to verify calculations
"""

from cash_tools import (
    cash_generation_tracker,
    rookie_price_curve_model,
    downgrade_target_finder,
    cash_gen_ceiling_floor
)

def main():
    """Test main function"""
    print("=== Testing Cash Generation Tracker ===")
    results = cash_generation_tracker()
    print(f"Found {len(results)} players for potential cash generation")
    print("\nTop 3 players by potential price increase:")
    for player in sorted(results, key=lambda x: x['price_change_est'], reverse=True)[:3]:
        print(f"{player['player']} (${player['price']:,}): ${player['price_change_est']:+,}")
    
    print("\n=== Testing Rookie Price Curve Model ===")
    rookies = rookie_price_curve_model()
    print(f"Found {len(rookies)} rookies to model")
    if rookies:
        rookie = rookies[0]
        print(f"\nSample rookie: {rookie.get('player')}")
        print(f"Current price: ${rookie.get('price'):,}")
        print(f"Price curve: {rookie.get('price_curve')}")
    
    print("\n=== Testing Downgrade Target Finder ===")
    targets = downgrade_target_finder()
    print(f"Found {len(targets)} potential downgrade targets")
    
    print("\n=== Testing Cash Gen Ceiling/Floor ===")
    ceiling_floors = cash_gen_ceiling_floor()
    print(f"Found {len(ceiling_floors)} players with ceiling/floor calculations")
    if ceiling_floors:
        cf = ceiling_floors[0]
        print(f"\nSample player: {cf.get('player')}")
        ceiling = cf.get('ceiling')
        floor = cf.get('floor')
        print(f"Ceiling: ${ceiling:+,}" if ceiling is not None else "Ceiling: None")
        print(f"Floor: ${floor:+,}" if floor is not None else "Floor: None")
        
if __name__ == "__main__":
    main()