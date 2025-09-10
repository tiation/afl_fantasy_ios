# AFL Fantasy Scraper Setup & Usage Guide

## 🎯 Overview
This setup includes three main scripts for AFL Fantasy data collection and management:

1. **`basic_afl_scraper.py`** - Basic AFL Fantasy page scraper
2. **`afl_scraper.py`** - Advanced player-specific scraper (from your original code)  
3. **`rename_player_files.py`** - Utility to rename files from IDs to player names

## 🚀 Quick Start

### Prerequisites
```bash
# Ensure you're in the project directory
cd /Users/tiaastor/workspace/10_projects/afl_fantasy_ios

# Activate virtual environment
source venv/bin/activate
```

### Test Your Setup
```bash
# Test that everything works
python test_setup.py
```

## 📋 Scripts Overview

### 1. Basic AFL Scraper (`basic_afl_scraper.py`)

**Purpose**: General AFL Fantasy page scraping for exploratory data collection.

**Usage**:
```bash
python basic_afl_scraper.py
```

**What it does**:
- Opens the main AFL Fantasy page
- Looks for any data tables
- Saves tables as CSV files
- Saves raw HTML for inspection
- Shows preview of found data

**Output Files**:
- `afl_fantasy_table_1.csv`, `afl_fantasy_table_2.csv`, etc.
- `afl_fantasy_page.html` (raw page for inspection)

### 2. Advanced Player Scraper (`afl_scraper.py`)

**Purpose**: Detailed scraping of individual player statistics from specific URLs.

**Requirements**: 
- `AFL_Fantasy_Player_URLs.xlsx` file with columns:
  - `playerId`: Unique identifier for each player
  - `url`: Full URL to the player's fantasy page

**Usage**:
```bash
python afl_scraper.py
```

**What it does**:
- Reads player URLs from Excel file
- Visits each player's page individually
- Extracts specific data tables:
  - Career Averages (`fantasyPlayerCareer`)
  - Opponent Splits (`vsOpponentCareer`) 
  - Game Logs (`playerGames`)
- Saves each player's data as separate Excel file with multiple sheets
- Shows progress with emojis and status updates

**Output**:
- `dfs_player_summary/[playerId].xlsx` files
- Each Excel file contains multiple sheets (one per table type)

### 3. File Renamer (`rename_player_files.py`)

**Purpose**: Rename player files from ID-based names to readable player names.

**Requirements**:
- `AFL_Fantasy_Player_URLs.xlsx` with columns:
  - `playerId`: Original file identifier  
  - `Player`: Human-readable player name
- Existing files in `dfs_player_summary/` folder

**Usage**:
```bash
python rename_player_files.py
```

**What it does**:
- Shows current files in the directory
- Maps player IDs to names using the Excel file
- Renames files from `player_001.xlsx` to `Marcus Bontempelli.xlsx`
- Handles duplicate names by adding numbers
- Provides detailed progress and summary

## 📊 Sample Data Files

The setup includes sample data:

```csv
playerId,Player,url
player_001,Marcus Bontempelli,https://www.afl.com.au/fantasy/player/1
player_002,Patrick Cripps,https://www.afl.com.au/fantasy/player/2
player_003,Lachie Neale,https://www.afl.com.au/fantasy/player/3
```

## 🔧 Configuration

### Changing Target Tables (Advanced Scraper)
Edit the `TABLE_IDS` dictionary in `afl_scraper.py`:

```python
TABLE_IDS = {
    "Career Averages": "fantasyPlayerCareer",
    "Opponent Splits": "vsOpponentCareer", 
    "Game Logs": "playerGames",
    # Add new tables here:
    # "New Table": "tableId"
}
```

### Changing File Paths
Update paths in the scripts as needed:
- `folder_path` in `rename_player_files.py`
- `output_folder` in `afl_scraper.py`

## 🛠️ Troubleshooting

### Common Issues

**1. ChromeDriver Version Mismatch**
```bash
# This is handled automatically by webdriver-manager
# If you see errors, try updating:
pip install --upgrade webdriver-manager
```

**2. Missing Excel File**
```bash
# Create sample file:
python update_sample_data.py
```

**3. Permission Errors**
```bash
# Make sure files aren't open in Excel/other apps
# Check folder permissions
ls -la dfs_player_summary/
```

**4. Import Errors**
```bash
# Reinstall requirements:
pip install pandas beautifulsoup4 openpyxl selenium webdriver-manager lxml html5lib
```

### Debug Mode
Add this to any script for more debugging info:
```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

## 📈 Workflow Examples

### Full Scraping Workflow
```bash
# 1. Prepare data
python update_sample_data.py

# 2. Run advanced scraper
python afl_scraper.py

# 3. Rename files to readable names
python rename_player_files.py

# 4. Check results
ls -la dfs_player_summary/ | head -10
```

### Exploratory Workflow
```bash
# 1. Explore AFL Fantasy site structure
python basic_afl_scraper.py

# 2. Check what data was found
cat afl_fantasy_table_1.csv | head -5

# 3. Inspect raw HTML
open afl_fantasy_page.html
```

## 🔍 Monitoring & Logs

All scripts provide:
- ✅ Success indicators
- ⚠️ Warning messages  
- ❌ Error notifications
- 📊 Progress summaries

### Sample Output
```
🔄 Processing 150 player files...
✅ Renamed: player_001.xlsx → Marcus Bontempelli.xlsx
✅ Renamed: player_002.xlsx → Patrick Cripps.xlsx
⚠️ File not found: player_150.xlsx
📊 RENAMING SUMMARY:
✅ Successfully renamed: 149
❌ Files not found: 1
```

## 📝 Tips

1. **Start Small**: Test with 3-5 players before running full dataset
2. **Check URLs**: Ensure URLs in Excel file are accessible  
3. **Monitor Progress**: Scripts show real-time progress
4. **Backup Data**: Keep copies of original files before renaming
5. **Rate Limiting**: Scripts include delays to be respectful to servers

## 🚨 Important Notes

- **Respectful Scraping**: Scripts include delays between requests
- **Error Handling**: Scripts continue even if individual pages fail
- **File Safety**: Rename utility backs up existing files with timestamps
- **Chrome Version**: ChromeDriver is automatically managed - no manual setup needed

## 📞 Support

If you encounter issues:
1. Check the error messages carefully
2. Run `python test_setup.py` to verify your environment
3. Check that your Excel file has the correct column names
4. Ensure your URLs are valid and accessible

---

**Happy Scraping! 🎉**
