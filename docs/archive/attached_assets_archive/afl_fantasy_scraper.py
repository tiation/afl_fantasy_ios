import requests
from bs4 import BeautifulSoup
import pandas as pd

def scrape_footywire_breakevens(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')
    table = soup.find("table")
    rows = table.find_all("tr")
    data = []
    headers = [th.text.strip() for th in rows[0].find_all("th")]
    for row in rows[1:]:
        cols = [td.text.strip() for td in row.find_all("td")]
        if cols:
            data.append(cols)
    return pd.DataFrame(data, columns=headers)

def scrape_dfs_price_projector(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')
    table = soup.find("table")
    rows = table.find_all("tr")
    data = []
    headers = [th.text.strip() for th in rows[0].find_all("th")]
    for row in rows[1:]:
        cols = [td.text.strip() for td in row.find_all("td")]
        if cols:
            data.append(cols)
    return pd.DataFrame(data, columns=headers)

# Example usage:
# footywire_df = scrape_footywire_breakevens("https://www.footywire.com/afl/footy/dream_team_breakevens")
# dfs_df = scrape_dfs_price_projector("https://dfsaustralia.com/afl-fantasy-price-projector/")
# print(footywire_df.head())
# print(dfs_df.head())