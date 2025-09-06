import React, { useState, useEffect } from 'react';
import { fetchPriceRecoveryPredictions } from '@/services/priceService';
import { SortableTable } from '../sortable-table';
import { Button } from '@/components/ui/button';
import { Loader2 } from 'lucide-react';
import { Progress } from '@/components/ui/progress';

type RecoveryPrediction = {
  player: string;
  team: string;
  position: string;
  price_now: number;
  price_peak: number;
  price_drop: number;
  l3_avg: number;
  breakeven: number;
  recovery_chance: number;
  recovery_time: number;
};

export function PriceDropRecoveryPredictor() {
  const [recoveries, setRecoveries] = useState<RecoveryPrediction[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  async function loadData() {
    setLoading(true);
    try {
      const response = await fetchPriceRecoveryPredictions();
      if (response.status === 'ok' && response.data) {
        setRecoveries(response.data);
      } else {
        setError('Failed to load price recovery data');
      }
    } catch (err) {
      setError('Error fetching price recovery data');
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
      key: 'position',
      label: 'Position',
      sortable: true,
      render: (value: string) => (
        <div className="text-center">{value}</div>
      ),
    },
    {
      key: 'price_drop',
      label: 'Price Drop',
      sortable: true,
      render: (value: number) => (
        <div className="text-center text-red-600">
          -${Math.abs(value).toLocaleString()} 
          <span className="text-xs ml-1">({(Math.abs(value) / 1000).toFixed(1)}k)</span>
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
      key: 'recovery_chance',
      label: 'Recovery',
      sortable: true,
      render: (value: number) => (
        <div className="w-28">
          <div className="text-center mb-1 text-xs">{Math.round(value * 100)}%</div>
          <Progress
            value={value * 100}
            className={value > 0.7 ? 'bg-green-200' : value > 0.4 ? 'bg-yellow-200' : 'bg-red-200'}
          />
        </div>
      ),
    },
    {
      key: 'recovery_time',
      label: 'Est. Rounds',
      sortable: true,
      render: (value: number) => (
        <div className="text-center">
          {value > 10 ? '10+' : Math.round(value)}
        </div>
      ),
    },
  ];

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center py-8">
        <Loader2 className="h-8 w-8 animate-spin text-blue-600 mb-2" />
        <p className="text-sm text-muted-foreground">Loading price recovery predictions...</p>
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
        <h3 className="font-medium text-sm">Price Drop Recovery Predictor</h3>
        <p className="text-sm text-muted-foreground mt-1">
          This tool identifies premium players who have recently dropped in price but may recover.
          The recovery chance is based on the player's current form versus their breakeven score.
          A high recovery chance indicates a good opportunity to buy a premium at a discount.
        </p>
      </div>
      
      <div className="rounded-md border">
        <SortableTable
          data={recoveries}
          columns={columns}
          emptyMessage="No price recovery data available"
        />
      </div>
    </div>
  );
}