import React, { useState, useEffect } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import {
  HomeIcon,
  UsersIcon,
  ArrowsRightLeftIcon,
  ChartBarIcon,
  Cog6ToothIcon,
  Bars3Icon,
  XMarkIcon,
  MagnifyingGlassIcon
} from '@heroicons/react/24/outline';
import {
  HomeIcon as HomeIconSolid,
  UsersIcon as UsersIconSolid,
  ArrowsRightLeftIcon as ArrowsRightLeftIconSolid,
  ChartBarIcon as ChartBarIconSolid,
  Cog6ToothIcon as Cog6ToothIconSolid
} from '@heroicons/react/24/solid';

interface NavItem {
  name: string;
  href: string;
  icon: React.ComponentType<{ className?: string }>;
  solidIcon: React.ComponentType<{ className?: string }>;
  badge?: number;
}

const navigation: NavItem[] = [
  {
    name: 'Dashboard',
    href: '/',
    icon: HomeIcon,
    solidIcon: HomeIconSolid
  },
  {
    name: 'Players',
    href: '/players',
    icon: UsersIcon,
    solidIcon: UsersIconSolid
  },
  {
    name: 'Trades',
    href: '/trades',
    icon: ArrowsRightLeftIcon,
    solidIcon: ArrowsRightLeftIconSolid,
    badge: 2 // Example: 2 trades remaining
  },
  {
    name: 'Stats',
    href: '/stats',
    icon: ChartBarIcon,
    solidIcon: ChartBarIconSolid
  },
  {
    name: 'Settings',
    href: '/settings',
    icon: Cog6ToothIcon,
    solidIcon: Cog6ToothIconSolid
  }
];

interface MobileNavProps {
  onSearchOpen?: () => void;
}

export function MobileNav({ onSearchOpen }: MobileNavProps) {
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);
  const location = useLocation();

  // Close drawer on route change
  useEffect(() => {
    setIsDrawerOpen(false);
  }, [location.pathname]);

  // Prevent body scroll when drawer is open
  useEffect(() => {
    if (isDrawerOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = 'unset';
    }
    return () => {
      document.body.style.overflow = 'unset';
    };
  }, [isDrawerOpen]);

  const isActive = (href: string) => {
    if (href === '/') return location.pathname === '/';
    return location.pathname.startsWith(href);
  };

  return (
    <>
      {/* Top Navigation Bar - Mobile */}
      <div className="md:hidden bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-800 px-4 py-3 flex items-center justify-between sticky top-0 z-40">
        <button
          onClick={() => setIsDrawerOpen(true)}
          className="p-2 -ml-2 rounded-md text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-afl-primary focus:ring-offset-2"
          aria-label="Open navigation menu"
        >
          <Bars3Icon className="h-6 w-6" />
        </button>

        <div className="flex items-center space-x-2">
          <img 
            src="/afl-logo.svg" 
            alt="AFL Fantasy" 
            className="h-8 w-8"
            onError={(e) => {
              const target = e.target as HTMLImageElement;
              target.src = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzIiIGhlaWdodD0iMzIiIHZpZXdCb3g9IjAgMCAzMiAzMiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPGNpcmNsZSBjeD0iMTYiIGN5PSIxNiIgcj0iMTYiIGZpbGw9IiMwMDY2Q0MiLz4KPHN2ZyB4PSI4IiB5PSI4IiB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIGZpbGw9IndoaXRlIj4KPHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSI+CjxwYXRoIGQ9Ik04IDJMMTIgNkw4IDEwTDQgNkw4IDJaIiBmaWxsPSJjdXJyZW50Q29sb3IiLz4KPHN2Zz4KPC9zdmc+Cjwvc3ZnPgo=';
            }}
          />
          <span className="text-lg font-bold text-gray-900 dark:text-white">
            AFL Fantasy
          </span>
        </div>

        <button
          onClick={onSearchOpen}
          className="p-2 -mr-2 rounded-md text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-afl-primary focus:ring-offset-2"
          aria-label="Open search"
        >
          <MagnifyingGlassIcon className="h-6 w-6" />
        </button>
      </div>

      {/* Mobile Drawer */}
      <AnimatePresence>
        {isDrawerOpen && (
          <>
            {/* Backdrop */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="md:hidden fixed inset-0 bg-black bg-opacity-50 z-50"
              onClick={() => setIsDrawerOpen(false)}
            />

            {/* Drawer */}
            <motion.div
              initial={{ x: '-100%' }}
              animate={{ x: 0 }}
              exit={{ x: '-100%' }}
              transition={{ type: 'tween', duration: 0.3 }}
              className="md:hidden fixed left-0 top-0 bottom-0 w-80 bg-white dark:bg-gray-900 z-50 shadow-xl"
            >
              <div className="flex items-center justify-between p-4 border-b border-gray-200 dark:border-gray-800">
                <div className="flex items-center space-x-3">
                  <img 
                    src="/afl-logo.svg" 
                    alt="AFL Fantasy" 
                    className="h-8 w-8"
                    onError={(e) => {
                      const target = e.target as HTMLImageElement;
                      target.src = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzIiIGhlaWdodD0iMzIiIHZpZXdCb3g9IjAgMCAzMiAzMiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPGNpcmNsZSBjeD0iMTYiIGN5PSIxNiIgcj0iMTYiIGZpbGw9IiMwMDY2Q0MiLz4KPHN2ZyB4PSI4IiB5PSI4IiB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIGZpbGw9IndoaXRlIj4KPHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSI+CjxwYXRoIGQ9Ik04IDJMMTIgNkw4IDEwTDQgNkw4IDJaIiBmaWxsPSJjdXJyZW50Q29sb3IiLz4KPHN2Zz4KPC9zdmc+Cjwvc3ZnPgo=';
                    }}
                  />
                  <div>
                    <h2 className="text-lg font-bold text-gray-900 dark:text-white">
                      AFL Fantasy
                    </h2>
                    <p className="text-sm text-gray-500 dark:text-gray-400">
                      Round 23 • 2024
                    </p>
                  </div>
                </div>
                <button
                  onClick={() => setIsDrawerOpen(false)}
                  className="p-2 rounded-md text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-afl-primary"
                  aria-label="Close navigation menu"
                >
                  <XMarkIcon className="h-6 w-6" />
                </button>
              </div>

              <nav className="px-4 py-6">
                <ul className="space-y-2">
                  {navigation.map((item) => {
                    const Icon = isActive(item.href) ? item.solidIcon : item.icon;
                    return (
                      <li key={item.name}>
                        <Link
                          to={item.href}
                          className={`flex items-center px-3 py-2.5 rounded-lg text-sm font-medium transition-colors group ${
                            isActive(item.href)
                              ? 'bg-afl-primary text-white'
                              : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'
                          }`}
                        >
                          <Icon className="h-5 w-5 mr-3 flex-shrink-0" />
                          <span className="flex-1">{item.name}</span>
                          {item.badge && (
                            <span className="ml-2 px-2 py-0.5 text-xs font-medium bg-red-100 text-red-800 rounded-full">
                              {item.badge}
                            </span>
                          )}
                        </Link>
                      </li>
                    );
                  })}
                </ul>
              </nav>

              {/* User info at bottom */}
              <div className="absolute bottom-0 left-0 right-0 p-4 border-t border-gray-200 dark:border-gray-800">
                <div className="flex items-center space-x-3">
                  <div className="h-10 w-10 rounded-full bg-gradient-to-r from-afl-primary to-afl-secondary flex items-center justify-center text-white font-bold">
                    T
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-gray-900 dark:text-white truncate">
                      Team Name
                    </p>
                    <p className="text-xs text-gray-500 dark:text-gray-400 truncate">
                      Rank #1,234 • $12.4M value
                    </p>
                  </div>
                </div>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>

      {/* Bottom Tab Bar - Mobile */}
      <div className="md:hidden fixed bottom-0 left-0 right-0 bg-white dark:bg-gray-900 border-t border-gray-200 dark:border-gray-800 z-30">
        <div className="grid grid-cols-5 h-16">
          {navigation.slice(0, 4).map((item) => {
            const Icon = isActive(item.href) ? item.solidIcon : item.icon;
            return (
              <Link
                key={item.name}
                to={item.href}
                className={`flex flex-col items-center justify-center px-1 py-2 relative ${
                  isActive(item.href)
                    ? 'text-afl-primary'
                    : 'text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300'
                }`}
                aria-label={item.name}
              >
                <Icon className="h-6 w-6 mb-1" />
                <span className="text-xs font-medium truncate w-full text-center">
                  {item.name}
                </span>
                {item.badge && (
                  <span className="absolute -top-1 -right-1 h-4 w-4 bg-red-500 text-white text-xs rounded-full flex items-center justify-center">
                    {item.badge > 9 ? '9+' : item.badge}
                  </span>
                )}
              </Link>
            );
          })}
          
          {/* More button */}
          <button
            onClick={() => setIsDrawerOpen(true)}
            className="flex flex-col items-center justify-center px-1 py-2 text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300"
            aria-label="More options"
          >
            <Bars3Icon className="h-6 w-6 mb-1" />
            <span className="text-xs font-medium">More</span>
          </button>
        </div>
      </div>
    </>
  );
}
