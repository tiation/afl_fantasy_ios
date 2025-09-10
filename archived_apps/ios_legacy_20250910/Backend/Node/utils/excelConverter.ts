import * as XLSX from 'xlsx';
import * as fs from 'fs';
import * as path from 'path';

export class ExcelConverter {
  
  /**
   * Convert Excel file to proper format and import to database
   */
  async convertAndImport(filePath: string): Promise<{
    success: boolean;
    sheets: string[];
    converted: string[];
    errors: string[];
  }> {
    const result = {
      success: true,
      sheets: [] as string[],
      converted: [] as string[],
      errors: [] as string[]
    };

    try {
      // Read Excel file
      const workbook = XLSX.readFile(filePath);
      result.sheets = workbook.SheetNames;
      
      console.log(`Found Excel sheets: ${result.sheets.join(', ')}`);

      // Process each sheet
      for (const sheetName of workbook.SheetNames) {
        try {
          const worksheet = workbook.Sheets[sheetName];
          const jsonData = XLSX.utils.sheet_to_json(worksheet);
          
          if (jsonData.length === 0) {
            result.errors.push(`Sheet "${sheetName}" is empty`);
            continue;
          }

          console.log(`Processing sheet "${sheetName}" with ${jsonData.length} rows`);
          console.log('Sample columns:', Object.keys(jsonData[0] as any).slice(0, 10));

          // Auto-detect data type and convert
          const detectedType = this.detectDataType(sheetName, jsonData);
          
          if (detectedType) {
            const csvPath = await this.convertToCSV(jsonData, detectedType, sheetName);
            result.converted.push(csvPath);
            console.log(`Converted ${sheetName} to ${detectedType} format: ${csvPath}`);
          } else {
            result.errors.push(`Could not detect data type for sheet "${sheetName}"`);
          }

        } catch (error) {
          result.errors.push(`Error processing sheet "${sheetName}": ${error instanceof Error ? error.message : 'Unknown error'}`);
          result.success = false;
        }
      }

    } catch (error) {
      result.errors.push(`Error reading Excel file: ${error instanceof Error ? error.message : 'Unknown error'}`);
      result.success = false;
    }

    return result;
  }

  /**
   * Auto-detect what type of data is in the sheet
   */
  private detectDataType(sheetName: string, data: any[]): string | null {
    const sampleRow = data[0] as any;
    const columns = Object.keys(sampleRow).map(k => k.toLowerCase());
    
    console.log(`Analyzing sheet "${sheetName}" columns:`, columns);

    // Check for round scores data
    if (this.hasColumns(columns, ['round', 'score']) || 
        this.hasColumns(columns, ['player', 'points']) ||
        this.hasColumns(columns, ['name', 'round']) ||
        sheetName.toLowerCase().includes('round') ||
        sheetName.toLowerCase().includes('score')) {
      return 'round_scores';
    }

    // Check for price data
    if (this.hasColumns(columns, ['price', 'change']) ||
        this.hasColumns(columns, ['cost', 'value']) ||
        sheetName.toLowerCase().includes('price') ||
        sheetName.toLowerCase().includes('cost')) {
      return 'prices';
    }

    // Check for opponent data
    if (this.hasColumns(columns, ['opponent', 'average']) ||
        this.hasColumns(columns, ['vs', 'team']) ||
        sheetName.toLowerCase().includes('opponent') ||
        sheetName.toLowerCase().includes('matchup')) {
      return 'opponents';
    }

    // Check for venue data
    if (this.hasColumns(columns, ['venue', 'ground']) ||
        this.hasColumns(columns, ['stadium', 'home']) ||
        sheetName.toLowerCase().includes('venue') ||
        sheetName.toLowerCase().includes('ground')) {
      return 'venues';
    }

    // Check for fixtures
    if (this.hasColumns(columns, ['home', 'away']) ||
        this.hasColumns(columns, ['team1', 'team2']) ||
        sheetName.toLowerCase().includes('fixture') ||
        sheetName.toLowerCase().includes('game')) {
      return 'fixtures';
    }

    // Default to round scores if has player and score data
    if (this.hasColumns(columns, ['player', 'score']) ||
        this.hasColumns(columns, ['name', 'points'])) {
      return 'round_scores';
    }

    return null;
  }

  /**
   * Check if columns contain required fields
   */
  private hasColumns(columns: string[], required: string[]): boolean {
    return required.every(req => 
      columns.some(col => col.includes(req))
    );
  }

  /**
   * Convert data to proper CSV format
   */
  private async convertToCSV(data: any[], type: string, sheetName: string): Promise<string> {
    const convertedData = this.mapToStandardFormat(data, type);
    const csvContent = this.arrayToCSV(convertedData);
    
    const fileName = `${type}_${sheetName.replace(/[^a-zA-Z0-9]/g, '_')}.csv`;
    const filePath = path.join(process.cwd(), fileName);
    
    fs.writeFileSync(filePath, csvContent);
    return fileName;
  }

  /**
   * Map Excel data to standard database format
   */
  private mapToStandardFormat(data: any[], type: string): any[] {
    switch (type) {
      case 'round_scores':
        return this.mapRoundScores(data);
      case 'prices':
        return this.mapPrices(data);
      case 'opponents':
        return this.mapOpponents(data);
      case 'venues':
        return this.mapVenues(data);
      case 'fixtures':
        return this.mapFixtures(data);
      default:
        return data;
    }
  }

  /**
   * Map round scores data
   */
  private mapRoundScores(data: any[]): any[] {
    return data.map(row => {
      const mapped: any = {};
      
      // Find player name
      mapped.player_name = this.findValue(row, ['name', 'player', 'full_name', 'player_name']) || '';
      
      // Find round
      mapped.round = this.findValue(row, ['round', 'rd', 'week']) || 1;
      
      // Find score
      mapped.score = this.findValue(row, ['score', 'points', 'fantasy_points', 'total']) || 0;
      
      // Find price
      mapped.price = this.findValue(row, ['price', 'cost', 'value', 'salary']) || 0;
      
      // Find opponent
      mapped.opponent = this.findValue(row, ['opponent', 'opp', 'vs', 'against']) || '';
      
      // Find venue
      mapped.venue = this.findValue(row, ['venue', 'ground', 'stadium', 'location']) || '';
      
      // Find home/away
      const homeValue = this.findValue(row, ['home', 'is_home', 'h_a', 'venue_type']);
      mapped.is_home = homeValue === 'H' || homeValue === 'Home' || homeValue === true || homeValue === 1;
      
      // Find minutes
      mapped.minutes = this.findValue(row, ['minutes', 'mins', 'time_on_ground', 'tog']) || null;
      
      // Find breakeven
      mapped.break_even = this.findValue(row, ['breakeven', 'break_even', 'be']) || null;
      
      // Find price change
      mapped.price_change = this.findValue(row, ['price_change', 'change', 'delta']) || 0;
      
      return mapped;
    });
  }

  /**
   * Map price history data
   */
  private mapPrices(data: any[]): any[] {
    return data.map(row => ({
      player_name: this.findValue(row, ['name', 'player', 'full_name']) || '',
      round: this.findValue(row, ['round', 'rd', 'week']) || 1,
      start_price: this.findValue(row, ['start_price', 'price', 'old_price']) || 0,
      end_price: this.findValue(row, ['end_price', 'new_price', 'final_price']) || 0,
      price_change: this.findValue(row, ['price_change', 'change', 'delta']) || 0,
      break_even: this.findValue(row, ['breakeven', 'break_even', 'be']) || 0,
      score: this.findValue(row, ['score', 'points', 'fantasy_points']) || null,
      magic_number: this.findValue(row, ['magic_number', 'magic']) || 9650
    }));
  }

  /**
   * Map opponent history data
   */
  private mapOpponents(data: any[]): any[] {
    return data.map(row => ({
      player_name: this.findValue(row, ['name', 'player', 'full_name']) || '',
      opponent: this.findValue(row, ['opponent', 'opp', 'vs', 'team']) || '',
      average_score: this.findValue(row, ['average', 'avg', 'mean_score']) || 0,
      games_played: this.findValue(row, ['games', 'matches', 'count']) || 0,
      last_score: this.findValue(row, ['last_score', 'recent', 'latest']) || null,
      last_3_average: this.findValue(row, ['last_3', 'l3_avg', 'recent_avg']) || null,
      last_round: this.findValue(row, ['last_round', 'recent_round']) || null
    }));
  }

  /**
   * Map venue history data
   */
  private mapVenues(data: any[]): any[] {
    return data.map(row => ({
      player_name: this.findValue(row, ['name', 'player', 'full_name']) || '',
      venue: this.findValue(row, ['venue', 'ground', 'stadium']) || '',
      average_score: this.findValue(row, ['average', 'avg', 'mean_score']) || 0,
      games_played: this.findValue(row, ['games', 'matches', 'count']) || 0,
      last_score: this.findValue(row, ['last_score', 'recent', 'latest']) || null,
      last_3_average: this.findValue(row, ['last_3', 'l3_avg', 'recent_avg']) || null,
      last_round: this.findValue(row, ['last_round', 'recent_round']) || null
    }));
  }

  /**
   * Map fixtures data
   */
  private mapFixtures(data: any[]): any[] {
    return data.map(row => ({
      round: this.findValue(row, ['round', 'rd', 'week']) || 1,
      home_team: this.findValue(row, ['home', 'home_team', 'team1']) || '',
      away_team: this.findValue(row, ['away', 'away_team', 'team2']) || '',
      venue: this.findValue(row, ['venue', 'ground', 'stadium']) || '',
      game_date: this.findValue(row, ['date', 'game_date', 'match_date']) || null
    }));
  }

  /**
   * Find value from row using multiple possible column names
   */
  private findValue(row: any, possibleNames: string[]): any {
    for (const name of possibleNames) {
      // Try exact match
      if (row[name] !== undefined) return row[name];
      
      // Try case-insensitive match
      const key = Object.keys(row).find(k => k.toLowerCase() === name.toLowerCase());
      if (key && row[key] !== undefined) return row[key];
      
      // Try partial match
      const partialKey = Object.keys(row).find(k => 
        k.toLowerCase().includes(name.toLowerCase()) || 
        name.toLowerCase().includes(k.toLowerCase())
      );
      if (partialKey && row[partialKey] !== undefined) return row[partialKey];
    }
    return null;
  }

  /**
   * Convert array of objects to CSV string
   */
  private arrayToCSV(data: any[]): string {
    if (data.length === 0) return '';
    
    const headers = Object.keys(data[0]);
    const csvRows = [headers.join(',')];
    
    for (const row of data) {
      const values = headers.map(header => {
        const value = row[header];
        // Escape commas and quotes
        if (typeof value === 'string' && (value.includes(',') || value.includes('"'))) {
          return `"${value.replace(/"/g, '""')}"`;
        }
        return value;
      });
      csvRows.push(values.join(','));
    }
    
    return csvRows.join('\n');
  }

  /**
   * Get list of Excel files in directory
   */
  findExcelFiles(): string[] {
    const files: string[] = [];
    const rootDir = process.cwd();
    
    try {
      const dirContents = fs.readdirSync(rootDir);
      
      for (const file of dirContents) {
        const ext = path.extname(file).toLowerCase();
        if (ext === '.xlsx' || ext === '.xls') {
          files.push(path.join(rootDir, file));
        }
      }
    } catch (error) {
      console.error('Error scanning for Excel files:', error);
    }

    return files;
  }
}