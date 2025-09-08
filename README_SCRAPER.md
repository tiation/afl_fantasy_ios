# AFL Fantasy Web Scraper Setup

This setup provides a complete web scraping solution for AFL Fantasy player data using Selenium and ChromeDriver.

## ✅ What's Installed

- **ChromeDriver**: Automatically managed via `webdriver-manager` (no version conflicts!)
- **Selenium**: Web automation framework for Python
- **Required packages**: pandas, beautifulsoup4, openpyxl, lxml, html5lib
- **Sample data**: `AFL_Fantasy_Player_URLs.xlsx` with example structure

## 📁 Files Created

```
afl_fantasy_ios/
├── afl_scraper.py              # Main scraping script
├── test_setup.py               # Test script to verify setup
├── create_sample_data.py       # Creates sample Excel file
├── AFL_Fantasy_Player_URLs.xlsx # Input file with player URLs
├── dfs_player_summary/         # Output folder for scraped data
└── venv/                       # Python virtual environment
```

## 🚀 How to Use

### 1. Activate Virtual Environment
```bash
source venv/bin/activate
```

### 2. Update Player URLs
Edit `AFL_Fantasy_Player_URLs.xlsx` with actual AFL Fantasy player URLs:
- Column 1: `playerId` (unique identifier)
- Column 2: `url` (full URL to player page)

### 3. Run the Scraper
```bash
python afl_scraper.py
```

### 4. Check Output
Scraped data will be saved in `dfs_player_summary/` folder as Excel files.

## 🔧 Test Your Setup
```bash
python test_setup.py
```

## 📊 What Gets Scraped

The scraper looks for these tables on each player page:
- **Career Averages** (table ID: `fantasyPlayerCareer`)
- **Opponent Splits** (table ID: `vsOpponentCareer`)  
- **Game Logs** (table ID: `playerGames`)

Each table gets saved as a separate sheet in the output Excel file.

## ⚙️ Configuration

### Headless Mode
The scraper runs in headless mode by default (no browser window). To see the browser:
```python
# In afl_scraper.py, comment out this line:
# options.add_argument("--headless")
```

### Timing
Adjust the sleep time between page loads:
```python
time.sleep(3)  # Change to different number of seconds
```

## 🐛 Troubleshooting

### Chrome Version Issues
The setup uses `webdriver-manager` which automatically downloads the correct ChromeDriver version for your Chrome browser. No manual version matching needed!

### Permission Errors
If you get file permission errors, make sure Excel files aren't open in other applications.

### Network Issues
Add longer delays or retry logic if pages are slow to load.

## 🔄 Updates

To update packages:
```bash
source venv/bin/activate
pip install --upgrade selenium webdriver-manager pandas beautifulsoup4 openpyxl
```

## 📝 Notes

- Always respect website terms of service and rate limits
- Consider adding delays between requests to avoid overwhelming servers
- Test with a small subset of URLs first
- The sample URLs are placeholders - replace with actual AFL Fantasy URLs
