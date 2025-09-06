import React, { useState, useEffect } from 'react';
import { fetchValueRankings } from '@/services/priceService';
import { SortableTable } from '../sortable-table';
import { Button } from '@/components/ui/button';
import { Loader2 } from 'lucide-react';

type ValueRanking = {
  player: string;
  team: string;
  position: string;
  price: number;
  avg: number;
  value_score: number;
  rank: number;
};

export function ValueRankerByPosition() {
  const [rankings, setRankings] = useState<ValueRanking[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [positionFilter, setPositionFilter] = useState<string | null>(null);

  async function loadData() {
    setLoading(true);
    try {
      const response = await fetchValueRankings();
      if (response.status === 'ok' && response.data) {
        setRankings(response.data);
      } else {
        setError('Failed to load value ranking data');
      }
    } catch (err) {
      setError('Error fetching value ranking data');
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadData();
  }, []);

  const filteredData = positionFilter
    ? rankings.filter(player => player.position === positionFilter)
    : rankings;

  const positions = ['DEF', 'MID', 'RUC', 'FWD'];

  const columns = [
    {
      key: 'rank',
      label: 'Rank',
      sortable: true,
      render: (value: number) => (
        <div className="text-center">{value}</div>
      ),
    },
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
      key: 'price',
      label: 'Price',
      sortable: true,
      render: (value: number) => (
        <div className="text-right">
          ${value.toLocaleString()}
        </div>
      ),
    },
    {
      key: 'avg',
      label: 'Average',
      sortable: true,
      render: (value: number) => (
        <div className="text-center">{value.toFixed(1)}</div>
      ),
    },
    {
      key: 'value_score',
      label: 'Value Score',
      sortable: true,
      render: (value: number) => (
        <div className="text-center font-medium">
          {value.toFixed(2)}
        </div>
      ),
    },
  ];

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center py-8">
        <Loader2 className="h-8 w-8 animate-spin text-blue-600 mb-2" />
        <p className="text-sm text-muted-foreground">Loading value rankings...</p>
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
        <h3 className="font-medium text-sm">Value Ranker by Position</h3>
        <p className="text-sm text-muted-foreground mt-1">
          This tool ranks players by value (points per dollar) within each position.
          Higher value scores indicate better return on investment, helping you
          identify underpriced players for each position.
        </p>
      </div>
      
      <div className="flex justify-center space-x-2 mb-4">
        <Button
          size="sm"
          variant={positionFilter === null ? "default" : "outline"}
          onClick={() => setPositionFilter(null)}
        >
          All Positions
        </Button>
        {positions.map(pos => (
          <Button
            key={pos}
            size="sm"
            variant={positionFilter === pos ? "default" : "outline"}
            onClick={() => setPositionFilter(pos)}
          >
            {pos}
          </Button>
        ))}
      </div>
      
      <div className="rounded-md border">
        <SortableTable
          data={filteredData}
          columns={columns}
          emptyMessage="No value ranking data available"
        />
      </div>
    </div>
  );
}