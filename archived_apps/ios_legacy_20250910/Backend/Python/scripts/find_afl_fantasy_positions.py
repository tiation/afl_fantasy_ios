#!/usr/bin/env python3
"""
Find the correct AFL Fantasy positions from the available spreadsheets
"""

import pandas as pd
import json

def check_dtlive_file():
    """Check the dtlive file for AFL Fantasy positions"""
    print("Checking dtlive_1752999476691.xlsx...")
    
    try:
        xl = pd.ExcelFile('attached_assets/dtlive_1752999476691.xlsx')
        print(f"Sheets: {xl.sheet_names}")
        
        for sheet in xl.sheet_names:
            df = pd.read_excel('attached_assets/dtlive_1752999476691.xlsx', sheet_name=sheet)
            print(f"\nSheet '{sheet}' columns: {list(df.columns)}")
            print(f"Sample data:")
            print(df.head(3).to_string())
            
    except Exception as e:
        print(f"Error reading dtlive file: {e}")

def check_currentdt_original():
    """Check the original currentdt file"""
    print("\nChecking currentdt_liveR13_1753044004317.xlsx...")
    
    try:
        xl = pd.ExcelFile('attached_assets/currentdt_liveR13_1753044004317.xlsx')
        print(f"Sheets: {xl.sheet_names}")
        
        for sheet in xl.sheet_names:
            df = pd.read_excel('attached_assets/currentdt_liveR13_1753044004317.xlsx', sheet_name=sheet)
            print(f"\nSheet '{sheet}' columns: {list(df.columns)}")
            print(f"Sample data:")
            print(df.head(3).to_string())
            
    except Exception as e:
        print(f"Error reading original currentdt file: {e}")

def check_afl_fantasy_2025():
    """Check the AFL Fantasy 2025 file"""
    print("\nChecking afl-fantasy-2025 (5).xlsx...")
    
    try:
        xl = pd.ExcelFile('attached_assets/afl-fantasy-2025 (5).xlsx')
        print(f"Sheets: {xl.sheet_names}")
        
        for sheet in xl.sheet_names:
            df = pd.read_excel('attached_assets/afl-fantasy-2025 (5).xlsx', sheet_name=sheet)
            print(f"\nSheet '{sheet}' columns: {list(df.columns)}")
            print(f"Sample data:")
            print(df.head(3).to_string())
            
    except Exception as e:
        print(f"Error reading AFL Fantasy 2025 file: {e}")

def main():
    """Check all potential files for AFL Fantasy position data"""
    check_dtlive_file()
    check_currentdt_original()
    check_afl_fantasy_2025()

if __name__ == "__main__":
    main()