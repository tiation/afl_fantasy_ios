import React, { useState, useEffect } from 'react';
import { fetchPriceProjections } from '@/services/priceService';
import { SortableTable } from '../sortable-table';
import { Button } from '@/components/ui/button';
import { Loader2 } from 'lucide-react';

type PriceProjection = {
  player: string;
  price_now: number;
  l3_avg: number;
  breakeven: number;
  projected_price_next: number;
};

export function PriceProjectionCalculator() {
  const [projections, setProjections] = useState<PriceProjection[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  async function loadData() {
    setLoading(true);
    try {
      const response = await fetchPriceProjections();
      if (response.status === 'ok' && response.data) {
        setProjections(response.data);
      } else {
        setError('Failed to load price projection data');
      }
    } catch (err) {
      setError('Error fetching price projection data');
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
      key: 'price_now',
      label: 'Current Price',
      sortable: true,
      render: (value: number) => (
        <div className="text-right">
          ${value.toLocaleString()}
        </div>
      ),
    },
    {
      key: 'l3_avg',
      label: 'L3 Average',
      sortable: true,
      render: (value: number) => (
        <div className="text-center">{Math.round(value)}</div>
      ),
    },
    {
      key: 'breakeven',
      label: 'Breakeven',
      sortable: true,
      render: (value: number) => (
        <div className="text-center">{Math.round(value)}</div>
      ),
    },
    {
      key: 'projected_price_next',
      label: 'Projected Price',
      sortable: true,
      render: (value: number, item: PriceProjection) => {
        const priceChange = value - item.price_now;
        const isPositive = priceChange > 0;
        
        return (
          <div className={`text-right font-medium ${isPositive ? 'text-green-600' : 'text-red-600'}`}>
            ${value.toLocaleString()} 
            <span className="ml-1 text-xs">
              ({isPositive ? '+' : ''}{(priceChange / 1000).toFixed(1)}k)
            </span>
          </div>
        );
      },
    },
  ];

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center py-8">
        <Loader2 className="h-8 w-8 animate-spin text-blue-600 mb-2" />
        <p className="text-sm text-muted-foreground">Loading price projections...</p>
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
        <h3 className="font-medium text-sm">Price Projection Calculator</h3>
        <p className="text-sm text-muted-foreground mt-1">
          This tool calculates projected price changes based on player's breakeven and recent
          scoring form (L3 average). Green values indicate price increases, while red values
          indicate price decreases. Sort by projected price to find the best trading targets.
        </p>
      </div>
      
      <div className="rounded-md border">
        <SortableTable
          data={projections}
          columns={columns}
          emptyMessage="No price projection data available"
        />
      </div>
    </div>
  );
}