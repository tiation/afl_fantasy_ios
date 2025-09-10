import axios from 'axios';
import * as cheerio from 'cheerio';

/**
 * Scrape player data from DFS Australia Fantasy Big Board
 * This provides detailed AFL Fantasy stats
 */
export async function scrapeDfsAustraliaData(): Promise<any[]> {
  try {
    // DFS Australia has an API endpoint for their Fantasy Big Board
    const response = await axios.get('https://dfsaustralia.com/wp-json/fantasyapi/v1/big-board');
    
    if (!response.data) {
      throw new Error('No data returned from DFS Australia API');
    }
    
    const playerData = response.data.map((player: any) => {
      // Normalize team names to match our database format
      const team = normalizeTeamName(player.team);
      
      return {
        name: player.name,
        position: player.position,
        team,
        price: parseInt(player.price?.replace(/[$,]/g, '') || '0'),
        averageScore: parseFloat(player.avg || '0'),
        lastScore: parseInt(player.lastScore || '0'),
        breakEven: parseInt(player.breakEven || '0'),
        l3Average: parseFloat(player.l3Avg || '0'),
        l5Average: parseFloat(player.l5Avg || '0'),
        projectedScore: parseFloat(player.projectedScore || '0'),
        valueScore: parseFloat(player.valueScore || '0'),
        valuePercent: parseFloat(player.valuePercent || '0'),
        consistency: parseFloat(player.consistency || '0'),
        ceiling: parseFloat(player.ceiling || '0'),
        floor: parseFloat(player.floor || '0'),
        ownership: parseFloat(player.ownership?.replace(/%/g, '') || '0'),
        ownedBy: player.name ? `${Math.round(Math.random() * 30)}%` : '0%', // Placeholder, real data would come from AFL Fantasy API
        priceChange: parseInt(player.priceChange?.replace(/[$,]/g, '') || '0'),
        roundsPlayed: parseInt(player.roundsPlayed || '0'),
        minutesPlayed: parseInt(player.minutesPlayed || '0'),
        draftRank: parseInt(player.draftRank || '0'),
        status: player.status || 'Available',
        injuryInfo: player.injuryInfo || '',
      };
    });
    
    return playerData;
  } catch (error) {
    console.error('Error scraping DFS Australia data:', error);
    return [];
  }
}

/**
 * Scrape FootyWire for player stats and recent form
 */
export async function scrapeFootyWireData(): Promise<any[]> {
  try {
    const players: any[] = [];
    const baseUrl = 'https://www.footywire.com/afl/footy/ft_players';
    
    // Get the list of players from the FootyWire players page
    const response = await axios.get(baseUrl);
    const $ = cheerio.load(response.data);
    
    // Process player list
    $('.playersBox').each((i, element) => {
      const playerLink = $(element).find('a').attr('href');
      const playerName = $(element).find('a').text().trim();
      const playerTeam = $(element).find('.playersTeam').text().trim();
      
      if (playerLink && playerName) {
        const playerId = playerLink.split('?').pop()?.split('=').pop();
        
        if (playerId) {
          // Create a basic player record from the list page
          players.push({
            name: playerName,
            position: 'Unknown', // Will be populated when scraping individual player pages
            team: normalizeTeamName(playerTeam),
            price: 0, // Will be populated when scraping individual player pages
            averageScore: 0,
            lastScore: 0,
            breakEven: 0,
            source: 'FootyWire',
            externalId: playerId,
          });
        }
      }
    });
    
    // Get detailed data for each player (limit to 20 for testing)
    // In production, we would process all players or implement pagination
    const limitedPlayers = players.slice(0, 20);
    
    for (const player of limitedPlayers) {
      if (player.externalId) {
        const playerUrl = `https://www.footywire.com/afl/footy/ft_player_profile?playerid=${player.externalId}`;
        const playerResponse = await axios.get(playerUrl);
        const playerPage = cheerio.load(playerResponse.data);
        
        // Extract position
        const position = playerPage('.playersPosition').text().trim();
        player.position = mapFootyWirePositionToFantasy(position);
        
        // Extract stats
        playerPage('.playerStats table tr').each((i, row) => {
          const columns = playerPage(row).find('td');
          if (columns.length >= 2) {
            const statName = playerPage(columns[0]).text().trim();
            const statValue = playerPage(columns[1]).text().trim();
            
            if (statName === 'Fantasy Average') {
              player.averageScore = parseFloat(statValue) || 0;
            } else if (statName === 'Fantasy Last') {
              player.lastScore = parseInt(statValue) || 0;
            } else if (statName === 'Current Price') {
              player.price = parseInt(statValue.replace(/[$,]/g, '')) || 0;
            }
          }
        });
      }
    }
    
    return players;
  } catch (error) {
    console.error('Error scraping FootyWire data:', error);
    return [];
  }
}

/**
 * Get Defense vs Position (DVP) matrix from DFS Australia
 */
export async function scrapeDvpMatrix(): Promise<any> {
  try {
    const response = await axios.get('https://dfsaustralia.com/afldvp/');
    const $ = cheerio.load(response.data);
    
    const dvpMatrix: any = {
      DEF: {},
      MID: {},
      RUC: {},
      FWD: {},
    };
    
    // Parse the DVP table for each position
    $('.dvp-table').each((i, table) => {
      const positionHeader = $(table).prev('h2').text().trim();
      let position: string = '';
      
      if (positionHeader.includes('Defender')) {
        position = 'DEF';
      } else if (positionHeader.includes('Midfielder')) {
        position = 'MID';
      } else if (positionHeader.includes('Ruck')) {
        position = 'RUC';
      } else if (positionHeader.includes('Forward')) {
        position = 'FWD';
      }
      
      if (position) {
        $(table).find('tbody tr').each((j, row) => {
          const columns = $(row).find('td');
          const teamAbbr = $(columns[0]).text().trim();
          const team = normalizeTeamName(teamAbbr);
          const pointsAllowed = parseFloat($(columns[1]).text().trim()) || 0;
          const dvpScore = parseFloat($(columns[2]).text().trim()) || 0;
          
          if (team) {
            dvpMatrix[position][team] = {
              pointsAllowed,
              dvpScore,
              rank: j + 1
            };
          }
        });
      }
    });
    
    return dvpMatrix;
  } catch (error) {
    console.error('Error scraping DVP matrix:', error);
    return {
      DEF: {},
      MID: {},
      RUC: {},
      FWD: {},
    };
  }
}

/**
 * Normalize team names across different data sources
 */
function normalizeTeamName(teamName: string): string {
  if (!teamName) return '';
  
  const teamMappings: Record<string, string> = {
    // Abbreviations to full names
    'ADEL': 'Adelaide',
    'BL': 'Brisbane Lions',
    'CARL': 'Carlton',
    'COLL': 'Collingwood',
    'ESS': 'Essendon',
    'FREM': 'Fremantle',
    'GEEL': 'Geelong',
    'GCFC': 'Gold Coast',
    'GWS': 'Greater Western Sydney',
    'HAW': 'Hawthorn',
    'MELB': 'Melbourne',
    'NMFC': 'North Melbourne',
    'PORT': 'Port Adelaide',
    'RICH': 'Richmond',
    'STK': 'St Kilda',
    'SYD': 'Sydney',
    'WCE': 'West Coast',
    'WB': 'Western Bulldogs',
    
    // Alternative names
    'Adelaide Crows': 'Adelaide',
    'Brisbane': 'Brisbane Lions',
    'Gold Coast Suns': 'Gold Coast',
    'GWS Giants': 'Greater Western Sydney',
    'Kangaroos': 'North Melbourne',
    'Bulldogs': 'Western Bulldogs',
    'Saints': 'St Kilda',
    'Power': 'Port Adelaide',
    'Bombers': 'Essendon',
    'Blues': 'Carlton',
    'Magpies': 'Collingwood',
    'Cats': 'Geelong',
    'Hawks': 'Hawthorn',
    'Demons': 'Melbourne',
    'Swans': 'Sydney',
    'Tigers': 'Richmond',
    'Eagles': 'West Coast',
    'Dockers': 'Fremantle',
  };
  
  // Try to match the full name first
  if (teamMappings[teamName]) {
    return teamMappings[teamName];
  }
  
  // Try to match any part of the team name
  for (const [key, value] of Object.entries(teamMappings)) {
    if (teamName.includes(key) || value.includes(teamName)) {
      return value;
    }
  }
  
  return teamName;
}

/**
 * Map FootyWire position to Fantasy positions
 */
function mapFootyWirePositionToFantasy(position: string): string {
  const midPositions = ['Midfielder', 'Inside Midfielder', 'Outside Midfielder', 'Wing'];
  const defPositions = ['Defender', 'Back Pocket', 'Back', 'Fullback'];
  const fwdPositions = ['Forward', 'Forward Pocket', 'Centre Half Forward', 'Full Forward'];
  const rucPositions = ['Ruck', 'Ruckman'];
  
  if (midPositions.some(p => position.includes(p))) {
    return 'MID';
  } else if (defPositions.some(p => position.includes(p))) {
    return 'DEF';
  } else if (fwdPositions.some(p => position.includes(p))) {
    return 'FWD';
  } else if (rucPositions.some(p => position.includes(p))) {
    return 'RUC';
  }
  
  return 'MID'; // Default to midfielder if unknown
}