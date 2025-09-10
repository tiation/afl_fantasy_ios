import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { useAFLToasts } from '@/hooks/use-toast';
import { StatBadge, PriceBadge, PositionBadge } from '@/components/ui/stat-badge';
import { EmptyState, NoTradesEmptyState, LoadingFailedEmptyState, TradesLockedEmptyState } from '@/components/ui/empty-state';
import { Skeleton } from '@/components/ui/skeleton';
import {
  ArrowsRightLeftIcon,
  CheckCircleIcon,
  XCircleIcon,
  ClockIcon,
  UserIcon,
  TrendingUpIcon,
  TrendingDownIcon,
  ExclamationTriangleIcon,
  InformationCircleIcon
} from '@heroicons/react/24/outline';

interface Player {
  id: string;
  name: string;
  team: string;
  position: 'DEF' | 'MID' | 'RUC' | 'FWD';
  price: number;
  averageScore: number;
  lastScore: number;
  ownership: number;
  trend: 'up' | 'down' | 'stable';
  priceChange: number;
}

interface Trade {
  id: string;
  playerOut: Player;
  playerIn: Player;
  timestamp: Date;
  status: 'pending' | 'completed' | 'failed';
  savings: number;
}

const mockPlayers: Player[] = [
  {
    id: '1',
    name: 'Marcus Bontempelli',
    team: 'Western Bulldogs',
    position: 'MID',
    price: 695000,
    averageScore: 108.5,
    lastScore: 124,
    ownership: 67.2,
    trend: 'up',
    priceChange: 12000
  },
  {
    id: '2',
    name: 'Max Gawn',
    team: 'Melbourne',
    position: 'RUC',
    price: 678000,
    averageScore: 103.8,
    lastScore: 89,
    ownership: 89.1,
    trend: 'down',
    priceChange: -8000
  },
  {
    id: '3',
    name: 'Christian Petracca',
    team: 'Melbourne',
    position: 'MID',
    price: 645000,
    averageScore: 98.2,
    lastScore: 112,
    ownership: 78.5,
    trend: 'up',
    priceChange: 15000
  },
  {
    id: '4',
    name: 'Touk Miller',
    team: 'Gold Coast',
    position: 'MID',
    price: 612000,
    averageScore: 89.7,
    lastScore: 95,
    ownership: 45.3,
    trend: 'stable',
    priceChange: 0
  },
  {
    id: '5',
    name: 'Zach Merrett',
    team: 'Essendon',
    position: 'MID',
    price: 578000,
    averageScore: 92.1,
    lastScore: 108,
    ownership: 34.7,
    trend: 'up',
    priceChange: 18000
  }
];

const mockRecentTrades: Trade[] = [
  {
    id: 't1',
    playerOut: mockPlayers[1], // Max Gawn
    playerIn: mockPlayers[4], // Zach Merrett
    timestamp: new Date(Date.now() - 2 * 60 * 60 * 1000), // 2 hours ago
    status: 'completed',
    savings: 100000
  },
  {
    id: 't2',
    playerOut: mockPlayers[3], // Touk Miller
    playerIn: mockPlayers[2], // Christian Petracca
    timestamp: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000), // 1 day ago
    status: 'completed',
    savings: -33000
  }
];

export default function TradesDemo() {
  const [selectedPlayerOut, setSelectedPlayerOut] = useState<Player | null>(null);
  const [selectedPlayerIn, setSelectedPlayerIn] = useState<Player | null>(null);
  const [recentTrades, setRecentTrades] = useState(mockRecentTrades);
  const [isTrading, setIsTrading] = useState(false);
  const [tradeHistory] = useState<Trade[]>(mockRecentTrades);
  const [tradesRemaining] = useState(2);
  const [isLoading] = useState(false);
  const [hasError] = useState(false);

  const { tradeOptimistic, tradeSuccess, tradeError, captainSet, teamValueUpdated } = useAFLToasts();

  const handleTrade = async () => {
    if (!selectedPlayerOut || !selectedPlayerIn) return;

    setIsTrading(true);
    
    // Show optimistic toast
    const optimisticToast = tradeOptimistic(selectedPlayerIn.name, selectedPlayerOut.name);

    try {
      // Simulate API call delay
      await new Promise(resolve => setTimeout(resolve, 2000 + Math.random() * 1000));
      
      // Simulate random success/failure (90% success rate)
      const success = Math.random() > 0.1;
      
      if (success) {
        // Update recent trades optimistically
        const newTrade: Trade = {
          id: `t${Date.now()}`,
          playerOut: selectedPlayerOut,
          playerIn: selectedPlayerIn,
          timestamp: new Date(),
          status: 'completed',
          savings: selectedPlayerOut.price - selectedPlayerIn.price
        };

        setRecentTrades(prev => [newTrade, ...prev.slice(0, 4)]);
        
        // Show success toast
        tradeSuccess(selectedPlayerIn.name, selectedPlayerOut.name);
        
        // Reset selection
        setSelectedPlayerOut(null);
        setSelectedPlayerIn(null);
      } else {
        tradeError('Insufficient funds or player unavailable');
      }
    } catch (error) {
      tradeError('Network error - please try again');
    } finally {
      setIsTrading(false);
    }
  };

  const formatPrice = (price: number) => `$${(price / 1000).toFixed(0)}k`;
  
  const formatTimeAgo = (date: Date) => {
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const hours = Math.floor(diff / (1000 * 60 * 60));
    const days = Math.floor(hours / 24);
    
    if (days > 0) return `${days}d ago`;
    if (hours > 0) return `${hours}h ago`;
    return 'Just now';
  };

  if (hasError) {
    return <LoadingFailedEmptyState onRetry={() => window.location.reload()} />;
  }

  if (tradesRemaining === 0) {
    return <TradesLockedEmptyState />;
  }

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900 p-6">
      <div className="max-w-6xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
                Trades
              </h1>
              <p className="text-gray-600 dark:text-gray-400 mt-2">
                Make strategic player swaps to improve your team
              </p>
            </div>
            <div className="text-right">
              <div className="text-2xl font-bold text-afl-primary">
                {tradesRemaining}
              </div>
              <div className="text-sm text-gray-500 dark:text-gray-400">
                trades remaining
              </div>
            </div>
          </div>
        </div>

        {/* Trade Interface */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
          {/* Trade Out */}
          <motion.div
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden"
          >
            <div className="px-6 py-4 bg-red-50 dark:bg-red-950 border-b border-red-200 dark:border-red-800">
              <div className="flex items-center space-x-2">
                <XCircleIcon className="h-5 w-5 text-red-500" />
                <h3 className="font-semibold text-red-900 dark:text-red-100">
                  Trade Out
                </h3>
              </div>
            </div>
            
            <div className="p-6">
              {selectedPlayerOut ? (
                <motion.div
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  className="space-y-4"
                >
                  <div className="flex items-center space-x-4">
                    <div className="w-12 h-12 bg-gradient-to-br from-red-500 to-red-600 rounded-lg flex items-center justify-center text-white font-bold">
                      {selectedPlayerOut.name.split(' ').map(n => n[0]).join('')}
                    </div>
                    <div className="flex-1">
                      <h4 className="font-semibold text-gray-900 dark:text-white">
                        {selectedPlayerOut.name}
                      </h4>
                      <p className="text-sm text-gray-500 dark:text-gray-400">
                        {selectedPlayerOut.team}
                      </p>
                    </div>
                    <button
                      onClick={() => setSelectedPlayerOut(null)}
                      className="p-2 rounded-md text-gray-400 hover:text-gray-600 hover:bg-gray-100 dark:hover:bg-gray-700"
                    >
                      <XCircleIcon className="h-5 w-5" />
                    </button>
                  </div>
                  
                  <div className="grid grid-cols-2 gap-3">
                    <PositionBadge position={selectedPlayerOut.position.toLowerCase() as any} />
                    <PriceBadge price={selectedPlayerOut.price} />
                    <StatBadge
                      label="Avg Score"
                      value={selectedPlayerOut.averageScore.toFixed(1)}
                      variant="neutral"
                      size="sm"
                    />
                    <StatBadge
                      label="Ownership"
                      value={`${selectedPlayerOut.ownership.toFixed(1)}%`}
                      variant="info"
                      size="sm"
                    />
                  </div>
                </motion.div>
              ) : (
                <div className="text-center py-8">
                  <UserIcon className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                  <p className="text-gray-500 dark:text-gray-400 mb-4">
                    Select a player to trade out
                  </p>
                  <div className="space-y-2">
                    {isLoading ? (
                      Array(3).fill(0).map((_, i) => (
                        <Skeleton key={i} className="h-12 w-full" />
                      ))
                    ) : (
                      mockPlayers.slice(0, 3).map(player => (
                        <button
                          key={player.id}
                          onClick={() => setSelectedPlayerOut(player)}
                          className="w-full p-3 text-left bg-gray-50 dark:bg-gray-700 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-600 transition-colors"
                        >
                          <div className="flex items-center justify-between">
                            <div>
                              <div className="font-medium text-gray-900 dark:text-white">
                                {player.name}
                              </div>
                              <div className="text-sm text-gray-500 dark:text-gray-400">
                                {player.team} • {formatPrice(player.price)}
                              </div>
                            </div>
                            <PositionBadge position={player.position.toLowerCase() as any} size="xs" />
                          </div>
                        </button>
                      ))
                    )}
                  </div>
                </div>
              )}
            </div>
          </motion.div>

          {/* Trade In */}
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden"
          >
            <div className="px-6 py-4 bg-green-50 dark:bg-green-950 border-b border-green-200 dark:border-green-800">
              <div className="flex items-center space-x-2">
                <CheckCircleIcon className="h-5 w-5 text-green-500" />
                <h3 className="font-semibold text-green-900 dark:text-green-100">
                  Trade In
                </h3>
              </div>
            </div>
            
            <div className="p-6">
              {selectedPlayerIn ? (
                <motion.div
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  className="space-y-4"
                >
                  <div className="flex items-center space-x-4">
                    <div className="w-12 h-12 bg-gradient-to-br from-green-500 to-green-600 rounded-lg flex items-center justify-center text-white font-bold">
                      {selectedPlayerIn.name.split(' ').map(n => n[0]).join('')}
                    </div>
                    <div className="flex-1">
                      <h4 className="font-semibold text-gray-900 dark:text-white">
                        {selectedPlayerIn.name}
                      </h4>
                      <p className="text-sm text-gray-500 dark:text-gray-400">
                        {selectedPlayerIn.team}
                      </p>
                    </div>
                    <button
                      onClick={() => setSelectedPlayerIn(null)}
                      className="p-2 rounded-md text-gray-400 hover:text-gray-600 hover:bg-gray-100 dark:hover:bg-gray-700"
                    >
                      <XCircleIcon className="h-5 w-5" />
                    </button>
                  </div>
                  
                  <div className="grid grid-cols-2 gap-3">
                    <PositionBadge position={selectedPlayerIn.position.toLowerCase() as any} />
                    <PriceBadge price={selectedPlayerIn.price} />
                    <StatBadge
                      label="Avg Score"
                      value={selectedPlayerIn.averageScore.toFixed(1)}
                      variant="neutral"
                      size="sm"
                    />
                    <StatBadge
                      label="Ownership"
                      value={`${selectedPlayerIn.ownership.toFixed(1)}%`}
                      variant="info"
                      size="sm"
                    />
                  </div>
                </motion.div>
              ) : (
                <div className="text-center py-8">
                  <UserIcon className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                  <p className="text-gray-500 dark:text-gray-400 mb-4">
                    Select a player to trade in
                  </p>
                  <div className="space-y-2">
                    {mockPlayers.slice(3).map(player => (
                      <button
                        key={player.id}
                        onClick={() => setSelectedPlayerIn(player)}
                        className="w-full p-3 text-left bg-gray-50 dark:bg-gray-700 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-600 transition-colors"
                      >
                        <div className="flex items-center justify-between">
                          <div>
                            <div className="font-medium text-gray-900 dark:text-white">
                              {player.name}
                            </div>
                            <div className="text-sm text-gray-500 dark:text-gray-400">
                              {player.team} • {formatPrice(player.price)}
                            </div>
                          </div>
                          <PositionBadge position={player.position.toLowerCase() as any} size="xs" />
                        </div>
                      </button>
                    ))}
                  </div>
                </div>
              )}
            </div>
          </motion.div>
        </div>

        {/* Trade Summary & Action */}
        {selectedPlayerOut && selectedPlayerIn && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6 mb-8"
          >
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
                Trade Summary
              </h3>
              <div className="flex items-center space-x-2 text-sm">
                <ClockIcon className="h-4 w-4 text-gray-500" />
                <span className="text-gray-500 dark:text-gray-400">
                  Trades lock in 2h 15m
                </span>
              </div>
            </div>

            <div className="flex items-center space-x-4 mb-6">
              <div className="flex-1 text-center">
                <div className="font-medium text-gray-900 dark:text-white">
                  {selectedPlayerOut.name}
                </div>
                <div className="text-sm text-gray-500 dark:text-gray-400">
                  {formatPrice(selectedPlayerOut.price)}
                </div>
              </div>
              
              <div className="p-3 bg-afl-primary bg-opacity-10 rounded-full">
                <ArrowsRightLeftIcon className="h-6 w-6 text-afl-primary" />
              </div>
              
              <div className="flex-1 text-center">
                <div className="font-medium text-gray-900 dark:text-white">
                  {selectedPlayerIn.name}
                </div>
                <div className="text-sm text-gray-500 dark:text-gray-400">
                  {formatPrice(selectedPlayerIn.price)}
                </div>
              </div>
            </div>

            <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-4 mb-6">
              <div className="flex justify-between items-center">
                <span className="text-gray-600 dark:text-gray-400">Bank Change:</span>
                <StatBadge
                  value={formatPrice(Math.abs(selectedPlayerOut.price - selectedPlayerIn.price))}
                  variant={selectedPlayerOut.price > selectedPlayerIn.price ? 'positive' : 'negative'}
                  trend={selectedPlayerOut.price > selectedPlayerIn.price ? 'up' : selectedPlayerOut.price < selectedPlayerIn.price ? 'down' : 'neutral'}
                />
              </div>
            </div>

            <button
              onClick={handleTrade}
              disabled={isTrading}
              className="w-full bg-afl-primary text-white py-3 px-6 rounded-lg font-medium hover:bg-afl-primary-dark disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {isTrading ? 'Processing Trade...' : 'Confirm Trade'}
            </button>
          </motion.div>
        )}

        {/* Recent Trades */}
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700">
          <div className="px-6 py-4 border-b border-gray-200 dark:border-gray-700">
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
              Recent Trades
            </h3>
          </div>
          
          <div className="p-6">
            {recentTrades.length === 0 ? (
              <NoTradesEmptyState />
            ) : (
              <div className="space-y-4">
                {recentTrades.map((trade, index) => (
                  <motion.div
                    key={trade.id}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: index * 0.1 }}
                    className="flex items-center space-x-4 p-4 bg-gray-50 dark:bg-gray-700 rounded-lg"
                  >
                    <div className="flex-1">
                      <div className="flex items-center space-x-2 mb-2">
                        <span className="font-medium text-gray-900 dark:text-white">
                          {trade.playerOut.name}
                        </span>
                        <ArrowsRightLeftIcon className="h-4 w-4 text-gray-400" />
                        <span className="font-medium text-gray-900 dark:text-white">
                          {trade.playerIn.name}
                        </span>
                      </div>
                      <div className="flex items-center space-x-4 text-sm text-gray-500 dark:text-gray-400">
                        <span>{formatTimeAgo(trade.timestamp)}</span>
                        <StatBadge
                          value={formatPrice(Math.abs(trade.savings))}
                          variant={trade.savings > 0 ? 'positive' : 'negative'}
                          size="xs"
                        />
                      </div>
                    </div>
                    
                    <div className="flex items-center space-x-2">
                      {trade.status === 'completed' && (
                        <CheckCircleIcon className="h-5 w-5 text-green-500" />
                      )}
                      {trade.status === 'failed' && (
                        <XCircleIcon className="h-5 w-5 text-red-500" />
                      )}
                      {trade.status === 'pending' && (
                        <ClockIcon className="h-5 w-5 text-yellow-500" />
                      )}
                    </div>
                  </motion.div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
