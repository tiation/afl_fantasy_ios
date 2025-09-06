# 🔄 AFL Fantasy iOS: Data Flow Architecture Diagram

> **Visual System Architecture & Data Pipeline Documentation**
> *Last Updated: September 6, 2025*

---

## 🏗️ **System Architecture Overview**

```mermaid
graph TB
    %% External Data Sources
    subgraph "🌐 External Data Sources"
        AFL[AFL.com Fantasy]
        FW[FootyWire.com]
        DFS[DFS Australia]
        DT[DT Talk]
    end

    %% Backend Processing Layer
    subgraph "🐍 Backend Processing Layer"
        subgraph "Data Scrapers"
            AFL_S[AFL Fantasy Scraper]
            FW_S[FootyWire Scraper]
            DFS_S[DFS Australia Scraper]
            DT_S[DT Talk Scraper]
        end
        
        subgraph "Data Processing"
            MAIN[main.py - Data Orchestrator]
            MERGE[Data Merger & Enricher]
            JSON[player_data.json]
        end
        
        subgraph "Analytics Engine"
            AI_TOOLS[AI Tools Service]
            CASH_TOOLS[Cash Tools Service]
            RISK_TOOLS[Risk Tools Service]
            CAPTAIN_TOOLS[Captain Tools Service]
        end
        
        subgraph "Scheduler"
            SCHED[scheduler.py - 12h Updates]
        end
    end

    %% API Layer
    subgraph "🔄 API Orchestration Layer"
        subgraph "TypeScript API"
            INDEX[index.ts - Main API]
            CATEGORIES[Tool Categories]
        end
        
        subgraph "Flask APIs"
            AFL_API[AFL Fantasy API]
            CAPTAIN_API[Captain API]
            CASH_API[Cash API]
            RISK_API[Risk API]
            TRADE_API[Trade API]
        end
    end

    %% Infrastructure Layer
    subgraph "🏗️ Infrastructure Layer"
        DOCKER[Docker Compose Services]
        POSTGRES[(PostgreSQL DB)]
        REDIS[(Redis Cache)]
        NGINX[Nginx Load Balancer]
    end

    %% iOS Application Layer
    subgraph "📱 iOS Application Layer"
        subgraph "Data Services"
            AFL_DATA_SERVICE[AFL Fantasy Data Service]
            APP_STATE[AppState - Observable]
            NETWORK[Network Layer]
        end
        
        subgraph "UI Components"
            DASHBOARD[Dashboard View]
            CAPTAIN[Captain Advisor]
            CASH_COW[Cash Cow Tracker]
            TRADE_CALC[Trade Calculator]
            SETTINGS[Settings View]
        end
        
        subgraph "Support Services"
            ALERTS[Alert Service]
            PERFORMANCE[Performance Monitor]
            KEYCHAIN[Keychain Manager]
        end
    end

    %% Data Flow Connections
    AFL --> AFL_S
    FW --> FW_S
    DFS --> DFS_S
    DT --> DT_S
    
    AFL_S --> MAIN
    FW_S --> MAIN
    DFS_S --> MAIN
    DT_S --> MAIN
    
    MAIN --> MERGE
    MERGE --> JSON
    JSON --> AI_TOOLS
    JSON --> CASH_TOOLS
    JSON --> RISK_TOOLS
    JSON --> CAPTAIN_TOOLS
    
    SCHED --> MAIN
    
    INDEX --> CATEGORIES
    CATEGORIES --> AFL_API
    CATEGORIES --> CAPTAIN_API
    CATEGORIES --> CASH_API
    CATEGORIES --> RISK_API
    CATEGORIES --> TRADE_API
    
    AI_TOOLS --> CAPTAIN_API
    CASH_TOOLS --> CASH_API
    RISK_TOOLS --> RISK_API
    CAPTAIN_TOOLS --> CAPTAIN_API
    
    DOCKER --> POSTGRES
    DOCKER --> REDIS
    DOCKER --> NGINX
    
    AFL_API --> NETWORK
    CAPTAIN_API --> NETWORK
    CASH_API --> NETWORK
    RISK_API --> NETWORK
    TRADE_API --> NETWORK
    
    NETWORK --> AFL_DATA_SERVICE
    AFL_DATA_SERVICE --> APP_STATE
    
    APP_STATE --> DASHBOARD
    APP_STATE --> CAPTAIN
    APP_STATE --> CASH_COW
    APP_STATE --> TRADE_CALC
    APP_STATE --> SETTINGS
    
    ALERTS --> SETTINGS
    PERFORMANCE --> SETTINGS
    KEYCHAIN --> SETTINGS

    %% Styling
    classDef external fill:#e1f5fe
    classDef backend fill:#f3e5f5
    classDef api fill:#fff3e0
    classDef infra fill:#e8f5e8
    classDef ios fill:#fce4ec
    
    class AFL,FW,DFS,DT external
    class AFL_S,FW_S,DFS_S,DT_S,MAIN,MERGE,JSON,AI_TOOLS,CASH_TOOLS,RISK_TOOLS,CAPTAIN_TOOLS,SCHED backend
    class INDEX,CATEGORIES,AFL_API,CAPTAIN_API,CASH_API,RISK_API,TRADE_API api
    class DOCKER,POSTGRES,REDIS,NGINX infra
    class AFL_DATA_SERVICE,APP_STATE,NETWORK,DASHBOARD,CAPTAIN,CASH_COW,TRADE_CALC,SETTINGS,ALERTS,PERFORMANCE,KEYCHAIN ios
```

---

## 📊 **Detailed Component Data Flow**

### **1. Data Ingestion Pipeline**

```mermaid
sequenceDiagram
    participant EXT as External Sources
    participant SCR as Python Scrapers
    participant PROC as Data Processor
    participant JSON as JSON Storage
    participant API as API Layer
    participant iOS as iOS App

    Note over EXT,iOS: 12-Hour Automated Data Refresh Cycle

    EXT->>SCR: Web scraping requests
    SCR->>PROC: Raw player data
    PROC->>PROC: Data enrichment & validation
    PROC->>JSON: Structured player data
    JSON->>API: Data ready for consumption
    API->>iOS: Live data updates
    
    Note over SCR,PROC: Multi-source data merging
    Note over PROC,JSON: 600+ players processed
    Note over API,iOS: RESTful API calls
```

### **2. Real-Time UI Updates**

```mermaid
sequenceDiagram
    participant User as iOS User
    participant UI as SwiftUI Views
    participant State as AppState
    participant API as Backend APIs
    participant Cache as Redis Cache

    User->>UI: View appears
    UI->>State: Request data update
    State->>API: API call
    
    alt Cache Hit
        API->>Cache: Check cache
        Cache->>API: Return cached data
        API->>State: Cached response
    else Cache Miss
        API->>API: Process request
        API->>Cache: Store result
        API->>State: Fresh response
    end
    
    State->>UI: Data binding update
    UI->>User: UI refresh complete
    
    Note over User,Cache: Sub-second response times
```

### **3. Feature-Specific Data Flows**

#### **Dashboard Data Flow:**
```
External Sources → Scrapers → main.py → JSON → AFL Fantasy API → AppState → SimpleDashboardView
```

#### **Captain Advisor Data Flow:**
```
Player Data → AI Tools → Captain Analysis → Captain API → AppState → SimpleCaptainView
```

#### **Cash Cow Tracker Data Flow:**
```
Price Data → Cash Tools → Price Projections → Cash API → AppState → SimpleCashCowView
```

#### **Trade Calculator Data Flow:**
```
Player Prices → Trade Tools → Trade Analysis → Trade API → AppState → SimpleTradeCalculatorView
```

---

## 🔧 **API Endpoint Architecture**

### **Core AFL Fantasy Endpoints**

| **Endpoint** | **Backend Service** | **UI Consumer** | **Update Frequency** |
|-------------|-------------------|-----------------|-------------------|
| `/api/afl-fantasy/dashboard-data` | AFL Fantasy Data Service | Dashboard View | Real-time |
| `/api/afl-fantasy/team-value` | Cash Tools Service | Team Value Display | 5-minute cache |
| `/api/afl-fantasy/team-score` | Score Calculator | Score Header | Live updates |
| `/api/afl-fantasy/rank` | Rank Tracker | Rank Display | Daily |
| `/api/afl-fantasy/captain` | Captain Service | Captain View | Hourly |

### **Analytics Tool Endpoints**

| **Tool Category** | **Endpoint Pattern** | **Backend Implementation** | **iOS Integration** |
|-------------------|---------------------|---------------------------|-------------------|
| **Trade Analysis** | `/api/trade/*` | TypeScript + Python | Trade Calculator UI |
| **Cash Generation** | `/api/cash/*` | Python Cash Tools | Cash Cow Tracker |
| **Risk Assessment** | `/api/risk/*` | Python Risk Tools | Alert System |
| **AI Analysis** | `/api/ai/*` | Python AI Tools | AI Advisor Views |

---

## 🚀 **Performance Optimization Architecture**

### **Caching Strategy**

```mermaid
graph LR
    subgraph "📱 iOS App"
        MEM[Memory Cache]
        LOCAL[Local Storage]
    end
    
    subgraph "🔄 API Layer"
        REDIS[(Redis Cache)]
        API[API Server]
    end
    
    subgraph "🐍 Backend"
        JSON[JSON Files]
        DB[(PostgreSQL)]
    end

    MEM --> LOCAL
    LOCAL --> REDIS
    REDIS --> API
    API --> JSON
    JSON --> DB

    MEM -.->|"Immediate"| MEM
    LOCAL -.->|"< 100ms"| LOCAL
    REDIS -.->|"< 200ms"| REDIS
    API -.->|"< 500ms"| API
    JSON -.->|"< 1s"| JSON
    DB -.->|"< 2s"| DB
```

### **Data Synchronization Strategy**

| **Data Type** | **Sync Method** | **Frequency** | **Fallback Strategy** |
|---------------|----------------|---------------|---------------------|
| **Player Stats** | Scheduled scraping | Every 12 hours | Cached previous version |
| **Team Scores** | Real-time API | Live updates | 5-minute stale data |
| **Price Changes** | Calculated updates | Hourly | Last known prices |
| **Fixtures** | Weekly scraping | Weekly | Static fixture list |

---

## 🔐 **Security Architecture**

### **Authentication & Authorization Flow**

```mermaid
sequenceDiagram
    participant iOS as iOS App
    participant KC as Keychain
    participant API as Backend API
    participant AFL as AFL.com
    participant DB as Database

    iOS->>KC: Request stored credentials
    KC->>iOS: Return tokens (if available)
    
    alt Tokens Available
        iOS->>API: API request with tokens
        API->>AFL: Validate session
        AFL->>API: Session valid
        API->>DB: Fetch user data
        DB->>API: Return data
        API->>iOS: Protected response
    else No Tokens
        iOS->>iOS: Show login required
        iOS->>AFL: Manual authentication
        AFL->>iOS: Session tokens
        iOS->>KC: Store securely
    end
```

### **Data Protection Measures**

| **Layer** | **Protection Method** | **Implementation** |
|-----------|---------------------|-------------------|
| **Transport** | TLS 1.3 encryption | HTTPS everywhere |
| **Storage** | Keychain encryption | iOS secure enclave |
| **API Keys** | Environment variables | Docker secrets |
| **Session Management** | Secure cookies | HTTPOnly + Secure flags |
| **Database** | Encryption at rest | PostgreSQL encryption |

---

## 📈 **Monitoring & Observability**

### **Performance Metrics Architecture**

```mermaid
graph TB
    subgraph "📱 iOS Metrics"
        COLD[Cold Start Time]
        MEM[Memory Usage]
        CPU[CPU Usage]
        NET[Network Latency]
    end
    
    subgraph "🔄 API Metrics"
        RPS[Requests/Second]
        LAT[Response Latency]
        ERR[Error Rate]
        CACHE[Cache Hit Rate]
    end
    
    subgraph "🐍 Backend Metrics"
        SCRAPE[Scraping Success]
        PROC[Processing Time]
        DATA[Data Quality]
        UPTIME[Service Uptime]
    end
    
    subgraph "📊 Monitoring Stack"
        PROM[Prometheus]
        GRAF[Grafana]
        ALERTS[Alert Manager]
    end

    COLD --> PROM
    MEM --> PROM
    CPU --> PROM
    NET --> PROM
    
    RPS --> PROM
    LAT --> PROM
    ERR --> PROM
    CACHE --> PROM
    
    SCRAPE --> PROM
    PROC --> PROM
    DATA --> PROM
    UPTIME --> PROM
    
    PROM --> GRAF
    PROM --> ALERTS
```

### **Health Check Endpoints**

| **Service** | **Health Check** | **Success Criteria** | **Failure Actions** |
|-------------|-----------------|---------------------|-------------------|
| **API Server** | `/api/health` | 200 OK + service status | Container restart |
| **Python Service** | `/health` | Data freshness check | Scraper restart |
| **Database** | `pg_isready` | Connection successful | Database recovery |
| **Redis** | `redis-cli ping` | PONG response | Cache clear + restart |

---

## 🎯 **Development & Deployment Flow**

### **CI/CD Pipeline Architecture**

```mermaid
graph LR
    subgraph "👩‍💻 Development"
        DEV[Local Development]
        COMMIT[Git Commit]
    end
    
    subgraph "🔄 CI Pipeline"
        BUILD[Build & Test]
        LINT[Lint & Format]
        SEC[Security Scan]
    end
    
    subgraph "🚀 Deployment"
        STAGE[Staging Deploy]
        PROD[Production Deploy]
        MON[Monitoring]
    end

    DEV --> COMMIT
    COMMIT --> BUILD
    BUILD --> LINT
    LINT --> SEC
    SEC --> STAGE
    STAGE --> PROD
    PROD --> MON
    MON -.->|"Feedback"| DEV
```

---

## 🏆 **Architecture Benefits**

### **Scalability Features**
- **Horizontal Scaling**: Container-based microservices
- **Database Sharding**: Player data partitioned by team
- **CDN Integration**: Static assets cached globally
- **Load Balancing**: Nginx with health checks

### **Reliability Features**
- **Data Redundancy**: Multiple scraping sources
- **Graceful Degradation**: Fallback to cached data
- **Circuit Breakers**: API failure protection
- **Health Monitoring**: Proactive issue detection

### **Performance Features**
- **Multi-layer Caching**: Memory → Redis → Database
- **Background Processing**: Non-blocking data updates
- **Optimized Queries**: Database indexing strategy
- **Lazy Loading**: UI components load on demand

---

*This architecture documentation provides a complete visual and technical reference for understanding the AFL Fantasy iOS app's data flow, from external sources through backend processing to iOS UI rendering.*
