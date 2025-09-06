# AFL Fantasy Data Import Instructions

## SUPER SIMPLE 2-STEP PROCESS FOR EXCEL

### Step 1: Upload Your Excel File
1. **Drag and drop** your Excel file into the file explorer (left sidebar)
2. **Any Excel format works:** .xlsx or .xls
3. **Any column names work** - I'll auto-detect and map them
4. **Multiple sheets OK** - I'll process all sheets automatically

### Step 2: Tell Me to Convert It
Just say: **"Convert my Excel file"** and I'll:
- ✅ **Auto-detect** your column structure
- ✅ **Map** to proper database format  
- ✅ **Convert** to CSV files
- ✅ **Import** into database with magic number 9650
- ✅ **Test** both algorithms with your real data
- ✅ **Show** you the results immediately

## THAT'S IT! 🎯

**No renaming needed. No format changes needed. Just upload and ask me to convert!**

## Step-by-Step Database Import Process

### Method 1: Upload Files to Project Directory

1. **Upload your data files to the project:**
   - Drag and drop files into the file explorer (left sidebar)
   - Or upload via the "+" button in file explorer
   - Supported formats: CSV, JSON, Excel (.xlsx)

2. **File naming convention:**
   - `player_round_scores.csv` - Individual round scores
   - `price_history.csv` - Historical price data
   - `opponent_history.csv` - Head-to-head records
   - `venue_history.csv` - Venue performance
   - `fixtures.csv` - Upcoming games

3. **Required CSV column headers:**

**player_round_scores.csv:**
```
player_id,player_name,round,score,price,opponent,venue,is_home,minutes,break_even,price_change
```

**price_history.csv:**
```
player_id,round,start_price,end_price,price_change,break_even,score,magic_number
```

**opponent_history.csv:**
```
player_id,opponent,average_score,games_played,last_score,last_3_average,last_round
```

**venue_history.csv:**
```
player_id,venue,average_score,games_played,last_score,last_3_average,last_round
```

**fixtures.csv:**
```
round,home_team,away_team,venue,game_date
```

### Method 2: Direct SQL Import

1. **Upload your data as CSV files**
2. **Run import script** (I'll create this for you)
3. **Verify data imported correctly**

### Method 3: JSON Bulk Import

Upload a single JSON file with this structure:
```json
{
  "playerRoundScores": [
    {
      "playerId": 1,
      "round": 1,
      "score": 120,
      "price": 500000,
      "opponent": "COL",
      "venue": "MCG",
      "isHome": true
    }
  ],
  "priceHistory": [...],
  "opponentHistory": [...],
  "venueHistory": [...],
  "fixtures": [...]
}
```

## Next Steps After Upload

1. I'll detect your file format automatically
2. Create import scripts for your specific data structure
3. Run data validation and import
4. Test the algorithms with your real data
5. Show you the results

## Database Tables Ready

The following tables are already created and waiting for your data:
- ✅ player_round_scores
- ✅ price_history  
- ✅ opponent_history
- ✅ venue_history
- ✅ fixtures
- ✅ system_parameters (magic number 9650 already set)

## Ready to Import

Simply upload your files and I'll handle the rest automatically!