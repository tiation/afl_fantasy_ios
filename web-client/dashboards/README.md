# AFL Fantasy Platform - Consolidated Operations Dashboard

*Enterprise-grade monitoring and management interface*

## Overview

The AFL Fantasy Operations Dashboard provides real-time monitoring, system management, and troubleshooting capabilities for the AFL Fantasy Platform infrastructure. This consolidated dashboard replaces 5 legacy dashboard files with a single, unified, accessible experience.

## Features

### ✨ **Key Capabilities**
- **Real-time System Monitoring** - Live status updates every 5-30 seconds
- **Multi-section Navigation** - Overview, System Health, Data Pipeline, Performance, Debug Tools
- **Mobile-responsive Design** - Optimized for desktop, tablet, and mobile devices
- **Enterprise Accessibility** - WCAG 2.1 AA compliant with screen reader support
- **Theme Support** - Dark/light mode with system preference detection
- **Keyboard Navigation** - Full keyboard shortcuts and focus management
- **Performance Optimized** - <2s load time, <90KB gzipped bundle size

### 🎛️ **Dashboard Sections**

#### 1. Overview (Default)
- **System Status Cards** - API Server, Database, Python Services, iOS Build
- **Quick Actions** - Refresh All, View Logs, Restart Services, API Health
- **Activity Feed** - Recent system events and changes
- **Setup Progress** - Installation/configuration status (when applicable)

#### 2. System Health  
- **Service Status Grid** - Detailed metrics for all services
- **Resource Usage** - CPU, memory, disk utilization
- **External Dependencies** - Third-party API status
- **Alert Center** - Active warnings and errors

#### 3. Data Pipeline
- **Scraper Status** - FootyWire, AFL.com, Champion Data scrapers
- **Data Freshness** - Last update times and staleness indicators
- **Processing Queue** - Background job status and queue depth
- **Data Quality** - Validation errors and completeness metrics

#### 4. Performance
- **API Latency Charts** - Response time trends (P50, P95, P99)
- **Request Volume** - Endpoint usage heatmaps
- **Error Rate Trends** - 24h, 7d, 30d error analysis
- **Database Performance** - Query performance and connection metrics

#### 5. Debug Tools
- **System Test Runner** - Automated diagnostic tests
- **Live Log Viewer** - Real-time, filterable application logs
- **API Explorer** - Interactive endpoint testing
- **Configuration Inspector** - Environment variables and feature flags

## Quick Start

### Prerequisites
- Node.js 18+ and npm/pnpm
- AFL Fantasy Platform backend running
- Modern web browser (Chrome, Firefox, Safari, Edge)

### Access Methods

#### 1. Direct URL Access
```
http://localhost:5174/dashboard
```

#### 2. Legacy Redirects (Automatic)
- `/status` → `/dashboard`
- `/debug-status` → `/dashboard#debug`
- `/simple-status` → `/dashboard`

### Environment Setup

Create `.env` file in project root:
```env
# API Configuration
API_BASE_URL=http://localhost:5174
REFRESH_INTERVAL=10000

# Optional: Analytics & Monitoring
SENTRY_DSN=your_sentry_dsn_here
ENABLE_METRICS=true

# Feature Flags
ENABLE_HELP_PANEL=true
ENABLE_THEME_SWITCHER=true
```

## Usage Guide

### Keyboard Shortcuts
| Shortcut | Action |
|----------|--------|
| `Alt + 1-5` | Navigate between sections |
| `R` | Refresh all status |
| `?` | Open/close help panel |
| `Esc` | Close all panels |
| `Tab / Shift+Tab` | Navigate focusable elements |

### Status Indicators
- 🟢 **Healthy** - System operating normally
- 🟡 **Warning** - Non-critical issues detected
- 🔴 **Error** - Service unavailable or critical failure
- ⚫ **Loading** - Status check in progress

### Quick Actions
- **🔄 Refresh All** - Update all dashboard data
- **📋 View Logs** - Jump to debug section logs
- **🔁 Restart Services** - Restart backend services (confirmation required)
- **🏥 API Health** - Run comprehensive API health check

## API Integration

### Health Check Endpoint
```javascript
GET /api/health
```

Expected response:
```json
{
  "status": "healthy",
  "uptime": 86400,
  "services": {
    "database": "healthy",
    "python": "healthy"
  },
  "responseTime": 45,
  "db": {
    "connections": 12,
    "avgQueryTime": 8
  },
  "python": {
    "queueDepth": 0,
    "lastScrape": 1641234567890
  }
}
```

### Events Endpoint (Future)
```javascript
GET /api/events
```

For real-time activity feed updates.

### Metrics Endpoint
```javascript
GET /metrics
```

Prometheus-compatible metrics for external monitoring.

## Customization

### Adding New Widgets

1. **Define Component** in `docs/dashboard_components.csv`:
```csv
my-widget,My Widget,Widget description,/api/my-data,30,chart,region,Custom notes
```

2. **Create Widget Module** in `assets/js/widgets/my-widget.js`:
```javascript
export class MyWidget {
  constructor(containerId) {
    this.containerId = containerId;
  }
  
  async refresh() {
    // Fetch and update widget data
  }
}
```

3. **Add to Dashboard** in `assets/js/dashboard.js`:
```javascript
import { MyWidget } from './widgets/my-widget.js';

// In loadSectionData method
case 'my-section':
  await this.widgets.myWidget.refresh();
  break;
```

### Theme Customization

Edit CSS custom properties in `assets/css/dashboard.css`:
```css
:root {
  --status-success: #10B981;  /* Green */
  --status-warning: #F59E0B;   /* Amber */
  --status-error: #EF4444;     /* Red */
  --bg-primary: #000000;       /* Background */
  --text-primary: #FFFFFF;     /* Text */
}
```

## Performance Targets

- **Initial Load**: < 2 seconds
- **Section Navigation**: < 200ms
- **Data Refresh**: < 500ms per widget
- **Bundle Size**: < 90KB JavaScript (gzipped)
- **Accessibility**: Lighthouse score > 90

## Browser Support

| Browser | Minimum Version | Notes |
|---------|----------------|-------|
| Chrome | 88+ | Full feature support |
| Firefox | 85+ | Full feature support |
| Safari | 14+ | Full feature support |
| Edge | 88+ | Full feature support |
| Mobile Safari | iOS 14+ | Touch-optimized |
| Chrome Mobile | 88+ | Touch-optimized |

## Architecture

### File Structure
```
dashboards/
├── index.html              # Main dashboard HTML
├── assets/
│   ├── css/
│   │   └── dashboard.css   # Consolidated styles
│   └── js/
│       ├── dashboard.js    # Main application logic
│       └── widgets/        # Individual widget modules
├── README.md              # This file
└── docs/                  # Documentation and specs
```

### Technology Stack
- **HTML5** - Semantic, accessible markup
- **CSS3** - Modern features (Grid, Custom Properties, etc.)
- **Vanilla JavaScript** - ES2020 modules, no frameworks
- **Web APIs** - Fetch, Intersection Observer, etc.

### Data Flow
1. **Dashboard Init** → Load initial section (Overview)
2. **Section Switch** → Hide current, show target, load data
3. **Auto Refresh** → Interval-based updates (5-30s)
4. **User Actions** → Manual refresh, service controls
5. **Error Handling** → Graceful fallbacks, user feedback

## Monitoring & Observability

### Client-side Metrics
Access via browser console:
```javascript
// View dashboard metrics
console.log(window.dashboardMetrics);

// Force refresh all status
window.dashboard.refreshAllStatus();

// Switch sections programmatically
window.dashboard.switchToSection('performance');
```

### Performance Monitoring
- **API Call Count** - Total requests made
- **Error Count** - Failed requests and exceptions
- **Last Refresh** - Timestamp of last successful update
- **Section Load Times** - Navigation performance

### Debugging
1. Open browser DevTools (F12)
2. Check Console for error messages
3. Review Network tab for failed requests
4. Use Lighthouse for performance audit

## Migration from Legacy Dashboards

### Automatic Redirects
Legacy URLs automatically redirect to the new dashboard:
- `GET /status` → `GET /dashboard`
- `GET /debug-status` → `GET /dashboard#debug`
- `GET /simple-status` → `GET /dashboard`

### Legacy File Access
For backwards compatibility, legacy files remain accessible:
- `/legacy-debug` → `debug-status.html`
- `/legacy-simple` → `simple-status.html`

**Note**: Legacy files are deprecated and will be removed in v2.0.

### Feature Mapping
| Legacy Dashboard | New Section | Equivalent Features |
|------------------|-------------|-------------------|
| `dashboard.html` | Overview | Status cards, activity feed |
| `status.html` | System Health | Health indicators, metrics |
| `debug-status.html` | Debug Tools | System tests, logs |
| `simple-status.html` | Overview (simplified) | Basic status cards |
| `setup-dashboard.html` | Overview | Setup progress widget |

## Security Considerations

### Data Protection
- No sensitive data logged to browser console in production
- API keys masked in configuration inspector
- CSRF protection on state-changing operations

### Content Security Policy
```http
Content-Security-Policy: default-src 'self'; 
  script-src 'self' 'unsafe-eval'; 
  style-src 'self' 'unsafe-inline' fonts.googleapis.com;
  font-src fonts.gstatic.com;
```

### Access Control
Dashboard assumes users have appropriate access to the AFL Fantasy Platform. Implement authentication at the server/proxy level as needed.

## Troubleshooting

### Common Issues

#### Dashboard Won't Load
1. Check server is running: `curl http://localhost:5174/api/health`
2. Verify dashboard route: `curl http://localhost:5174/dashboard`
3. Check browser console for JavaScript errors

#### Status Cards Show Errors
1. Verify API endpoints are responding
2. Check network connectivity
3. Review CORS configuration

#### Performance Issues
1. Check bundle size: Network tab → dashboard.js
2. Profile JavaScript: DevTools → Performance
3. Run Lighthouse audit for recommendations

#### Mobile Display Issues
1. Verify viewport meta tag
2. Test responsive breakpoints
3. Check touch interactions

### Support

For technical support:
1. Check browser console for errors
2. Review `/api/health` endpoint response  
3. Test with latest browser version
4. Disable browser extensions
5. Clear cache and reload

## Development

### Local Development
```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production  
npm run build

# Run tests
npm test
```

### Code Quality
```bash
# Lint HTML/CSS/JS
npm run lint

# Format code
npm run format

# Accessibility audit
npm run a11y

# Performance audit
npm run lighthouse
```

### Contributing

1. **Fork** the repository
2. **Create** feature branch (`git checkout -b feature/amazing-widget`)
3. **Commit** changes (`git commit -am 'Add amazing widget'`)
4. **Test** thoroughly (manual + automated)
5. **Push** to branch (`git push origin feature/amazing-widget`)
6. **Create** Pull Request

## Changelog

### v1.0.0 (2025-01-06)
- ✨ Initial consolidated dashboard release
- 🎨 Modern, accessible design system
- 📱 Mobile-responsive layout
- ⌨️ Full keyboard navigation
- 🔄 Real-time status updates
- 📊 Five dashboard sections
- 🎭 Dark/light theme support
- 🚀 Performance optimizations (<2s load)
- ♿ WCAG 2.1 AA accessibility compliance
- 📚 Comprehensive help system

---

**Built with ❤️ for the AFL Fantasy Platform**  
*Enterprise-grade monitoring that scales with your needs*
