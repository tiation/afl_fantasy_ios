#!/usr/bin/env python3
"""
Process the authentic AFL Fantasy Excel data
Uses the actual Round 13 live data from currentdt_liveR13_1753069161334.xlsx
"""

import pandas as pd
import json
import datetime

def process_excel_data():
    """Process the authentic Excel file"""
    print("Processing authentic AFL Fantasy Excel data...")
    
    try:
        # Read the Excel file
        excel_file = 'attached_assets/currentdt_liveR13_1753069161334.xlsx'
        
        # Try to read all sheets to see what's available
        xl = pd.ExcelFile(excel_file)
        print(f"Available sheets: {xl.sheet_names}")
        
        # Read the main data sheet (usually the first one or 'Data')
        if 'Data' in xl.sheet_names:
            df = pd.read_excel(excel_file, sheet_name='Data')
        else:
            df = pd.read_excel(excel_file, sheet_name=0)  # First sheet
        
        print(f"Loaded {len(df)} rows from Excel")
        print(f"Columns: {list(df.columns)}")
        
        # Show first few rows to understand the structure
        print("\nFirst 5 rows:")
        print(df.head().to_string())
        
        return df
        
    except Exception as e:
        print(f"Error processing Excel file: {e}")
        return None

def create_authentic_database_from_excel():
    """Create authentic database from Excel data"""
    df = process_excel_data()
    
    if df is None:
        print("Could not load Excel data")
        return
    
    players = []
    player_id = 40000  # Use high IDs to avoid conflicts
    
    # Process each row
    for index, row in df.iterrows():
        try:
            # Extract player data (adjust column names based on actual Excel structure)
            # We'll need to examine the actual column names first
            player_data = {
                'id': player_id,
                'source': 'Authentic_Excel_R13'
            }
            
            # Add all available columns from Excel
            for col in df.columns:
                if pd.notna(row[col]):
                    player_data[col] = row[col]
            
            players.append(player_data)
            player_id += 1
            
        except Exception as e:
            print(f"Error processing row {index}: {e}")
            continue
    
    # Create backup
    backup_filename = f"player_data_backup_before_excel_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    try:
        import shutil
        shutil.copy('player_data_stats_enhanced_20250720_205845.json', backup_filename)
        print(f"Created backup: {backup_filename}")
    except:
        print("Could not create backup")
    
    # Save the data
    with open('excel_data_raw.json', 'w') as f:
        json.dump(players, f, indent=2)
    
    print(f"Saved {len(players)} records from Excel to excel_data_raw.json")
    print("Please check this file to see the actual data structure")

if __name__ == "__main__":
    create_authentic_database_from_excel()