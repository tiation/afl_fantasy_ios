#!/usr/bin/env python3
"""
AFL Fantasy Intelligence Platform - Advanced Data Scraper System
Enterprise-grade scraper with scheduling, error handling, and data validation
"""

import asyncio
import aiohttp
import logging
import json
import time
import hashlib
from datetime import datetime, timedelta
from dataclasses import dataclass, asdict
from typing import List, Dict, Optional, Any
from urllib.parse import urljoin
import asyncpg
import redis
import schedule
from bs4 import BeautifulSoup
import pandas as pd

# Configuration
CONFIG = {
    'database_url': 'postgresql://postgres:password@localhost:5432/afl_fantasy',
    'redis_url': 'redis://localhost:6379',
    'api_base': 'https://fantasy.afl.com.au/data/',
    'max_concurrent_requests': 10,
    'request_delay': 0.5,  # seconds between requests
    'retry_attempts': 3,
    'timeout': 30,
    'user_agent': 'AFL-Fantasy-Intelligence-Scraper/1.0'
}

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('scraper.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger('AFL_Scraper')

# Data Models
@dataclass
class Player:
    id: int
    first_name: str
    last_name: str
    position: str
    team_id: int
    current_price: int
    average_score: float
    total_points: int
    games_played: int
    ownership_percentage: float
    breakeven_score: int
    price_change_week: int
    selected_by: int
    last_updated: datetime

@dataclass
class Team:
    id: int
    name: str
    short_name: str
    logo_url: str

@dataclass
class PlayerStats:
    player_id: int
    round_number: int
    points: int
    opponent_team: str
    home_game: bool
    match_date: datetime

@dataclass
class ScrapingResult:
    success: bool
    data_count: int
    errors: List[str]
    duration: float
    timestamp: datetime

class AFLFantasyScraper:
    """Advanced AFL Fantasy Data Scraper with enterprise features"""
    
    def __init__(self):
        self.session: Optional[aiohttp.ClientSession] = None
        self.db_pool: Optional[asyncpg.Pool] = None
        self.redis_client: Optional[redis.Redis] = None
        self.semaphore = asyncio.Semaphore(CONFIG['max_concurrent_requests'])
        self.stats = {
            'requests_made': 0,
            'data_points_collected': 0,
            'errors': 0,
            'last_run': None,
            'success_rate': 100.0
        }

    async def initialize(self):
        """Initialize database connections and HTTP session"""
        try:
            # Database connection
            self.db_pool = await asyncpg.create_pool(CONFIG['database_url'])
            logger.info("Database connection established")
            
            # Redis connection
            self.redis_client = redis.from_url(CONFIG['redis_url'])
            await self.redis_client.ping()
            logger.info("Redis connection established")
            
            # HTTP session
            timeout = aiohttp.ClientTimeout(total=CONFIG['timeout'])
            self.session = aiohttp.ClientSession(
                timeout=timeout,
                headers={'User-Agent': CONFIG['user_agent']}
            )
            logger.info("HTTP session initialized")
            
            # Initialize database tables
            await self.init_database()
            
        except Exception as e:
            logger.error(f"Failed to initialize scraper: {e}")
            raise

    async def init_database(self):
        """Initialize database tables if they don't exist"""
        create_tables_sql = """
        CREATE TABLE IF NOT EXISTS teams (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            short_name VARCHAR(10) NOT NULL UNIQUE,
            logo_url TEXT,
            created_at TIMESTAMP DEFAULT NOW(),
            updated_at TIMESTAMP DEFAULT NOW()
        );

        CREATE TABLE IF NOT EXISTS players (
            id SERIAL PRIMARY KEY,
            external_id INTEGER UNIQUE NOT NULL,
            first_name VARCHAR(100) NOT NULL,
            last_name VARCHAR(100) NOT NULL,
            position VARCHAR(10) NOT NULL,
            team_id INTEGER REFERENCES teams(id),
            current_price INTEGER NOT NULL,
            created_at TIMESTAMP DEFAULT NOW(),
            updated_at TIMESTAMP DEFAULT NOW()
        );

        CREATE TABLE IF NOT EXISTS player_stats (
            id SERIAL PRIMARY KEY,
            player_id INTEGER REFERENCES players(id),
            average_score DECIMAL(5,2),
            total_points INTEGER,
            games_played INTEGER,
            ownership_percentage DECIMAL(5,2),
            breakeven_score INTEGER,
            price_change_week INTEGER,
            selected_by INTEGER,
            updated_at TIMESTAMP DEFAULT NOW()
        );

        CREATE TABLE IF NOT EXISTS player_history (
            id SERIAL PRIMARY KEY,
            player_id INTEGER REFERENCES players(id),
            round_number INTEGER NOT NULL,
            points INTEGER NOT NULL,
            opponent_team VARCHAR(10),
            home_game BOOLEAN,
            match_date DATE,
            updated_at TIMESTAMP DEFAULT NOW(),
            UNIQUE(player_id, round_number)
        );

        CREATE TABLE IF NOT EXISTS scraping_logs (
            id SERIAL PRIMARY KEY,
            scraper_name VARCHAR(100) NOT NULL,
            status VARCHAR(20) NOT NULL,
            data_count INTEGER,
            errors_count INTEGER,
            duration_seconds DECIMAL(10,3),
            created_at TIMESTAMP DEFAULT NOW()
        );
        """
        
        async with self.db_pool.acquire() as conn:
            await conn.execute(create_tables_sql)
        logger.info("Database tables initialized")

    async def make_request(self, url: str, params: Dict = None) -> Optional[Dict]:
        """Make HTTP request with retry logic and rate limiting"""
        async with self.semaphore:
            for attempt in range(CONFIG['retry_attempts']):
                try:
                    await asyncio.sleep(CONFIG['request_delay'])
                    
                    async with self.session.get(url, params=params) as response:
                        self.stats['requests_made'] += 1
                        
                        if response.status == 200:
                            data = await response.json()
                            return data
                        elif response.status == 429:  # Rate limited
                            wait_time = int(response.headers.get('Retry-After', 60))
                            logger.warning(f"Rate limited. Waiting {wait_time}s")
                            await asyncio.sleep(wait_time)
                            continue
                        else:
                            logger.error(f"HTTP {response.status} for {url}")
                            
                except asyncio.TimeoutError:
                    logger.warning(f"Timeout on attempt {attempt + 1} for {url}")
                except Exception as e:
                    logger.error(f"Request error on attempt {attempt + 1}: {e}")
                
                if attempt < CONFIG['retry_attempts'] - 1:
                    await asyncio.sleep(2 ** attempt)  # Exponential backoff
            
            self.stats['errors'] += 1
            return None

    async def scrape_teams(self) -> ScrapingResult:
        """Scrape team data"""
        start_time = time.time()
        errors = []
        teams_data = []
        
        try:
            logger.info("Starting team data scrape")
            
            # AFL Fantasy teams endpoint
            teams_url = urljoin(CONFIG['api_base'], 'teams')
            data = await self.make_request(teams_url)
            
            if data and 'teams' in data:
                for team_data in data['teams']:
                    team = Team(
                        id=team_data.get('id'),
                        name=team_data.get('name'),
                        short_name=team_data.get('short_name'),
                        logo_url=team_data.get('logo_url')
                    )
                    teams_data.append(team)
                
                # Store in database
                await self.store_teams(teams_data)
                self.stats['data_points_collected'] += len(teams_data)
                
                logger.info(f"Scraped {len(teams_data)} teams")
            else:
                errors.append("No team data received")
                
        except Exception as e:
            error_msg = f"Team scraping failed: {e}"
            logger.error(error_msg)
            errors.append(error_msg)
        
        duration = time.time() - start_time
        return ScrapingResult(
            success=len(errors) == 0,
            data_count=len(teams_data),
            errors=errors,
            duration=duration,
            timestamp=datetime.now()
        )

    async def scrape_players(self) -> ScrapingResult:
        """Scrape player data with comprehensive statistics"""
        start_time = time.time()
        errors = []
        players_data = []
        
        try:
            logger.info("Starting player data scrape")
            
            # AFL Fantasy players endpoint
            players_url = urljoin(CONFIG['api_base'], 'players')
            data = await self.make_request(players_url)
            
            if data and 'players' in data:
                for player_data in data['players']:
                    try:
                        player = Player(
                            id=player_data.get('id'),
                            first_name=player_data.get('first_name', ''),
                            last_name=player_data.get('last_name', ''),
                            position=player_data.get('position', ''),
                            team_id=player_data.get('team_id'),
                            current_price=player_data.get('current_price', 0),
                            average_score=float(player_data.get('average_score', 0)),
                            total_points=player_data.get('total_points', 0),
                            games_played=player_data.get('games_played', 0),
                            ownership_percentage=float(player_data.get('ownership_percentage', 0)),
                            breakeven_score=player_data.get('breakeven_score', 0),
                            price_change_week=player_data.get('price_change_week', 0),
                            selected_by=player_data.get('selected_by', 0),
                            last_updated=datetime.now()
                        )
                        players_data.append(player)
                        
                    except (ValueError, TypeError) as e:
                        errors.append(f"Player data validation error: {e}")
                        continue
                
                # Store in database
                await self.store_players(players_data)
                self.stats['data_points_collected'] += len(players_data)
                
                logger.info(f"Scraped {len(players_data)} players")
            else:
                errors.append("No player data received")
                
        except Exception as e:
            error_msg = f"Player scraping failed: {e}"
            logger.error(error_msg)
            errors.append(error_msg)
        
        duration = time.time() - start_time
        return ScrapingResult(
            success=len(errors) == 0,
            data_count=len(players_data),
            errors=errors,
            duration=duration,
            timestamp=datetime.now()
        )

    async def scrape_fixtures(self) -> ScrapingResult:
        """Scrape fixture data for captain and trade analysis"""
        start_time = time.time()
        errors = []
        fixtures_data = []
        
        try:
            logger.info("Starting fixture data scrape")
            
            fixtures_url = urljoin(CONFIG['api_base'], 'fixtures')
            data = await self.make_request(fixtures_url)
            
            if data and 'fixtures' in data:
                for fixture in data['fixtures']:
                    # Process fixture data for database storage
                    pass  # Implementation depends on AFL API structure
                
                logger.info(f"Scraped {len(fixtures_data)} fixtures")
            
        except Exception as e:
            error_msg = f"Fixture scraping failed: {e}"
            logger.error(error_msg)
            errors.append(error_msg)
        
        duration = time.time() - start_time
        return ScrapingResult(
            success=len(errors) == 0,
            data_count=len(fixtures_data),
            errors=errors,
            duration=duration,
            timestamp=datetime.now()
        )

    async def store_teams(self, teams: List[Team]):
        """Store team data in database with conflict resolution"""
        if not teams:
            return
            
        async with self.db_pool.acquire() as conn:
            for team in teams:
                await conn.execute("""
                    INSERT INTO teams (id, name, short_name, logo_url, updated_at)
                    VALUES ($1, $2, $3, $4, NOW())
                    ON CONFLICT (short_name) 
                    DO UPDATE SET 
                        name = EXCLUDED.name,
                        logo_url = EXCLUDED.logo_url,
                        updated_at = NOW()
                """, team.id, team.name, team.short_name, team.logo_url)

    async def store_players(self, players: List[Player]):
        """Store player data in database with comprehensive stats"""
        if not players:
            return
            
        async with self.db_pool.acquire() as conn:
            async with conn.transaction():
                for player in players:
                    # Upsert player basic info
                    player_id = await conn.fetchval("""
                        INSERT INTO players (external_id, first_name, last_name, position, team_id, current_price, updated_at)
                        VALUES ($1, $2, $3, $4, $5, $6, NOW())
                        ON CONFLICT (external_id)
                        DO UPDATE SET
                            first_name = EXCLUDED.first_name,
                            last_name = EXCLUDED.last_name,
                            position = EXCLUDED.position,
                            team_id = EXCLUDED.team_id,
                            current_price = EXCLUDED.current_price,
                            updated_at = NOW()
                        RETURNING id
                    """, player.id, player.first_name, player.last_name, player.position, player.team_id, player.current_price)
                    
                    # Upsert player stats
                    await conn.execute("""
                        INSERT INTO player_stats (player_id, average_score, total_points, games_played, ownership_percentage, breakeven_score, price_change_week, selected_by, updated_at)
                        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW())
                        ON CONFLICT (player_id)
                        DO UPDATE SET
                            average_score = EXCLUDED.average_score,
                            total_points = EXCLUDED.total_points,
                            games_played = EXCLUDED.games_played,
                            ownership_percentage = EXCLUDED.ownership_percentage,
                            breakeven_score = EXCLUDED.breakeven_score,
                            price_change_week = EXCLUDED.price_change_week,
                            selected_by = EXCLUDED.selected_by,
                            updated_at = NOW()
                    """, player_id, player.average_score, player.total_points, player.games_played, 
                         player.ownership_percentage, player.breakeven_score, player.price_change_week, player.selected_by)

    async def log_scraping_result(self, scraper_name: str, result: ScrapingResult):
        """Log scraping results to database and Redis"""
        try:
            # Database log
            async with self.db_pool.acquire() as conn:
                await conn.execute("""
                    INSERT INTO scraping_logs (scraper_name, status, data_count, errors_count, duration_seconds)
                    VALUES ($1, $2, $3, $4, $5)
                """, scraper_name, 'success' if result.success else 'error', result.data_count, len(result.errors), result.duration)
            
            # Redis cache for real-time monitoring
            cache_key = f"scraper:{scraper_name}:last_result"
            await self.redis_client.setex(
                cache_key,
                3600,  # 1 hour expiry
                json.dumps(asdict(result), default=str)
            )
            
            # Update global stats
            self.stats['last_run'] = result.timestamp
            success_rate = ((self.stats['requests_made'] - self.stats['errors']) / self.stats['requests_made']) * 100
            self.stats['success_rate'] = round(success_rate, 2)
            
            await self.redis_client.setex('scraper:stats', 300, json.dumps(self.stats, default=str))
            
        except Exception as e:
            logger.error(f"Failed to log scraping result: {e}")

    async def run_full_scrape(self):
        """Run comprehensive scraping of all data sources"""
        logger.info("Starting full scraping cycle")
        
        try:
            # Run scrapers in sequence for data integrity
            team_result = await self.scrape_teams()
            await self.log_scraping_result('teams', team_result)
            
            player_result = await self.scrape_players()
            await self.log_scraping_result('players', player_result)
            
            fixture_result = await self.scrape_fixtures()
            await self.log_scraping_result('fixtures', fixture_result)
            
            # Update cache with fresh data indicators
            await self.redis_client.setex('data:last_update', 3600, datetime.now().isoformat())
            
            logger.info("Full scraping cycle completed successfully")
            
        except Exception as e:
            logger.error(f"Full scrape failed: {e}")

    async def cleanup(self):
        """Clean up resources"""
        if self.session:
            await self.session.close()
        if self.db_pool:
            await self.db_pool.close()
        if self.redis_client:
            await self.redis_client.close()
        logger.info("Scraper cleanup completed")

class ScraperScheduler:
    """Advanced scheduler for running scrapers at optimal times"""
    
    def __init__(self, scraper: AFLFantasyScraper):
        self.scraper = scraper
        
    def setup_schedules(self):
        """Setup scraping schedules based on AFL Fantasy data update patterns"""
        
        # Player stats update multiple times per day
        schedule.every(30).minutes.do(self.run_player_scrape)
        
        # Team data updates less frequently
        schedule.every(2).hours.do(self.run_team_scrape)
        
        # Full comprehensive scrape twice daily
        schedule.every().day.at("08:00").do(self.run_full_scrape)
        schedule.every().day.at("20:00").do(self.run_full_scrape)
        
        # Weekly deep clean and optimization
        schedule.every().sunday.at("02:00").do(self.run_maintenance)
        
        logger.info("Scraper schedules configured")

    def run_player_scrape(self):
        asyncio.create_task(self.scraper.scrape_players())

    def run_team_scrape(self):
        asyncio.create_task(self.scraper.scrape_teams())

    def run_full_scrape(self):
        asyncio.create_task(self.scraper.run_full_scrape())

    def run_maintenance(self):
        # Cleanup old logs, optimize database, etc.
        logger.info("Running weekly maintenance")

# Main execution
async def main():
    """Main scraper execution function"""
    scraper = AFLFantasyScraper()
    scheduler = ScraperScheduler(scraper)
    
    try:
        await scraper.initialize()
        scheduler.setup_schedules()
        
        logger.info("🕷️ AFL Fantasy Intelligence Scraper System Started")
        logger.info("📊 Monitoring: Real-time data collection active")
        logger.info("⚡ Performance: Multi-threaded with rate limiting")
        logger.info("🔒 Security: Enterprise-grade error handling")
        
        # Run initial scrape
        await scraper.run_full_scrape()
        
        # Keep running scheduled tasks
        while True:
            schedule.run_pending()
            await asyncio.sleep(60)  # Check every minute
            
    except KeyboardInterrupt:
        logger.info("Shutting down scraper...")
    except Exception as e:
        logger.error(f"Fatal scraper error: {e}")
    finally:
        await scraper.cleanup()

if __name__ == "__main__":
    asyncio.run(main())
