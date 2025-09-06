# scrapy_afl_fantasy_extended_spider.py

import scrapy

class AFLFantasyExtendedSpider(scrapy.Spider):
    name = "afl_fantasy_extended"
    allowed_domains = [
        "footywire.com", "dfsaustralia.com", "fantasysports.win",
        "afl.com.au", "bigfooty.com", "twitter.com"
    ]
    start_urls = [
        "https://www.footywire.com/afl/footy/dream_team_breakevens",
        "https://dfsaustralia.com/afl-fantasy-price-projector/",
        "https://www.fantasysports.win/break-evens.html?round=5",
        "https://www.afl.com.au/news/injury-list",
        "https://www.bigfooty.com/forum/forums/afl-fantasy.168/",
        "https://twitter.com/search?q=afl%20fantasy%20OUT&src=typed_query"
    ]

    def parse(self, response):
        if "footywire" in response.url:
            yield from self.parse_footywire(response)
        elif "dfsaustralia" in response.url:
            yield from self.parse_dfsaustralia(response)
        elif "fantasysports" in response.url:
            yield from self.parse_fantasysports(response)
        elif "afl.com.au" in response.url:
            yield from self.parse_afl_injury_list(response)
        elif "bigfooty" in response.url:
            yield from self.parse_bigfooty_tags(response)
        elif "twitter" in response.url:
            yield from self.parse_x_twitter_alerts(response)

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

    def parse_afl_injury_list(self, response):
        for row in response.css("table tr"):
            yield {
                "Player Name": row.css("td:nth-child(1)::text").get(),
                "Injury Status": row.css("td:nth-child(2)::text").get()
            }

    def parse_bigfooty_tags(self, response):
        for post in response.css("div.structItem--thread"):
            yield {
                "Thread Title": post.css("div.structItem-title a::text").get(),
                "Thread Link": response.urljoin(post.css("div.structItem-title a::attr(href)").get())
            }

    def parse_x_twitter_alerts(self, response):
        for tweet in response.css("div[lang]"):
            text = tweet.css("::text").getall()
            if "OUT" in "".join(text).upper():
                yield {
                    "Tweet": "".join(text).strip()
                }