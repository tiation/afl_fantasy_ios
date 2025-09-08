#!/usr/bin/env python3
"""
Test script to verify ChromeDriver and Selenium setup
"""
import sys
import pandas as pd
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager

def test_imports():
    """Test if all required packages can be imported"""
    try:
        import os
        import time
        import pandas as pd
        from io import StringIO
        from bs4 import BeautifulSoup
        from selenium import webdriver
        from selenium.webdriver.chrome.service import Service
        from selenium.webdriver.chrome.options import Options
        from selenium.webdriver.common.by import By
        from webdriver_manager.chrome import ChromeDriverManager
        print("✅ All imports successful")
        return True
    except ImportError as e:
        print(f"❌ Import failed: {e}")
        return False

def test_chromedriver():
    """Test ChromeDriver setup"""
    try:
        options = Options()
        options.add_argument("--headless")
        options.add_argument("--disable-gpu")
        options.add_argument("--no-sandbox")
        options.add_argument("--disable-dev-shm-usage")
        
        service = Service(ChromeDriverManager().install())
        driver = webdriver.Chrome(service=service, options=options)
        
        # Test basic navigation
        driver.get("https://httpbin.org/html")
        title = driver.title
        print(f"✅ ChromeDriver working - Page title: {title}")
        
        driver.quit()
        return True
    except Exception as e:
        print(f"❌ ChromeDriver test failed: {e}")
        return False

def test_pandas_excel():
    """Test pandas Excel functionality"""
    try:
        # Test Excel file exists
        df = pd.read_excel("AFL_Fantasy_Player_URLs.xlsx")
        print(f"✅ Excel file loaded - {len(df)} rows found")
        print(f"Columns: {list(df.columns)}")
        return True
    except Exception as e:
        print(f"❌ Excel test failed: {e}")
        return False

def main():
    print("🔧 Testing ChromeDriver and Selenium setup...")
    print("-" * 50)
    
    tests = [
        ("Package Imports", test_imports),
        ("ChromeDriver", test_chromedriver), 
        ("Excel File", test_pandas_excel)
    ]
    
    results = []
    for test_name, test_func in tests:
        print(f"\nTesting {test_name}:")
        result = test_func()
        results.append(result)
    
    print("\n" + "=" * 50)
    print("SUMMARY:")
    
    if all(results):
        print("🎉 All tests passed! Setup is ready to use.")
        print("\nTo run the scraper:")
        print("source venv/bin/activate && python afl_scraper.py")
    else:
        print("❌ Some tests failed. Please fix the issues above.")
        sys.exit(1)

if __name__ == "__main__":
    main()
