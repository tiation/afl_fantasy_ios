import React, { useState, useEffect } from 'react';
import { fetchLateSeasonTaper } from '@/services/contextService';
import { SortableTable } from '../sortable-table';
import { Button } from '@/components/ui/button';
import { Loader2, TrendingDown } from 'lucide-react';

type TaperData = {
  player: string;
  warning: string;
};

export function LateSeasonTaperFlagger() {
  const [taperData, setTaperData] = useState<TaperData[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  async function loadData() {
    setLoading(true);
    try {
      const response = await fetchLateSeasonTaper();
      if (response.status === 'ok' && response.data) {
        setTaperData(response.data);
      } else {
        setError('Failed to load late season taper data');
      }
    } catch (err) {
      setError('Error fetching late season taper data');
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadData();
  }, []);

  // Table columns
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
      key: 'warning',
      label: 'Late Season Warning',
      sortable: true,
      render: (value: string) => (
        <div className="flex items-center">
          <TrendingDown className="h-4 w-4 text-amber-600 mr-2" />
          <span>{value}</span>
        </div>
      ),
    },
  ];

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center py-8">
        <Loader2 className="h-8 w-8 animate-spin text-yellow-600 mb-2" />
        <p className="text-sm text-muted-foreground">Loading late season taper data...</p>
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
      <div className="rounded-md border px-4 py-3 bg-yellow-50">
        <h3 className="font-medium text-sm">Late Season Taper Flagger</h3>
        <p className="text-sm text-muted-foreground mt-1">
          This tool identifies players with historical late-season performance drops.
          Be cautious when selecting these players as they tend to taper off or get managed in the latter part of the season.
        </p>
      </div>
      
      <div className="rounded-md border">
        <SortableTable
          data={taperData}
          columns={columns}
          emptyMessage="No late season taper data available"
        />
      </div>

      <div className="mt-4 text-sm text-muted-foreground">
        <p><span className="font-medium">Strategy Tip:</span> Consider trading out players flagged for late-season tapering 
        before they drop in performance. This is especially important during the fantasy finals period.</p>
      </div>
    </div>
  );
}