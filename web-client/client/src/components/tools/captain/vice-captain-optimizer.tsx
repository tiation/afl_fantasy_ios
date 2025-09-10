import React, { useState, useEffect } from 'react';
import { fetchViceCaptainOptimizer } from '@/services/captainService';
import { SortableTable } from '../sortable-table';
import { Button } from '@/components/ui/button';
import { Loader2 } from 'lucide-react';

type CaptainCombo = {
  vice_captain: string;
  vc_team: string;
  vc_position: string;
  vc_avg: number;
  vc_day: string;
  captain: string;
  c_team: string;
  c_position: string;
  c_avg: number;
  c_day: string;
  expected_pts: number;
};

export function ViceCaptainOptimizer() {
  const [combinations, setCombinations] = useState<CaptainCombo[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  async function loadData() {
    setLoading(true);
    try {
      const data = await fetchViceCaptainOptimizer();
      if (data.status === 'ok' && data.combinations) {
        setCombinations(data.combinations);
      } else {
        setError('Failed to load vice-captain data');
      }
    } catch (err) {
      setError('Error fetching vice-captain data');
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
      key: 'vice_captain',
      label: 'Vice-Captain',
      sortable: true,
      render: (value: string) => (
        <div className="font-medium">{value}</div>
      ),
    },
    {
      key: 'vc_team',
      label: 'VC Team',
      sortable: true,
      render: (value: string) => (
        <div className="text-xs">{value}</div>
      ),
    },
    {
      key: 'vc_position',
      label: 'VC Pos',
      sortable: true,
      render: (value: string) => (
        <div className="text-center text-xs">{value}</div>
      ),
    },
    {
      key: 'vc_avg',
      label: 'VC Avg',
      sortable: true,
      render: (value: number) => (
        <div className="text-center">{value}</div>
      ),
    },
    {
      key: 'vc_day',
      label: 'VC Day',
      sortable: true,
      render: (value: string) => (
        <div className="text-center text-xs">{value}</div>
      ),
    },
    {
      key: 'captain',
      label: 'Captain',
      sortable: true,
      render: (value: string) => (
        <div className="font-medium">{value}</div>
      ),
    },
    {
      key: 'c_team',
      label: 'C Team',
      sortable: true,
      render: (value: string) => (
        <div className="text-xs">{value}</div>
      ),
    },
    {
      key: 'c_position',
      label: 'C Pos',
      sortable: true,
      render: (value: string) => (
        <div className="text-center text-xs">{value}</div>
      ),
    },
    {
      key: 'c_avg',
      label: 'C Avg',
      sortable: true,
      render: (value: number) => (
        <div className="text-center">{value}</div>
      ),
    },
    {
      key: 'c_day',
      label: 'C Day',
      sortable: true,
      render: (value: string) => (
        <div className="text-center text-xs">{value}</div>
      ),
    },
    {
      key: 'expected_pts',
      label: 'Expected Pts',
      sortable: true,
      render: (value: number) => (
        <div className="text-center font-medium text-amber-600">{value}</div>
      ),
    },
  ];

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center py-8">
        <Loader2 className="h-8 w-8 animate-spin text-amber-600 mb-2" />
        <p className="text-sm text-muted-foreground">Loading vice-captain data...</p>
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
          This tool recommends optimal Vice-Captain (VC) and Captain (C) combinations
          based on player schedules and scoring patterns. The recommended combinations
          maximize expected points by placing VC on earlier games (Friday/Saturday)
          and C on Sunday games, allowing you to use the captain loophole if your VC
          scores well.
        </p>
      </div>
      
      <div className="rounded-md border overflow-x-auto">
        <SortableTable
          data={combinations}
          columns={columns}
          emptyMessage="No combinations available"
        />
      </div>
    </div>
  );
}