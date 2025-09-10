import React, { useState, useEffect } from 'react';
import { fetchBreakevenTrends } from '@/services/priceService';
import { SortableTable } from '../sortable-table';
import { Button } from '@/components/ui/button';
import { Loader2, TrendingDown, TrendingUp } from 'lucide-react';

type BETrend = {
  player: string;
  team: string;
  position: string;
  current_be: number;
  BE_trend: number[];
  direction: string;
};

export function BreakevenTrendAnalyzer() {
  const [trends, setTrends] = useState<BETrend[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  async function loadData() {
    setLoading(true);
    try {
      const response = await fetchBreakevenTrends();
      if (response.status === 'ok' && response.data) {
        setTrends(response.data);
      } else {
        setError('Failed to load breakeven trend data');
      }
    } catch (err) {
      setError('Error fetching breakeven trend data');
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadData();
  }, []);

  const columns = [
    {
      key: 'player',
      label: 'Player',
      sortable: true,
      render: (value: string) => (
        <div className="font-medium">{value}</div>
      ),
    },
    {
      key: 'team',
      label: 'Team',
      sortable: true,
    },
    {
      key: 'position',
      label: 'Position',
      sortable: true,
      render: (value: string) => (
        <div className="text-center">{value}</div>
      ),
    },
    {
      key: 'current_be',
      label: 'Current BE',
      sortable: true,
      render: (value: number) => (
        <div className="text-center font-medium">{value}</div>
      ),
    },
    {
      key: 'BE_trend',
      label: 'BE Trend',
      sortable: false,
      render: (value: number[]) => (
        <div className="text-center">
          {value.map((be, idx) => (
            <span key={idx} className="mx-1">{be}</span>
          )).reduce((prev, curr, i) => 
            i === 0 ? [curr] : [...prev, <span key={`sep-${i}`} className="text-gray-400"> → </span>, curr]
          , [] as React.ReactNode[])}
        </div>
      ),
    },
    {
      key: 'direction',
      label: 'Trend',
      sortable: true,
      render: (value: string) => (
        <div className={`text-center flex items-center justify-center ${value === 'Falling' ? 'text-green-600' : 'text-red-600'}`}>
          {value === 'Falling' ? (
            <>
              <TrendingDown className="h-4 w-4 mr-1" />
              <span>Falling</span>
            </>
          ) : (
            <>
              <TrendingUp className="h-4 w-4 mr-1" />
              <span>Rising</span>
            </>
          )}
        </div>
      ),
    },
  ];

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center py-8">
        <Loader2 className="h-8 w-8 animate-spin text-blue-600 mb-2" />
        <p className="text-sm text-muted-foreground">Loading breakeven trends...</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex flex-col items-center justify-center py-8">
        <p className="text-sm text-red-500 mb-4">{error}</p>
        <Button onClick={loadData} variant="outline" size="sm">
          Try Again
        </Button>
      </div>
    );
  }

  return (
    <div className="w-full space-y-4">
      <div className="rounded-md border px-4 py-3 bg-blue-50">
        <h3 className="font-medium text-sm">Breakeven Trend Analyzer</h3>
        <p className="text-sm text-muted-foreground mt-1">
          This tool analyzes trends in player breakevens over recent rounds. 
          A falling breakeven is good for future price growth and vice versa.
          Look for premium players with falling breakevens for good trade targets.
        </p>
      </div>
      
      <div className="rounded-md border">
        <SortableTable
          data={trends}
          columns={columns}
          emptyMessage="No breakeven trend data available"
        />
      </div>
    </div>
  );
}