import { JSDOM } from 'jsdom';
import https from 'https';

// Constants
const FOOTYWIRE_BREAKEVENS_URL = 'https://www.footywire.com/afl/footy/dream_team_breakevens';
const USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36';

/**
 * Normalize team name
 */
function normalizeTeamName(teamStr) {
  if (!teamStr) return "Unknown";
  
  // Remove any non-alphabetic characters
  const team = teamStr.replace(/[^a-zA-Z\s]/g, '').trim();
  
  // Check if it's a known abbreviation or team name
  const teamMap = {
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
  
  return teamMap[team] || team;
}

/**
 * Make an HTTP request with proper headers
 */
function fetchUrl(url) {
  return new Promise((resolve, reject) => {
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

    https.get(url, requestOptions, (response) => {
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
    
    console.log(`Found ${tables.length} tables on the page.`);
    
    // Process all tables that contain player data
    for (let i = 0; i < tables.length; i++) {
      const table = tables[i];
      const rows = table.querySelectorAll('tr');
      
      console.log(`Table ${i+1} has ${rows.length} rows.`);
      
      // Skip tables with no rows or just a header
      if (!rows || rows.length <= 1) {
        console.log(`Table ${i+1} skipped - not enough rows.`);
        continue;
      }
      
      // Get the header row to find column indices
      const headerRow = rows[0];
      const headerCells = headerRow.querySelectorAll('th');
      
      console.log(`Table ${i+1} has ${headerCells.length} columns.`);
      
      const headerNames = [];
      for (let j = 0; j < headerCells.length; j++) {
        headerNames.push(headerCells[j].textContent.trim());
      }
      console.log(`Table ${i+1} headers: ${headerNames.join(', ')}`);
      
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
      
      console.log(`Table ${i+1}: nameIdx=${nameIdx}, beIdx=${beIdx}, teamIdx=${teamIdx}`);
      
      // Skip this table if we can't find the required columns
      if (nameIdx === -1 || beIdx === -1) {
        console.log(`Table ${i+1} skipped - missing required columns.`);
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
            
            // Log for first few players
            if (j < 5) {
              console.log(`Player: ${name}, Team: ${team}, BE: ${breakeven}`);
            }
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

// Run the test
async function runTest() {
  console.log("Starting breakeven scraper test...");
  try {
    const breakevens = await scrapeFootyWireBreakevens();
    console.log(`Test completed with ${Object.keys(breakevens).length} players.`);
    
    // Show the first 10 players as a sample
    const sample = Object.keys(breakevens).slice(0, 10).map(key => breakevens[key]);
    console.log("Sample of breakeven data:");
    console.log(JSON.stringify(sample, null, 2));
  } catch (error) {
    console.error("Test failed:", error);
  }
}

runTest();