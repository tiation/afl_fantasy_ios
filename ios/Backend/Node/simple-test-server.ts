#!/usr/bin/env tsx
/**
 * Simple Test Server for API Endpoints
 * Tests basic API endpoints with database connectivity
 */

import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config({ path: '../../../.env' });

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    service: 'AFL Fantasy Node API',
    version: '1.0.0'
  });
});

// Mock dashboard data endpoint
app.get('/v1/dashboard', (req, res) => {
  // Simulate dashboard data that iOS expects
  const dashboardData = {
    teamValue: {
      total: 83000000,
      remaining: 10000000,
      formatted: '$83.0M'
    },
    rank: {
      current: 15847,
      change: -234,
      formatted: '15,847'
    },
    upcomingMatchups: [
      { homeTeam: 'Melbourne', awayTeam: 'Collingwood', round: 24 },
      { homeTeam: 'Carlton', awayTeam: 'Brisbane', round: 24 }
    ],
    topPlayers: [
      { name: 'Max Gawn', score: 145, team: 'Melbourne' },
      { name: 'Clayton Oliver', score: 128, team: 'Melbourne' },
      { name: 'Christian Petracca', score: 94, team: 'Melbourne' }
    ],
    lastUpdated: new Date().toISOString()
  };

  res.json(dashboardData);
});

// Mock players list endpoint
app.get('/v1/players', async (req, res) => {
  try {
    // Mock player data (in real app, this would come from database)
    const mockPlayers = [
      {
        id: 1,
        name: 'Max Gawn',
        team: 'Melbourne',
        position: 'RUC',
        price: 800000,
        avg: 105.2,
        lastScore: 112,
        ownership: 45.8
      },
      {
        id: 2,
        name: 'Clayton Oliver',
        team: 'Melbourne', 
        position: 'MID',
        price: 750000,
        avg: 115.8,
        lastScore: 128,
        ownership: 52.3
      },
      {
        id: 3,
        name: 'Christian Petracca',
        team: 'Melbourne',
        position: 'MID', 
        price: 720000,
        avg: 110.4,
        lastScore: 94,
        ownership: 41.2
      },
      {
        id: 4,
        name: 'Marcus Bontempelli',
        team: 'Western Bulldogs',
        position: 'MID',
        price: 700000,
        avg: 108.7,
        lastScore: 115,
        ownership: 48.7
      },
      {
        id: 5,
        name: 'Charlie Curnow',
        team: 'Carlton',
        position: 'FWD',
        price: 750000,
        avg: 98.5,
        lastScore: 85,
        ownership: 39.8
      }
    ];

    // Apply position filter if provided
    const { position } = req.query;
    let filteredPlayers = mockPlayers;
    
    if (position) {
      filteredPlayers = mockPlayers.filter(p => 
        p.position.toLowerCase() === position.toString().toLowerCase()
      );
    }

    res.json({
      status: 'success',
      data: filteredPlayers,
      count: filteredPlayers.length,
      total: mockPlayers.length,
      filters: { position: position || 'all' }
    });
  } catch (error) {
    console.error('Error fetching players:', error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch players'
    });
  }
});

// Single player endpoint
app.get('/v1/players/:id', (req, res) => {
  const playerId = parseInt(req.params.id);
  
  // Mock single player data
  const player = {
    id: playerId,
    name: 'Max Gawn',
    team: 'Melbourne',
    position: 'RUC',
    price: 800000,
    avg: 105.2,
    lastScore: 112,
    ownership: 45.8,
    breakeven: 78,
    form: 'Good',
    injury: null,
    stats: {
      games: 22,
      goals: 12,
      assists: 8,
      disposals: 18.5,
      marks: 4.2
    }
  };

  res.json({
    status: 'success',
    data: player
  });
});

// Trade score endpoint (mock)
app.post('/api/trade_score', (req, res) => {
  const { player_in_id, player_out_id, budget } = req.body;
  
  // Mock trade score calculation
  const tradeScore = {
    score: Math.round(Math.random() * 100),
    confidence: Math.round(Math.random() * 100),
    recommendation: Math.random() > 0.5 ? 'Good trade' : 'Consider alternatives',
    factors: {
      form: Math.round(Math.random() * 50),
      price: Math.round(Math.random() * 50),
      fixture: Math.round(Math.random() * 50),
      ownership: Math.round(Math.random() * 50)
    }
  };

  res.json({
    status: 'success',
    data: tradeScore
  });
});

// Error handling
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Error:', err);
  res.status(500).json({
    status: 'error',
    message: 'Internal server error'
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    status: 'error',
    message: 'Endpoint not found',
    availableEndpoints: [
      'GET /api/health',
      'GET /v1/dashboard', 
      'GET /v1/players',
      'GET /v1/players/:id',
      'POST /api/trade_score'
    ]
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Test API Server running on port ${PORT}`);
  console.log(`📍 Health check: http://localhost:${PORT}/api/health`);
  console.log(`📊 Dashboard: http://localhost:${PORT}/v1/dashboard`);
  console.log(`👥 Players: http://localhost:${PORT}/v1/players`);
});

export default app;
