# AFL Fantasy Data Integration

This document explains how player data is integrated into the AFL Fantasy Tools application.

## Data Sources

The application supports multiple data sources with a fallback chain:

1. **CSV Import** - The most reliable source of up-to-date player information
2. **FootyWire Scraper** - JavaScript-based scraping of FootyWire website (when available)
3. **Fallback Player Data** - Built-in player database when external sources are unavailable

## CSV Data Import

The most reliable data source is the official AFL Fantasy data imported via CSV. The process works as follows:

1. Use the `import_csv_breakevens.js` script to process the `All_Player_Breakevens_-_Round_7.csv` file
2. This extracts player names, positions, prices, and breakeven values
3. Data is saved to the `player_data.json` file for application use
4. This data takes priority over other sources

## FootyWire Integration

When the FootyWire website is accessible, the application can scrape player data:

1. `footywire_js_scraper.js` attempts to scrape data from FootyWire
2. If successful, this data is used as a supplement to CSV data or as primary data if CSV is unavailable
3. This data source may be unreliable due to website access restrictions

## Data Processing

The application transforms raw data through several steps:

1. **Data Normalization** - Convert various formats to a standard format
2. **Player Matching** - Match player names across different data sources
3. **Value Computation** - Calculate derived values like averages if not provided
4. **Team Integration** - Map player data to team positions

## Updating Player Data

To update player data with the latest information:

1. Place an updated CSV in the `attached_assets` folder
2. Update the file path in `import_csv_breakevens.js` if needed
3. Run the script using `node import_csv_breakevens.js`
4. Restart the application to use the new data

## Data Format

The player data follows this structure:

```javascript
{
  "name": "M. Bontempelli",
  "position": "MID",
  "price": 1086000,
  "breakeven": 137,
  "avg": 137,
  "breakEven": 137,
  "last3_avg": 137,
  "last5_avg": 133,
  "projected_score": 142,
  "source": "csv_import",
  "games": 12,
  "timestamp": 1746158040,
  "status": "fit"
}
```

## Troubleshooting

If you encounter data integration issues:

1. **Missing Players** - Check if the player's name format in your team matches the format in the data source
2. **Incorrect Values** - Verify the data in the source CSV file
3. **No Data** - Check if `player_data.json` exists and contains valid data