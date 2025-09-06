import * as fs from 'fs';
import * as path from 'path';
import * as csv from 'csv-parse';
import { db } from '../db';
import { 
  playerRoundScores, 
  priceHistory, 
  opponentHistory, 
  venueHistory, 
  fixtures,
  systemParameters,
  players
} from '../../shared/schema';

export class DataImporter {
  
  /**
   * Auto-detect and import data files from the project directory
   */
  async autoImportData(): Promise<{
    success: boolean;
    imported: string[];
    errors: string[];
  }> {
    const results = {
      success: true,
      imported: [] as string[],
      errors: [] as string[]
    };

    try {
      // Check for common data file patterns
      const dataFiles = this.findDataFiles();
      
      for (const file of dataFiles) {
        try {
          await this.importFile(file);
          results.imported.push(file);
        } catch (error) {
          results.errors.push(`${file}: ${error instanceof Error ? error.message : 'Unknown error'}`);
          results.success = false;
        }
      }

    } catch (error) {
      results.errors.push(`Auto-import failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
      results.success = false;
    }

    return results;
  }

  /**
   * Find data files in the project directory
   */
  private findDataFiles(): string[] {
    const files: string[] = [];
    const rootDir = process.cwd();
    
    // Common file patterns to look for
    const patterns = [
      'player_round_scores',
      'round_scores', 
      'price_history',
      'prices',
      'opponent_history',
      'opponents',
      'venue_history',
      'venues',
      'fixtures',
      'games'
    ];

    try {
      const dirContents = fs.readdirSync(rootDir);
      
      for (const file of dirContents) {
        const filePath = path.join(rootDir, file);
        const stat = fs.statSync(filePath);
        
        if (stat.isFile()) {
          const ext = path.extname(file).toLowerCase();
          const name = path.basename(file, ext).toLowerCase();
          
          // Check if it matches our patterns and is a supported format
          if ((ext === '.csv' || ext === '.json') && 
              patterns.some(pattern => name.includes(pattern))) {
            files.push(filePath);
          }
        }
      }
    } catch (error) {
      console.error('Error scanning for data files:', error);
    }

    return files;
  }

  /**
   * Import a specific file based on its name and format
   */
  async importFile(filePath: string): Promise<void> {
    const fileName = path.basename(filePath).toLowerCase();
    const ext = path.extname(filePath).toLowerCase();

    if (ext === '.csv') {
      await this.importCSV(filePath, fileName);
    } else if (ext === '.json') {
      await this.importJSON(filePath);
    } else {
      throw new Error(`Unsupported file format: ${ext}`);
    }
  }

  /**
   * Import CSV files based on filename patterns
   */
  private async importCSV(filePath: string, fileName: string): Promise<void> {
    const data = await this.parseCSV(filePath);
    
    if (fileName.includes('round_scores') || fileName.includes('player_round')) {
      await this.importPlayerRoundScores(data);
    } else if (fileName.includes('price_history') || fileName.includes('prices')) {
      await this.importPriceHistory(data);
    } else if (fileName.includes('opponent_history') || fileName.includes('opponents')) {
      await this.importOpponentHistory(data);
    } else if (fileName.includes('venue_history') || fileName.includes('venues')) {
      await this.importVenueHistory(data);
    } else if (fileName.includes('fixtures') || fileName.includes('games')) {
      await this.importFixtures(data);
    } else {
      throw new Error(`Unknown CSV file pattern: ${fileName}`);
    }
  }

  /**
   * Import JSON files with bulk data
   */
  private async importJSON(filePath: string): Promise<void> {
    const jsonData = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
    
    if (jsonData.playerRoundScores) {
      await this.importPlayerRoundScores(jsonData.playerRoundScores);
    }
    if (jsonData.priceHistory) {
      await this.importPriceHistory(jsonData.priceHistory);
    }
    if (jsonData.opponentHistory) {
      await this.importOpponentHistory(jsonData.opponentHistory);
    }
    if (jsonData.venueHistory) {
      await this.importVenueHistory(jsonData.venueHistory);
    }
    if (jsonData.fixtures) {
      await this.importFixtures(jsonData.fixtures);
    }
  }

  /**
   * Parse CSV file into array of objects
   */
  private async parseCSV(filePath: string): Promise<any[]> {
    return new Promise((resolve, reject) => {
      const results: any[] = [];
      
      fs.createReadStream(filePath)
        .pipe(csv.parse({ 
          headers: true, 
          skip_empty_lines: true,
          trim: true
        }))
        .on('data', (row) => results.push(row))
        .on('end', () => resolve(results))
        .on('error', reject);
    });
  }

  /**
   * Import player round scores
   */
  private async importPlayerRoundScores(data: any[]): Promise<void> {
    const batchSize = 100;
    
    for (let i = 0; i < data.length; i += batchSize) {
      const batch = data.slice(i, i + batchSize);
      const records = batch.map(row => ({
        playerId: this.getPlayerId(row.player_name || row.name),
        round: parseInt(row.round),
        score: parseInt(row.score),
        price: parseInt(row.price),
        opponent: row.opponent || '',
        venue: row.venue || '',
        isHome: this.parseBoolean(row.is_home),
        minutes: row.minutes ? parseInt(row.minutes) : null,
        breakEven: row.break_even ? parseInt(row.break_even) : null,
        priceChange: row.price_change ? parseInt(row.price_change) : 0
      })).filter(record => 
        !isNaN(record.playerId) && 
        !isNaN(record.round) && 
        !isNaN(record.score)
      );

      if (records.length > 0) {
        await db.insert(playerRoundScores).values(records);
      }
    }
  }

  /**
   * Import price history
   */
  private async importPriceHistory(data: any[]): Promise<void> {
    const batchSize = 100;
    
    for (let i = 0; i < data.length; i += batchSize) {
      const batch = data.slice(i, i + batchSize);
      const records = batch.map(row => ({
        playerId: this.getPlayerId(row.player_name || row.name),
        round: parseInt(row.round),
        startPrice: parseInt(row.start_price || row.price),
        endPrice: parseInt(row.end_price || row.new_price),
        priceChange: parseInt(row.price_change),
        breakEven: parseInt(row.break_even),
        score: row.score ? parseInt(row.score) : null,
        magicNumber: row.magic_number ? parseFloat(row.magic_number) : 9650
      })).filter(record => 
        !isNaN(record.playerId) && 
        !isNaN(record.round)
      );

      if (records.length > 0) {
        await db.insert(priceHistory).values(records);
      }
    }
  }

  /**
   * Import opponent history
   */
  private async importOpponentHistory(data: any[]): Promise<void> {
    const records = data.map(row => ({
      playerId: this.getPlayerId(row.player_name || row.name),
      opponent: row.opponent,
      averageScore: parseFloat(row.average_score),
      gamesPlayed: parseInt(row.games_played),
      lastScore: row.last_score ? parseInt(row.last_score) : null,
      last3Average: row.last_3_average ? parseFloat(row.last_3_average) : null,
      lastRound: row.last_round ? parseInt(row.last_round) : null
    })).filter(record => 
      !isNaN(record.playerId) && 
      record.opponent &&
      !isNaN(record.averageScore)
    );

    if (records.length > 0) {
      await db.insert(opponentHistory).values(records);
    }
  }

  /**
   * Import venue history
   */
  private async importVenueHistory(data: any[]): Promise<void> {
    const records = data.map(row => ({
      playerId: this.getPlayerId(row.player_name || row.name),
      venue: row.venue,
      averageScore: parseFloat(row.average_score),
      gamesPlayed: parseInt(row.games_played),
      lastScore: row.last_score ? parseInt(row.last_score) : null,
      last3Average: row.last_3_average ? parseFloat(row.last_3_average) : null,
      lastRound: row.last_round ? parseInt(row.last_round) : null
    })).filter(record => 
      !isNaN(record.playerId) && 
      record.venue &&
      !isNaN(record.averageScore)
    );

    if (records.length > 0) {
      await db.insert(venueHistory).values(records);
    }
  }

  /**
   * Import fixtures
   */
  private async importFixtures(data: any[]): Promise<void> {
    const records = data.map(row => ({
      round: parseInt(row.round),
      homeTeam: row.home_team,
      awayTeam: row.away_team,
      venue: row.venue,
      gameDate: row.game_date ? new Date(row.game_date) : null
    })).filter(record => 
      !isNaN(record.round) && 
      record.homeTeam && 
      record.awayTeam
    );

    if (records.length > 0) {
      await db.insert(fixtures).values(records);
    }
  }

  /**
   * Get or create player ID from name
   */
  private getPlayerId(playerName: string): number {
    // This is a simplified version - in reality, you'd want to
    // match against existing players in the database
    // For now, we'll use a hash of the name as ID
    if (!playerName) return 0;
    
    let hash = 0;
    for (let i = 0; i < playerName.length; i++) {
      const char = playerName.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32-bit integer
    }
    return Math.abs(hash);
  }

  /**
   * Parse boolean values from strings
   */
  private parseBoolean(value: any): boolean {
    if (typeof value === 'boolean') return value;
    if (typeof value === 'string') {
      return value.toLowerCase() === 'true' || value === '1' || value.toLowerCase() === 'yes';
    }
    return Boolean(value);
  }

  /**
   * Get import status and statistics
   */
  async getImportStatus(): Promise<{
    playerRoundScores: number;
    priceHistory: number;
    opponentHistory: number;
    venueHistory: number;
    fixtures: number;
  }> {
    const [
      roundScoresCount,
      priceHistoryCount,
      opponentHistoryCount,
      venueHistoryCount,
      fixturesCount
    ] = await Promise.all([
      db.select().from(playerRoundScores).then(rows => rows.length),
      db.select().from(priceHistory).then(rows => rows.length),
      db.select().from(opponentHistory).then(rows => rows.length),
      db.select().from(venueHistory).then(rows => rows.length),
      db.select().from(fixtures).then(rows => rows.length)
    ]);

    return {
      playerRoundScores: roundScoresCount,
      priceHistory: priceHistoryCount,
      opponentHistory: opponentHistoryCount,
      venueHistory: venueHistoryCount,
      fixtures: fixturesCount
    };
  }
}