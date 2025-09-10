import React from 'react';
import { motion } from 'framer-motion';
import {
  UsersIcon,
  ArrowsRightLeftIcon,
  ChartBarIcon,
  ExclamationTriangleIcon,
  MagnifyingGlassIcon,
  PlusIcon,
  ClockIcon,
  WifiIcon,
  ShieldExclamationIcon
} from '@heroicons/react/24/outline';

interface EmptyStateProps {
  variant: 
    | 'no-players' 
    | 'no-trades' 
    | 'no-stats' 
    | 'no-search-results' 
    | 'no-data'
    | 'offline'
    | 'loading-failed'
    | 'trades-locked'
    | 'season-ended'
    | 'maintenance';
  title: string;
  description?: string;
  action?: {
    label: string;
    onClick: () => void;
    variant?: 'primary' | 'secondary';
  };
  illustration?: React.ReactNode;
  compact?: boolean;
}

const getVariantConfig = (variant: EmptyStateProps['variant']) => {
  const configs = {
    'no-players': {
      icon: UsersIcon,
      iconColor: 'text-blue-500',
      bgColor: 'bg-blue-50 dark:bg-blue-950',
      borderColor: 'border-blue-200 dark:border-blue-800'
    },
    'no-trades': {
      icon: ArrowsRightLeftIcon,
      iconColor: 'text-green-500',
      bgColor: 'bg-green-50 dark:bg-green-950',
      borderColor: 'border-green-200 dark:border-green-800'
    },
    'no-stats': {
      icon: ChartBarIcon,
      iconColor: 'text-purple-500',
      bgColor: 'bg-purple-50 dark:bg-purple-950',
      borderColor: 'border-purple-200 dark:border-purple-800'
    },
    'no-search-results': {
      icon: MagnifyingGlassIcon,
      iconColor: 'text-gray-500',
      bgColor: 'bg-gray-50 dark:bg-gray-950',
      borderColor: 'border-gray-200 dark:border-gray-800'
    },
    'no-data': {
      icon: ExclamationTriangleIcon,
      iconColor: 'text-yellow-500',
      bgColor: 'bg-yellow-50 dark:bg-yellow-950',
      borderColor: 'border-yellow-200 dark:border-yellow-800'
    },
    'offline': {
      icon: WifiIcon,
      iconColor: 'text-red-500',
      bgColor: 'bg-red-50 dark:bg-red-950',
      borderColor: 'border-red-200 dark:border-red-800'
    },
    'loading-failed': {
      icon: ExclamationTriangleIcon,
      iconColor: 'text-red-500',
      bgColor: 'bg-red-50 dark:bg-red-950',
      borderColor: 'border-red-200 dark:border-red-800'
    },
    'trades-locked': {
      icon: ClockIcon,
      iconColor: 'text-orange-500',
      bgColor: 'bg-orange-50 dark:bg-orange-950',
      borderColor: 'border-orange-200 dark:border-orange-800'
    },
    'season-ended': {
      icon: ShieldExclamationIcon,
      iconColor: 'text-gray-500',
      bgColor: 'bg-gray-50 dark:bg-gray-950',
      borderColor: 'border-gray-200 dark:border-gray-800'
    },
    'maintenance': {
      icon: ExclamationTriangleIcon,
      iconColor: 'text-yellow-500',
      bgColor: 'bg-yellow-50 dark:bg-yellow-950',
      borderColor: 'border-yellow-200 dark:border-yellow-800'
    }
  };
  
  return configs[variant];
};

const defaultIllustrations = {
  'no-players': (
    <div className="relative">
      <div className="flex space-x-2 mb-4">
        <div className="w-12 h-16 bg-gray-200 dark:bg-gray-700 rounded-lg opacity-50" />
        <div className="w-12 h-16 bg-gray-200 dark:bg-gray-700 rounded-lg opacity-30" />
        <div className="w-12 h-16 bg-gray-200 dark:bg-gray-700 rounded-lg opacity-20" />
      </div>
      <div className="text-center">
        <div className="w-16 h-1 bg-gray-300 dark:bg-gray-600 rounded mx-auto" />
      </div>
    </div>
  ),
  'no-trades': (
    <div className="relative">
      <div className="flex items-center justify-center space-x-4">
        <div className="w-16 h-20 bg-gradient-to-br from-afl-primary to-afl-secondary rounded-lg flex items-center justify-center text-white font-bold opacity-50">
          OUT
        </div>
        <ArrowsRightLeftIcon className="h-8 w-8 text-gray-400" />
        <div className="w-16 h-20 bg-gradient-to-br from-green-500 to-green-600 rounded-lg flex items-center justify-center text-white font-bold opacity-50">
          IN
        </div>
      </div>
    </div>
  ),
  'no-stats': (
    <div className="relative">
      <div className="flex items-end justify-center space-x-1">
        <div className="w-3 h-8 bg-gray-200 dark:bg-gray-700 rounded opacity-50" />
        <div className="w-3 h-12 bg-gray-200 dark:bg-gray-700 rounded opacity-30" />
        <div className="w-3 h-6 bg-gray-200 dark:bg-gray-700 rounded opacity-40" />
        <div className="w-3 h-16 bg-gray-200 dark:bg-gray-700 rounded opacity-60" />
        <div className="w-3 h-4 bg-gray-200 dark:bg-gray-700 rounded opacity-30" />
      </div>
    </div>
  )
};

export function EmptyState({
  variant,
  title,
  description,
  action,
  illustration,
  compact = false
}: EmptyStateProps) {
  const config = getVariantConfig(variant);
  const Icon = config.icon;

  const containerVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        duration: 0.4,
        staggerChildren: 0.1
      }
    }
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 10 },
    visible: { opacity: 1, y: 0 }
  };

  return (
    <motion.div
      variants={containerVariants}
      initial="hidden"
      animate="visible"
      className={`
        flex flex-col items-center justify-center text-center
        ${compact ? 'py-8 px-4' : 'py-16 px-6'}
      `}
    >
      {/* Illustration or Icon */}
      <motion.div
        variants={itemVariants}
        className={`
          mb-6 p-6 rounded-2xl border-2 border-dashed
          ${config.bgColor} ${config.borderColor}
        `}
      >
        {illustration || defaultIllustrations[variant] || (
          <Icon className={`h-16 w-16 ${config.iconColor} mx-auto`} />
        )}
      </motion.div>

      {/* Content */}
      <div className={`max-w-md mx-auto ${compact ? 'space-y-2' : 'space-y-4'}`}>
        <motion.h3
          variants={itemVariants}
          className={`
            font-semibold text-gray-900 dark:text-white
            ${compact ? 'text-lg' : 'text-xl'}
          `}
        >
          {title}
        </motion.h3>

        {description && (
          <motion.p
            variants={itemVariants}
            className={`
              text-gray-500 dark:text-gray-400
              ${compact ? 'text-sm' : 'text-base'}
            `}
          >
            {description}
          </motion.p>
        )}

        {action && (
          <motion.div variants={itemVariants} className="pt-4">
            <button
              onClick={action.onClick}
              className={`
                inline-flex items-center px-6 py-3 rounded-lg font-medium transition-colors
                focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-afl-primary
                ${action.variant === 'secondary'
                  ? 'bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-700'
                  : 'bg-afl-primary text-white hover:bg-afl-primary-dark'
                }
              `}
            >
              <PlusIcon className="h-5 w-5 mr-2" />
              {action.label}
            </button>
          </motion.div>
        )}
      </div>
    </motion.div>
  );
}

// Specialized empty states for common AFL Fantasy scenarios
export function NoPlayersEmptyState({ onAddPlayer }: { onAddPlayer?: () => void }) {
  return (
    <EmptyState
      variant="no-players"
      title="No Players Selected"
      description="Your team is empty. Start building your AFL Fantasy team by adding players to your lineup."
      action={onAddPlayer ? {
        label: "Add Players",
        onClick: onAddPlayer
      } : undefined}
    />
  );
}

export function NoTradesEmptyState({ onMakeTrade }: { onMakeTrade?: () => void }) {
  return (
    <EmptyState
      variant="no-trades"
      title="No Recent Trades"
      description="You haven't made any trades recently. Make strategic player swaps to improve your team."
      action={onMakeTrade ? {
        label: "Make a Trade",
        onClick: onMakeTrade
      } : undefined}
    />
  );
}

export function NoSearchResultsEmptyState({ query, onClearSearch }: { query: string; onClearSearch?: () => void }) {
  return (
    <EmptyState
      variant="no-search-results"
      title="No Results Found"
      description={`We couldn't find any players matching "${query}". Try adjusting your search terms.`}
      action={onClearSearch ? {
        label: "Clear Search",
        onClick: onClearSearch,
        variant: 'secondary'
      } : undefined}
      compact
    />
  );
}

export function TradesLockedEmptyState() {
  return (
    <EmptyState
      variant="trades-locked"
      title="Trades Locked"
      description="Trading is currently locked. Check back when the next trading period opens."
      compact
    />
  );
}

export function OfflineEmptyState({ onRetry }: { onRetry?: () => void }) {
  return (
    <EmptyState
      variant="offline"
      title="Connection Lost"
      description="Unable to load data. Check your internet connection and try again."
      action={onRetry ? {
        label: "Try Again",
        onClick: onRetry,
        variant: 'secondary'
      } : undefined}
      compact
    />
  );
}

export function LoadingFailedEmptyState({ onRetry }: { onRetry?: () => void }) {
  return (
    <EmptyState
      variant="loading-failed"
      title="Failed to Load"
      description="Something went wrong while loading your data. Please try again."
      action={onRetry ? {
        label: "Retry",
        onClick: onRetry
      } : undefined}
      compact
    />
  );
}
