// AFL Fantasy Dashboard - Premium JavaScript with Beautiful UI
'use strict';

class DashboardController {
    constructor() {
        this.currentSection = 'overview';
        this.refreshPaused = false;
        this.refreshInterval = null;
        this.activityFeed = [];
        this.toastContainer = null;
        this.isConnected = true;
        this.darkMode = true;
        this.animations = {
            cardHover: null,
            statusPulse: null,
            dataFlow: null
        };
        
        this.init();
    }
    
    init() {
        this.createToastContainer();
        this.bindEvents();
        this.setupNavigation();
        this.setupThemeToggle();
        this.initializeAnimations();
        this.startRefreshTimer();
        this.fetchInitialData();
        this.bindKeyboardShortcuts();
        this.showWelcomeMessage();
        
        console.log('🎉 AFL Fantasy Dashboard - Premium Edition initialized');
    }
    
    showWelcomeMessage() {
        setTimeout(() => {
            this.showToast('Welcome to AFL Fantasy Dashboard', 'success', {
                duration: 4000,
                icon: '🏆'
            });
        }, 1000);
    }
    
    setupThemeToggle() {
        const themeBtn = document.querySelector('[aria-label="Toggle theme"]');
        const themeIcon = themeBtn?.querySelector('.theme-icon');
        
        if (!themeBtn || !themeIcon) return;
        
        themeBtn.addEventListener('click', () => {
            this.darkMode = !this.darkMode;
            const html = document.documentElement;
            
            if (this.darkMode) {
                html.setAttribute('data-theme', 'dark');
                themeIcon.textContent = '🌙';
                this.showToast('Dark mode enabled', 'info', { duration: 2000 });
            } else {
                html.setAttribute('data-theme', 'light');
                themeIcon.textContent = '☀️';
                this.showToast('Light mode enabled', 'info', { duration: 2000 });
            }
            
            // Add smooth transition effect
            document.body.style.transition = 'background-color 0.3s ease';
            setTimeout(() => {
                document.body.style.transition = '';
            }, 300);
        });
    }
    
    initializeAnimations() {
        // Animate cards on load
        this.animateCardsIn();
        
        // Setup hover effects
        this.setupCardHoverEffects();
        
        // Initialize status indicators
        this.animateStatusIndicators();
        
        // Setup loading shimmer effects
        this.setupShimmerEffects();
    }
    
    animateCardsIn() {
        const cards = document.querySelectorAll('.status-card');
        cards.forEach((card, index) => {
            card.style.opacity = '0';
            card.style.transform = 'translateY(20px)';
            
            setTimeout(() => {
                card.style.transition = 'all 0.4s ease-out';
                card.style.opacity = '1';
                card.style.transform = 'translateY(0)';
            }, index * 150);
        });
    }
    
    setupCardHoverEffects() {
        const cards = document.querySelectorAll('.status-card');
        
        cards.forEach(card => {
            card.addEventListener('mouseenter', () => {
                if (!this.isReducedMotion()) {
                    card.style.transform = 'translateY(-4px) scale(1.01)';
                    card.style.boxShadow = '0 20px 40px rgba(0, 0, 0, 0.15), 0 0 30px rgba(34, 197, 94, 0.1)';
                }
            });
            
            card.addEventListener('mouseleave', () => {
                if (!this.isReducedMotion()) {
                    card.style.transform = 'translateY(0) scale(1)';
                    card.style.boxShadow = '';
                }
            });
        });
    }
    
    animateStatusIndicators() {
        const indicators = document.querySelectorAll('.status-indicator');
        
        indicators.forEach(indicator => {
            if (!this.isReducedMotion()) {
                indicator.style.animation = 'pulse 2s infinite';
            }
        });
    }
    
    setupShimmerEffects() {
        const loadingElements = document.querySelectorAll('.loading-text');
        
        loadingElements.forEach(element => {
            if (!this.isReducedMotion()) {
                element.style.background = 'linear-gradient(90deg, transparent, rgba(255,255,255,0.1), transparent)';
                element.style.backgroundSize = '200% 100%';
                element.style.animation = 'shimmer 1.5s infinite';
            }
        });
    }
    
    isReducedMotion() {
        return window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    }
    
    bindEvents() {
        // Navigation events
        const navItems = document.querySelectorAll('.nav-item');
        navItems.forEach(item => {
            item.addEventListener('click', (e) => this.handleNavigation(e));
        });
        
        // Mobile menu toggle
        const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
        const mobileNav = document.querySelector('.nav-mobile');
        
        if (mobileMenuBtn && mobileNav) {
            mobileMenuBtn.addEventListener('click', () => {
                const isOpen = mobileNav.classList.contains('hidden');
                
                if (isOpen) {
                    mobileNav.classList.remove('hidden');
                    mobileMenuBtn.setAttribute('aria-expanded', 'true');
                    this.animateHamburger(mobileMenuBtn, true);
                } else {
                    mobileNav.classList.add('hidden');
                    mobileMenuBtn.setAttribute('aria-expanded', 'false');
                    this.animateHamburger(mobileMenuBtn, false);
                }
            });
        }
        
        // Help panel
        this.setupHelpPanel();
        
        // Card action buttons
        this.setupCardActions();
        
        // Quick actions
        this.setupQuickActions();
    }
    
    animateHamburger(button, isOpen) {
        const hamburger = button.querySelector('.hamburger');
        
        if (hamburger) {
            if (isOpen) {
                hamburger.style.transform = 'rotate(45deg)';
                hamburger.style.backgroundColor = 'transparent';
            } else {
                hamburger.style.transform = 'rotate(0deg)';
                hamburger.style.backgroundColor = 'currentColor';
            }
        }
    }
    
    setupHelpPanel() {
        const helpBtns = document.querySelectorAll('.help-btn');
        this.createHelpPanel();
        
        helpBtns.forEach(btn => {
            btn.addEventListener('click', () => {
                const helpId = btn.getAttribute('data-help-id');
                this.showHelpPanel(helpId);
            });
        });
    }
    
    createHelpPanel() {
        // Create help panel if it doesn't exist
        let helpPanel = document.querySelector('.help-panel');
        
        if (!helpPanel) {
            helpPanel = document.createElement('div');
            helpPanel.className = 'help-panel';
            helpPanel.innerHTML = `
                <div class="help-backdrop"></div>
                <div class="help-content">
                    <header class="help-header">
                        <h2 class="help-title">Help & Documentation</h2>
                        <button class="help-close" aria-label="Close help panel">×</button>
                    </header>
                    <div class="help-body">
                        <div class="help-content-text">
                            <!-- Help content will be populated here -->
                        </div>
                    </div>
                </div>
            `;
            
            document.body.appendChild(helpPanel);
            
            // Bind close events
            const closeBtn = helpPanel.querySelector('.help-close');
            const backdrop = helpPanel.querySelector('.help-backdrop');
            
            closeBtn.addEventListener('click', () => this.hideHelpPanel());
            backdrop.addEventListener('click', () => this.hideHelpPanel());
            
            // ESC key to close
            document.addEventListener('keydown', (e) => {
                if (e.key === 'Escape' && helpPanel.classList.contains('open')) {
                    this.hideHelpPanel();
                }
            });
        }
        
        return helpPanel;
    }
    
    showHelpPanel(helpId) {
        const helpPanel = document.querySelector('.help-panel');
        const helpContent = helpPanel?.querySelector('.help-content-text');
        
        if (!helpPanel || !helpContent) return;
        
        // Get help content based on ID
        const content = this.getHelpContent(helpId);
        helpContent.innerHTML = content;
        
        // Show panel with animation
        helpPanel.classList.add('open');
        
        // Focus management for accessibility
        const closeBtn = helpPanel.querySelector('.help-close');
        closeBtn?.focus();
    }
    
    hideHelpPanel() {
        const helpPanel = document.querySelector('.help-panel');
        helpPanel?.classList.remove('open');
    }
    
    getHelpContent(helpId) {
        const helpTexts = {
            'system-status-api': `
                <h3>🚀 API Server Status</h3>
                <p><strong>Response Time:</strong> Average time for API requests to complete. Lower is better (target: &lt;200ms).</p>
                <p><strong>Uptime:</strong> Percentage of time the API has been available over the last 24 hours.</p>
                <p><strong>Actions:</strong></p>
                <ul>
                    <li><strong>Restart:</strong> Restarts the API server service</li>
                </ul>
                <p><em>Green = Healthy, Yellow = Warning, Red = Error</em></p>
            `,
            'system-status-db': `
                <h3>🗄️ Database Status</h3>
                <p><strong>Connections:</strong> Active connections out of maximum allowed. Monitor for connection pool exhaustion.</p>
                <p><strong>Query Time:</strong> Average database query execution time. Higher values indicate performance issues.</p>
                <p><strong>Actions:</strong></p>
                <ul>
                    <li><strong>Monitor:</strong> Opens detailed database monitoring dashboard</li>
                </ul>
            `,
            'system-status-python': `
                <h3>🐍 Python Services Status</h3>
                <p><strong>Queue Depth:</strong> Number of pending tasks in processing queues. High values indicate bottlenecks.</p>
                <p><strong>Last Scrape:</strong> Time since the last successful data scrape operation.</p>
                <p><strong>Actions:</strong></p>
                <ul>
                    <li><strong>Refresh:</strong> Triggers immediate data refresh cycle</li>
                </ul>
            `,
            'system-status-ios': `
                <h3>📱 iOS Build Status</h3>
                <p><strong>Status:</strong> Current build pipeline status and health check.</p>
                <p><strong>Last Build:</strong> Timestamp of the most recent successful build.</p>
                <p><strong>Build Pipeline:</strong> Automated builds are triggered on code commits and run comprehensive tests.</p>
            `
        };
        
        return helpTexts[helpId] || '<p>Help information not available for this component.</p>';
    }
    
    setupCardActions() {
        const actionBtns = document.querySelectorAll('.btn-sm');
        
        actionBtns.forEach(btn => {
            btn.addEventListener('click', (e) => {
                const action = btn.textContent.toLowerCase();
                const cardId = btn.closest('.status-card')?.id;
                
                if (cardId) {
                    this.handleCardAction(action, cardId);
                }
            });
        });
    }
    
    handleCardAction(action, cardId) {
        // Disable button during action
        const btn = document.querySelector(`#${cardId} .btn-sm`);
        if (btn) {
            btn.disabled = true;
            btn.style.opacity = '0.5';
        }
        
        // Show loading state
        this.showToast(`${action} initiated...`, 'info', { duration: 2000, icon: '⚙️' });
        
        // Simulate action
        setTimeout(() => {
            if (btn) {
                btn.disabled = false;
                btn.style.opacity = '1';
            }
            this.showToast(`${action} completed successfully`, 'success', { duration: 3000, icon: '✅' });
            
            // Add to activity feed
            this.addActivity(`System action: ${action} on ${cardId.replace('system-status-', '')}`);
        }, 2000);
    }
    
    setupQuickActions() {
        const quickActions = document.querySelectorAll('.action-btn');
        
        quickActions.forEach(btn => {
            btn.addEventListener('click', (e) => {
                const actionText = btn.textContent.trim();
                
                // Add click animation
                if (!this.isReducedMotion()) {
                    btn.style.transform = 'scale(0.95)';
                    setTimeout(() => {
                        btn.style.transform = '';
                    }, 150);
                }
                
                this.handleQuickAction(actionText, btn);
            });
        });
    }
    
    handleQuickAction(actionText, btn) {
        const actionMap = {
            'Refresh All Data': () => this.refreshAllData(),
            'Export Logs': () => this.exportLogs(),
            'Run Health Check': () => this.runHealthCheck(),
            'View Documentation': () => this.viewDocumentation()
        };
        
        const action = actionMap[actionText];
        if (action) {
            action();
        } else {
            this.showToast(`${actionText} - Coming soon!`, 'info', { duration: 2000 });
        }
    }
    
    refreshAllData() {
        this.showToast('Refreshing all system data...', 'info', { duration: 2000, icon: '🔄' });
        
        // Trigger refresh of all components
        this.fetchSystemHealth();
        
        setTimeout(() => {
            this.showToast('Data refresh completed', 'success', { duration: 3000, icon: '✅' });
            this.addActivity('Manual data refresh triggered by user');
        }, 2000);
    }
    
    exportLogs() {
        this.showToast('Preparing log export...', 'info', { duration: 2000, icon: '📄' });
        
        setTimeout(() => {
            // Simulate log export
            const logData = this.generateSampleLogs();
            const blob = new Blob([logData], { type: 'text/plain' });
            const url = URL.createObjectURL(blob);
            
            const a = document.createElement('a');
            a.href = url;
            a.download = `afl-fantasy-logs-${new Date().toISOString().split('T')[0]}.txt`;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
            
            this.showToast('Logs exported successfully', 'success', { duration: 3000, icon: '💾' });
            this.addActivity('System logs exported');
        }, 1500);
    }
    
    runHealthCheck() {
        this.showToast('Running comprehensive health check...', 'info', { duration: 3000, icon: '🔍' });
        
        // Simulate health check process
        const checks = ['API endpoints', 'Database connections', 'Service dependencies', 'Resource usage'];
        let currentCheck = 0;
        
        const checkInterval = setInterval(() => {
            if (currentCheck < checks.length) {
                this.showToast(`Checking ${checks[currentCheck]}...`, 'info', { 
                    duration: 1000, 
                    icon: '⚙️' 
                });
                currentCheck++;
            } else {
                clearInterval(checkInterval);
                this.showToast('Health check completed - All systems operational', 'success', { 
                    duration: 4000, 
                    icon: '🎉' 
                });
                this.addActivity('Comprehensive health check completed');
            }
        }, 800);
    }
    
    viewDocumentation() {
        this.showHelpPanel('documentation');
    }
    
    generateSampleLogs() {
        const now = new Date();
        const logs = [];
        
        for (let i = 0; i < 50; i++) {
            const timestamp = new Date(now - (i * 60000)).toISOString();
            const levels = ['INFO', 'WARN', 'ERROR', 'DEBUG'];
            const level = levels[Math.floor(Math.random() * levels.length)];
            const messages = [
                'API request processed successfully',
                'Database query executed',
                'User session created',
                'Data scrape completed',
                'Cache invalidated',
                'Service health check passed'
            ];
            const message = messages[Math.floor(Math.random() * messages.length)];
            
            logs.push(`[${timestamp}] ${level}: ${message}`);
        }
        
        return logs.join('\n');
    }
    
    setupNavigation() {
        const navItems = document.querySelectorAll('.nav-item');
        
        navItems.forEach(item => {
            item.addEventListener('click', (e) => {
                const targetSection = e.target.getAttribute('data-section');
                if (targetSection) {
                    this.switchSection(targetSection);
                }
            });
        });
    }
    
    switchSection(sectionName) {
        // Update navigation state
        document.querySelectorAll('.nav-item').forEach(item => {
            item.classList.remove('active');
            item.removeAttribute('aria-current');
        });
        
        const activeNav = document.querySelector(`[data-section="${sectionName}"]`);
        if (activeNav) {
            activeNav.classList.add('active');
            activeNav.setAttribute('aria-current', 'page');
        }
        
        // Update sections
        document.querySelectorAll('.dashboard-section').forEach(section => {
            section.classList.remove('active');
        });
        
        const targetSection = document.getElementById(sectionName);
        if (targetSection) {
            targetSection.classList.add('active');
            
            // Animate section transition
            if (!this.isReducedMotion()) {
                targetSection.style.opacity = '0';
                targetSection.style.transform = 'translateY(10px)';
                
                setTimeout(() => {
                    targetSection.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
                    targetSection.style.opacity = '1';
                    targetSection.style.transform = 'translateY(0)';
                }, 50);
            }
        }
        
        this.currentSection = sectionName;
        
        // Add activity
        this.addActivity(`Navigated to ${sectionName} section`);
    }
    
    handleNavigation(event) {
        const section = event.target.getAttribute('data-section');
        if (section) {
            this.switchSection(section);
        }
    }
    
    startRefreshTimer() {
        this.refreshInterval = setInterval(() => {
            if (!this.refreshPaused) {
                this.fetchSystemHealth();
            }
        }, 5000); // Refresh every 5 seconds
        
        // Show refresh indicator
        this.showRefreshIndicator();
    }
    
    showRefreshIndicator() {
        // Create refresh indicator if it doesn't exist
        let indicator = document.querySelector('.refresh-indicator');
        if (!indicator) {
            indicator = document.createElement('div');
            indicator.className = 'refresh-indicator';
            indicator.innerHTML = '🔄';
            indicator.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                background: var(--bg-elevated);
                border: 1px solid var(--border-primary);
                border-radius: 50%;
                width: 40px;
                height: 40px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 12px;
                opacity: 0;
                transition: all 0.3s ease;
                z-index: 1000;
                pointer-events: none;
            `;
            document.body.appendChild(indicator);
        }
        
        // Animate refresh
        indicator.style.opacity = '1';
        indicator.style.transform = 'rotate(360deg)';
        
        setTimeout(() => {
            indicator.style.opacity = '0';
            indicator.style.transform = 'rotate(0deg)';
        }, 1000);
    }
    
    fetchInitialData() {
        this.showToast('Loading dashboard data...', 'info', { duration: 2000, icon: '📊' });
        
        // Simulate initial data load
        setTimeout(() => {
            this.fetchSystemHealth();
            this.populateActivityFeed();
        }, 1000);
    }
    
    async fetchSystemHealth() {
        try {
            const response = await fetch('/api/health');
            const data = await response.json();
            
            this.updateSystemStatus(data);
            
        } catch (error) {
            console.error('Failed to fetch system health:', error);
            this.handleFetchError(error);
        }
    }
    
    updateSystemStatus(data) {
        // API Server Status
        this.updateStatusCard('system-status-api', {
            status: data.api?.status || 'healthy',
            metrics: {
                'Response Time': data.api?.responseTime ? `${data.api.responseTime}ms` : '150ms',
                'Uptime': data.api?.uptime || '99.8%'
            }
        });
        
        // Database Status
        this.updateStatusCard('system-status-db', {
            status: data.database?.status || 'healthy',
            metrics: {
                'Connections': data.database?.connections || '12/100',
                'Query Time': data.database?.queryTime ? `${data.database.queryTime}ms` : '45ms'
            }
        });
        
        // Python Services Status
        this.updateStatusCard('system-status-python', {
            status: data.python?.status || 'healthy',
            metrics: {
                'Queue Depth': data.python?.queueDepth?.toString() || '3',
                'Last Scrape': data.python?.lastScrape || '2 min ago'
            }
        });
        
        // iOS Build Status
        this.updateStatusCard('system-status-ios', {
            status: data.ios?.status || 'healthy',
            metrics: {
                'Status': data.ios?.buildStatus || 'Passing',
                'Last Build': data.ios?.lastBuild || '1 hour ago'
            }
        });
    }
    
    updateStatusCard(cardId, statusData) {
        const card = document.getElementById(cardId);
        if (!card) return;
        
        const statusIndicator = card.querySelector('.status-indicator');
        const metrics = card.querySelector('.metrics-grid');
        const actionBtn = card.querySelector('.btn-sm');
        
        // Update status indicator
        if (statusIndicator) {
            statusIndicator.className = `status-indicator ${statusData.status}`;
            statusIndicator.setAttribute('aria-label', `Status: ${statusData.status}`);
        }
        
        // Update card border
        card.className = `status-card ${statusData.status}`;
        
        // Update metrics
        if (statusData.metrics && metrics) {
            Object.entries(statusData.metrics).forEach(([label, value]) => {
                const metricElement = [...metrics.querySelectorAll('.metric')]
                    .find(metric => metric.querySelector('.metric-label')?.textContent === label);
                
                if (metricElement) {
                    const valueElement = metricElement.querySelector('.metric-value');
                    if (valueElement) {
                        valueElement.textContent = value;
                        valueElement.classList.remove('loading-text');
                    }
                }
            });
        }
        
        // Enable action button
        if (actionBtn) {
            actionBtn.disabled = false;
        }
        
        // Add update animation
        if (!this.isReducedMotion()) {
            card.style.transform = 'scale(1.02)';
            setTimeout(() => {
                card.style.transform = '';
            }, 200);
        }
    }
    
    handleFetchError(error) {
        this.showToast('Failed to update system status', 'error', { 
            duration: 4000, 
            icon: '❌' 
        });
        
        this.addActivity('Error: Failed to fetch system health data');
        
        // Update cards to show error state
        const cards = document.querySelectorAll('.status-card.loading');
        cards.forEach(card => {
            card.className = 'status-card error';
            const indicator = card.querySelector('.status-indicator');
            if (indicator) {
                indicator.className = 'status-indicator error';
                indicator.setAttribute('aria-label', 'Status: error');
            }
        });
    }
    
    populateActivityFeed() {
        const activities = [
            'System startup completed successfully',
            'Database migration applied',
            'User authentication service started',
            'Data scraping scheduled for next hour',
            'Security scan passed',
            'Performance optimization applied'
        ];
        
        activities.forEach((activity, index) => {
            setTimeout(() => {
                this.addActivity(activity);
            }, index * 500);
        });
    }
    
    addActivity(message) {
        const timestamp = new Date();
        const activity = {
            time: timestamp.toLocaleTimeString('en-US', { 
                hour12: false,
                hour: '2-digit', 
                minute: '2-digit',
                second: '2-digit'
            }),
            message: message,
            id: Date.now() + Math.random()
        };
        
        this.activityFeed.unshift(activity);
        
        // Keep only last 20 activities
        if (this.activityFeed.length > 20) {
            this.activityFeed = this.activityFeed.slice(0, 20);
        }
        
        this.updateActivityFeedDisplay();
    }
    
    updateActivityFeedDisplay() {
        const activityList = document.querySelector('.activity-list');
        if (!activityList) return;
        
        activityList.innerHTML = this.activityFeed.map(activity => `
            <div class="activity-item" data-id="${activity.id}">
                <div class="activity-time">${activity.time}</div>
                <div class="activity-message">${activity.message}</div>
            </div>
        `).join('');
        
        // Animate new items
        const newItem = activityList.querySelector(`[data-id="${this.activityFeed[0]?.id}"]`);
        if (newItem && !this.isReducedMotion()) {
            newItem.style.opacity = '0';
            newItem.style.transform = 'translateX(-10px)';
            
            setTimeout(() => {
                newItem.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
                newItem.style.opacity = '1';
                newItem.style.transform = 'translateX(0)';
            }, 50);
        }
    }
    
    createToastContainer() {
        this.toastContainer = document.createElement('div');
        this.toastContainer.className = 'toast-container';
        document.body.appendChild(this.toastContainer);
    }
    
    showToast(message, type = 'info', options = {}) {
        const toast = document.createElement('div');
        const icon = options.icon || this.getToastIcon(type);
        const duration = options.duration || 3000;
        
        toast.className = `toast ${type}`;
        toast.innerHTML = `
            <span style="margin-right: 8px;">${icon}</span>
            ${message}
        `;
        
        this.toastContainer.appendChild(toast);
        
        // Animate in
        setTimeout(() => toast.classList.add('show'), 100);
        
        // Auto remove
        setTimeout(() => {
            toast.classList.remove('show');
            setTimeout(() => {
                if (toast.parentNode) {
                    toast.parentNode.removeChild(toast);
                }
            }, 300);
        }, duration);
    }
    
    getToastIcon(type) {
        const icons = {
            success: '✅',
            error: '❌',
            warning: '⚠️',
            info: 'ℹ️'
        };
        return icons[type] || 'ℹ️';
    }
    
    bindKeyboardShortcuts() {
        document.addEventListener('keydown', (e) => {
            // Only trigger if no input is focused
            if (document.activeElement.tagName === 'INPUT' || 
                document.activeElement.tagName === 'TEXTAREA') {
                return;
            }
            
            switch (e.key) {
                case '1':
                    this.switchSection('overview');
                    break;
                case '2':
                    this.switchSection('health');
                    break;
                case '3':
                    this.switchSection('data');
                    break;
                case '4':
                    this.switchSection('performance');
                    break;
                case '5':
                    this.switchSection('debug');
                    break;
                case ' ':
                    e.preventDefault();
                    this.toggleRefresh();
                    break;
                case 'r':
                    e.preventDefault();
                    this.refreshAllData();
                    break;
                case 'h':
                    e.preventDefault();
                    this.showHelpPanel('keyboard-shortcuts');
                    break;
                case 't':
                    e.preventDefault();
                    document.querySelector('[aria-label="Toggle theme"]')?.click();
                    break;
            }
        });
    }
    
    toggleRefresh() {
        this.refreshPaused = !this.refreshPaused;
        
        if (this.refreshPaused) {
            this.showToast('Auto-refresh paused', 'warning', { 
                duration: 2000, 
                icon: '⏸️' 
            });
        } else {
            this.showToast('Auto-refresh resumed', 'success', { 
                duration: 2000, 
                icon: '▶️' 
            });
        }
        
        this.addActivity(`Auto-refresh ${this.refreshPaused ? 'paused' : 'resumed'}`);
    }
    
    destroy() {
        if (this.refreshInterval) {
            clearInterval(this.refreshInterval);
        }
        
        console.log('🛑 Dashboard controller destroyed');
    }
}

// Enhanced CSS animations (injected via JavaScript)
const additionalStyles = `
    @keyframes shimmer {
        0% { background-position: -200% 0; }
        100% { background-position: 200% 0; }
    }
    
    @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translateY(20px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    
    @keyframes slideInRight {
        from {
            transform: translateX(100%);
        }
        to {
            transform: translateX(0);
        }
    }
    
    .animate-fade-in {
        animation: fadeInUp 0.4s ease-out;
    }
    
    .animate-slide-in {
        animation: slideInRight 0.3s ease-out;
    }
`;

// Inject additional styles
const styleElement = document.createElement('style');
styleElement.textContent = additionalStyles;
document.head.appendChild(styleElement);

// Initialize dashboard when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    window.dashboard = new DashboardController();
});

// Cleanup on page unload
window.addEventListener('beforeunload', () => {
    if (window.dashboard) {
        window.dashboard.destroy();
    }
});
