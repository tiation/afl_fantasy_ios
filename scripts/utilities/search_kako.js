/**
 * Search for Isaac Kako in all available data sources
 */

import fs from 'fs';
import readline from 'readline';
import path from 'path';

// Search the player data JSON file
async function searchPlayerData() {
  try {
    console.log("Searching player_data.json for Isaac Kako...");
    const data = fs.readFileSync('./player_data.json', 'utf8');
    const playerData = JSON.parse(data);
    
    // Attempt different name variations and case-insensitive search
    const matchingPlayers = playerData.filter(player => {
      if (!player.name) return false;
      const name = player.name.toLowerCase();
      return name.includes('kako') || 
             name.includes('kaco') || 
             name.includes('kak') || 
             name.includes('kac');
    });
    
    if (matchingPlayers.length > 0) {
      console.log(`Found ${matchingPlayers.length} potential matches in player_data.json:`);
      matchingPlayers.forEach(player => {
        console.log(`- ${player.name} (${player.team}) - $${player.price} - Avg: ${player.avg} - BE: ${player.breakeven || player.breakEven}`);
      });
    } else {
      console.log("No players with similar names found in player_data.json");
    }
  } catch (error) {
    console.error("Error searching player_data.json:", error);
  }
}

// Search CSV files in attached_assets
async function searchCSVFiles() {
  try {
    console.log("\nSearching CSV files for Isaac Kako...");
    const dir = './attached_assets';
    const files = fs.readdirSync(dir);
    
    for (const file of files) {
      if (path.extname(file).toLowerCase() === '.csv') {
        console.log(`\nSearching in ${file}...`);
        const filePath = path.join(dir, file);
        
        // Create a readline interface
        const fileStream = fs.createReadStream(filePath);
        const rl = readline.createInterface({
          input: fileStream,
          crlfDelay: Infinity
        });
        
        let isFirstRow = true;
        let headers = [];
        let found = false;
        
        for await (const line of rl) {
          if (isFirstRow) {
            headers = line.split(',').map(h => h.trim());
            isFirstRow = false;
            continue;
          }
          
          // Search for different variations of the name
          const lineLower = line.toLowerCase();
          if (lineLower.includes('kako') || 
              lineLower.includes('kaco') || 
              lineLower.includes('kak') || 
              lineLower.includes('kac')) {
            
            found = true;
            const columns = line.split(',');
            console.log("FOUND MATCH:");
            
            // Create a formatted output with headers
            for (let i = 0; i < Math.min(headers.length, columns.length); i++) {
              console.log(`${headers[i]}: ${columns[i].trim()}`);
            }
            
            // Also output the full row for reference
            console.log("\nFull row data:");
            console.log(line);
          }
        }
        
        if (!found) {
          console.log(`No matches found in ${file}`);
        }
      }
    }
  } catch (error) {
    console.error("Error searching CSV files:", error);
  }
}

// Search for Essendon rookies in all CSV files
async function searchEssendonRookies() {
  try {
    console.log("\nSearching for Essendon rookies...");
    const dir = './attached_assets';
    const files = fs.readdirSync(dir);
    
    for (const file of files) {
      if (path.extname(file).toLowerCase() === '.csv') {
        console.log(`\nSearching for Essendon rookies in ${file}...`);
        const filePath = path.join(dir, file);
        
        // Create a readline interface
        const fileStream = fs.createReadStream(filePath);
        const rl = readline.createInterface({
          input: fileStream,
          crlfDelay: Infinity
        });
        
        let isFirstRow = true;
        let headers = [];
        let found = false;
        
        for await (const line of rl) {
          if (isFirstRow) {
            headers = line.split(',').map(h => h.trim());
            isFirstRow = false;
            continue;
          }
          
          // Look for Essendon rookies (players under ~300K price)
          const lineLower = line.toLowerCase();
          if ((lineLower.includes('essendon') || lineLower.includes('bombers')) && 
              (lineLower.includes('200000') || lineLower.includes('1900') || 
               lineLower.includes('180000') || lineLower.includes('170000') ||
               lineLower.includes('160000') || lineLower.includes('150000') ||
               lineLower.includes('140000') || lineLower.includes('130000') ||
               lineLower.includes('120000') || lineLower.includes('250000') ||
               lineLower.includes('210000') || lineLower.includes('220000'))) {
            
            found = true;
            const columns = line.split(',');
            console.log("FOUND POTENTIAL ROOKIE:");
            
            // Create a formatted output with headers
            for (let i = 0; i < Math.min(headers.length, columns.length); i++) {
              console.log(`${headers[i]}: ${columns[i].trim()}`);
            }
            
            // Also output the full row for reference
            console.log("\nFull row data:");
            console.log(line);
          }
        }
        
        if (!found) {
          console.log(`No Essendon rookies found in ${file}`);
        }
      }
    }
  } catch (error) {
    console.error("Error searching for Essendon rookies:", error);
  }
}

// Search for new midfielders in all files
async function searchNewPlayers() {
  try {
    console.log("\nSearching for new Essendon midfielders...");
    const dir = './attached_assets';
    const files = fs.readdirSync(dir);
    
    for (const file of files) {
      if (path.extname(file).toLowerCase() === '.csv') {
        console.log(`\nSearching for new players in ${file}...`);
        const filePath = path.join(dir, file);
        
        // Create a readline interface
        const fileStream = fs.createReadStream(filePath);
        const rl = readline.createInterface({
          input: fileStream,
          crlfDelay: Infinity
        });
        
        let isFirstRow = true;
        let headers = [];
        let foundPlayers = 0;
        
        for await (const line of rl) {
          if (isFirstRow) {
            headers = line.split(',').map(h => h.trim());
            isFirstRow = false;
            continue;
          }
          
          // Look for Essendon players with few games
          const lineLower = line.toLowerCase();
          const columns = line.split(',');
          
          if ((lineLower.includes('essendon') || lineLower.includes('bombers')) && 
              (columns[2] === '1' || columns[2] === '2' || columns[2] === '3')) {
            
            foundPlayers++;
            console.log("FOUND NEW PLAYER:");
            
            // Create a formatted output with headers
            for (let i = 0; i < Math.min(headers.length, columns.length); i++) {
              console.log(`${headers[i]}: ${columns[i].trim()}`);
            }
            
            // Also output the full row for reference
            console.log("\nFull row data:");
            console.log(line);
          }
        }
        
        if (foundPlayers === 0) {
          console.log(`No new Essendon players found in ${file}`);
        } else {
          console.log(`Found ${foundPlayers} new Essendon players in ${file}`);
        }
      }
    }
  } catch (error) {
    console.error("Error searching for new players:", error);
  }
}

// Main function
async function main() {
  try {
    await searchPlayerData();
    await searchCSVFiles();
    await searchEssendonRookies();
    await searchNewPlayers();
  } catch (error) {
    console.error("Error in search:", error);
  }
}

// Run the search
main();