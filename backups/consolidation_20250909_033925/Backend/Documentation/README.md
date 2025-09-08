# AFL Fantasy iOS Backend Services

## Overview

The AFL Fantasy iOS project includes comprehensive backend services that power the mobile application with real-time data, advanced analytics, and AI-driven insights. The backend is organized into two main components:

- **Python Services**: Data scraping, analysis, and AI-powered trade recommendations
- **Node.js Services**: RESTful API, real-time communication, and business logic

## Architecture

```
ios/Backend/
├── Python/           # Python-based services
│   ├── api/         # Flask REST API endpoints
│   ├── scrapers/    # Data collection and parsing
│   ├── tools/       # Analysis and calculation engines
│   └── scripts/     # Maintenance and utility scripts
├── Node/            # Node.js/TypeScript services  
│   ├── routes/      # API route definitions
│   ├── services/    # Business logic services
│   ├── middleware/  # Request processing middleware
│   └── utils/       # Utility functions
├── Shared/          # Shared configuration and schemas
└── Documentation/   # This documentation
```

## Key Features

### Python Services
- **AFL Fantasy Data Scraping**: Automated collection of player stats, prices, and team data
- **Trade Score Calculator**: Advanced algorithm for evaluating fantasy trades
- **AI-Powered Analysis**: Machine learning models for player performance prediction
- **Price Trend Analysis**: Historical and predictive price modeling
- **Breakeven Calculations**: Complex financial modeling for player values

### Node.js Services
- **RESTful API Gateway**: Unified API for mobile app consumption
- **Real-time Updates**: WebSocket connections for live data
- **Authentication & Authorization**: Secure user management
- **Caching Layer**: Redis-based performance optimization
- **Monitoring & Metrics**: Prometheus metrics collection

## Quick Start

### Prerequisites
- Python 3.13+
- Node.js 20+
- PostgreSQL 14+
- Redis 7+

### Setup Python Services
```bash
cd ios/Backend/Python
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python api/trade_api.py  # Starts Flask server on port 5000
```

### Setup Node.js Services
```bash
cd ios/Backend/Node
pnpm install
pnpm build
pnpm start  # Starts Express server on port 3000
```

## API Endpoints

### Python Flask API (Port 5000)
- `GET /health` - Health check
- `POST /api/trade_score` - Trade analysis and scoring
- `GET /api/players` - Player data with filtering
- `POST /api/analysis` - Advanced statistical analysis

### Node.js Express API (Port 3000)
- `GET /api/health` - Health check and system status
- `GET /api/dashboard` - Dashboard aggregated data
- `GET /api/players` - Comprehensive player data
- `GET /api/trades` - Trade suggestions and analysis
- `WebSocket /ws` - Real-time updates

## Configuration

### Environment Variables
```bash
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/afl_fantasy
REDIS_URL=redis://localhost:6379

# Security
JWT_SECRET=your_jwt_secret_here
SESSION_SECRET=your_session_secret_here

# AFL Fantasy Credentials (optional)
AFL_FANTASY_USERNAME=your_username
AFL_FANTASY_PASSWORD=your_password

# API Keys (optional)
OPENAI_API_KEY=your_openai_key
GEMINI_API_KEY=your_gemini_key
```

## Data Flow

```mermaid
graph TD
    A[iOS App] --> B[Node.js API Gateway]
    B --> C[Python Analysis Engine]
    B --> D[PostgreSQL Database]
    B --> E[Redis Cache]
    C --> F[AFL Fantasy Scraper]
    C --> G[AI Analysis Models]
    F --> D
    G --> D
```

## Development Workflow

### 1. Data Collection
Python scrapers collect real-time data from AFL Fantasy and other sources.

### 2. Data Processing
Raw data is cleaned, validated, and stored in PostgreSQL with proper indexing.

### 3. Analysis Engine
Python analysis tools calculate trade scores, predict prices, and generate insights.

### 4. API Layer
Node.js serves processed data through RESTful endpoints optimized for mobile consumption.

### 5. Real-time Updates
WebSocket connections push live updates to connected iOS clients.

## Performance Considerations

### Python Services
- **Async Processing**: Uses asyncio for concurrent operations
- **Database Connection Pooling**: Optimized PostgreSQL connections
- **Memory Management**: Efficient data structures and garbage collection
- **Caching**: In-memory caching for frequently accessed data

### Node.js Services  
- **Cluster Mode**: Multi-process deployment for scalability
- **Redis Caching**: Strategic caching of expensive operations
- **Compression**: Gzip compression for API responses
- **Rate Limiting**: Protection against API abuse

## Security

### Authentication
- JWT-based authentication with refresh tokens
- Secure session management
- Password hashing with bcrypt

### Data Protection
- Environment variable secrets management
- SQL injection prevention
- XSS protection middleware
- CORS configuration for iOS app

### Network Security
- HTTPS enforcement in production
- Request rate limiting
- Input validation and sanitization

## Monitoring & Logging

### Metrics Collection
- Prometheus metrics for both Python and Node.js services
- Custom business metrics (trade calculations, API response times)
- System metrics (CPU, memory, database connections)

### Logging
- Structured JSON logging
- Different log levels (debug, info, warn, error)
- Centralized log aggregation
- Error alerting and notifications

## Testing

### Python Tests
```bash
cd ios/Backend/Python
pytest tests/ --coverage --cov-report=html
```

### Node.js Tests
```bash
cd ios/Backend/Node
pnpm test:coverage
```

### Integration Tests
```bash
# Run full integration test suite
cd ios/Backend
./run_integration_tests.sh
```

## Deployment

### Docker Containers
Both Python and Node.js services are containerized for consistent deployment:

```bash
# Build and run with Docker Compose
docker-compose up -d
```

### Environment-specific Configuration
- Development: Local PostgreSQL and Redis
- Staging: Containerized services with test data
- Production: Cloud-hosted with high availability

## Troubleshooting

### Common Issues

1. **Database Connection Errors**
   - Check PostgreSQL is running
   - Verify DATABASE_URL environment variable
   - Check connection limits and permissions

2. **API Timeouts**
   - Review Redis cache status
   - Check network connectivity to AFL Fantasy
   - Monitor system resource usage

3. **Data Inconsistencies** 
   - Run data validation scripts
   - Check scraper logs for errors
   - Verify data transformation logic

## Contributing

1. Follow the established code style (PEP 8 for Python, ESLint for Node.js)
2. Write comprehensive tests for new features
3. Update documentation for API changes
4. Use semantic commit messages
5. Ensure all tests pass before submitting PRs

## Support

For technical support or questions:
- Check the documentation in `ios/Backend/Documentation/`
- Review API specifications in `ios/Backend/Documentation/API/`
- Consult troubleshooting guides
- Create an issue in the project repository

---

*Last updated: $(date)*
