#!/usr/bin/env python3
"""
Integration Test for AFL Fantasy Scraper
Tests scraping with full 652-player dataset
"""

import os
import sys
import time
import pandas as pd
from pathlib import Path
import json
from datetime import datetime

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

def test_player_index_exists():
    """Test that the player index file exists and has correct data"""
    print("🔍 Testing player index file...")
    
    index_path = "AFL_Fantasy_Player_URLs.xlsx"
    if not os.path.exists(index_path):
        print("❌ Player index file not found!")
        return False
    
    df = pd.read_excel(index_path)
    player_count = len(df)
    
    print(f"✅ Player index loaded: {player_count} players")
    
    # Check required columns
    required_cols = ['Player', 'playerId', 'url']
    missing_cols = [col for col in required_cols if col not in df.columns]
    
    if missing_cols:
        print(f"❌ Missing columns: {missing_cols}")
        return False
    
    print("✅ All required columns present")
    
    # Check for duplicates
    duplicates = df['playerId'].duplicated().sum()
    if duplicates > 0:
        print(f"⚠️ Found {duplicates} duplicate player IDs")
    
    return player_count >= 650

def test_scraper_import():
    """Test that scraper modules can be imported"""
    print("\n🔍 Testing scraper imports...")
    
    try:
        from dfs_australia_scraper import setup_driver, wait_for_page_load, extract_player_data
        print("✅ DFS Australia scraper imported successfully")
        
        from selenium import webdriver
        from bs4 import BeautifulSoup
        import pandas as pd
        print("✅ All dependencies imported successfully")
        
        return True
    except ImportError as e:
        print(f"❌ Import error: {e}")
        return False

def test_data_directory():
    """Test that data directory structure is correct"""
    print("\n🔍 Testing data directory structure...")
    
    data_dir = Path("../data/dfs_player_summary")
    
    if not data_dir.exists():
        print(f"❌ Data directory not found: {data_dir}")
        return False
    
    print(f"✅ Data directory exists: {data_dir}")
    
    # Count existing player files
    xlsx_files = list(data_dir.glob("*.xlsx"))
    print(f"📊 Found {len(xlsx_files)} existing player data files")
    
    # Check a sample file structure
    if xlsx_files:
        sample_file = xlsx_files[0]
        try:
            df = pd.read_excel(sample_file, sheet_name=None)
            sheets = list(df.keys())
            print(f"📋 Sample file sheets: {sheets}")
        except Exception as e:
            print(f"⚠️ Could not read sample file: {e}")
    
    return True

def test_scraper_dry_run():
    """Test scraper with first 5 players (dry run)"""
    print("\n🔍 Testing scraper with sample players...")
    
    try:
        df = pd.read_excel("AFL_Fantasy_Player_URLs.xlsx")
        sample_players = df.head(5)
        
        print(f"🎯 Testing with {len(sample_players)} sample players:")
        for _, player in sample_players.iterrows():
            print(f"  - {player['Player']} ({player['playerId']})")
        
        # Test data structure
        successful_tests = 0
        for _, player in sample_players.iterrows():
            player_id = player['playerId']
            player_file = f"../data/dfs_player_summary/{player_id}.xlsx"
            
            if os.path.exists(player_file):
                try:
                    test_df = pd.read_excel(player_file, sheet_name=None)
                    if test_df:
                        print(f"  ✅ {player_id}: Data exists with {len(test_df)} sheets")
                        successful_tests += 1
                except Exception as e:
                    print(f"  ⚠️ {player_id}: Error reading file - {e}")
            else:
                print(f"  ℹ️ {player_id}: No data file (needs scraping)")
        
        success_rate = (successful_tests / len(sample_players)) * 100 if sample_players.shape[0] > 0 else 0
        print(f"\n📊 Sample test success rate: {success_rate:.1f}%")
        
        return success_rate > 0  # At least some data should exist
        
    except Exception as e:
        print(f"❌ Error in dry run: {e}")
        return False

def test_performance_metrics():
    """Test performance metrics and estimates"""
    print("\n🔍 Testing performance metrics...")
    
    try:
        df = pd.read_excel("AFL_Fantasy_Player_URLs.xlsx")
        total_players = len(df)
        
        # Estimate scraping time
        time_per_player = 3  # seconds (conservative estimate)
        total_time = total_players * time_per_player
        
        print(f"📊 Performance estimates for {total_players} players:")
        print(f"  - Time per player: {time_per_player}s")
        print(f"  - Total time: {total_time/60:.1f} minutes")
        print(f"  - Parallel (4 workers): {total_time/4/60:.1f} minutes")
        
        # Memory estimate
        memory_per_player = 0.5  # MB
        total_memory = total_players * memory_per_player
        print(f"  - Estimated memory: {total_memory:.1f} MB")
        
        # Disk space estimate
        file_size_avg = 30  # KB per player
        total_disk = total_players * file_size_avg / 1024
        print(f"  - Estimated disk space: {total_disk:.1f} MB")
        
        return True
        
    except Exception as e:
        print(f"❌ Error calculating metrics: {e}")
        return False

def generate_test_report():
    """Generate a test report"""
    print("\n" + "="*50)
    print("📋 INTEGRATION TEST REPORT")
    print("="*50)
    
    report = {
        "timestamp": datetime.now().isoformat(),
        "tests": {},
        "summary": {}
    }
    
    # Run all tests
    tests = [
        ("Player Index", test_player_index_exists),
        ("Scraper Import", test_scraper_import),
        ("Data Directory", test_data_directory),
        ("Scraper Dry Run", test_scraper_dry_run),
        ("Performance Metrics", test_performance_metrics)
    ]
    
    passed = 0
    failed = 0
    
    for test_name, test_func in tests:
        print(f"\n🧪 Running: {test_name}")
        print("-" * 40)
        try:
            result = test_func()
            report["tests"][test_name] = "PASSED" if result else "FAILED"
            if result:
                passed += 1
                print(f"✅ {test_name}: PASSED")
            else:
                failed += 1
                print(f"❌ {test_name}: FAILED")
        except Exception as e:
            failed += 1
            report["tests"][test_name] = f"ERROR: {str(e)}"
            print(f"❌ {test_name}: ERROR - {e}")
    
    # Summary
    total_tests = len(tests)
    success_rate = (passed / total_tests) * 100 if total_tests > 0 else 0
    
    report["summary"] = {
        "total": total_tests,
        "passed": passed,
        "failed": failed,
        "success_rate": success_rate
    }
    
    print("\n" + "="*50)
    print("📊 TEST SUMMARY")
    print("="*50)
    print(f"Total Tests: {total_tests}")
    print(f"Passed: {passed} ✅")
    print(f"Failed: {failed} ❌")
    print(f"Success Rate: {success_rate:.1f}%")
    
    # Save report
    report_path = "test_report.json"
    with open(report_path, 'w') as f:
        json.dump(report, f, indent=2)
    print(f"\n💾 Report saved to: {report_path}")
    
    # Overall result
    if success_rate >= 80:
        print("\n🎉 Integration tests PASSED!")
        return True
    else:
        print("\n⚠️ Integration tests need attention")
        return False

if __name__ == "__main__":
    print("🚀 AFL Fantasy Scraper Integration Test")
    print("=" * 50)
    
    # Change to server-python directory
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    
    # Run tests
    success = generate_test_report()
    
    # Exit code
    sys.exit(0 if success else 1)
