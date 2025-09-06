import React, { useState, useEffect, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useLocation } from 'wouter';
import {
  MagnifyingGlassIcon,
  XMarkIcon,
  UserIcon,
  ChartBarIcon,
  ArrowsRightLeftIcon,
  HomeIcon,
  ClockIcon,
  FireIcon
} from '@heroicons/react/24/outline';

interface SearchResult {
  id: string;
  title: string;
  subtitle?: string;
  type: 'player' | 'team' | 'action' | 'page';
  icon: React.ComponentType<{ className?: string }>;
  href?: string;
  action?: () => void;
  shortcut?: string[];
  priority?: number;
}

interface GlobalSearchProps {
  isOpen: boolean;
  onClose: () => void;
}

// Mock data - replace with real API calls
const mockSearchResults: SearchResult[] = [
  // Pages
  {
    id: 'dashboard',
    title: 'Dashboard',
    subtitle: 'View your team overview',
    type: 'page',
    icon: HomeIcon,
    href: '/',
    priority: 10
  },
  {
    id: 'trades',
    title: 'Trades',
    subtitle: 'Make player trades',
    type: 'page',
    icon: ArrowsRightLeftIcon,
    href: '/trades',
    shortcut: ['t'],
    priority: 9
  },
  {
    id: 'stats',
    title: 'Statistics',
    subtitle: 'Player and team stats',
    type: 'page',
    icon: ChartBarIcon,
    href: '/stats',
    shortcut: ['s'],
    priority: 8
  },
  
  // Actions
  {
    id: 'trade-out',
    title: 'Trade Out Player',
    subtitle: 'Remove a player from your team',
    type: 'action',
    icon: ArrowsRightLeftIcon,
    action: () => console.log('Trade out action'),
    shortcut: ['t', 'o'],
    priority: 7
  },
  {
    id: 'set-captain',
    title: 'Set Captain',
    subtitle: 'Choose your team captain',
    type: 'action',
    icon: UserIcon,
    action: () => console.log('Set captain action'),
    shortcut: ['c'],
    priority: 6
  },
  
  // Popular players
  {
    id: 'player-1',
    title: 'Marcus Bontempelli',
    subtitle: 'Western Bulldogs • MID • $695k',
    type: 'player',
    icon: UserIcon,
    href: '/players/bontempelli',
    priority: 5
  },
  {
    id: 'player-2',
    title: 'Max Gawn',
    subtitle: 'Melbourne • RUC • $678k',
    type: 'player',
    icon: UserIcon,
    href: '/players/gawn',
    priority: 5
  },
  {
    id: 'player-3',
    title: 'Christian Petracca',
    subtitle: 'Melbourne • MID • $645k',
    type: 'player',
    icon: UserIcon,
    href: '/players/petracca',
    priority: 5
  },
  {
    id: 'player-4',
    title: 'Touk Miller',
    subtitle: 'Gold Coast • MID • $612k',
    type: 'player',
    icon: UserIcon,
    href: '/players/miller',
    priority: 4
  }
];

export function GlobalSearch({ isOpen, onClose }: GlobalSearchProps) {
  const [query, setQuery] = useState('');
  const [selectedIndex, setSelectedIndex] = useState(0);
  const [recentSearches, setRecentSearches] = useState<string[]>([]);
  const [, navigate] = useLocation();

  // Filter and sort results
  const filteredResults = useMemo(() => {
    if (!query.trim()) {
      // Show recent searches and high priority items
      return mockSearchResults
        .filter(result => result.priority && result.priority >= 6)
        .sort((a, b) => (b.priority || 0) - (a.priority || 0))
        .slice(0, 8);
    }

    const lowercaseQuery = query.toLowerCase();
    return mockSearchResults
      .filter(result => 
        result.title.toLowerCase().includes(lowercaseQuery) ||
        result.subtitle?.toLowerCase().includes(lowercaseQuery)
      )
      .sort((a, b) => {
        // Exact title matches first
        if (a.title.toLowerCase().startsWith(lowercaseQuery) && !b.title.toLowerCase().startsWith(lowercaseQuery)) {
          return -1;
        }
        if (b.title.toLowerCase().startsWith(lowercaseQuery) && !a.title.toLowerCase().startsWith(lowercaseQuery)) {
          return 1;
        }
        // Then by priority
        return (b.priority || 0) - (a.priority || 0);
      })
      .slice(0, 10);
  }, [query]);

  // Keyboard shortcuts
  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      if (!isOpen) return;

      switch (event.key) {
        case 'Escape':
          event.preventDefault();
          onClose();
          break;
        case 'ArrowDown':
          event.preventDefault();
          setSelectedIndex(prev => Math.min(prev + 1, filteredResults.length - 1));
          break;
        case 'ArrowUp':
          event.preventDefault();
          setSelectedIndex(prev => Math.max(prev - 1, 0));
          break;
        case 'Enter':
          event.preventDefault();
          if (filteredResults[selectedIndex]) {
            handleResultSelect(filteredResults[selectedIndex]);
          }
          break;
      }
    };

    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, selectedIndex, filteredResults, onClose]);

  // Global Cmd+K shortcut
  useEffect(() => {
    const handleGlobalKeyDown = (event: KeyboardEvent) => {
      if ((event.metaKey || event.ctrlKey) && event.key === 'k') {
        event.preventDefault();
        if (!isOpen) {
          // Open search
          setQuery('');
          setSelectedIndex(0);
        }
      }
    };

    document.addEventListener('keydown', handleGlobalKeyDown);
    return () => document.removeEventListener('keydown', handleGlobalKeyDown);
  }, [isOpen]);

  // Reset selection when results change
  useEffect(() => {
    setSelectedIndex(0);
  }, [filteredResults]);

  // Reset state when opening/closing
  useEffect(() => {
    if (isOpen) {
      setQuery('');
      setSelectedIndex(0);
    }
  }, [isOpen]);

  const handleResultSelect = (result: SearchResult) => {
    // Add to recent searches
    setRecentSearches(prev => {
      const updated = [result.title, ...prev.filter(s => s !== result.title)].slice(0, 5);
      localStorage.setItem('afl-fantasy-recent-searches', JSON.stringify(updated));
      return updated;
    });

    if (result.href) {
      navigate(result.href);
    } else if (result.action) {
      result.action();
    }
    
    onClose();
  };

  // Load recent searches on mount
  useEffect(() => {
    const saved = localStorage.getItem('afl-fantasy-recent-searches');
    if (saved) {
      setRecentSearches(JSON.parse(saved));
    }
  }, []);

  if (!isOpen) return null;

  return (
    <AnimatePresence>
      <div className="fixed inset-0 z-50 overflow-y-auto">
        {/* Backdrop */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="fixed inset-0 bg-black bg-opacity-50"
          onClick={onClose}
        />

        {/* Search Modal */}
        <div className="flex min-h-full items-start justify-center p-4 pt-[10vh]">
          <motion.div
            initial={{ opacity: 0, scale: 0.95, y: -20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: -20 }}
            transition={{ duration: 0.2 }}
            className="w-full max-w-2xl bg-white dark:bg-gray-900 rounded-xl shadow-2xl ring-1 ring-black ring-opacity-5 divide-y divide-gray-100 dark:divide-gray-800 overflow-hidden"
          >
            {/* Search Input */}
            <div className="flex items-center px-4 py-3">
              <MagnifyingGlassIcon className="h-5 w-5 text-gray-400 flex-shrink-0" />
              <input
                type="text"
                className="flex-1 mx-3 bg-transparent border-none outline-none text-gray-900 dark:text-white placeholder-gray-500 text-lg"
                placeholder="Search players, teams, actions..."
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                autoFocus
              />
              <div className="flex items-center space-x-2">
                <kbd className="hidden sm:inline-flex px-2 py-1 text-xs font-semibold text-gray-500 bg-gray-100 dark:bg-gray-700 dark:text-gray-300 rounded border border-gray-300 dark:border-gray-600">
                  ⌘K
                </kbd>
                <button
                  onClick={onClose}
                  className="p-1.5 rounded-md text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800"
                  aria-label="Close search"
                >
                  <XMarkIcon className="h-4 w-4" />
                </button>
              </div>
            </div>

            {/* Results */}
            {filteredResults.length > 0 ? (
              <div className="max-h-80 overflow-y-auto">
                {!query.trim() && recentSearches.length > 0 && (
                  <div className="px-4 py-2">
                    <div className="flex items-center text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wide">
                      <ClockIcon className="h-3 w-3 mr-1" />
                      Recent
                    </div>
                  </div>
                )}
                
                {filteredResults.map((result, index) => {
                  const Icon = result.icon;
                  const isSelected = index === selectedIndex;
                  
                  return (
                    <button
                      key={result.id}
                      className={`w-full flex items-center px-4 py-3 text-left hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors ${
                        isSelected ? 'bg-afl-primary bg-opacity-10 border-r-2 border-afl-primary' : ''
                      }`}
                      onClick={() => handleResultSelect(result)}
                    >
                      <div className={`flex-shrink-0 p-2 rounded-lg mr-3 ${
                        result.type === 'player' ? 'bg-blue-100 dark:bg-blue-900 text-blue-600 dark:text-blue-400' :
                        result.type === 'action' ? 'bg-green-100 dark:bg-green-900 text-green-600 dark:text-green-400' :
                        result.type === 'team' ? 'bg-purple-100 dark:bg-purple-900 text-purple-600 dark:text-purple-400' :
                        'bg-gray-100 dark:bg-gray-800 text-gray-600 dark:text-gray-400'
                      }`}>
                        <Icon className="h-4 w-4" />
                      </div>
                      
                      <div className="flex-1 min-w-0">
                        <div className="text-sm font-medium text-gray-900 dark:text-white truncate">
                          {result.title}
                        </div>
                        {result.subtitle && (
                          <div className="text-xs text-gray-500 dark:text-gray-400 truncate">
                            {result.subtitle}
                          </div>
                        )}
                      </div>
                      
                      {result.shortcut && (
                        <div className="flex-shrink-0 ml-2">
                          <div className="flex space-x-1">
                            {result.shortcut.map((key, i) => (
                              <kbd key={i} className="px-1.5 py-0.5 text-xs font-semibold text-gray-500 bg-gray-100 dark:bg-gray-700 dark:text-gray-300 rounded border border-gray-300 dark:border-gray-600">
                                {key}
                              </kbd>
                            ))}
                          </div>
                        </div>
                      )}
                    </button>
                  );
                })}
              </div>
            ) : query.trim() ? (
              <div className="px-4 py-8 text-center text-gray-500 dark:text-gray-400">
                <MagnifyingGlassIcon className="h-8 w-8 mx-auto mb-3 opacity-40" />
                <p className="text-sm">No results found for "{query}"</p>
                <p className="text-xs mt-1">Try searching for players, teams, or actions</p>
              </div>
            ) : (
              <div className="px-4 py-8 text-center text-gray-500 dark:text-gray-400">
                <div className="flex items-center justify-center space-x-4 mb-4">
                  <div className="flex items-center space-x-1">
                    <FireIcon className="h-4 w-4" />
                    <span className="text-xs font-medium">Popular</span>
                  </div>
                </div>
                <p className="text-xs">Start typing to search players, teams, and actions</p>
              </div>
            )}

            {/* Footer */}
            <div className="px-4 py-2 text-xs text-gray-500 dark:text-gray-400 bg-gray-50 dark:bg-gray-800">
              <div className="flex items-center justify-between">
                <span>Search powered by AFL Fantasy</span>
                <div className="flex items-center space-x-3">
                  <span className="flex items-center">
                    <kbd className="mr-1">↑</kbd>
                    <kbd>↓</kbd>
                    <span className="ml-1">navigate</span>
                  </span>
                  <span className="flex items-center">
                    <kbd className="mr-1">↵</kbd>
                    <span>select</span>
                  </span>
                  <span className="flex items-center">
                    <kbd className="mr-1">esc</kbd>
                    <span>close</span>
                  </span>
                </div>
              </div>
            </div>
          </motion.div>
        </div>
      </div>
    </AnimatePresence>
  );
}
