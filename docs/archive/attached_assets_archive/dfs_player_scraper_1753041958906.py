import os
import time
import pandas as pd
from io import StringIO
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By

# Load player list
df = pd.read_excel("AFL_Fantasy_Player_URLs.xlsx")

# Setup headless Chrome
options = Options()
options.add_argument("--headless")
options.add_argument("--disable-gpu")
service = Service()
driver = webdriver.Chrome(service=service, options=options)

# Output folder
output_folder = "dfs_player_summary"
os.makedirs(output_folder, exist_ok=True)

# Table IDs to extract
TABLE_IDS = {
    "Career Averages": "fantasyPlayerCareer",
    "Opponent Splits": "vsOpponentCareer",
    "Game Logs": "playerGames"
}

# Scrape loop
for index, row in df.iterrows():
    player_id = row["playerId"]
    url = row["url"]
    print(f"🔄 Scraping {player_id}...")

    output_path = os.path.join(output_folder, f"{player_id}.xlsx")

    # Delete existing file
    if os.path.exists(output_path):
        try:
            os.remove(output_path)
        except PermissionError:
            print(f"❌ File in use or locked: {output_path}")
            continue

    try:
        driver.get(url)
        time.sleep(3)  # Let page fully load

        soup = BeautifulSoup(driver.page_source, "html.parser")
        writer = pd.ExcelWriter(output_path, engine="openpyxl")
        found_any = False

        for sheet_name, table_id in TABLE_IDS.items():
            table = soup.select_one(f"table#{table_id}")
            if table:
                df_table = pd.read_html(StringIO(str(table)))[0]
                df_table.to_excel(writer, sheet_name=sheet_name, index=False)
                found_any = True
            else:
                print(f"⚠️ Table '{sheet_name}' not found for {player_id}")

        writer.close()
        if found_any:
            print(f"✅ Saved {player_id}.xlsx")
        else:
            print(f"⚠️ No tables found for {player_id}")

    except Exception as e:
        print(f"❌ Error scraping {player_id}: {e}")

driver.quit()
print("✅ Scraping complete.")
