# scrapy_afl_fantasy_spider.py

import scrapy

class AFLFantasySpider(scrapy.Spider):
    name = "afl_fantasy"
    allowed_domains = ["footywire.com", "dfsaustralia.com", "fantasysports.win"]
    start_urls = [
        "https://www.footywire.com/afl/footy/dream_team_breakevens",
        "https://dfsaustralia.com/afl-fantasy-price-projector/",
        "https://www.fantasysports.win/break-evens.html?round=5"
    ]

    def parse(self, response):
        if "footywire" in response.url:
            yield from self.parse_footywire(response)
        elif "dfsaustralia" in response.url:
            yield from self.parse_dfsaustralia(response)
        elif "fantasysports" in response.url:
            yield from self.parse_fantasysports(response)

    def parse_footywire(self, response):
        rows = response.css("table tr")
        for row in rows[1:]:
            yield {
                "Player Name": row.css("td:nth-child(1)::text").get(),
                "Team": row.css("td:nth-child(2)::text").get(),
                "Position": row.css("td:nth-child(3)::text").get(),
                "Current Price": row.css("td:nth-child(5)::text").get(),
                "BE": row.css("td:nth-child(6)::text").get()
            }

    def parse_dfsaustralia(self, response):
        rows = response.css("table tr")
        for row in rows[1:]:
            yield {
                "Player Name": row.css("td:nth-child(1)::text").get(),
                "Projected Score": row.css("td:nth-child(2)::text").get(),
                "Projected Price Change": row.css("td:nth-child(3)::text").get()
            }

    def parse_fantasysports(self, response):
        rows = response.css("table tr")
        for row in rows[1:]:
            yield {
                "Player Name": row.css("td:nth-child(1)::text").get(),
                "Team": row.css("td:nth-child(2)::text").get(),
                "BE": row.css("td:nth-child(4)::text").get(),
                "Score": row.css("td:nth-child(5)::text").get()
            }