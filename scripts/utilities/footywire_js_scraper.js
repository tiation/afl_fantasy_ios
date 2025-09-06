#!/usr/bin/env node

/**
 * FootyWire JavaScript Scraper
 * 
 * This script scrapes AFL Fantasy player data directly from FootyWire
 * using Node.js and stores it in a JSON file.
 */

import fs from 'fs';
import https from 'https';
import http from 'http';
import { JSDOM } from 'jsdom';

// Constants
const FOOTYWIRE_RANKINGS_URL = 'https://www.footywire.com/afl/footy/dream_team_round';
const FOOTYWIRE_BREAKEVENS_URL = 'https://www.footywire.com/afl/footy/dream_team_breakevens';
const USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36';

// Team mappings
const TEAM_MAPPING = {
  'ADE': 'Adelaide',
  'BRL': 'Brisbane Lions',
  'CAR': 'Carlton',
  'COL': 'Collingwood',
  'ESS': 'Essendon',
  'FRE': 'Fremantle',
  'GEE': 'Geelong',
  'GCS': 'Gold Coast',
  'GWS': 'Greater Western Sydney',
  'HAW': 'Hawthorn',
  'MEL': 'Melbourne',
  'NTH': 'North Melbourne',
  'POR': 'Port Adelaide',
  'RIC': 'Richmond',
  'STK': 'St Kilda',
  'SYD': 'Sydney',
  'WCE': 'West Coast',
  'WBD': 'Western Bulldogs',
  // Short name variations
  'Brisbane': 'Brisbane Lions',
  'Gold Coast': 'Gold Coast',
  'Port Adelaide': 'Port Adelaide',
  'Western Bulldogs': 'Western Bulldogs',
  'North Melbourne': 'North Melbourne',
  'West Coast': 'West Coast',
  'Greater Western Sydney': 'Greater Western Sydney',
};

// Position mappings
const POSITION_MAPPING = {
  'DEF': 'DEF',
  'FWD': 'FWD',
  'MID': 'MID',
  'RK': 'RUCK',
  'RUC': 'RUCK',
  'RUCK': 'RUCK',
  'MID/FWD': 'MID',  // Use primary position if multi-position
  'DEF/MID': 'DEF',
  'FWD/MID': 'FWD',
};

/**
 * Normalize team name
 */
function normalizeTeamName(teamStr) {
  if (!teamStr) return "Unknown";
  
  // Remove any non-alphabetic characters
  const team = teamStr.replace(/[^a-zA-Z\s]/g, '').trim();
  
  // Check if it's a known abbreviation or team name
  return TEAM_MAPPING[team] || team;
}

/**
 * Normalize position
 */
function normalizePosition(pos) {
  if (!pos) return "MID";  // Default position
  
  // Clean and standardize position
  const cleanPos = pos.trim().toUpperCase();
  return POSITION_MAPPING[cleanPos] || 'MID';  // Default to MID if unknown
}

/**
 * Parse price string to integer
 */
function parsePrice(priceStr) {
  if (!priceStr) return 0;
  
  try {
    // Remove non-numeric characters except decimal point
    const cleanPrice = priceStr.replace(/[^\d.]/g, '');
    
    // Convert to integer, handling both $650,000 and $650K formats
    if (priceStr.includes('K')) {
      return Math.round(parseFloat(cleanPrice) * 1000);
    } else {
      return Math.round(parseFloat(cleanPrice));
    }
  } catch (error) {
    return 0;
  }
}

/**
 * Make an HTTP request with proper headers
 */
function fetchUrl(url) {
  return new Promise((resolve, reject) => {
    const protocol = url.startsWith('https') ? https : http;
    const requestOptions = {
      headers: {
        'User-Agent': USER_AGENT,
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
        'Cache-Control': 'max-age=0'
      }
    };

    protocol.get(url, requestOptions, (response) => {
      let data = '';
      response.on('data', (chunk) => {
        data += chunk;
      });
      response.on('end', () => {
        resolve(data);
      });
    }).on('error', (error) => {
      reject(error);
    });
  });
}

/**
 * Scrape player rankings from FootyWire
 */
async function scrapeFootyWireRankings() {
  console.log(`Scraping AFL Fantasy player data from ${FOOTYWIRE_RANKINGS_URL}`);
  
  try {
    const html = await fetchUrl(FOOTYWIRE_RANKINGS_URL);
    const dom = new JSDOM(html);
    const document = dom.window.document;
    
    // Find all tables with the class 'data'
    const tables = document.querySelectorAll('table.data');
    if (!tables || tables.length === 0) {
      console.log("No data tables found on the page.");
      return [];
    }
    
    // Get the main player stats table
    let mainTable = null;
    for (let i = 0; i < tables.length; i++) {
      const headers = tables[i].querySelectorAll('th');
      for (let j = 0; j < headers.length; j++) {
        if (headers[j].textContent.includes('Player')) {
          mainTable = tables[i];
          break;
        }
      }
      if (mainTable) break;
    }
    
    if (!mainTable) {
      console.log("Could not find player stats table.");
      return [];
    }
    
    // Extract table headers
    const headers = [];
    const headerRow = mainTable.querySelector('tr');
    if (headerRow) {
      const headerCells = headerRow.querySelectorAll('th');
      for (let i = 0; i < headerCells.length; i++) {
        headers.push(headerCells[i].textContent.trim());
      }
    }
    
    console.log(`Found headers: ${headers.join(', ')}`);
    
    // Find indices for required columns
    let nameIdx = null;
    let teamIdx = null;
    let positionIdx = null;
    let priceIdx = null;
    let avgIdx = null;
    let beIdx = null;
    
    for (let i = 0; i < headers.length; i++) {
      if (headers[i].includes('Player')) {
        nameIdx = i;
      } else if (headers[i].includes('Team') || headers[i].includes('Club')) {
        teamIdx = i;
      } else if (headers[i].includes('Pos')) {
        positionIdx = i;
      } else if (headers[i].includes('Price') || headers[i].includes('Value') || headers[i].includes('$')) {
        priceIdx = i;
      } else if (headers[i].includes('Avg')) {
        avgIdx = i;
      } else if (headers[i].includes('BE') || headers[i].includes('Break')) {
        beIdx = i;
      }
    }
    
    // Check if we have the minimum required columns
    if (nameIdx === null || teamIdx === null) {
      console.log(`Could not find required columns. Name index: ${nameIdx}, Team index: ${teamIdx}`);
      return [];
    }
    
    // Process rows in the table (skip header row)
    const rows = mainTable.querySelectorAll('tr');
    const playerData = [];
    
    for (let i = 1; i < rows.length; i++) {  // Skip header row
      const cells = rows[i].querySelectorAll('td, th');
      
      // Skip rows with insufficient cells
      const reqIdxMax = Math.max(nameIdx || 0, teamIdx || 0);
      if (cells.length <= reqIdxMax) continue;
      
      try {
        // Extract player name
        const nameCell = cells[nameIdx];
        const nameLink = nameCell.querySelector('a');
        const name = nameLink ? nameLink.textContent.trim() : nameCell.textContent.trim();
        
        // Skip empty rows or header rows
        if (!name || name.toLowerCase() === 'player') continue;
        
        // Extract other data
        const team = normalizeTeamName(cells[teamIdx].textContent.trim());
        
        // Extract position if available
        let position = "MID";  // Default position
        if (positionIdx !== null && positionIdx < cells.length) {
          position = normalizePosition(cells[positionIdx].textContent.trim());
        }
        
        // Extract price if available
        let price = 0;
        if (priceIdx !== null && priceIdx < cells.length) {
          price = parsePrice(cells[priceIdx].textContent.trim());
        }
        
        // Extract average points if available
        let avgPoints = 0;
        if (avgIdx !== null && avgIdx < cells.length) {
          const avgText = cells[avgIdx].textContent.trim();
          avgPoints = parseFloat(avgText) || 0;
        }
        
        // Extract breakeven if available
        let breakeven = null;
        if (beIdx !== null && beIdx < cells.length) {
          const beText = cells[beIdx].textContent.trim();
          breakeven = parseInt(beText) || Math.round(avgPoints * 0.9);  // Estimate if not available
        } else {
          breakeven = Math.round(avgPoints * 0.9);  // Estimate breakeven if not available
        }
        
        // Calculate other missing values
        const projectedScore = Math.round(avgPoints + 5);  // Project future score as average + 5
        const games = 1;  // Default if not available
        
        // Create player object
        const player = {
          name: name,
          team: team,
          position: position,
          price: price,
          avg: avgPoints.toFixed(1),
          games: games,
          breakeven: breakeven,
          projected_score: projectedScore,
          status: "fit",  // Default status
          source: "footywire_rankings",
          timestamp: Math.floor(Date.now() / 1000)
        };
        
        playerData.push(player);
        
      } catch (error) {
        console.log(`Error processing row: ${error}`);
        continue;
      }
    }
    
    // Sort by average points (highest first)
    playerData.sort((a, b) => parseFloat(b.avg) - parseFloat(a.avg));
    
    console.log(`Successfully scraped ${playerData.length} players from FootyWire rankings.`);
    return playerData;
    
  } catch (error) {
    console.log(`Error scraping FootyWire data: ${error}`);
    return [];
  }
}

/**
 * Scrape breakeven values from FootyWire
 */
async function scrapeFootyWireBreakevens() {
  console.log(`Scraping AFL Fantasy breakeven data from ${FOOTYWIRE_BREAKEVENS_URL}`);
  
  const breakevens = {};
  
  try {
    // Fetch the HTML content from FootyWire
    const html = await fetchUrl(FOOTYWIRE_BREAKEVENS_URL);
    const dom = new JSDOM(html);
    const document = dom.window.document;
    
    // Find all tables on the page - FootyWire has multiple tables with breakevens for different positions
    const tables = document.querySelectorAll('table.data');
    if (!tables || tables.length === 0) {
      console.log("No data tables found on the page.");
      return {};
    }
    
    // Process all tables that contain player data
    for (let i = 0; i < tables.length; i++) {
      const table = tables[i];
      const rows = table.querySelectorAll('tr');
      
      // Skip tables with no rows or just a header
      if (!rows || rows.length <= 1) continue;
      
      // Get the header row to find column indices
      const headerRow = rows[0];
      const headerCells = headerRow.querySelectorAll('th');
      
      // Find the name and breakeven column indices
      let nameIdx = -1;
      let beIdx = -1;
      let teamIdx = -1;
      
      for (let j = 0; j < headerCells.length; j++) {
        const cellText = headerCells[j].textContent.trim().toLowerCase();
        if (cellText.includes('player')) {
          nameIdx = j;
        } else if (cellText.includes('be') || cellText.includes('break')) {
          beIdx = j;
        } else if (cellText.includes('team') || cellText.includes('club')) {
          teamIdx = j;
        }
      }
      
      // Skip this table if we can't find the required columns
      if (nameIdx === -1 || beIdx === -1) {
        continue;
      }
      
      // Process each player row
      for (let j = 1; j < rows.length; j++) {
        try {
          const cells = rows[j].querySelectorAll('td');
          
          // Skip rows without enough cells
          if (!cells || cells.length <= Math.max(nameIdx, beIdx)) {
            continue;
          }
          
          // Extract player name
          const nameCell = cells[nameIdx];
          const nameLinks = nameCell.querySelectorAll('a');
          let name = '';
          
          if (nameLinks && nameLinks.length > 0) {
            name = nameLinks[0].textContent.trim();
          } else {
            name = nameCell.textContent.trim();
          }
          
          // Skip if no name found
          if (!name) continue;
          
          // Extract team if available
          let team = '';
          if (teamIdx !== -1 && cells.length > teamIdx) {
            team = cells[teamIdx].textContent.trim();
            team = normalizeTeamName(team);
          }
          
          // Extract breakeven
          const beText = cells[beIdx].textContent.trim().replace(/[^0-9-]/g, '');
          
          if (beText) {
            // Convert breakeven to number, handling negative values
            const breakeven = parseInt(beText);
            
            // Store player data
            const playerKey = name;
            breakevens[playerKey] = {
              name,
              team,
              breakeven
            };
          }
        } catch (error) {
          console.error(`Error processing player row: ${error}`);
          continue;
        }
      }
    }
    
    console.log(`Successfully scraped ${Object.keys(breakevens).length} breakevens.`);
    return breakevens;
    
  } catch (error) {
    console.error(`Error scraping breakeven data: ${error}`);
    return {};
  }
}

/**
 * Add breakeven values to player data
 */
function enrichWithBreakevens(players, breakevens) {
  if (!breakevens || Object.keys(breakevens).length === 0) {
    return players;
  }
  
  // Create a map of player names (normalized) for faster lookup
  const playerNameMap = {};
  players.forEach(player => {
    const normalizedName = player.name.toLowerCase().replace(/[.']/g, '').trim();
    playerNameMap[normalizedName] = player;
  });
  
  // Process breakevens data
  Object.values(breakevens).forEach(beData => {
    if (!beData || !beData.name) return;
    
    const normalizedName = beData.name.toLowerCase().replace(/[.']/g, '').trim();
    const player = playerNameMap[normalizedName];
    
    if (player) {
      player.breakeven = beData.breakeven;
      
      // If team data was missing but we have it in the breakeven data, update it
      if (!player.team && beData.team) {
        player.team = beData.team;
      }
    }
  });
  
  return players;
}

/**
 * Add common variations of player names for better matching in team upload
 */
function addPlayerVariations(players) {
  const playerMap = {};
  const variations = [];
  
  // Create a map of existing players by name
  players.forEach(player => {
    playerMap[player.name.toLowerCase()] = player;
  });
  
  // Define common variations
  const commonVariations = [
    { original: "Tom De Koning", variation: "Tom DeKoning" },
    { original: "Isaac Rankine", variation: "Izak Rankine" },
    { original: "Finn O'Sullivan", variation: "Finn OSullivan" },
    { original: "Finn O'Sullivan", variation: "Finn Sullivan" },
    { original: "Sam Davidson", variation: "San Davidson" },
    { original: "Tristan Xerri", variation: "Tristan Zerri" },
    // Add more common variations as needed
  ];
  
  // Add variations for existing players
  commonVariations.forEach(({ original, variation }) => {
    const originalLower = original.toLowerCase();
    if (playerMap[originalLower]) {
      const player = { ...playerMap[originalLower] };
      player.name = variation;
      variations.push(player);
    }
  });
  
  // Return combined list
  return [...players, ...variations];
}

/**
 * Add fallback data for common rookies and star players
 */
function addFallbackPlayers(players) {
  // Create a map of existing players by name
  const playerMap = {};
  players.forEach(player => {
    playerMap[player.name.toLowerCase()] = true;
  });
  
  // Define fallback data for common players that might be missing
  const fallbackPlayers = [
    { name: "Harry Sheezel", team: "North Melbourne", position: "DEF", price: 982000, breakeven: 123, avg: 115.3 },
    { name: "Jayden Short", team: "Richmond", position: "DEF", price: 909000, breakeven: 98, avg: 108.0 },
    { name: "Matt Roberts", team: "Sydney", position: "DEF", price: 785000, breakeven: 89, avg: 95.6 },
    { name: "Riley Bice", team: "Carlton", position: "DEF", price: 203000, breakeven: -24, avg: 45.0 },
    { name: "Jaxon Prior", team: "Brisbane", position: "DEF", price: 557000, breakeven: 72, avg: 82.1 },
    { name: "Zach Reid", team: "Essendon", position: "DEF", price: 498000, breakeven: 65, avg: 76.3 },
    { name: "Finn O'Sullivan", team: "Western Bulldogs", position: "DEF", price: 205000, breakeven: -28, avg: 47.2 },
    { name: "Connor Stone", team: "Hawthorn", position: "DEF", price: 228000, breakeven: -15, avg: 52.8 },
    { name: "Jordan Dawson", team: "Adelaide", position: "MID", price: 943000, breakeven: 115, avg: 118.7 },
    { name: "Andrew Brayshaw", team: "Fremantle", position: "MID", price: 875000, breakeven: 105, avg: 112.3 },
    { name: "Nick Daicos", team: "Collingwood", position: "MID", price: 1025000, breakeven: 132, avg: 128.9 },
    { name: "Connor Rozee", team: "Port Adelaide", position: "MID", price: 892000, breakeven: 108, avg: 113.5 },
    { name: "Zach Merrett", team: "Essendon", position: "MID", price: 967000, breakeven: 120, avg: 122.1 },
    { name: "Clayton Oliver", team: "Melbourne", position: "MID", price: 935000, breakeven: 112, avg: 117.8 },
    { name: "Levi Ashcroft", team: "Brisbane", position: "MID", price: 415000, breakeven: 38, avg: 72.5 },
    { name: "Xavier Lindsay", team: "Gold Coast", position: "MID", price: 186000, breakeven: -36, avg: 42.3 },
    { name: "Hugh Boxshall", team: "Richmond", position: "MID", price: 178000, breakeven: -42, avg: 38.9 },
    { name: "Isaac Kako", team: "Carlton", position: "MID", price: 193000, breakeven: -32, avg: 44.1 },
    { name: "Tristan Xerri", team: "North Melbourne", position: "RUCK", price: 745000, breakeven: 92, avg: 103.5 },
    { name: "Tom De Koning", team: "Carlton", position: "RUCK", price: 682000, breakeven: 78, avg: 94.2 },
    { name: "Harry Boyd", team: "Hawthorn", position: "RUCK", price: 236000, breakeven: -12, avg: 54.8 },
    { name: "Isaac Rankine", team: "Gold Coast", position: "FWD", price: 739000, breakeven: 88, avg: 99.5 },
    { name: "Christian Petracca", team: "Melbourne", position: "FWD", price: 865000, breakeven: 102, avg: 111.2 },
    { name: "Bailey Smith", team: "Western Bulldogs", position: "FWD", price: 828000, breakeven: 95, avg: 105.3 },
    { name: "Jack Macrae", team: "Western Bulldogs", position: "FWD", price: 795000, breakeven: 92, avg: 102.7 },
    { name: "Caleb Daniel", team: "Western Bulldogs", position: "FWD", price: 729000, breakeven: 85, avg: 97.3 },
    { name: "Sam Davidson", team: "Geelong", position: "FWD", price: 236000, breakeven: -15, avg: 55.2 },
    { name: "Caiden Cleary", team: "Sydney", position: "FWD", price: 189000, breakeven: -38, avg: 43.6 },
    { name: "Campbell Gray", team: "St Kilda", position: "FWD", price: 158000, breakeven: -45, avg: 35.8 },
    { name: "James Leake", team: "Adelaide", position: "FWD", price: 172000, breakeven: -44, avg: 38.4 }
  ];
  
  // Add fields and timestamp to each fallback player
  const now = Math.floor(Date.now() / 1000);
  const formattedFallbackPlayers = fallbackPlayers.map(player => {
    // Skip if player already exists in the scraped data
    if (playerMap[player.name.toLowerCase()]) {
      return null;
    }
    
    return {
      name: player.name,
      team: player.team,
      position: player.position,
      price: player.price,
      avg: player.avg.toFixed(1),
      breakeven: player.breakeven,
      games: 12,
      projected_score: Math.round(player.avg + 5),
      status: "fit",
      source: "fallback",
      timestamp: now,
      last3_avg: player.avg,
      last5_avg: player.avg * 0.97  // Slightly lower for last 5
    };
  }).filter(player => player !== null);
  
  // Return combined list
  return [...players, ...formattedFallbackPlayers];
}

/**
 * Save player data to JSON file
 */
function saveToJson(data, filename = 'player_data.json') {
  fs.writeFileSync(filename, JSON.stringify(data, null, 2));
  console.log(`Saved ${data.length} players to ${filename}`);
}

/**
 * Main function
 */
async function main() {
  console.log("Starting FootyWire AFL Fantasy JavaScript scraper...");
  
  try {
    // Try to fetch from FootyWire first
    console.log("Attempting to scrape data from FootyWire...");
    let players = await scrapeFootyWireRankings();
    
    if (players && players.length > 0) {
      console.log("Successfully scraped player rankings from FootyWire.");
      console.log(`Found ${players.length} players.`);
      
      // Try to enrich with breakevens
      console.log("Fetching breakeven data...");
      // Small delay to avoid rate limiting
      await new Promise(resolve => setTimeout(resolve, 1000));
      const breakevens = await scrapeFootyWireBreakevens();
      
      if (breakevens && Object.keys(breakevens).length > 0) {
        console.log(`Successfully scraped ${Object.keys(breakevens).length} breakevens.`);
        players = enrichWithBreakevens(players, breakevens);
      } else {
        console.log("Could not scrape breakeven data. Using estimated breakevens.");
      }
      
      // Add player name variations
      players = addPlayerVariations(players);
      
      // Add fallback data for missing players
      players = addFallbackPlayers(players);
      
      // Save to JSON
      saveToJson(players);
      console.log("FootyWire data saved successfully.");
      console.log(`Total players processed: ${players.length}`);
      return;
    }
  } catch (error) {
    console.log(`Error in FootyWire scraping process: ${error}`);
  }
  
  // If we get here, FootyWire scraping failed or returned no data
  console.log("\n");
  console.log("==========================================================");
  console.log("FOOTYWIRE DATA UNAVAILABLE - USING FALLBACK DATA ONLY");
  console.log("==========================================================");
  console.log("FootyWire may be experiencing server issues or has changed their website structure.");
  
  // Create fallback data for common players
  const fallbackPlayers = [
    { name: "Harry Sheezel", team: "North Melbourne", position: "DEF", price: 982000, breakeven: 123, avg: 115.3 },
    { name: "Jayden Short", team: "Richmond", position: "DEF", price: 909000, breakeven: 98, avg: 108.0 },
    { name: "Matt Roberts", team: "Sydney", position: "DEF", price: 785000, breakeven: 89, avg: 95.6 },
    { name: "Riley Bice", team: "Carlton", position: "DEF", price: 203000, breakeven: -24, avg: 45.0 },
    { name: "Jaxon Prior", team: "Brisbane", position: "DEF", price: 557000, breakeven: 72, avg: 82.1 },
    { name: "Zach Reid", team: "Essendon", position: "DEF", price: 498000, breakeven: 65, avg: 76.3 },
    { name: "Finn O'Sullivan", team: "Western Bulldogs", position: "DEF", price: 205000, breakeven: -28, avg: 47.2 },
    { name: "Connor Stone", team: "Hawthorn", position: "DEF", price: 228000, breakeven: -15, avg: 52.8 },
    { name: "Jordan Dawson", team: "Adelaide", position: "MID", price: 943000, breakeven: 115, avg: 118.7 },
    { name: "Andrew Brayshaw", team: "Fremantle", position: "MID", price: 875000, breakeven: 105, avg: 112.3 },
    { name: "Nick Daicos", team: "Collingwood", position: "MID", price: 1025000, breakeven: 132, avg: 128.9 },
    { name: "Connor Rozee", team: "Port Adelaide", position: "MID", price: 892000, breakeven: 108, avg: 113.5 },
    { name: "Zach Merrett", team: "Essendon", position: "MID", price: 967000, breakeven: 120, avg: 122.1 },
    { name: "Clayton Oliver", team: "Melbourne", position: "MID", price: 935000, breakeven: 112, avg: 117.8 },
    { name: "Levi Ashcroft", team: "Brisbane", position: "MID", price: 415000, breakeven: 38, avg: 72.5 },
    { name: "Xavier Lindsay", team: "Gold Coast", position: "MID", price: 186000, breakeven: -36, avg: 42.3 },
    { name: "Hugh Boxshall", team: "Richmond", position: "MID", price: 178000, breakeven: -42, avg: 38.9 },
    { name: "Isaac Kako", team: "Carlton", position: "MID", price: 193000, breakeven: -32, avg: 44.1 },
    { name: "Tristan Xerri", team: "North Melbourne", position: "RUCK", price: 745000, breakeven: 92, avg: 103.5 },
    { name: "Tom De Koning", team: "Carlton", position: "RUCK", price: 682000, breakeven: 78, avg: 94.2 },
    { name: "Harry Boyd", team: "Hawthorn", position: "RUCK", price: 236000, breakeven: -12, avg: 54.8 },
    { name: "Isaac Rankine", team: "Gold Coast", position: "FWD", price: 739000, breakeven: 88, avg: 99.5 },
    { name: "Christian Petracca", team: "Melbourne", position: "FWD", price: 865000, breakeven: 102, avg: 111.2 },
    { name: "Bailey Smith", team: "Western Bulldogs", position: "FWD", price: 828000, breakeven: 95, avg: 105.3 },
    { name: "Jack Macrae", team: "Western Bulldogs", position: "FWD", price: 795000, breakeven: 92, avg: 102.7 },
    { name: "Caleb Daniel", team: "Western Bulldogs", position: "FWD", price: 729000, breakeven: 85, avg: 97.3 },
    { name: "Sam Davidson", team: "Geelong", position: "FWD", price: 236000, breakeven: -15, avg: 55.2 },
    { name: "Caiden Cleary", team: "Sydney", position: "FWD", price: 189000, breakeven: -38, avg: 43.6 },
    { name: "Campbell Gray", team: "St Kilda", position: "FWD", price: 158000, breakeven: -45, avg: 35.8 },
    { name: "James Leake", team: "Adelaide", position: "FWD", price: 172000, breakeven: -44, avg: 38.4 }
  ];

  // Add common variations of player names
  const variations = [
    { name: "Izak Rankine", team: "Gold Coast", position: "FWD", price: 739000, breakeven: 88, avg: 99.5 },
    { name: "Tom DeKoning", team: "Carlton", position: "RUCK", price: 682000, breakeven: 78, avg: 94.2 },
    { name: "Finn OSullivan", team: "Western Bulldogs", position: "DEF", price: 205000, breakeven: -28, avg: 47.2 },
    { name: "Finn Sullivan", team: "Western Bulldogs", position: "DEF", price: 205000, breakeven: -28, avg: 47.2 },
    { name: "San Davidson", team: "Geelong", position: "FWD", price: 236000, breakeven: -15, avg: 55.2 }
  ];

  // Add fields and timestamp to each player
  const now = Math.floor(Date.now() / 1000);
  const formattedPlayers = [...fallbackPlayers, ...variations].map(player => ({
    name: player.name,
    team: player.team,
    position: player.position,
    price: player.price,
    avg: player.avg.toFixed(1),
    breakeven: player.breakeven,
    games: 12,
    projected_score: Math.round(player.avg + 5),
    status: "fit",
    source: "fallback",
    timestamp: now,
    last3_avg: player.avg,
    last5_avg: player.avg * 0.97  // Slightly lower for last 5
  }));

  // Save to JSON
  saveToJson(formattedPlayers);
  console.log(`Successfully saved fallback AFL Fantasy player data!`);
  console.log(`Total players: ${formattedPlayers.length}`);
}

// Run the script
main().catch(error => {
  console.error('Error in main function:', error);
  process.exit(1);
});