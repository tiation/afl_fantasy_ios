import React, { useState, useEffect } from "react";
import {
  CircleDollarSign,
  Shield,
  Sparkles,
  ArrowRightCircle,
  Calculator,
  ArrowUpDown,
  LineChart,
  TrendingUp,
  PiggyBank,
  Activity,
  AlertTriangle,
  BarChart3,
  Trophy,
  Users,
  Home,
  Settings,
  Bell,
  Search,
  Menu,
  X,
  ChevronRight,
  Star
} from "lucide-react";
import { CashGenCeilingFloorTool } from "./CashGenCeilingFloorTool";

interface DashboardState {
  activeSection: string;
  selectedTool: string;
  isMobileMenuOpen: boolean;
  notifications: number;
}

interface ToolConfig {
  id: string;
  name: string;
  description: string;
  icon: React.ReactNode;
  component?: React.ComponentType;
  comingSoon?: boolean;
}

interface SectionConfig {
  id: string;
  name: string;
  icon: React.ReactNode;
  tools: ToolConfig[];
  color: string;
  gradient: string;
}

// Mock components for tools that don't exist yet
const ComingSoonTool = ({ toolName }: { toolName: string }) => (
  <div className="min-h-96 flex flex-col items-center justify-center bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-800 dark:to-gray-900 rounded-xl border border-gray-200 dark:border-gray-700">
    <div className="w-16 h-16 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center mb-4">
      <Settings className="h-8 w-8 text-white animate-spin" />
    </div>
    <h3 className="text-xl font-semibold text-gray-800 dark:text-white mb-2">{toolName}</h3>
    <p className="text-gray-600 dark:text-gray-400 text-center max-w-md">
      This powerful tool is currently under development and will be available soon.
    </p>
    <div className="mt-4 px-4 py-2 bg-blue-100 dark:bg-blue-900/30 rounded-full">
      <span className="text-blue-600 dark:text-blue-400 text-sm font-medium">Coming Soon</span>
    </div>
  </div>
);

const WelcomeDashboard = () => (
  <div className="space-y-8">
    {/* Hero Section */}
    <div className="relative overflow-hidden bg-gradient-to-br from-blue-600 via-purple-600 to-green-600 rounded-2xl p-8 text-white">
      <div className="relative z-10">
        <h2 className="text-3xl font-bold mb-4">🏆 AFL Fantasy Coach Platform</h2>
        <p className="text-xl opacity-90 mb-6">
          Your ultimate toolkit for dominating AFL Fantasy. Analyze trades, track cash generation, 
          manage risk, and get AI-powered insights.
        </p>
        <div className="flex flex-wrap gap-4">
          <div className="bg-white/20 backdrop-blur-sm px-4 py-2 rounded-lg">
            <span className="font-semibold">25+</span> Professional Tools
          </div>
          <div className="bg-white/20 backdrop-blur-sm px-4 py-2 rounded-lg">
            <span className="font-semibold">AI-Powered</span> Insights
          </div>
          <div className="bg-white/20 backdrop-blur-sm px-4 py-2 rounded-lg">
            <span className="font-semibold">Real-Time</span> Data
          </div>
        </div>
      </div>
      <div className="absolute inset-0 bg-black/10"></div>
    </div>

    {/* Quick Stats */}
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
      <div className="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-gray-600 dark:text-gray-400">Active Tools</p>
            <p className="text-2xl font-bold text-gray-900 dark:text-white">12</p>
          </div>
          <div className="w-12 h-12 bg-blue-100 dark:bg-blue-900/30 rounded-lg flex items-center justify-center">
            <Calculator className="h-6 w-6 text-blue-600 dark:text-blue-400" />
          </div>
        </div>
      </div>

      <div className="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-gray-600 dark:text-gray-400">AI Insights</p>
            <p className="text-2xl font-bold text-gray-900 dark:text-white">8</p>
          </div>
          <div className="w-12 h-12 bg-purple-100 dark:bg-purple-900/30 rounded-lg flex items-center justify-center">
            <Sparkles className="h-6 w-6 text-purple-600 dark:text-purple-400" />
          </div>
        </div>
      </div>

      <div className="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-gray-600 dark:text-gray-400">Data Points</p>
            <p className="text-2xl font-bold text-gray-900 dark:text-white">1.2K+</p>
          </div>
          <div className="w-12 h-12 bg-green-100 dark:bg-green-900/30 rounded-lg flex items-center justify-center">
            <BarChart3 className="h-6 w-6 text-green-600 dark:text-green-400" />
          </div>
        </div>
      </div>
    </div>

    {/* Recent Activity */}
    <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700">
      <div className="p-6 border-b border-gray-200 dark:border-gray-700">
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white">Getting Started</h3>
      </div>
      <div className="p-6">
        <div className="space-y-4">
          <div className="flex items-center p-4 bg-blue-50 dark:bg-blue-900/20 rounded-lg border border-blue-200 dark:border-blue-800">
            <ArrowUpDown className="h-5 w-5 text-blue-600 dark:text-blue-400 mr-3" />
            <div>
              <p className="font-medium text-gray-900 dark:text-white">Start with Trade Analysis</p>
              <p className="text-sm text-gray-600 dark:text-gray-400">Calculate trade scores and find optimal combinations</p>
            </div>
          </div>
          <div className="flex items-center p-4 bg-green-50 dark:bg-green-900/20 rounded-lg border border-green-200 dark:border-green-800">
            <CircleDollarSign className="h-5 w-5 text-green-600 dark:text-green-400 mr-3" />
            <div>
              <p className="font-medium text-gray-900 dark:text-white">Track Cash Generation</p>
              <p className="text-sm text-gray-600 dark:text-gray-400">Monitor player price changes and cash flow</p>
            </div>
          </div>
          <div className="flex items-center p-4 bg-purple-50 dark:bg-purple-900/20 rounded-lg border border-purple-200 dark:border-purple-800">
            <Sparkles className="h-5 w-5 text-purple-600 dark:text-purple-400 mr-3" />
            <div>
              <p className="font-medium text-gray-900 dark:text-white">Get AI Insights</p>
              <p className="text-sm text-gray-600 dark:text-gray-400">Leverage AI for captain picks and team analysis</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
);

export default function AFLFantasyDashboardImproved() {
  const [state, setState] = useState<DashboardState>({
    activeSection: 'home',
    selectedTool: '',
    isMobileMenuOpen: false,
    notifications: 3
  });

  // Define all sections and their tools
  const sections: SectionConfig[] = [
    {
      id: 'home',
      name: 'Dashboard',
      icon: <Home className="h-5 w-5" />,
      tools: [],
      color: 'blue',
      gradient: 'from-blue-500 to-blue-600'
    },
    {
      id: 'trade',
      name: 'Trade Analysis',
      icon: <ArrowUpDown className="h-5 w-5" />,
      color: 'emerald',
      gradient: 'from-emerald-500 to-emerald-600',
      tools: [
        {
          id: 'trade_calculator',
          name: 'Trade Calculator',
          description: 'Calculate comprehensive trade scores and comparisons',
          icon: <Calculator className="h-4 w-4" />,
          comingSoon: true
        },
        {
          id: 'one_up_one_down',
          name: 'One Up One Down',
          description: 'Find optimal trade combinations for maximum value',
          icon: <ArrowUpDown className="h-4 w-4" />,
          comingSoon: true
        },
        {
          id: 'price_predictor',
          name: 'Price Predictor',
          description: 'Predict future player price movements',
          icon: <TrendingUp className="h-4 w-4" />,
          comingSoon: true
        }
      ]
    },
    {
      id: 'cash',
      name: 'Cash Management',
      icon: <CircleDollarSign className="h-5 w-5" />,
      color: 'green',
      gradient: 'from-green-500 to-green-600',
      tools: [
        {
          id: 'cash_gen_ceiling_floor',
          name: 'Cash Gen Ceiling/Floor',
          description: 'Calculate potential price ranges for cash generation',
          icon: <PiggyBank className="h-4 w-4" />,
          component: CashGenCeilingFloorTool
        },
        {
          id: 'cash_tracker',
          name: 'Cash Generation Tracker',
          description: 'Track projected cash generation over time',
          icon: <LineChart className="h-4 w-4" />,
          comingSoon: true
        },
        {
          id: 'rookie_curves',
          name: 'Rookie Price Curves',
          description: 'Model rookie price trajectories and breakevens',
          icon: <TrendingUp className="h-4 w-4" />,
          comingSoon: true
        }
      ]
    },
    {
      id: 'risk',
      name: 'Risk Analysis',
      icon: <Shield className="h-5 w-5" />,
      color: 'orange',
      gradient: 'from-orange-500 to-orange-600',
      tools: [
        {
          id: 'tag_monitor',
          name: 'Tag Monitor',
          description: 'Monitor players at risk of being tagged',
          icon: <AlertTriangle className="h-4 w-4" />,
          comingSoon: true
        },
        {
          id: 'volatility_index',
          name: 'Volatility Index',
          description: 'Calculate player score consistency and volatility',
          icon: <Activity className="h-4 w-4" />,
          comingSoon: true
        },
        {
          id: 'injury_tracker',
          name: 'Injury Risk Tracker',
          description: 'Track injury risks and late withdrawal patterns',
          icon: <AlertTriangle className="h-4 w-4" />,
          comingSoon: true
        }
      ]
    },
    {
      id: 'ai',
      name: 'AI Insights',
      icon: <Sparkles className="h-5 w-5" />,
      color: 'purple',
      gradient: 'from-purple-500 to-purple-600',
      tools: [
        {
          id: 'ai_trade_suggester',
          name: 'AI Trade Suggester',
          description: 'Get AI-powered trade recommendations',
          icon: <Sparkles className="h-4 w-4" />,
          comingSoon: true
        },
        {
          id: 'captain_advisor',
          name: 'Captain Advisor',
          description: 'AI-powered captain selection analysis',
          icon: <Trophy className="h-4 w-4" />,
          comingSoon: true
        },
        {
          id: 'team_analyzer',
          name: 'Team Structure Analyzer',
          description: 'Analyze team balance and structure',
          icon: <Users className="h-4 w-4" />,
          comingSoon: true
        }
      ]
    }
  ];

  const activeSection = sections.find(s => s.id === state.activeSection);
  const selectedTool = activeSection?.tools.find(t => t.id === state.selectedTool);

  const handleSectionChange = (sectionId: string) => {
    setState(prev => ({ 
      ...prev, 
      activeSection: sectionId, 
      selectedTool: sectionId === 'home' ? '' : (sections.find(s => s.id === sectionId)?.tools[0]?.id || ''),
      isMobileMenuOpen: false
    }));
  };

  const handleToolChange = (toolId: string) => {
    setState(prev => ({ ...prev, selectedTool: toolId }));
  };

  const renderToolContent = () => {
    if (state.activeSection === 'home') {
      return <WelcomeDashboard />;
    }

    if (!selectedTool) {
      return (
        <div className="text-center py-12">
          <div className="w-16 h-16 bg-gray-100 dark:bg-gray-800 rounded-full flex items-center justify-center mx-auto mb-4">
            {activeSection?.icon}
          </div>
          <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">
            {activeSection?.name}
          </h3>
          <p className="text-gray-600 dark:text-gray-400">Select a tool from the sidebar to get started</p>
        </div>
      );
    }

    if (selectedTool.component) {
      const ToolComponent = selectedTool.component;
      return <ToolComponent />;
    }

    return <ComingSoonTool toolName={selectedTool.name} />;
  };

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      {/* Mobile Header */}
      <div className="lg:hidden bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 px-4 py-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-3">
            <button
              onClick={() => setState(prev => ({ ...prev, isMobileMenuOpen: !prev.isMobileMenuOpen }))}
              className="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700"
            >
              {state.isMobileMenuOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
            </button>
            <h1 className="text-lg font-semibold text-gray-900 dark:text-white">AFL Fantasy</h1>
          </div>
          <div className="flex items-center space-x-2">
            <button className="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 relative">
              <Bell className="h-5 w-5 text-gray-600 dark:text-gray-400" />
              {state.notifications > 0 && (
                <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center">
                  {state.notifications}
                </span>
              )}
            </button>
          </div>
        </div>
      </div>

      <div className="flex">
        {/* Sidebar */}
        <div className={`fixed inset-y-0 left-0 z-50 w-64 bg-white dark:bg-gray-800 border-r border-gray-200 dark:border-gray-700 transform transition-transform lg:relative lg:translate-x-0 ${
          state.isMobileMenuOpen ? 'translate-x-0' : '-translate-x-full'
        }`}>
          <div className="flex flex-col h-full">
            {/* Logo */}
            <div className="hidden lg:flex items-center justify-center h-16 border-b border-gray-200 dark:border-gray-700">
              <h1 className="text-xl font-bold text-gray-900 dark:text-white flex items-center">
                🏆 AFL Fantasy Coach
              </h1>
            </div>

            {/* Navigation */}
            <nav className="flex-1 px-4 py-6 space-y-2 overflow-y-auto">
              {sections.map((section) => (
                <button
                  key={section.id}
                  onClick={() => handleSectionChange(section.id)}
                  className={`w-full flex items-center px-3 py-3 rounded-lg text-left transition-all duration-200 ${
                    state.activeSection === section.id
                      ? `bg-gradient-to-r ${section.gradient} text-white shadow-lg`
                      : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'
                  }`}
                >
                  {section.icon}
                  <span className="ml-3 font-medium">{section.name}</span>
                  {section.tools.length > 0 && (
                    <ChevronRight className="h-4 w-4 ml-auto" />
                  )}
                </button>
              ))}
            </nav>

            {/* Tools Sidebar */}
            {activeSection && activeSection.tools.length > 0 && state.activeSection !== 'home' && (
              <div className="border-t border-gray-200 dark:border-gray-700 p-4">
                <h4 className="text-sm font-semibold text-gray-900 dark:text-white mb-3">
                  {activeSection.name} Tools
                </h4>
                <div className="space-y-1">
                  {activeSection.tools.map((tool) => (
                    <button
                      key={tool.id}
                      onClick={() => handleToolChange(tool.id)}
                      className={`w-full flex items-center px-2 py-2 rounded text-sm text-left transition-colors ${
                        state.selectedTool === tool.id
                          ? 'bg-gray-100 dark:bg-gray-700 text-gray-900 dark:text-white'
                          : 'text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white hover:bg-gray-50 dark:hover:bg-gray-750'
                      }`}
                    >
                      {tool.icon}
                      <span className="ml-2 truncate">{tool.name}</span>
                      {tool.comingSoon && (
                        <Star className="h-3 w-3 ml-auto text-yellow-500" />
                      )}
                    </button>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Main Content */}
        <div className="flex-1 flex flex-col min-w-0">
          {/* Desktop Header */}
          <div className="hidden lg:flex items-center justify-between bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 px-6 py-4">
            <div>
              <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
                {selectedTool?.name || activeSection?.name || 'Dashboard'}
              </h2>
              {selectedTool && (
                <p className="text-gray-600 dark:text-gray-400 mt-1">
                  {selectedTool.description}
                </p>
              )}
            </div>
            <div className="flex items-center space-x-4">
              <button className="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700">
                <Search className="h-5 w-5 text-gray-600 dark:text-gray-400" />
              </button>
              <button className="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 relative">
                <Bell className="h-5 w-5 text-gray-600 dark:text-gray-400" />
                {state.notifications > 0 && (
                  <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center">
                    {state.notifications}
                  </span>
                )}
              </button>
            </div>
          </div>

          {/* Content Area */}
          <main className="flex-1 p-6 overflow-y-auto">
            {renderToolContent()}
          </main>
        </div>
      </div>

      {/* Mobile Menu Overlay */}
      {state.isMobileMenuOpen && (
        <div 
          className="fixed inset-0 bg-black bg-opacity-50 z-40 lg:hidden" 
          onClick={() => setState(prev => ({ ...prev, isMobileMenuOpen: false }))}
        />
      )}
    </div>
  );
}
