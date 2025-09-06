import React, { useState, useEffect } from 'react';
import { fetchFormBasedCaptainAnalyzer } from '@/services/captainService';
import { SortableTable } from '../sortable-table';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Loader2 } from 'lucide-react';

type FormPlayer = {
  player: string;
  team: string;
  position: string;
  last_3_form: number;
  last_5_form: number | string;
  season_form: number;
  trend: string;
  recommendation: string;
};

export function FormBasedCaptainAnalyzer() {
  const [players, setPlayers] = useState<FormPlayer[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  async function loadData() {
    setLoading(true);
    try {
      const data = await fetchFormBasedCaptainAnalyzer();
      if (data.status === 'ok' && data.players) {
        setPlayers(data.players);
      } else {
        setError('Failed to load form-based captain data');
      }
    } catch (err) {
      setError('Error fetching form-based captain data');
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadData();
  }, []);

  // Get badge variant based on recommendation
  const getRecommendationVariant = (recommendation: string) => {
    switch (recommendation) {
      case 'Highly recommended':
        return 'success';
      case 'Recommended':
        return 'default';
      case 'Consider alternatives':
        return 'secondary';
      case 'Not recommended':
        return 'destructive';
      default:
        return 'outline';
    }
  };

  // Get trend color
  const getTrendColor = (trend: string) => {
    if (trend.includes('upward') || trend === 'Above average' || trend === 'Strong upward') {
      return 'text-green-600';
    } else if (trend.includes('downward') || trend === 'Below average' || trend === 'Strong downward') {
      return 'text-red-600';
    } else {
      return 'text-amber-600';
    }
  };

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
      key: 'last_3_form',
      label: 'L3 Form',
      sortable: true,
      render: (value: number) => (
        <div className="text-center font-medium">{value}</div>
      ),
    },
    {
      key: 'last_5_form',
      label: 'L5 Form',
      sortable: true,
      render: (value: number | string) => (
        <div className="text-center">{value}</div>
      ),
    },
    {
      key: 'season_form',
      label: 'Season',
      sortable: true,
      render: (value: number) => (
        <div className="text-center">{value}</div>
      ),
    },
    {
      key: 'trend',
      label: 'Trend',
      sortable: true,
      render: (value: string, item: any) => (
        <div className={`text-center ${getTrendColor(value)}`}>{value}</div>
      ),
    },
    {
      key: 'recommendation',
      label: 'Recommendation',
      sortable: true,
      render: (value: string) => (
        <Badge variant={getRecommendationVariant(value) as any}>{value}</Badge>
      ),
    },
  ];

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center py-8">
        <Loader2 className="h-8 w-8 animate-spin text-amber-600 mb-2" />
        <p className="text-sm text-muted-foreground">Loading captain form data...</p>
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
          This tool analyzes player form over various timeframes to recommend captain choices.
          Players with strong upward trends in their recent form (last 3 games) compared to their
          season average may be good captain picks. Focus on "Highly recommended" or "Recommended"
          players with positive trends.
        </p>
      </div>
      
      <div className="rounded-md border">
        <SortableTable
          data={players}
          columns={columns}
          emptyMessage="No form data available"
        />
      </div>
    </div>
  );
}