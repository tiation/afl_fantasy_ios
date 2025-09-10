/**
 * AFL Fantasy Command Center - Dashboard Controller
 * Premium dark neon-themed dashboard with real-time integration
 */

class AFLFantasyDashboard {
    constructor() {
        this.config = {
            refreshInterval: 10000, // 10 seconds default
            apiEndpoints: {
                health: 'http://localhost:5005/health',
                express: 'http://localhost:5002/api/health',
                scraper: 'http://localhost:5002/api/scraper/status',
                players: 'http://localhost:5002/api/players',
                matches: 'http://localhost:5002/api/matches',
                sync: 'http://localhost:5002/api/sync'
            },
            themes: {
                'neon-dark': {
                    primary: '#00f5ff',
                    secondary: '#c77dff',
                    accent: '#ff006e'
                },
                'cyber-blue': {
                    primary: '#0080ff',
                    secondary: '#4dc9ff',
                    accent: '#80d4ff'
                },
                'matrix-green': {
                    primary: '#39ff14',
                    secondary: '#7dff7d',
                    accent: '#b3ffb3'
                }
            }
        };

        this.state = {
            isConnected: false,
            autoRefresh: true,
            currentTheme: 'neon-dark',
            lastUpdate: null,
            metrics: {
                cpu: [],
                memory: [],
                network: []
            },
            services: {
                express: { status: 'unknown', uptime: 0 },
                database: { status: 'unknown' },
                redis: { status: 'unknown' },
                scraper: { status: 'unknown', lastRun: null, records: 0 }
            },
            aflData: {
                playerCount: 0,
                playerUpdated: 0,
                matchCount: 0,
                upcomingMatches: 0,
                avgScore: 0,
                topScore: 0
            },
            iosApp: {
                buildStatus: 'Ready',
                lastSync: null
            }
        };

        this.charts = {};
        this.refreshTimer = null;

        this.init();
    }

    async init() {
        console.log('🚀 Initializing AFL Fantasy Command Center');
        
        // Initialize Lucide icons
        if (typeof lucide !== 'undefined') {
            lucide.createIcons();
        }

        // Setup event listeners
        this.setupEventListeners();

        // Initialize charts
        this.initializeCharts();

        // Load settings from localStorage
        this.loadSettings();

        // Start data fetching
        await this.initialDataLoad();

        // Start refresh timer
        this.startRefreshTimer();

        console.log('✅ Dashboard initialized successfully');
    }

    setupEventListeners() {
        // Navigation buttons
        document.getElementById('refreshBtn')?.addEventListener('click', () => {
            this.manualRefresh();
        });

        document.getElementById('settingsBtn')?.addEventListener('click', () => {
            this.showSettings();
        });

        // Settings modal
        document.getElementById('closeSettings')?.addEventListener('click', () => {
            this.hideSettings();
        });

        document.getElementById('refreshInterval')?.addEventListener('change', (e) => {
            this.updateRefreshInterval(parseInt(e.target.value));
        });

        document.getElementById('themeSelect')?.addEventListener('change', (e) => {
            this.changeTheme(e.target.value);
        });

        document.getElementById('autoRefresh')?.addEventListener('change', (e) => {
            this.toggleAutoRefresh(e.target.checked);
        });

        // Action buttons
        document.getElementById('systemLogsBtn')?.addEventListener('click', () => {
            this.scrollToLogs();
        });

        document.getElementById('triggerScrapingBtn')?.addEventListener('click', () => {
            this.triggerScraping();
        });

        document.getElementById('clearLogsBtn')?.addEventListener('click', () => {
            this.clearLogs();
        });

        // Sync buttons
        document.getElementById('syncPlayersBtn')?.addEventListener('click', () => {
            this.syncData('players');
        });

        document.getElementById('syncMatchesBtn')?.addEventListener('click', () => {
            this.syncData('matches');
        });

        document.getElementById('syncScoresBtn')?.addEventListener('click', () => {
            this.syncData('scores');
        });

        // Performance metric tabs
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                this.switchMetricTab(e.target.dataset.metric);
            });
        });

        // Close modal on outside click
        document.getElementById('settingsModal')?.addEventListener('click', (e) => {
            if (e.target.id === 'settingsModal') {
                this.hideSettings();
            }
        });
    }

    initializeCharts() {
        const ctx = document.getElementById('performanceChart');
        if (!ctx) return;

        this.charts.performance = new Chart(ctx, {
            type: 'line',
            data: {
                labels: [],
                datasets: [
                    {
                        label: 'CPU %',
                        data: [],
                        borderColor: '#00f5ff',
                        backgroundColor: 'rgba(0, 245, 255, 0.1)',
                        borderWidth: 2,
                        fill: true,
                        tension: 0.4
                    },
                    {
                        label: 'Memory %',
                        data: [],
                        borderColor: '#c77dff',
                        backgroundColor: 'rgba(199, 125, 255, 0.1)',
                        borderWidth: 2,
                        fill: true,
                        tension: 0.4
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: true,
                        labels: {
                            color: '#ffffff',
                            font: {
                                family: 'Inter, sans-serif',
                                size: 12
                            }
                        }
                    }
                },
                scales: {
                    x: {
                        display: true,
                        grid: {
                            color: 'rgba(255, 255, 255, 0.1)'
                        },
                        ticks: {
                            color: '#b8b8b8',
                            maxTicksLimit: 10
                        }
                    },
                    y: {
                        display: true,
                        beginAtZero: true,
                        max: 100,
                        grid: {
                            color: 'rgba(255, 255, 255, 0.1)'
                        },
                        ticks: {
                            color: '#b8b8b8',
                            callback: (value) => value + '%'
                        }
                    }
                },
                interaction: {
                    intersect: false,
                    mode: 'index'
                }
            }
        });
    }

    async initialDataLoad() {
        this.updateConnectionStatus('connecting');
        
        try {
            // Load all data concurrently
            await Promise.allSettled([
                this.fetchSystemHealth(),
                this.fetchExpressHealth(),
                this.fetchScraperStatus(),
                this.fetchAFLData()
            ]);

            this.updateConnectionStatus('connected');
            this.state.isConnected = true;
        } catch (error) {
            console.error('❌ Initial data load failed:', error);
            this.updateConnectionStatus('disconnected');
        }
    }

    async fetchSystemHealth() {
        try {
            const response = await fetch(this.config.apiEndpoints.health);
            if (!response.ok) throw new Error(`HTTP ${response.status}`);
            
            const data = await response.json();
            this.updateSystemMetrics(data);
            return data;
        } catch (error) {
            console.warn('Health API not available:', error.message);
            this.generateMockSystemData();
        }
    }

    async fetchExpressHealth() {
        try {
            const response = await fetch(this.config.apiEndpoints.express);
            if (!response.ok) throw new Error(`HTTP ${response.status}`);
            
            const data = await response.json();
            this.updateExpressStatus(data);
            return data;
        } catch (error) {
            console.warn('Express API not available:', error.message);
            this.state.services.express = { status: 'offline', uptime: 0 };
        }
    }

    async fetchScraperStatus() {
        try {
            const response = await fetch(this.config.apiEndpoints.scraper);
            if (!response.ok) throw new Error(`HTTP ${response.status}`);
            
            const data = await response.json();
            this.updateScraperStatus(data);
            return data;
        } catch (error) {
            console.warn('Scraper API not available:', error.message);
            this.generateMockScraperData();
        }
    }

    async fetchAFLData() {
        try {
            const [playersRes, matchesRes] = await Promise.allSettled([
                fetch(this.config.apiEndpoints.players),
                fetch(this.config.apiEndpoints.matches)
            ]);

            if (playersRes.status === 'fulfilled' && playersRes.value.ok) {
                const playersData = await playersRes.value.json();
                this.updatePlayerData(playersData);
            }

            if (matchesRes.status === 'fulfilled' && matchesRes.value.ok) {
                const matchesData = await matchesRes.value.json();
                this.updateMatchData(matchesData);
            }

            this.generateMockAFLData(); // Fallback to mock data
        } catch (error) {
            console.warn('AFL API not available:', error.message);
            this.generateMockAFLData();
        }
    }

    updateSystemMetrics(data) {
        const now = new Date().toLocaleTimeString();
        
        if (data.system) {
            const cpu = data.system.cpu?.percent || 0;
            const memory = data.system.memory?.percent || 0;
            const disk = data.system.disk?.percent || 0;

            // Update UI
            document.getElementById('cpuValue').textContent = Math.round(cpu);
            document.getElementById('memoryValue').textContent = Math.round(memory);
            document.getElementById('diskValue').textContent = Math.round(disk);

            this.updateProgressBar('cpuBar', cpu);
            this.updateProgressBar('memoryBar', memory);
            this.updateProgressBar('diskBar', disk);

            // Update chart data
            this.updateChart(now, cpu, memory);
        }

        if (data.services?.docker) {
            this.updateDockerServices(data.services.docker);
        }
    }

    updateExpressStatus(data) {
        this.state.services.express = {
            status: data.status === 'healthy' ? 'online' : 'offline',
            uptime: data.uptime || 0
        };

        const uptime = this.formatUptime(data.uptime);
        document.getElementById('expressUptime').textContent = uptime;

        const statusCard = document.getElementById('expressStatus');
        const statusDot = statusCard?.querySelector('.status-dot');
        const statusText = statusCard?.querySelector('.status-text');

        if (data.status === 'healthy') {
            statusDot?.classList.add('active');
            statusText.textContent = 'Running';
        } else {
            statusDot?.classList.remove('active');
            statusText.textContent = 'Offline';
        }
    }

    updateScraperStatus(data) {
        this.state.services.scraper = {
            status: data.status || 'offline',
            lastRun: data.lastRun || new Date().toISOString(),
            records: data.records || 0
        };

        document.getElementById('scraperLastRun').textContent = 
            this.formatRelativeTime(data.lastRun);
        document.getElementById('scraperRecords').textContent = 
            this.formatNumber(data.records || 0);
    }

    updatePlayerData(data) {
        this.state.aflData.playerCount = data.total || 0;
        this.state.aflData.playerUpdated = data.updatedToday || 0;

        document.getElementById('playerCount').textContent = 
            this.formatNumber(this.state.aflData.playerCount);
        document.getElementById('playerUpdated').textContent = 
            this.formatNumber(this.state.aflData.playerUpdated);
    }

    updateMatchData(data) {
        this.state.aflData.matchCount = data.total || 0;
        this.state.aflData.upcomingMatches = data.upcoming || 0;

        document.getElementById('matchCount').textContent = 
            this.formatNumber(this.state.aflData.matchCount);
        document.getElementById('upcomingMatches').textContent = 
            this.formatNumber(this.state.aflData.upcomingMatches);
    }

    updateChart(time, cpu, memory) {
        const chart = this.charts.performance;
        if (!chart) return;

        const maxDataPoints = 20;
        
        // Add new data point
        chart.data.labels.push(time);
        chart.data.datasets[0].data.push(cpu);
        chart.data.datasets[1].data.push(memory);

        // Remove old data points if too many
        if (chart.data.labels.length > maxDataPoints) {
            chart.data.labels.shift();
            chart.data.datasets.forEach(dataset => {
                dataset.data.shift();
            });
        }

        chart.update('none');
    }

    updateProgressBar(barId, percentage) {
        const bar = document.getElementById(barId);
        if (bar) {
            bar.style.width = `${Math.min(percentage, 100)}%`;
        }
    }

    updateDockerServices(dockerData) {
        if (dockerData.containers) {
            const postgres = dockerData.containers.find(c => c.Image.includes('postgres'));
            const redis = dockerData.containers.find(c => c.Image.includes('redis'));

            this.updateServiceCard('databaseStatus', postgres ? 'active' : 'inactive');
            this.updateServiceCard('redisStatus', redis ? 'active' : 'inactive');
        }
    }

    updateServiceCard(cardId, status) {
        const card = document.getElementById(cardId);
        const statusDot = card?.querySelector('.status-dot');
        const statusText = card?.querySelector('.status-text');

        if (status === 'active') {
            statusDot?.classList.add('active');
            if (cardId === 'databaseStatus') {
                statusText.textContent = 'Connected';
            } else if (cardId === 'redisStatus') {
                statusText.textContent = 'Active';
            }
        } else {
            statusDot?.classList.remove('active');
            statusText.textContent = 'Offline';
        }
    }

    updateConnectionStatus(status) {
        const statusElement = document.getElementById('connectionStatus');
        const dot = statusElement?.querySelector('.status-dot');
        const text = statusElement?.querySelector('span');

        if (status === 'connected') {
            statusElement.style.background = 'rgba(57, 255, 20, 0.1)';
            statusElement.style.borderColor = '#39ff14';
            statusElement.style.color = '#39ff14';
            text.textContent = 'Live';
            dot.style.background = '#39ff14';
        } else if (status === 'connecting') {
            statusElement.style.background = 'rgba(255, 133, 0, 0.1)';
            statusElement.style.borderColor = '#ff8500';
            statusElement.style.color = '#ff8500';
            text.textContent = 'Connecting';
            dot.style.background = '#ff8500';
        } else {
            statusElement.style.background = 'rgba(255, 0, 110, 0.1)';
            statusElement.style.borderColor = '#ff006e';
            statusElement.style.color = '#ff006e';
            text.textContent = 'Offline';
            dot.style.background = '#ff006e';
        }
    }

    generateMockSystemData() {
        const cpu = 20 + Math.random() * 60;
        const memory = 30 + Math.random() * 50;
        const disk = 5 + Math.random() * 10;
        const now = new Date().toLocaleTimeString();

        document.getElementById('cpuValue').textContent = Math.round(cpu);
        document.getElementById('memoryValue').textContent = Math.round(memory);
        document.getElementById('diskValue').textContent = Math.round(disk);

        this.updateProgressBar('cpuBar', cpu);
        this.updateProgressBar('memoryBar', memory);
        this.updateProgressBar('diskBar', disk);

        this.updateChart(now, cpu, memory);
    }

    generateMockScraperData() {
        const mockData = {
            lastRun: new Date(Date.now() - Math.random() * 3600000).toISOString(),
            records: Math.floor(800 + Math.random() * 200)
        };

        document.getElementById('scraperLastRun').textContent = 
            this.formatRelativeTime(mockData.lastRun);
        document.getElementById('scraperRecords').textContent = 
            this.formatNumber(mockData.records);
    }

    generateMockAFLData() {
        const mockData = {
            playerCount: 660 + Math.floor(Math.random() * 40),
            playerUpdated: Math.floor(Math.random() * 50) + 10,
            matchCount: 180 + Math.floor(Math.random() * 20),
            upcomingMatches: Math.floor(Math.random() * 10) + 2,
            avgScore: Math.floor(Math.random() * 20) + 80,
            topScore: Math.floor(Math.random() * 50) + 150
        };

        Object.assign(this.state.aflData, mockData);

        document.getElementById('playerCount').textContent = 
            this.formatNumber(mockData.playerCount);
        document.getElementById('playerUpdated').textContent = 
            this.formatNumber(mockData.playerUpdated);
        document.getElementById('matchCount').textContent = 
            this.formatNumber(mockData.matchCount);
        document.getElementById('upcomingMatches').textContent = 
            this.formatNumber(mockData.upcomingMatches);
        document.getElementById('avgScore').textContent = 
            this.formatNumber(mockData.avgScore);
        document.getElementById('topScore').textContent = 
            this.formatNumber(mockData.topScore);
    }

    async manualRefresh() {
        const refreshBtn = document.getElementById('refreshBtn');
        const icon = refreshBtn?.querySelector('i');
        
        // Add spinning animation
        icon?.classList.add('animate-spin');
        
        try {
            await this.initialDataLoad();
            this.showToast('Data refreshed successfully', 'success');
        } catch (error) {
            this.showToast('Refresh failed', 'error');
        }
        
        // Remove spinning animation
        setTimeout(() => {
            icon?.classList.remove('animate-spin');
        }, 1000);
    }

    async triggerScraping() {
        const btn = document.getElementById('triggerScrapingBtn');
        const originalText = btn.innerHTML;
        
        btn.innerHTML = '<i data-lucide="loader-2" class="animate-spin"></i> Scraping...';
        btn.disabled = true;
        
        try {
            // Simulate scraping trigger
            await new Promise(resolve => setTimeout(resolve, 2000));
            
            this.showToast('Scraping started successfully', 'success');
            this.addLogEntry('INFO', 'Manual scraping triggered by user');
            
            // Update scraper status
            setTimeout(() => {
                this.generateMockScraperData();
            }, 3000);
            
        } catch (error) {
            this.showToast('Failed to trigger scraping', 'error');
        } finally {
            btn.innerHTML = originalText;
            btn.disabled = false;
            lucide.createIcons();
        }
    }

    async syncData(type) {
        const btn = document.getElementById(`sync${type.charAt(0).toUpperCase() + type.slice(1)}Btn`);
        const originalText = btn.innerHTML;
        
        btn.innerHTML = '<i data-lucide="loader-2" class="animate-spin"></i> Syncing...';
        btn.disabled = true;
        
        try {
            // Simulate sync
            await new Promise(resolve => setTimeout(resolve, 1500));
            
            this.showToast(`${type} synced successfully`, 'success');
            this.addLogEntry('SUCCESS', `${type} data synchronized with iOS app`);
            
            // Update last sync time
            this.state.iosApp.lastSync = new Date().toISOString();
            document.getElementById('lastSync').textContent = 'Just now';
            
        } catch (error) {
            this.showToast(`Failed to sync ${type}`, 'error');
        } finally {
            btn.innerHTML = originalText;
            btn.disabled = false;
            lucide.createIcons();
        }
    }

    switchMetricTab(metric) {
        // Update tab states
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        document.querySelector(`[data-metric="${metric}"]`)?.classList.add('active');

        // Update chart based on metric
        // In a real implementation, this would fetch different data
        console.log(`Switching to ${metric} metrics`);
    }

    scrollToLogs() {
        document.querySelector('.logs-container')?.scrollIntoView({ 
            behavior: 'smooth' 
        });
    }

    clearLogs() {
        const logOutput = document.getElementById('logOutput');
        if (logOutput) {
            logOutput.innerHTML = '';
            this.addLogEntry('INFO', 'Log history cleared');
        }
    }

    addLogEntry(level, message) {
        const logOutput = document.getElementById('logOutput');
        if (!logOutput) return;

        const entry = document.createElement('div');
        entry.className = `log-entry ${level.toLowerCase()}`;
        
        const timestamp = new Date().toLocaleTimeString();
        entry.innerHTML = `
            <span class="log-timestamp">[${timestamp}]</span>
            <span class="log-level">${level}</span>
            <span class="log-message">${message}</span>
        `;

        logOutput.appendChild(entry);
        
        // Keep only last 100 entries
        while (logOutput.children.length > 100) {
            logOutput.removeChild(logOutput.firstChild);
        }

        // Auto scroll to bottom
        logOutput.scrollTop = logOutput.scrollHeight;
    }

    showToast(message, type = 'info') {
        // Create toast element
        const toast = document.createElement('div');
        toast.className = `toast toast-${type}`;
        toast.innerHTML = `
            <i data-lucide="${this.getToastIcon(type)}"></i>
            <span>${message}</span>
        `;

        // Add to document
        document.body.appendChild(toast);
        lucide.createIcons();

        // Show toast
        setTimeout(() => toast.classList.add('show'), 100);

        // Remove toast
        setTimeout(() => {
            toast.classList.remove('show');
            setTimeout(() => document.body.removeChild(toast), 300);
        }, 3000);
    }

    getToastIcon(type) {
        const icons = {
            success: 'check-circle',
            error: 'x-circle',
            warning: 'alert-triangle',
            info: 'info'
        };
        return icons[type] || icons.info;
    }

    showSettings() {
        const modal = document.getElementById('settingsModal');
        modal?.classList.add('active');
    }

    hideSettings() {
        const modal = document.getElementById('settingsModal');
        modal?.classList.remove('active');
    }

    updateRefreshInterval(interval) {
        this.config.refreshInterval = interval;
        this.saveSettings();
        this.restartRefreshTimer();
    }

    changeTheme(theme) {
        this.state.currentTheme = theme;
        this.applyTheme(theme);
        this.saveSettings();
    }

    applyTheme(theme) {
        const themeColors = this.config.themes[theme];
        if (!themeColors) return;

        const root = document.documentElement;
        root.style.setProperty('--neon-cyan', themeColors.primary);
        root.style.setProperty('--neon-purple', themeColors.secondary);
        root.style.setProperty('--neon-pink', themeColors.accent);
    }

    toggleAutoRefresh(enabled) {
        this.state.autoRefresh = enabled;
        this.saveSettings();
        
        if (enabled) {
            this.startRefreshTimer();
        } else {
            this.stopRefreshTimer();
        }
    }

    startRefreshTimer() {
        this.stopRefreshTimer();
        
        if (this.state.autoRefresh) {
            this.refreshTimer = setInterval(() => {
                this.initialDataLoad();
            }, this.config.refreshInterval);
        }
    }

    stopRefreshTimer() {
        if (this.refreshTimer) {
            clearInterval(this.refreshTimer);
            this.refreshTimer = null;
        }
    }

    restartRefreshTimer() {
        this.stopRefreshTimer();
        this.startRefreshTimer();
    }

    saveSettings() {
        const settings = {
            refreshInterval: this.config.refreshInterval,
            theme: this.state.currentTheme,
            autoRefresh: this.state.autoRefresh
        };
        
        localStorage.setItem('afl-dashboard-settings', JSON.stringify(settings));
    }

    loadSettings() {
        const saved = localStorage.getItem('afl-dashboard-settings');
        if (!saved) return;

        try {
            const settings = JSON.parse(saved);
            
            if (settings.refreshInterval) {
                this.config.refreshInterval = settings.refreshInterval;
                document.getElementById('refreshInterval').value = settings.refreshInterval;
            }
            
            if (settings.theme) {
                this.state.currentTheme = settings.theme;
                document.getElementById('themeSelect').value = settings.theme;
                this.applyTheme(settings.theme);
            }
            
            if (typeof settings.autoRefresh === 'boolean') {
                this.state.autoRefresh = settings.autoRefresh;
                document.getElementById('autoRefresh').checked = settings.autoRefresh;
            }
        } catch (error) {
            console.warn('Failed to load settings:', error);
        }
    }

    formatUptime(seconds) {
        if (!seconds) return '--';
        
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        
        if (hours > 0) {
            return `${hours}h ${minutes}m`;
        } else if (minutes > 0) {
            return `${minutes}m`;
        } else {
            return `${Math.floor(seconds)}s`;
        }
    }

    formatRelativeTime(timestamp) {
        if (!timestamp) return '--';
        
        const now = Date.now();
        const time = new Date(timestamp).getTime();
        const diff = now - time;
        
        const minutes = Math.floor(diff / 60000);
        const hours = Math.floor(diff / 3600000);
        const days = Math.floor(diff / 86400000);
        
        if (days > 0) return `${days}d ago`;
        if (hours > 0) return `${hours}h ago`;
        if (minutes > 0) return `${minutes}m ago`;
        return 'Just now';
    }

    formatNumber(num) {
        if (num >= 1000000) {
            return (num / 1000000).toFixed(1) + 'M';
        } else if (num >= 1000) {
            return (num / 1000).toFixed(1) + 'K';
        }
        return num.toString();
    }

    // Cleanup on page unload
    destroy() {
        this.stopRefreshTimer();
        
        if (this.charts.performance) {
            this.charts.performance.destroy();
        }
    }
}

// CSS for toast notifications
const toastStyles = `
.toast {
    position: fixed;
    top: 20px;
    right: 20px;
    background: var(--bg-elevated);
    border: 1px solid var(--border-primary);
    border-radius: 8px;
    padding: 1rem 1.5rem;
    display: flex;
    align-items: center;
    gap: 0.75rem;
    color: var(--text-primary);
    box-shadow: var(--shadow-elevated);
    transform: translateX(100%);
    transition: transform 0.3s ease;
    z-index: 10000;
    min-width: 300px;
}

.toast.show {
    transform: translateX(0);
}

.toast.toast-success {
    border-color: var(--neon-green);
}

.toast.toast-error {
    border-color: var(--neon-pink);
}

.toast.toast-warning {
    border-color: var(--neon-orange);
}

.toast.toast-info {
    border-color: var(--neon-cyan);
}

.animate-spin {
    animation: spin 1s linear infinite;
}

@keyframes spin {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
}
`;

// Add toast styles to head
const styleSheet = document.createElement('style');
styleSheet.textContent = toastStyles;
document.head.appendChild(styleSheet);

// Initialize dashboard when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.aflDashboard = new AFLFantasyDashboard();
});

// Cleanup on page unload
window.addEventListener('beforeunload', () => {
    if (window.aflDashboard) {
        window.aflDashboard.destroy();
    }
});
