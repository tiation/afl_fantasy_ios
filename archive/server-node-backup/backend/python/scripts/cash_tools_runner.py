
import json
import sys
from cash_tools import (
    cash_generation_tracker,
    rookie_price_curve_model,
    downgrade_target_finder, 
    cash_gen_ceiling_floor,
    price_predictor_calculator,
    price_ceiling_floor_estimator
)

def main():
    if len(sys.argv) < 2:
        print(json.dumps({"error": "No tool specified"}))
        return
        
    tool = sys.argv[1]
    
    try:
        if tool == "cash_generation_tracker":
            result = cash_generation_tracker()
            print(json.dumps({"status": "ok", "data": result}))
            
        elif tool == "rookie_price_curve":
            result = rookie_price_curve_model()
            print(json.dumps({"status": "ok", "data": result}))
            
        elif tool == "downgrade_targets":
            result = downgrade_target_finder()
            print(json.dumps({"status": "ok", "data": result}))
            
        elif tool == "ceiling_floor":
            result = cash_gen_ceiling_floor()
            print(json.dumps({"status": "ok", "data": result}))
            
        elif tool == "price_predictor":
            if len(sys.argv) < 4:
                print(json.dumps({"error": "Missing player_name or scores"}))
                return
                
            player_name = sys.argv[2]
            scores = json.loads(sys.argv[3])
            result = price_predictor_calculator(player_name, scores)
            print(json.dumps({"status": "ok", "data": result}))
            
        elif tool == "price_ceiling_floor":
            result = price_ceiling_floor_estimator()
            print(json.dumps({"status": "ok", "data": result}))
            
        else:
            print(json.dumps({"error": f"Unknown tool: {tool}"}))
            
    except Exception as e:
        print(json.dumps({"error": str(e)}))

if __name__ == "__main__":
    main()
  