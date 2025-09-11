/**
 * Prometheus Metrics Middleware for Enterprise Monitoring
 */

import { Request, Response, NextFunction } from 'express';
import { register, collectDefaultMetrics, Counter, Histogram, Gauge } from 'prom-client';

// Collect default metrics (CPU, memory, etc.)
collectDefaultMetrics({ register });

// Custom metrics
export const httpRequestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10]
});

export const httpRequestsTotal = new Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

export const activeConnections = new Gauge({
  name: 'active_connections',
  help: 'Number of active connections'
});

export const scraperErrorsTotal = new Counter({
  name: 'scraper_errors_total',
  help: 'Total number of scraper errors',
  labelNames: ['scraper_type', 'error_type']
});

export const dataFreshnessSeconds = new Gauge({
  name: 'data_freshness_seconds',
  help: 'Time since last successful data update',
  labelNames: ['data_source']
});

export const databaseConnectionsActive = new Gauge({
  name: 'database_connections_active',
  help: 'Number of active database connections'
});

export const redisConnectionsActive = new Gauge({
  name: 'redis_connections_active',
  help: 'Number of active Redis connections'
});

// Middleware to track HTTP metrics
export const metricsMiddleware = (req: Request, res: Response, next: NextFunction) => {
  const start = Date.now();
  
  // Track active connections
  activeConnections.inc();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const route = req.route?.path || req.path;
    
    // Record metrics
    httpRequestDuration
      .labels(req.method, route, res.statusCode.toString())
      .observe(duration);
    
    httpRequestsTotal
      .labels(req.method, route, res.statusCode.toString())
      .inc();
    
    // Decrement active connections
    activeConnections.dec();
  });
  
  next();
};

// Health check endpoint
export const healthCheck = async (req: Request, res: Response) => {
  const healthStatus = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    version: process.env.npm_package_version || '1.0.0',
    environment: process.env.NODE_ENV || 'development',
    services: {
      database: 'healthy', // TODO: Add actual DB health check
      redis: 'healthy',    // TODO: Add actual Redis health check
      scrapers: 'healthy'  // TODO: Add scraper health check
    }
  };
  
  res.status(200).json(healthStatus);
};

// Metrics endpoint
export const metricsEndpoint = async (req: Request, res: Response) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
};

// Track scraper errors
export const trackScraperError = (scraperType: string, errorType: string) => {
  scraperErrorsTotal.labels(scraperType, errorType).inc();
};

// Update data freshness
export const updateDataFreshness = (dataSource: string, timestamp: Date) => {
  const freshnessSeconds = (Date.now() - timestamp.getTime()) / 1000;
  dataFreshnessSeconds.labels(dataSource).set(freshnessSeconds);
};