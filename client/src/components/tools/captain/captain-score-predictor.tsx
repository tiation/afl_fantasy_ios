import React, { useState, useEffect } from 'react';
import { fetchCaptainScorePredictor } from '@/services/captainService';
import { SortableTable } from '../sortable-table';
import { Button } from '@/components/ui/button';
import { Loader2 } from 'lucide-react';

type CaptainPlayer = {
  player: string;
  team: string;
  position: string;
  l3_avg: number;
  breakeven: number;
  captain_ceiling: number;
  captain_floor: number;
};

export function CaptainScorePredictor() {
  const [players, setPlayers] = useState<CaptainPlayer[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  async function loadData() {
    setLoading(true);
    try {
      const data = await fetchCaptainScorePredictor();
      if (data.status === 'ok' && data.players) {
        setPlayers(data.players);
      } else {
        setError('Failed to load captain score data');
      }
    } catch (err) {
      setError('Error fetching captain score data');
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
      key: 'l3_avg',
      label: 'L3 Avg',
      sortable: true,
      render: (value: number) => (
        <div className="text-center font-medium">{value}</div>
      ),
    },
    {
      key: 'breakeven',
      label: 'Breakeven',
      sortable: true,
      render: (value: number) => (
        <div className="text-center">{value}</div>
      ),
    },
    {
      key: 'captain_ceiling',
      label: 'C Ceiling',
      sortable: true,
      render: (value: number) => (
        <div className="text-center text-green-600 font-medium">{value}</div>
      ),
    },
    {
      key: 'captain_floor',
      label: 'C Floor',
      sortable: true,
      render: (value: number) => (
        <div className="text-center text-red-600 font-medium">{value}</div>
      ),
    },
  ];

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center py-8">
        <Loader2 className="h-8 w-8 animate-spin text-amber-600 mb-2" />
        <p className="text-sm text-muted-foreground">Loading captain data...</p>
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
      <div className="rounded-md border px-4 py-3 bg-amber-50">
        <h3 className="font-medium text-sm">How to use this tool:</h3>
        <p className="text-sm text-muted-foreground mt-1">
          This tool identifies the top 5 players based on L3 (last 3 rounds) 
          average scores and predicts their captain-worthy performance including 
          potential ceiling and floor. Consider selecting players with high ceilings 
          when you need a big score to climb ranks.
        </p>
      </div>
      
      <div className="rounded-md border">
        <SortableTable
          data={players}
          columns={columns}
          emptyMessage="No player data available"
        />
      </div>
    </div>
  );
}