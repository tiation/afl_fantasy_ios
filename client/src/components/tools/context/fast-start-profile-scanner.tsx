import React, { useState, useEffect } from 'react';
import { fetchFastStartProfiles } from '@/services/contextService';
import { SortableTable } from '../sortable-table';
import { Button } from '@/components/ui/button';
import { Loader2, Zap, BarChart } from 'lucide-react';

type ProfileData = {
  player: string;
  trend: string;
};

export function FastStartProfileScanner() {
  const [profileData, setProfileData] = useState<ProfileData[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  async function loadData() {
    setLoading(true);
    try {
      const response = await fetchFastStartProfiles();
      if (response.status === 'ok' && response.data) {
        setProfileData(response.data);
      } else {
        setError('Failed to load fast start profile data');
      }
    } catch (err) {
      setError('Error fetching fast start profile data');
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
      key: 'trend',
      label: 'Season Start Trend',
      sortable: true,
      render: (value: string) => (
        <div className="flex items-center">
          {value.toLowerCase().includes('fast starter') ? (
            <Zap className="h-4 w-4 text-yellow-500 mr-2" />
          ) : (
            <BarChart className="h-4 w-4 text-blue-500 mr-2" />
          )}
          <span>{value}</span>
        </div>
      ),
    },
  ];

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center py-8">
        <Loader2 className="h-8 w-8 animate-spin text-yellow-600 mb-2" />
        <p className="text-sm text-muted-foreground">Loading fast start profile data...</p>
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

  // Filter players into fast starters and slow starters
  const fastStarters = profileData.filter(p => 
    p.trend.toLowerCase().includes('fast starter') || 
    p.trend.toLowerCase().includes('early season')
  );
  
  const otherProfiles = profileData.filter(p => 
    !p.trend.toLowerCase().includes('fast starter') && 
    !p.trend.toLowerCase().includes('early season')
  );

  return (
    <div className="w-full space-y-4">
      <div className="rounded-md border px-4 py-3 bg-yellow-50">
        <h3 className="font-medium text-sm">Fast Start Profile Scanner</h3>
        <p className="text-sm text-muted-foreground mt-1">
          This tool identifies players who historically start seasons strongly or slowly.
          Use this to gain an early advantage by targeting fast starters or to avoid slow starters
          until they hit their stride later in the season.
        </p>
      </div>
      
      <div>
        <h4 className="text-sm font-medium mb-2 flex items-center">
          <Zap className="h-4 w-4 text-yellow-500 mr-2" />
          Fast Starters
        </h4>
        <div className="rounded-md border">
          <SortableTable
            data={fastStarters}
            columns={columns}
            emptyMessage="No fast starter data available"
          />
        </div>
      </div>

      <div>
        <h4 className="text-sm font-medium mb-2 flex items-center">
          <BarChart className="h-4 w-4 text-blue-500 mr-2" />
          Other Season Start Profiles
        </h4>
        <div className="rounded-md border">
          <SortableTable
            data={otherProfiles}
            columns={columns}
            emptyMessage="No additional profile data available"
          />
        </div>
      </div>

      <div className="mt-4 text-sm text-muted-foreground">
        <p><span className="font-medium">Strategy Tip:</span> Target fast starters for your Round 1 team, 
        but be prepared to trade to slow-starting premium players after they've dropped in price.</p>
      </div>
    </div>
  );
}