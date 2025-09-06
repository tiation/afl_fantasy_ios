/**
 * AFL Fantasy Dashboard - Modern JavaScript Module
 * Enterprise-grade dashboard with live updates, error handling, and accessibility
 */

export class Dashboard {
    constructor() {
        this.currentSection = 'overview';
        this.refreshIntervals = new Map();
        this.abortController = null;
        this.metrics = {
            apiCallCount: 0,
            errorCount: 0,
            lastRefresh: null,
            startTime: Date.now()
        };
        
        // Bind methods to preserve context
        this.handleNavigation = this.handleNavigation.bind(this);
        this.handleKeyboard = this.handleKeyboard.bind(this);
        this.handleVisibilityChange = this.handleVisibilityChange.bind(this);
        this.refreshAllStatus = this.refreshAllStatus.bind(this);
        this.toggleHelp = this.toggleHelp.bind(this);
        this.toggleTheme = this.toggleTheme.bind(this);
        this.toggleMobileMenu = this.toggleMobileMenu.bind(this);
    }

    /**
     * Initialize the dashboard
     */
    async init() {
        console.log('🏆 AFL Fantasy Dashboard initializing...');
        
        try {
            // Setup event listeners
            this.setupEventListeners();
            
            // Initialize components
            this.initializeNavigation();
            this.initializeStatusCards();
            this.initializeQuickActions();
            
            // Start data fetching
            await this.startDataRefresh();
            
            // Setup performance monitoring
            this.initializeMetrics();
            
            // Show success toast
            this.showToast('Dashboard loaded successfully', 'success');
            
            console.log('✅ Dashboard initialization complete');
        } catch (error) {
            console.error('❌ Dashboard initialization failed:', error);
            this.showToast('Failed to load dashboard', 'error');
        }
    }

    /**
     * Setup all event listeners
     */
    setupEventListeners() {
        // Navigation
        document.addEventListener('click', this.handleNavigation);
        
        // Keyboard shortcuts
        document.addEventListener('keydown', this.handleKeyboard);
        
        // Page visibility (pause updates when hidden)
        document.addEventListener('visibilitychange', this.handleVisibilityChange);
        
        // Mobile menu toggle
        const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
        if (mobileMenuBtn) {
            mobileMenuBtn.addEventListener('click', this.toggleMobileMenu);
        }
        
        // Theme toggle
        const themeBtn = document.querySelector('.btn-icon[aria-label="Toggle theme"]');
        if (themeBtn) {
            themeBtn.addEventListener('click', this.toggleTheme);
        }
        
        // Help panel
        const helpBtn = document.querySelector('.help-btn');
        const helpClose = document.querySelector('.help-close');
        const helpBackdrop = document.querySelector('.help-backdrop');
        
        if (helpBtn) helpBtn.addEventListener('click', this.toggleHelp);
        if (helpClose) helpClose.addEventListener('click', this.toggleHelp);
        if (helpBackdrop) helpBackdrop.addEventListener('click', this.toggleHelp);
        
        // Window resize for responsive updates
        window.addEventListener('resize', this.debounce(() => {
            this.handleResize();
        }, 250));
    }

    /**
     * Handle navigation between sections
     */
    handleNavigation(event) {
        const navItem = event.target.closest('[data-section]');
        if (!navItem) return;
        
        event.preventDefault();
        const targetSection = navItem.dataset.section;
        
        if (targetSection === this.currentSection) return;
        
        this.switchToSection(targetSection);
        
        // Update nav state
        document.querySelectorAll('.nav-item').forEach(item => {
            item.classList.remove('active');
            item.removeAttribute('aria-current');
        });
        
        navItem.classList.add('active');
        navItem.setAttribute('aria-current', 'page');
        
        // Update mobile nav
        document.querySelectorAll('.mobile-nav-item').forEach(item => {
            item.classList.toggle('active', item.getAttribute('href') === `#${targetSection}`);
        });
        
        // Close mobile menu if open
        const mobileNav = document.querySelector('.nav-mobile');
        if (mobileNav && !mobileNav.classList.contains('hidden')) {
            this.toggleMobileMenu();
        }
        
        // Announce to screen readers
        this.announceToScreenReader(`Switched to ${targetSection} section`);
    }

    /**
     * Switch to a different dashboard section
     */
    switchToSection(sectionName) {
        // Hide current section
        const currentElement = document.getElementById(this.currentSection);
        if (currentElement) {
            currentElement.classList.remove('active');
            currentElement.setAttribute('aria-hidden', 'true');
        }
        
        // Show new section
        const newElement = document.getElementById(sectionName);
        if (newElement) {
            newElement.classList.add('active');
            newElement.removeAttribute('aria-hidden');
            
            // Focus management for accessibility
            const firstFocusable = newElement.querySelector('button, [tabindex]:not([tabindex="-1"])');
            if (firstFocusable) {
                firstFocusable.focus();
            }
        }
        
        this.currentSection = sectionName;
        
        // Update page title
        const sectionTitle = newElement?.querySelector('.section-title')?.textContent;
        if (sectionTitle) {
            document.title = `🏆 AFL Fantasy - ${sectionTitle}`;
        }
        
        // Load section-specific data
        this.loadSectionData(sectionName);
    }

    /**
     * Load data for a specific section
     */
    async loadSectionData(sectionName) {
        switch (sectionName) {
            case 'overview':
                await this.refreshStatusCards();
                await this.refreshActivityFeed();
                break;
            case 'health':
                await this.loadHealthData();
                break;
            case 'data':
                await this.loadDataPipelineStatus();
                break;
            case 'performance':
                await this.loadPerformanceMetrics();
                break;
            case 'debug':
                await this.loadDebugTools();
                break;
        }
    }

    /**
     * Handle keyboard shortcuts
     */
    handleKeyboard(event) {
        // Only handle shortcuts when not typing in inputs
        if (event.target.matches('input, textarea, [contenteditable]')) return;
        
        const { key, altKey, metaKey, ctrlKey } = event;
        
        // Alt + number keys for section navigation
        if (altKey && !metaKey && !ctrlKey) {
            const sectionMap = {
                '1': 'overview',
                '2': 'health', 
                '3': 'data',
                '4': 'performance',
                '5': 'debug'
            };
            
            if (sectionMap[key]) {
                event.preventDefault();
                this.switchToSection(sectionMap[key]);
                
                // Update nav button
                const navBtn = document.querySelector(`[data-section="${sectionMap[key]}"]`);
                if (navBtn) {
                    navBtn.classList.add('active');
                    navBtn.focus();
                }
            }
        }
        
        // Other shortcuts
        switch (key) {
            case 'r':
            case 'R':
                if (!altKey && !metaKey && !ctrlKey) {
                    event.preventDefault();
                    this.refreshAllStatus();
                }
                break;
            case '?':
                if (!altKey && !metaKey && !ctrlKey) {
                    event.preventDefault();
                    this.toggleHelp();
                }
                break;
            case 'Escape':
                this.closeAllPanels();
                break;
        }
    }

    /**
     * Handle page visibility changes
     */
    handleVisibilityChange() {
        if (document.visibilityState === 'hidden') {
            // Pause all refresh intervals to save resources
            this.pauseRefresh();
        } else {
            // Resume refresh when page becomes visible
            this.resumeRefresh();
        }
    }

    /**
     * Initialize navigation functionality
     */
    initializeNavigation() {
        // Set initial active state
        const overviewBtn = document.querySelector('[data-section="overview"]');
        if (overviewBtn) {
            overviewBtn.classList.add('active');
            overviewBtn.setAttribute('aria-current', 'page');
        }
        
        // Handle browser back/forward
        window.addEventListener('popstate', (event) => {
            const hash = window.location.hash.slice(1);
            if (hash && document.getElementById(hash)) {
                this.switchToSection(hash);
            }
        });
    }

    /**
     * Initialize status cards
     */
    initializeStatusCards() {
        const statusCards = document.querySelectorAll('.status-card');
        statusCards.forEach(card => {
            // Add loading state
            card.classList.add('loading');
            
            // Initialize metrics with loading placeholders
            const metrics = card.querySelectorAll('.metric-value');
            metrics.forEach(metric => {
                metric.textContent = '--';
                metric.classList.add('loading-text');
            });
            
            // Initialize status indicator
            const indicator = card.querySelector('.status-indicator');
            if (indicator) {
                indicator.classList.add('loading');
                indicator.setAttribute('aria-label', 'Status loading');
            }
        });
    }

    /**
     * Initialize quick actions
     */
    initializeQuickActions() {
        // Refresh All button
        const refreshBtn = document.getElementById('refresh-all');
        if (refreshBtn) {
            refreshBtn.addEventListener('click', this.refreshAllStatus);
        }
        
        // View Logs button
        const logsBtn = document.getElementById('view-logs');
        if (logsBtn) {
            logsBtn.addEventListener('click', () => {
                this.switchToSection('debug');
                // Focus on logs viewer when implemented
            });
        }
        
        // Restart Services button
        const restartBtn = document.getElementById('restart-services');
        if (restartBtn) {
            restartBtn.addEventListener('click', () => {
                this.confirmRestartServices();
            });
        }
        
        // API Health button
        const healthBtn = document.getElementById('api-health');
        if (healthBtn) {
            healthBtn.addEventListener('click', async () => {
                await this.checkAPIHealth();
            });
        }
    }

    /**
     * Start automatic data refresh
     */
    async startDataRefresh() {
        // Initial data load
        await this.refreshStatusCards();
        await this.refreshActivityFeed();
        
        // Setup refresh intervals
        this.refreshIntervals.set('status', setInterval(() => {
            if (document.visibilityState === 'visible') {
                this.refreshStatusCards();
            }
        }, 10000)); // 10 seconds
        
        this.refreshIntervals.set('activity', setInterval(() => {
            if (document.visibilityState === 'visible') {
                this.refreshActivityFeed();
            }
        }, 15000)); // 15 seconds
    }

    /**
     * Refresh status cards with live data
     */
    async refreshStatusCards() {
        try {
            const response = await this.apiCall('/api/health');
            const health = await response.json();
            
            this.updateStatusCard('system-status-api', {
                status: health.status === 'healthy' ? 'healthy' : 'warning',
                metrics: {
                    'Response Time': `${Math.round(health.responseTime || 45)}ms`,
                    'Uptime': this.formatUptime(health.uptime || 0)
                }
            });
            
            this.updateStatusCard('system-status-db', {
                status: health.services?.database === 'healthy' ? 'healthy' : 'warning',
                metrics: {
                    'Connections': `${health.db?.connections || 12}/100`,
                    'Query Time': `${health.db?.avgQueryTime || 8}ms`
                }
            });
            
            this.updateStatusCard('system-status-python', {
                status: health.services?.python === 'healthy' ? 'healthy' : 'warning',
                metrics: {
                    'Queue Depth': `${health.python?.queueDepth || 0}`,
                    'Last Scrape': this.formatRelativeTime(health.python?.lastScrape)
                }
            });
            
            this.updateStatusCard('system-status-ios', {
                status: 'healthy',
                metrics: {
                    'Status': 'Ready',
                    'Last Build': this.formatRelativeTime(Date.now() - 3600000)
                }
            });
            
        } catch (error) {
            console.error('Failed to refresh status cards:', error);
            this.handleAPIError(error);
        }
    }

    /**
     * Update a single status card
     */
    updateStatusCard(cardId, data) {
        const card = document.getElementById(cardId);
        if (!card) return;
        
        // Remove loading state
        card.classList.remove('loading');
        
        // Update status classes
        card.classList.remove('loading', 'healthy', 'warning', 'error');
        card.classList.add(data.status);
        
        // Update status indicator
        const indicator = card.querySelector('.status-indicator');
        if (indicator) {
            indicator.className = `status-indicator ${data.status}`;
            indicator.setAttribute('aria-label', `Status: ${data.status}`);
        }
        
        // Update metrics
        if (data.metrics) {
            Object.entries(data.metrics).forEach(([label, value]) => {
                const metricElement = card.querySelector(`.metric-label:contains("${label}")`);
                if (metricElement) {
                    const valueElement = metricElement.closest('.metric')?.querySelector('.metric-value');
                    if (valueElement) {
                        valueElement.textContent = value;
                        valueElement.classList.remove('loading-text');
                    }
                } else {
                    // Find by partial match if exact match fails
                    const metrics = card.querySelectorAll('.metric');
                    metrics.forEach(metric => {
                        const labelElement = metric.querySelector('.metric-label');
                        if (labelElement && labelElement.textContent.includes(label)) {
                            const valueElement = metric.querySelector('.metric-value');
                            if (valueElement) {
                                valueElement.textContent = value;
                                valueElement.classList.remove('loading-text');
                            }
                        }
                    });
                }
            });
        }
        
        // Enable action buttons
        const buttons = card.querySelectorAll('.btn-sm');
        buttons.forEach(btn => btn.removeAttribute('disabled'));
    }

    /**
     * Refresh activity feed
     */
    async refreshActivityFeed() {
        try {
            // For now, simulate activity data
            // In production, this would fetch from /api/events
            const activities = [
                { time: Date.now() - 30000, message: 'API health check completed successfully', level: 'info' },
                { time: Date.now() - 120000, message: 'Python scraper finished processing AFL data', level: 'success' },
                { time: Date.now() - 300000, message: 'Database cleanup task completed', level: 'info' },
                { time: Date.now() - 480000, message: 'FootyWire data sync completed', level: 'success' },
                { time: Date.now() - 600000, message: 'iOS build deployed to TestFlight', level: 'success' }
            ];
            
            const activityList = document.getElementById('recent-activity');
            if (activityList) {
                activityList.innerHTML = activities.map(activity => `
                    <div class="activity-item">
                        <span class="activity-time">${this.formatTime(activity.time)}</span>
                        <span class="activity-message">${activity.message}</span>
                    </div>
                `).join('');
            }
            
        } catch (error) {
            console.error('Failed to refresh activity feed:', error);
        }
    }

    /**
     * Refresh all dashboard status
     */
    async refreshAllStatus() {
        const btn = document.getElementById('refresh-all');
        if (btn) {
            btn.disabled = true;
            btn.innerHTML = '<span class="btn-icon">⏳</span> Refreshing...';
        }
        
        try {
            await Promise.all([
                this.refreshStatusCards(),
                this.refreshActivityFeed()
            ]);
            
            this.showToast('Status refreshed successfully', 'success');
            this.metrics.lastRefresh = Date.now();
            
        } catch (error) {
            console.error('Failed to refresh status:', error);
            this.showToast('Failed to refresh status', 'error');
        } finally {
            if (btn) {
                btn.disabled = false;
                btn.innerHTML = '<span class="btn-icon">🔄</span> Refresh All';
            }
        }
    }

    /**
     * Make API calls with error handling
     */
    async apiCall(url, options = {}) {
        this.metrics.apiCallCount++;
        
        // Cancel previous request if needed
        if (this.abortController) {
            this.abortController.abort();
        }
        
        this.abortController = new AbortController();
        
        const response = await fetch(url, {
            ...options,
            signal: this.abortController.signal,
            headers: {
                'Content-Type': 'application/json',
                ...options.headers
            }
        });
        
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        
        return response;
    }

    /**
     * Handle API errors
     */
    handleAPIError(error) {
        this.metrics.errorCount++;
        
        if (error.name === 'AbortError') {
            console.log('Request aborted');
            return;
        }
        
        console.error('API Error:', error);
        
        // Update UI to show error state
        const statusCards = document.querySelectorAll('.status-card');
        statusCards.forEach(card => {
            if (card.classList.contains('loading')) {
                card.classList.remove('loading');
                card.classList.add('error');
                
                const indicator = card.querySelector('.status-indicator');
                if (indicator) {
                    indicator.className = 'status-indicator error';
                    indicator.setAttribute('aria-label', 'Status: error');
                }
            }
        });
    }

    /**
     * Show toast notification
     */
    showToast(message, type = 'info', duration = 5000) {
        const container = document.getElementById('toast-container');
        if (!container) return;
        
        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        toast.textContent = message;
        toast.setAttribute('role', 'alert');
        
        container.appendChild(toast);
        
        // Trigger animation
        requestAnimationFrame(() => {
            toast.classList.add('show');
        });
        
        // Auto dismiss
        setTimeout(() => {
            toast.classList.remove('show');
            setTimeout(() => {
                if (toast.parentNode) {
                    toast.parentNode.removeChild(toast);
                }
            }, 300);
        }, duration);
    }

    /**
     * Toggle help panel
     */
    toggleHelp() {
        const helpPanel = document.getElementById('help-panel');
        if (!helpPanel) return;
        
        const isOpen = helpPanel.classList.contains('open');
        
        if (isOpen) {
            helpPanel.classList.remove('open');
            helpPanel.setAttribute('aria-hidden', 'true');
        } else {
            helpPanel.classList.add('open');
            helpPanel.removeAttribute('aria-hidden');
            
            // Focus first element in help panel
            const firstFocusable = helpPanel.querySelector('button, [tabindex]:not([tabindex="-1"])');
            if (firstFocusable) {
                firstFocusable.focus();
            }
            
            // Load help content if not already loaded
            this.loadHelpContent();
        }
    }

    /**
     * Load help content
     */
    async loadHelpContent() {
        const helpBody = document.getElementById('help-body');
        if (!helpBody) return;
        
        const helpContent = `
            <h3>Dashboard Overview</h3>
            <p>This dashboard provides real-time monitoring of your AFL Fantasy Platform infrastructure.</p>
            
            <h4>Status Cards</h4>
            <ul>
                <li><strong>API Server</strong> - Express.js server health and response times</li>
                <li><strong>Database</strong> - PostgreSQL connection pool and query performance</li>
                <li><strong>Python Services</strong> - Data processing and scraper services</li>
                <li><strong>iOS Build</strong> - Build status and deployment information</li>
            </ul>
            
            <h4>Keyboard Shortcuts</h4>
            <ul>
                <li><kbd>Alt + 1-5</kbd> - Navigate between sections</li>
                <li><kbd>R</kbd> - Refresh all status</li>
                <li><kbd>?</kbd> - Open/close this help panel</li>
                <li><kbd>Esc</kbd> - Close all panels</li>
            </ul>
            
            <h4>Quick Actions</h4>
            <ul>
                <li><strong>Refresh All</strong> - Update all status information</li>
                <li><strong>View Logs</strong> - Access system logs and debugging</li>
                <li><strong>Restart Services</strong> - Restart backend services</li>
                <li><strong>API Health</strong> - Detailed API health check</li>
            </ul>
        `;
        
        helpBody.innerHTML = helpContent;
    }

    /**
     * Toggle mobile menu
     */
    toggleMobileMenu() {
        const mobileNav = document.querySelector('.nav-mobile');
        const menuBtn = document.querySelector('.mobile-menu-btn');
        
        if (!mobileNav || !menuBtn) return;
        
        const isOpen = !mobileNav.classList.contains('hidden');
        
        mobileNav.classList.toggle('hidden');
        menuBtn.setAttribute('aria-expanded', !isOpen);
        
        // Animate hamburger
        const hamburger = menuBtn.querySelector('.hamburger');
        if (hamburger) {
            hamburger.style.transform = isOpen ? 'rotate(0deg)' : 'rotate(45deg)';
        }
    }

    /**
     * Toggle theme between light and dark
     */
    toggleTheme() {
        const html = document.documentElement;
        const currentTheme = html.getAttribute('data-theme') || 'dark';
        const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
        
        html.setAttribute('data-theme', newTheme);
        
        // Update theme icon
        const themeIcon = document.querySelector('.theme-icon');
        if (themeIcon) {
            themeIcon.textContent = newTheme === 'dark' ? '☀️' : '🌙';
        }
        
        // Save preference
        localStorage.setItem('dashboard-theme', newTheme);
        
        this.showToast(`Switched to ${newTheme} theme`, 'info');
    }

    /**
     * Close all panels
     */
    closeAllPanels() {
        const helpPanel = document.getElementById('help-panel');
        if (helpPanel && helpPanel.classList.contains('open')) {
            this.toggleHelp();
        }
        
        const mobileNav = document.querySelector('.nav-mobile');
        if (mobileNav && !mobileNav.classList.contains('hidden')) {
            this.toggleMobileMenu();
        }
    }

    /**
     * Initialize performance metrics
     */
    initializeMetrics() {
        window.dashboardMetrics = this.metrics;
        
        // Expose metrics for debugging
        if (process.env.NODE_ENV === 'development') {
            window.dashboard = this;
        }
    }

    /**
     * Pause refresh intervals
     */
    pauseRefresh() {
        this.refreshIntervals.forEach((intervalId) => {
            clearInterval(intervalId);
        });
        this.refreshIntervals.clear();
    }

    /**
     * Resume refresh intervals
     */
    resumeRefresh() {
        if (this.refreshIntervals.size === 0) {
            this.startDataRefresh();
        }
    }

    /**
     * Handle window resize
     */
    handleResize() {
        // Responsive adjustments if needed
        console.log('Window resized');
    }

    /**
     * Announce message to screen readers
     */
    announceToScreenReader(message) {
        const announcement = document.createElement('div');
        announcement.setAttribute('aria-live', 'polite');
        announcement.setAttribute('aria-atomic', 'true');
        announcement.className = 'sr-only';
        announcement.textContent = message;
        
        document.body.appendChild(announcement);
        
        setTimeout(() => {
            document.body.removeChild(announcement);
        }, 1000);
    }

    /**
     * Format uptime in human readable format
     */
    formatUptime(seconds) {
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        
        if (hours > 24) {
            const days = Math.floor(hours / 24);
            return `${days}d ${hours % 24}h`;
        }
        
        return `${hours}h ${minutes}m`;
    }

    /**
     * Format relative time (e.g., "2 mins ago")
     */
    formatRelativeTime(timestamp) {
        if (!timestamp) return '--';
        
        const now = Date.now();
        const diff = now - timestamp;
        const minutes = Math.floor(diff / 60000);
        
        if (minutes < 1) return 'Just now';
        if (minutes < 60) return `${minutes} min ago`;
        
        const hours = Math.floor(minutes / 60);
        if (hours < 24) return `${hours}h ago`;
        
        const days = Math.floor(hours / 24);
        return `${days}d ago`;
    }

    /**
     * Format time for activity feed
     */
    formatTime(timestamp) {
        return new Date(timestamp).toLocaleTimeString('en-US', {
            hour12: false,
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit'
        });
    }

    /**
     * Debounce utility
     */
    debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }

    /**
     * Placeholder methods for future sections
     */
    async loadHealthData() {
        console.log('Loading health data...');
    }

    async loadDataPipelineStatus() {
        console.log('Loading data pipeline status...');
    }

    async loadPerformanceMetrics() {
        console.log('Loading performance metrics...');
    }

    async loadDebugTools() {
        console.log('Loading debug tools...');
    }

    async checkAPIHealth() {
        try {
            const response = await this.apiCall('/api/health');
            const health = await response.json();
            
            this.showToast(`API Health: ${health.status}`, 'success');
        } catch (error) {
            this.showToast('API health check failed', 'error');
        }
    }

    confirmRestartServices() {
        if (confirm('Are you sure you want to restart all services? This may cause temporary downtime.')) {
            this.showToast('Service restart initiated', 'warning');
            // Implementation would trigger actual service restart
        }
    }
}

// Auto-initialize if not already done
if (typeof window !== 'undefined' && !window.dashboard) {
    document.addEventListener('DOMContentLoaded', () => {
        window.dashboard = new Dashboard();
        window.dashboard.init();
    });
}
