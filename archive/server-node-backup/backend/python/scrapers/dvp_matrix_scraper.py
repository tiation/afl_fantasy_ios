"""
DVP Matrix Scraper

This script scrapes the DFS Australia website for Defense vs Position (DVP) data
and provides a structured matrix of how teams perform against each position.
"""

import requests
import pandas as pd
from bs4 import BeautifulSoup
import json

def get_dvp_matrix():
    """
    Scrape and parse the Defense vs Position (DVP) matrix from DFS Australia
    
    Returns:
        dict: A dictionary with position keys (DEF, MID, RUC, FWD) mapping to 
              team DVP data records
    """
    url = "https://dfsaustralia.com/afl-dvp/"
    response = requests.get(url)
    soup = BeautifulSoup(response.text, "html.parser")
    
    tables = pd.read_html(response.text)

    positions = ["DEF", "MID", "RUC", "FWD"]
    dvp_data = {}

    for i, pos in enumerate(positions):
        try:
            table = tables[i]
            table.columns = [c if i == 0 else c.split(" ")[0] for i, c in enumerate(table.columns)]
            table = table.rename(columns={table.columns[0]: "Team", table.columns[1]: "DVP"})
            dvp_data[pos] = table[["Team", "DVP"]].to_dict(orient="records")
        except Exception as e:
            dvp_data[pos] = {"error": str(e)}

    return dvp_data

def save_dvp_data(filename="dvp_matrix.json"):
    """
    Save the DVP matrix data to a JSON file
    
    Args:
        filename (str, optional): Output filename. Defaults to "dvp_matrix.json".
    """
    data = get_dvp_matrix()
    with open(filename, "w") as f:
        json.dump(data, f, indent=2)
    print(f"DVP matrix data saved to {filename}")

if __name__ == "__main__":
    # When run directly, print the DVP matrix data to console
    data = get_dvp_matrix()
    print(json.dumps(data, indent=2))
    
    # Optionally save the data to a file
    save_dvp_data()