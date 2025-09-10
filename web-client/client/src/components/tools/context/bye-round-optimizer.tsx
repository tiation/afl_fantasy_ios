import React, { useState, useEffect } from 'react';
import { fetchByeOptimizer } from '@/services/contextService';
import { SortableTable } from '../sortable-table';
import { Button } from '@/components/ui/button';
import { Loader2 } from 'lucide-react';
import { Badge } from '@/components/ui/badge';

type ByeRoundData = {
  round: string;
  player_count: number;
  risk_level: "High" | "Medium" | "Low";
};

export function ByeRoundOptimizer() {
  const [byeData, setByeData] = useState<ByeRoundData[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  async function loadData() {
    setLoading(true);
    try {
      const response = await fetchByeOptimizer();
      if (response.status === 'ok' && response.data) {
        setByeData(response.data);
      } else {
        setError('Failed to load bye round data');
      }
    } catch (err) {
      setError('Error fetching bye round data');
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadData();
  }, []);

  // Get color based on risk level
  const getRiskColor = (risk: string) => {
    switch (risk) {
      case 'High':
        return 'bg-red-100 text-red-800';
      case 'Medium':
        return 'bg-orange-100 text-orange-800';
      case 'Low':
        return 'bg-green-100 text-green-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  // Table columns
  const columns = [
    {
      key: 'round',
      label: 'Round',
      sortable: true,
      render: (value: string) => (
        <div className="text-center font-medium">{value}</div>
      ),
    },
    {
      key: 'player_count',
      label: 'Player Count',
      sortable: true,
      render: (value: number) => (
        <div className="text-center">
          <span className="text-lg font-medium">{value}</span>
        </div>
      ),
    },
    {
      key: 'risk_level',
      label: 'Risk Level',
      sortable: true,
      render: (value: string) => (
        <div className="text-center">
          <Badge variant="outline" className={getRiskColor(value)}>
            {value}
          </Badge>
        </div>
      ),
    },
  ];

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center py-8">
        <Loader2 className="h-8 w-8 animate-spin text-yellow-600 mb-2" />
        <p className="text-sm text-muted-foreground">Loading bye round data...</p>
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
        <h3 className="font-medium text-sm">Bye Round Optimizer</h3>
        <p className="text-sm text-muted-foreground mt-1">
          This tool helps you balance player availability during bye rounds.
          High risk rounds have many players missing, while low risk rounds have fewer players out.
          Plan your trades to avoid overloading certain bye rounds.
        </p>
      </div>
      
      <div className="rounded-md border">
        <SortableTable
          data={byeData}
          columns={columns}
          emptyMessage="No bye round data available"
        />
      </div>

      <div className="mt-4 text-sm text-muted-foreground">
        <p><span className="font-medium">Recommendation:</span> Try to keep your player counts balanced across all bye rounds, 
        with no more than 6 players out in any single round. Trade planning should account for upcoming bye rounds.</p>
      </div>
    </div>
  );
}