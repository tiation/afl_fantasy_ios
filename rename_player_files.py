#!/usr/bin/env python3
"""
AFL Fantasy File Renamer
Renames player files from ID-based names to player names
"""

import os
import pandas as pd
import re

def clean_filename(filename):
    """Clean filename to be filesystem-safe"""
    # Remove invalid characters
    filename = re.sub(r'[<>:"/\\|?*]', '', filename)
    # Replace other problematic characters
    filename = filename.replace('/', '-').replace('\\', '-')
    # Remove extra spaces and dots
    filename = re.sub(r'\s+', ' ', filename).strip()
    filename = filename.replace('..', '.')
    return filename

def rename_player_files():
    """Rename player files from IDs to names"""
    print("📁 Starting file renaming process...")
    
    # Configuration
    folder_path = "dfs_player_summary"  # Update this path as needed
    mapping_file = "AFL_Fantasy_Player_URLs.xlsx"
    
    # Check if folder exists
    if not os.path.exists(folder_path):
        print(f"❌ Folder not found: {folder_path}")
        return
    
    # Check if mapping file exists
    if not os.path.exists(mapping_file):
        print(f"❌ Mapping file not found: {mapping_file}")
        print("Please ensure AFL_Fantasy_Player_URLs.xlsx exists with 'playerId' and 'Player' columns")
        return
    
    # Load mapping data
    try:
        df = pd.read_excel(mapping_file)
        print(f"✅ Loaded mapping file with {len(df)} records")
    except Exception as e:
        print(f"❌ Error loading mapping file: {e}")
        return
    
    # Validate required columns
    required_cols = ['playerId', 'Player']
    missing_cols = [col for col in required_cols if col not in df.columns]
    
    if missing_cols:
        print(f"❌ Missing required columns: {missing_cols}")
        print(f"Available columns: {list(df.columns)}")
        return
    
    # Clean and prepare data
    df['playerId'] = df['playerId'].astype(str).str.strip()
    df['Player'] = df['Player'].astype(str).str.strip()
    
    # Track statistics
    renamed_count = 0
    not_found_count = 0
    error_count = 0
    
    # Track duplicate names
    name_count = {}
    
    print(f"🔄 Processing {len(df)} player files...")
    print("-" * 60)
    
    for index, row in df.iterrows():
        player_id = row['playerId']
        player_name = row['Player']
        
        # Skip if essential data is missing
        if pd.isna(player_id) or pd.isna(player_name):
            print(f"⚠️ Skipping row {index+1}: Missing player ID or name")
            continue
        
        # Clean the player name for filename
        clean_name = clean_filename(player_name)
        
        # Handle duplicate names by adding a counter
        if clean_name in name_count:
            name_count[clean_name] += 1
            clean_name = f"{clean_name}_{name_count[clean_name]}"
        else:
            name_count[clean_name] = 0
        
        # Define file paths
        old_file = os.path.join(folder_path, f"{player_id}.xlsx")
        new_file = os.path.join(folder_path, f"{clean_name}.xlsx")
        
        try:
            if os.path.exists(old_file):
                if os.path.exists(new_file):
                    print(f"⚠️ Target exists: {new_file}")
                    # Add timestamp to make unique
                    import time
                    timestamp = int(time.time())
                    new_file = os.path.join(folder_path, f"{clean_name}_{timestamp}.xlsx")
                
                os.rename(old_file, new_file)
                print(f"✅ Renamed: {player_id}.xlsx → {clean_name}.xlsx")
                renamed_count += 1
                
            else:
                print(f"❌ File not found: {old_file}")
                not_found_count += 1
                
        except Exception as e:
            print(f"❌ Error renaming {player_id}.xlsx: {e}")
            error_count += 1
    
    # Print summary
    print("-" * 60)
    print("📊 RENAMING SUMMARY:")
    print(f"✅ Successfully renamed: {renamed_count}")
    print(f"❌ Files not found: {not_found_count}")
    print(f"⚠️ Errors occurred: {error_count}")
    print(f"📁 Total files processed: {renamed_count + not_found_count + error_count}")
    
    if renamed_count > 0:
        print("\n🎉 File renaming completed successfully!")
    else:
        print("\n⚠️ No files were renamed. Please check your file paths and data.")

def list_current_files():
    """List current files in the player summary folder"""
    folder_path = "dfs_player_summary"
    
    if not os.path.exists(folder_path):
        print(f"❌ Folder not found: {folder_path}")
        return
    
    files = [f for f in os.listdir(folder_path) if f.endswith('.xlsx')]
    files.sort()
    
    print(f"📁 Files in {folder_path}:")
    print("-" * 40)
    
    if files:
        for i, file in enumerate(files[:10], 1):  # Show first 10
            print(f"{i:2d}. {file}")
        
        if len(files) > 10:
            print(f"... and {len(files) - 10} more files")
        
        print(f"\nTotal: {len(files)} Excel files")
    else:
        print("No Excel files found")

if __name__ == "__main__":
    # First, show current files
    list_current_files()
    print("\n" + "="*60 + "\n")
    
    # Then rename files
    rename_player_files()
