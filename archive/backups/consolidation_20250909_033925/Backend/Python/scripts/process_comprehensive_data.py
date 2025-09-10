import pandas as pd
import json
import os
from pathlib import Path
import glob
from datetime import datetime
import traceback

def process_dfs_player_files():
    """Process all 604+ individual player Excel files from DFS"""
    print("Processing DFS player summary files...")
    
    player_data = []
    dfs_dir = Path("dfs_player_summary")
    
    if not dfs_dir.exists():
        print("DFS player summary directory not found")
        return []
    
    xlsx_files = list(dfs_dir.glob("*.xlsx"))
    print(f"Found {len(xlsx_files)} Excel files to process")
    
    processed = 0
    for file_path in xlsx_files:
        try:
            # Skip the main summary file
            if "afl-fantasy-2025" in file_path.name:
                continue
                
            player_name = file_path.stem
            print(f"Processing {player_name}...")
            
            # Try to read multiple sheets from each player file
            try:
                xl_file = pd.ExcelFile(file_path)
                sheets = xl_file.sheet_names
                
                player_info = {
                    'name': player_name,
                    'source': 'dfs_individual',
                    'sheets': sheets,
                    'data': {}
                }
                
                # Process key sheets
                for sheet_name in sheets:
                    try:
                        df = pd.read_excel(file_path, sheet_name=sheet_name)
                        
                        # Convert to dict, handling different data structures
                        if not df.empty:
                            if sheet_name.lower() in ['career averages', 'career_averages', 'summary']:
                                # Extract key stats from career averages
                                player_info['data']['career_stats'] = df.to_dict('records')
                            elif 'game' in sheet_name.lower() or 'log' in sheet_name.lower():
                                # Game logs
                                player_info['data']['game_logs'] = df.to_dict('records')
                            elif 'opponent' in sheet_name.lower() or 'vs' in sheet_name.lower():
                                # Opponent matchups
                                player_info['data']['opponent_splits'] = df.to_dict('records')
                            else:
                                # Other data
                                player_info['data'][sheet_name.lower()] = df.to_dict('records')
                    
                    except Exception as e:
                        print(f"  Warning: Could not process sheet {sheet_name}: {e}")
                
                player_data.append(player_info)
                processed += 1
                
                if processed % 50 == 0:
                    print(f"  Processed {processed} players...")
                    
            except Exception as e:
                print(f"  Error reading {file_path}: {e}")
                continue
                
        except Exception as e:
            print(f"Error processing {file_path}: {e}")
            continue
    
    print(f"Successfully processed {processed} DFS player files")
    return player_data

def process_keeper_data():
    """Process Keeper Scraper data"""
    print("Processing Keeper scraper data...")
    
    keeper_dir = Path("Keeper_Scraper")
    keeper_data = []
    
    if not keeper_dir.exists():
        print("Keeper Scraper directory not found")
        return []
    
    # Find all files in keeper directory
    for file_path in keeper_dir.rglob("*"):
        if file_path.is_file() and file_path.suffix in ['.xlsx', '.csv', '.json']:
            try:
                print(f"Processing keeper file: {file_path.name}")
                
                if file_path.suffix == '.xlsx':
                    df = pd.read_excel(file_path)
                elif file_path.suffix == '.csv':
                    df = pd.read_csv(file_path)
                elif file_path.suffix == '.json':
                    with open(file_path, 'r') as f:
                        data = json.load(f)
                        keeper_data.append({
                            'filename': file_path.name,
                            'type': 'json',
                            'data': data
                        })
                        continue
                
                if not df.empty:
                    keeper_data.append({
                        'filename': file_path.name,
                        'type': file_path.suffix,
                        'data': df.to_dict('records'),
                        'columns': list(df.columns)
                    })
                    
            except Exception as e:
                print(f"Error processing keeper file {file_path}: {e}")
    
    print(f"Processed {len(keeper_data)} keeper files")
    return keeper_data

def process_live_round13_data():
    """Process the live Round 13 data file"""
    print("Processing live Round 13 data...")
    
    try:
        # Try to read the Excel file
        file_path = "attached_assets/currentdt_liveR13_1753044004317.xlsx"
        
        if os.path.exists(file_path):
            xl_file = pd.ExcelFile(file_path)
            sheets = xl_file.sheet_names
            print(f"Found sheets: {sheets}")
            
            round13_data = {}
            for sheet in sheets:
                try:
                    df = pd.read_excel(file_path, sheet_name=sheet)
                    if not df.empty:
                        round13_data[sheet] = {
                            'columns': list(df.columns),
                            'data': df.to_dict('records'),
                            'row_count': len(df)
                        }
                        print(f"  Processed sheet {sheet}: {len(df)} rows")
                except Exception as e:
                    print(f"  Error processing sheet {sheet}: {e}")
            
            return round13_data
        else:
            print("Round 13 file not found")
            return {}
            
    except Exception as e:
        print(f"Error processing Round 13 data: {e}")
        return {}

def integrate_with_existing_data(dfs_data, keeper_data, round13_data):
    """Integrate new data with existing player database"""
    print("Integrating with existing player database...")
    
    # Load existing player data
    existing_files = [
        'player_data.json',
        'player_data_backup_20250501_201717.json'
    ]
    
    existing_players = {}
    for file_path in existing_files:
        if os.path.exists(file_path):
            try:
                with open(file_path, 'r') as f:
                    players = json.load(f)
                    
                for player in players:
                    if 'name' in player:
                        # Normalize name for matching
                        normalized_name = player['name'].lower().replace('.', '').replace(' ', '')
                        existing_players[normalized_name] = player
                        
                print(f"Loaded {len(players)} players from {file_path}")
            except Exception as e:
                print(f"Error loading {file_path}: {e}")
    
    # Enhance existing players with new data
    enhanced_players = []
    matches_found = 0
    
    for normalized_name, player in existing_players.items():
        enhanced_player = player.copy()
        
        # Try to match with DFS data
        for dfs_player in dfs_data:
            dfs_normalized = dfs_player['name'].lower().replace('.', '').replace(' ', '')
            if dfs_normalized == normalized_name or dfs_normalized in normalized_name or normalized_name in dfs_normalized:
                enhanced_player['dfs_enhanced'] = dfs_player['data']
                enhanced_player['data_sources'] = enhanced_player.get('data_sources', []) + ['dfs_individual']
                matches_found += 1
                break
        
        # Add Round 13 live data if available
        if round13_data:
            enhanced_player['round13_data'] = round13_data
            enhanced_player['data_sources'] = enhanced_player.get('data_sources', []) + ['round13_live']
        
        enhanced_players.append(enhanced_player)
    
    print(f"Enhanced {matches_found} players with DFS individual data")
    return enhanced_players

def save_processed_data(enhanced_players, dfs_data, keeper_data, round13_data):
    """Save all processed data"""
    print("Saving processed data...")
    
    # Create timestamp for backup
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    # Save enhanced player data
    enhanced_file = f"player_data_enhanced_{timestamp}.json"
    with open(enhanced_file, 'w') as f:
        json.dump(enhanced_players, f, indent=2)
    print(f"Saved enhanced player data to {enhanced_file}")
    
    # Save raw DFS data
    dfs_file = f"dfs_individual_data_{timestamp}.json"
    with open(dfs_file, 'w') as f:
        json.dump(dfs_data, f, indent=2)
    print(f"Saved DFS individual data to {dfs_file}")
    
    # Save keeper data
    if keeper_data:
        keeper_file = f"keeper_data_{timestamp}.json"
        with open(keeper_file, 'w') as f:
            json.dump(keeper_data, f, indent=2)
        print(f"Saved keeper data to {keeper_file}")
    
    # Save Round 13 data
    if round13_data:
        round13_file = f"round13_live_{timestamp}.json"
        with open(round13_file, 'w') as f:
            json.dump(round13_data, f, indent=2)
        print(f"Saved Round 13 data to {round13_file}")
    
    # Create summary report
    summary = {
        'processing_timestamp': timestamp,
        'total_enhanced_players': len(enhanced_players),
        'dfs_individual_files': len(dfs_data),
        'keeper_files': len(keeper_data),
        'round13_sheets': len(round13_data),
        'data_sources_available': ['dfs_individual', 'keeper_scraper', 'round13_live'],
        'files_created': [enhanced_file, dfs_file, keeper_file, round13_file]
    }
    
    summary_file = f"data_processing_summary_{timestamp}.json"
    with open(summary_file, 'w') as f:
        json.dump(summary, f, indent=2)
    
    print(f"Processing complete! Summary saved to {summary_file}")
    return summary

def main():
    """Main data processing function"""
    print("Starting comprehensive data processing...")
    print("=" * 60)
    
    try:
        # Process all data sources
        dfs_data = process_dfs_player_files()
        keeper_data = process_keeper_data()
        round13_data = process_live_round13_data()
        
        # Integrate with existing data
        enhanced_players = integrate_with_existing_data(dfs_data, keeper_data, round13_data)
        
        # Save processed data
        summary = save_processed_data(enhanced_players, dfs_data, keeper_data, round13_data)
        
        print("=" * 60)
        print("DATA PROCESSING COMPLETE!")
        print(f"Enhanced {summary['total_enhanced_players']} players")
        print(f"Processed {summary['dfs_individual_files']} DFS individual files")
        print(f"Processed {summary['keeper_files']} keeper files")
        print(f"Processed {summary['round13_sheets']} Round 13 data sheets")
        
    except Exception as e:
        print(f"Error in main processing: {e}")
        traceback.print_exc()

if __name__ == "__main__":
    main()