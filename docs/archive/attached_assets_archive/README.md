# 🏉 Footywire AFL Stats Scraper 🏉

## 🎯 Kick Goals with AFL Data!

Ever wanted to analyze AFL player stats without the hassle of manual data entry? This simple R-based tool lets you fetch and analyze AFL player statistics from Footywire with just a few lines of code!

## 🏆 Why Use This Scraper?

- **Fantasy League Edge**: Get the latest player stats to dominate your fantasy footy league
- **Easy Analysis**: Export data to CSV for use in your favorite analysis tools
- **Up-to-Date**: Fetch the most current season data with minimal effort
- **Beginner-Friendly**: Simple commands that even footy fans new to R can use!

## 📋 Prerequisites

Before bouncing the ball, make sure you have:

- R installed on your computer
- Basic R knowledge (but don't worry, the commands are simple!)
- Internet connection to access Footywire data
- A passion for footy stats! 🏉

## 🚀 Installation

### 1. Install Required Packages

First, let's get the essential packages:

```R
# Install the remotes package for GitHub installations
install.packages("remotes")

# Install these helper packages
install.packages("httr")
install.packages("rvest")
install.packages("curl")
install.packages("httr2")
```

### 2. Install the fitzRoy Package

The magic happens with the fitzRoy package, which does the heavy lifting:

```R
# Install directly from GitHub for the latest version
remotes::install_github("jimmyday12/fitzRoy", force = TRUE)
```

### 3. Load the Library

```R
library(fitzRoy)
```

## 🎮 Usage Guide

Getting AFL stats is as easy as a set shot from directly in front! Just follow these steps:

```R
# Step 1: Get all match results for 2024
matches <- fetch_results_footywire(season = 2024)

# Step 2: Extract the match IDs
match_ids <- matches$match_id

# Step 3: Fetch player stats using match IDs
fw_data <- fetch_player_stats_footywire(match_ids)

# Step 4: Export to CSV
write.csv(fw_data, "footywire_2024_stats.csv", row.names = FALSE)
```

That's it! You now have a CSV file with all the player stats from the 2024 season.

## 📊 What Data You'll Get

The scraper collects comprehensive player statistics including:
- Disposals, marks, and goals
- Fantasy points
- Tackles and hitouts
- Time on ground
- And much more!

## 🛠️ Troubleshooting Tips

Even the best players have off days. Here's how to overcome common hurdles:

### Package Installation Issues
If you're having trouble installing fitzRoy:
```R
# Try with force = TRUE to reinstall dependencies
remotes::install_github("jimmyday12/fitzRoy", force = TRUE)

# If that doesn't work, try removing the package first
remove.packages("fitzRoy")
remotes::install_github("jimmyday12/fitzRoy", force = TRUE)
```

### Can't Find Saved Files?
Check your working directory:
```R
# See current working directory
getwd()

# Specify a full path when saving to be sure
write.csv(fw_data, "~/Downloads/footywire_2024_stats.csv", row.names = FALSE)

# Verify file exists
file.exists("~/Downloads/footywire_2024_stats.csv")
```

### Exploring Available Functions
Not sure what functions are available?
```R
# List all functions in the fitzRoy package
ls("package:fitzRoy")
```

### R Session Issues
If R is acting up:
```R
# Restart your R session
# In RStudio: Session > Restart R
# Or quit and restart:
q()
```

## 🌟 Pro Tips

- Update your data regularly during the season for the freshest stats
- Try different date ranges with `start_date` and `end_date` parameters
- Combine with other R packages like `dplyr` or `ggplot2` for powerful analysis

## 🏁 Final Siren

Now you're all set to become the data analysis champion of your footy group! Use these stats to gain insights, impress your mates, and maybe even predict the next Brownlow medalist!

Happy scraping and GO FOOTY! 🏆

