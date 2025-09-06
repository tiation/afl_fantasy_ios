#!/usr/bin/env tsx
/**
 * Test Database Connectivity - Node.js with Drizzle ORM
 * Tests connection to PostgreSQL database
 */

import { Pool } from 'pg';
import { drizzle } from 'drizzle-orm/node-postgres';
import { sql } from 'drizzle-orm';
import * as dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const DATABASE_URL = process.env.DATABASE_URL?.replace('localhost', '127.0.0.1') || 'postgresql://postgres:password@127.0.0.1:5432/afl_fantasy';

console.log('🔄 Testing Node.js Database Connectivity');
console.log('=' .repeat(50));

async function testDatabaseConnection() {
  let pool: Pool | null = null;
  
  try {
    // Test basic connection
    console.log('📡 Connecting to database...');
    console.log(`   URL: ${DATABASE_URL.replace(/password@/, '***@')}`);
    
    pool = new Pool({ 
      connectionString: DATABASE_URL,
      max: 1, // Only need one connection for testing
      connectTimeoutMillis: 5000,
      idleTimeoutMillis: 1000,
    });
    
    // Test connection with a simple query
    const testResult = await pool.query('SELECT version(), now() as current_time');
    console.log('✅ Database connection successful!');
    console.log(`   Version: ${testResult.rows[0].version.split(' ').slice(0, 3).join(' ')}`);
    console.log(`   Time: ${testResult.rows[0].current_time}`);
    
    // Test with Drizzle ORM
    console.log('\n🔄 Testing Drizzle ORM...');
    const db = drizzle(pool);
    
    const drizzleResult = await db.execute(sql`SELECT COUNT(*) as player_count FROM players`);
    const playerCount = drizzleResult.rows[0]?.player_count || 0;
    console.log('✅ Drizzle ORM connection successful!');
    console.log(`   Players in database: ${playerCount}`);
    
    if (playerCount > 0) {
      // Get a sample player
      const sampleResult = await db.execute(sql`
        SELECT id, name, team, position, price, average_score 
        FROM players 
        ORDER BY price DESC 
        LIMIT 3
      `);
      
      console.log('\n📊 Sample players (top 3 by price):');
      sampleResult.rows.forEach((player: any, index: number) => {
        console.log(`   ${index + 1}. ${player.name} (${player.team}) - $${Number(player.price).toLocaleString()} - ${player.average_score} avg`);
      });
    } else {
      console.log('⚠️  No players found in database. Run sync_players.py first.');
    }
    
    return true;
    
  } catch (error) {
    console.error('❌ Database connection failed:');
    if (error instanceof Error) {
      console.error(`   Error: ${error.message}`);
      if (error.message.includes('ECONNREFUSED')) {
        console.error('   💡 Tip: Make sure PostgreSQL is running on the specified host/port');
      } else if (error.message.includes('authentication')) {
        console.error('   💡 Tip: Check username/password in DATABASE_URL');
      } else if (error.message.includes('database') && error.message.includes('does not exist')) {
        console.error('   💡 Tip: Create the database first or check DATABASE_URL');
      }
    } else {
      console.error('   Unknown error:', error);
    }
    return false;
  } finally {
    if (pool) {
      await pool.end();
      console.log('\n🔐 Database connection closed');
    }
  }
}

// Test database connectivity
testDatabaseConnection()
  .then(success => {
    console.log(`\n${success ? '✅' : '❌'} Database connectivity test ${success ? 'PASSED' : 'FAILED'}`);
    process.exit(success ? 0 : 1);
  })
  .catch(error => {
    console.error('\n💥 Unexpected error:', error);
    process.exit(1);
  });
