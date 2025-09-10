import React, { useState, useEffect } from 'react'
import './AdminDashboard.css'

// Dark/Neon Admin Dashboard - Masculine AFL Fantasy Intelligence Command Center
export default function AdminDashboard() {
  const [activeSection, setActiveSection] = useState('overview')
  const [systemStats, setSystemStats] = useState({
    totalUsers: 15847,
    activeScrapers: 4,
    dataPoints: 2847291,
    systemHealth: 98.7,
    lastUpdate: new Date()
  })

  useEffect(() => {
    // Simulate real-time updates
    const interval = setInterval(() => {
      setSystemStats(prev => ({
        ...prev,
        dataPoints: prev.dataPoints + Math.floor(Math.random() * 50),
        systemHealth: 95 + Math.random() * 5,
        lastUpdate: new Date()
      }))
    }, 5000)
    return () => clearInterval(interval)
  }, [])

  return (
    <div className="admin-dashboard">
      {/* Neon Header */}
      <header className="admin-header">
        <div className="header-content">
          <div className="logo-section">
            <div className="neon-logo">⚡ AFL COMMAND</div>
            <div className="subtitle">Intelligence Platform</div>
          </div>
          
          <div className="header-stats">
            <div className="stat-pill">
              <span className="stat-value">{systemStats.totalUsers.toLocaleString()}</span>
              <span className="stat-label">Users</span>
            </div>
            <div className="stat-pill health">
              <span className="stat-value">{systemStats.systemHealth.toFixed(1)}%</span>
              <span className="stat-label">Health</span>
            </div>
            <div className="system-status active">SYSTEM ONLINE</div>
          </div>
        </div>
      </header>

      <div className="admin-body">
        {/* Neon Sidebar */}
        <aside className="admin-sidebar">
          <nav className="sidebar-nav">
            {[
              { id: 'overview', icon: '📊', label: 'System Overview' },
              { id: 'scrapers', icon: '🕷️', label: 'Data Scrapers' },
              { id: 'users', icon: '👥', label: 'User Management' },
              { id: 'analytics', icon: '📈', label: 'Analytics Engine' },
              { id: 'alerts', icon: '⚠️', label: 'System Alerts' },
              { id: 'api', icon: '🔌', label: 'API Management' },
              { id: 'database', icon: '🗄️', label: 'Database Control' },
              { id: 'monitoring', icon: '🎯', label: 'Performance' }
            ].map(item => (
              <button
                key={item.id}
                className={`nav-item ${activeSection === item.id ? 'active' : ''}`}
                onClick={() => setActiveSection(item.id)}
              >
                <span className="nav-icon">{item.icon}</span>
                <span className="nav-label">{item.label}</span>
                {activeSection === item.id && <div className="active-indicator" />}
              </button>
            ))}
          </nav>
        </aside>

        {/* Main Content */}
        <main className="admin-main">
          {activeSection === 'overview' && <SystemOverview stats={systemStats} />}
          {activeSection === 'scrapers' && <ScraperManagement />}
          {activeSection === 'users' && <UserManagement />}
          {activeSection === 'analytics' && <AnalyticsEngine />}
          {activeSection === 'alerts' && <SystemAlerts />}
          {activeSection === 'api' && <APIManagement />}
          {activeSection === 'database' && <DatabaseControl />}
          {activeSection === 'monitoring' && <PerformanceMonitoring />}
        </main>
      </div>
    </div>
  )
}

// System Overview Component
function SystemOverview({ stats }: { stats: any }) {
  return (
    <div className="overview-grid">
      <div className="overview-card primary">
        <h2 className="card-title">🎯 MISSION STATUS</h2>
        <div className="mission-stats">
          <div className="mission-stat">
            <div className="stat-number neon-green">{stats.dataPoints.toLocaleString()}</div>
            <div className="stat-desc">Data Points Collected</div>
          </div>
          <div className="mission-stat">
            <div className="stat-number neon-blue">{stats.activeScrapers}</div>
            <div className="stat-desc">Active Scrapers</div>
          </div>
        </div>
        <div className="pulse-indicator">
          <div className="pulse-dot" />
          <span>Real-time Intelligence Active</span>
        </div>
      </div>

      <div className="overview-card">
        <h3 className="card-title">⚡ SYSTEM PERFORMANCE</h3>
        <div className="perf-metrics">
          <div className="metric-bar">
            <span>CPU Usage</span>
            <div className="bar">
              <div className="bar-fill" style={{width: '67%'}} />
            </div>
            <span className="neon-orange">67%</span>
          </div>
          <div className="metric-bar">
            <span>Memory</span>
            <div className="bar">
              <div className="bar-fill" style={{width: '43%'}} />
            </div>
            <span className="neon-green">43%</span>
          </div>
          <div className="metric-bar">
            <span>Network</span>
            <div className="bar">
              <div className="bar-fill" style={{width: '89%'}} />
            </div>
            <span className="neon-red">89%</span>
          </div>
        </div>
      </div>

      <div className="overview-card">
        <h3 className="card-title">🔥 LIVE ACTIVITY</h3>
        <div className="activity-feed">
          <div className="activity-item">
            <div className="activity-dot neon-green" />
            <span>Scraper #1: Players data updated</span>
            <time>2s ago</time>
          </div>
          <div className="activity-item">
            <div className="activity-dot neon-blue" />
            <span>New user registration: tia_astor</span>
            <time>45s ago</time>
          </div>
          <div className="activity-item">
            <div className="activity-dot neon-orange" />
            <span>Price change detected: Max Gawn +$25k</span>
            <time>1m ago</time>
          </div>
        </div>
      </div>

      <div className="overview-card wide">
        <h3 className="card-title">📈 INTELLIGENCE METRICS</h3>
        <div className="metrics-grid">
          <div className="metric">
            <div className="metric-value neon-green">94.7%</div>
            <div className="metric-label">Prediction Accuracy</div>
          </div>
          <div className="metric">
            <div className="metric-value neon-blue">156ms</div>
            <div className="metric-label">Avg Response Time</div>
          </div>
          <div className="metric">
            <div className="metric-value neon-orange">15,847</div>
            <div className="metric-label">Active Users</div>
          </div>
          <div className="metric">
            <div className="metric-value neon-red">$2.4M</div>
            <div className="metric-label">Team Values Tracked</div>
          </div>
        </div>
      </div>
    </div>
  )
}

// Scraper Management Component  
function ScraperManagement() {
  const scrapers = [
    { id: 1, name: 'Player Stats Scraper', status: 'active', lastRun: '2 minutes ago', success: 99.2 },
    { id: 2, name: 'Price Monitor', status: 'active', lastRun: '5 minutes ago', success: 97.8 },
    { id: 3, name: 'Fixture Scraper', status: 'idle', lastRun: '1 hour ago', success: 100 },
    { id: 4, name: 'Team Analysis Bot', status: 'active', lastRun: '30 seconds ago', success: 94.5 }
  ]

  return (
    <div className="scraper-management">
      <div className="section-header">
        <h2 className="section-title">🕷️ DATA SCRAPER COMMAND</h2>
        <button className="neon-btn primary">Deploy New Scraper</button>
      </div>
      
      <div className="scraper-grid">
        {scrapers.map(scraper => (
          <div key={scraper.id} className={`scraper-card ${scraper.status}`}>
            <div className="scraper-header">
              <h3>{scraper.name}</h3>
              <div className={`status-badge ${scraper.status}`}>
                {scraper.status.toUpperCase()}
              </div>
            </div>
            
            <div className="scraper-metrics">
              <div className="metric">
                <span className="label">Success Rate:</span>
                <span className={`value ${scraper.success > 95 ? 'neon-green' : 'neon-orange'}`}>
                  {scraper.success}%
                </span>
              </div>
              <div className="metric">
                <span className="label">Last Run:</span>
                <span className="value">{scraper.lastRun}</span>
              </div>
            </div>
            
            <div className="scraper-actions">
              <button className="neon-btn small">Configure</button>
              <button className="neon-btn small secondary">Logs</button>
              {scraper.status === 'idle' ? 
                <button className="neon-btn small success">Start</button> :
                <button className="neon-btn small danger">Stop</button>
              }
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}

// User Management Component
function UserManagement() {
  return (
    <div className="user-management">
      <div className="section-header">
        <h2 className="section-title">👥 USER COMMAND CENTER</h2>
        <div className="header-actions">
          <input type="search" placeholder="Search users..." className="neon-input" />
          <button className="neon-btn primary">Add User</button>
        </div>
      </div>
      
      <div className="user-stats">
        <div className="stat-card">
          <div className="stat-number neon-green">15,847</div>
          <div className="stat-label">Total Users</div>
        </div>
        <div className="stat-card">
          <div className="stat-number neon-blue">3,291</div>
          <div className="stat-label">Active Today</div>
        </div>
        <div className="stat-card">
          <div className="stat-number neon-orange">847</div>
          <div className="stat-label">Premium Users</div>
        </div>
      </div>

      <div className="user-table-container">
        <table className="neon-table">
          <thead>
            <tr>
              <th>User</th>
              <th>Status</th>
              <th>Plan</th>
              <th>Last Active</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>
                <div className="user-cell">
                  <div className="user-avatar">TA</div>
                  <div>
                    <div className="user-name">Tia Astor</div>
                    <div className="user-email">tia@example.com</div>
                  </div>
                </div>
              </td>
              <td><span className="status-badge active">Online</span></td>
              <td><span className="plan-badge premium">Premium</span></td>
              <td>2 minutes ago</td>
              <td>
                <button className="action-btn">Edit</button>
                <button className="action-btn danger">Ban</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  )
}

// Additional component stubs for completeness
function AnalyticsEngine() {
  return <div className="section-placeholder">📈 Advanced Analytics Engine - Coming Soon</div>
}

function SystemAlerts() {
  return <div className="section-placeholder">⚠️ System Alert Management - Coming Soon</div>
}

function APIManagement() {
  return <div className="section-placeholder">🔌 API Management Console - Coming Soon</div>
}

function DatabaseControl() {
  return <div className="section-placeholder">🗄️ Database Control Panel - Coming Soon</div>
}

function PerformanceMonitoring() {
  return <div className="section-placeholder">🎯 Performance Monitoring - Coming Soon</div>
}
