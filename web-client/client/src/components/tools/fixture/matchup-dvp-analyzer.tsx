import React, { useState, useEffect } from 'react';
import { fetchMatchupDVP } from '@/services/fixtureService';
import { SortableTable } from '../sortable-table';
import { Button } from '@/components/ui/button';
import { Loader2 } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';

type Matchup = {
  round: number;
  team: string;
  opponent: string;
  is_home: boolean;
  dvp_rating: number;
  matchup_quality: number;
};

type PositionMatchups = {
  position: string;
  matchups: Matchup[];
};

export function MatchupDVPAnalyzer() {
  const [matchupData, setMatchupData] = useState<PositionMatchups[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [activePosition, setActivePosition] = useState<string>("DEF");

  async function loadData() {
    setLoading(true);
    try {
      const response = await fetchMatchupDVP();
      if (response.status === 'ok' && response.data) {
        setMatchupData(response.data);
        
        // Set active position based on first position in data if it exists
        if (response.data.length > 0) {
          setActivePosition(response.data[0].position);
        }
      } else {
        setError('Failed to load matchup DVP data');
      }
    } catch (err) {
      setError('Error fetching matchup DVP data');
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadData();
  }, []);

  // Get color based on matchup quality
  const getMatchupColor = (quality: number) => {
    if (quality >= 4) return 'bg-green-100 text-green-800';
    if (quality >= 3) return 'bg-lime-100 text-lime-800';
    if (quality >= 2) return 'bg-yellow-100 text-yellow-800';
    return 'bg-gray-100 text-gray-800';
  };

  // Columns for matchup table
  const columns = [
    {
      key: 'round',
      label: 'Round',
      sortable: true,
      render: (value: number) => (
        <div className="text-center font-medium">{value}</div>
      ),
    },
    {
      key: 'team',
      label: 'Team',
      sortable: true,
    },
    {
      key: 'opponent',
      label: 'Opponent',
      sortable: true,
    },
    {
      key: 'is_home',
      label: 'Venue',
      sortable: true,
      render: (value: boolean) => (
        <div className="text-center">
          {value ? 'Home' : 'Away'}
        </div>
      ),
    },
    {
      key: 'dvp_rating',
      label: 'DVP Rating',
      sortable: true,
      render: (value: number) => (
        <div className="text-center font-medium">
          {value.toFixed(1)}
        </div>
      ),
    },
    {
      key: 'matchup_quality',
      label: 'Quality',
      sortable: true,
      render: (value: number) => (
        <div className="text-center">
          <Badge variant="outline" className={getMatchupColor(value)}>
            {value.toFixed(1)}
          </Badge>
        </div>
      ),
    },
  ];

  // Get matchups for the active position
  const activeMatchups = matchupData.find(p => p.position === activePosition)?.matchups || [];

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center py-8">
        <Loader2 className="h-8 w-8 animate-spin text-purple-600 mb-2" />
        <p className="text-sm text-muted-foreground">Loading matchup DVP data...</p>
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
      <div className="rounded-md border px-4 py-3 bg-purple-50">
        <h3 className="font-medium text-sm">Matchup DVP Analyzer</h3>
        <p className="text-sm text-muted-foreground mt-1">
          This tool analyzes Defense vs Position (DVP) matchups for upcoming rounds.
          Higher DVP ratings indicate teams that give up more points to that position.
          Use the tabs to view favorable matchups by position.
        </p>
      </div>
      
      <Tabs value={activePosition} onValueChange={setActivePosition}>
        <TabsList className="grid grid-cols-4">
          <TabsTrigger value="DEF">Defenders</TabsTrigger>
          <TabsTrigger value="MID">Midfielders</TabsTrigger>
          <TabsTrigger value="RUC">Rucks</TabsTrigger>
          <TabsTrigger value="FWD">Forwards</TabsTrigger>
        </TabsList>
        
        <TabsContent value={activePosition} className="mt-4">
          <div className="rounded-md border">
            <SortableTable
              data={activeMatchups}
              columns={columns}
              emptyMessage={`No favorable ${activePosition} matchups available`}
            />
          </div>
        </TabsContent>
      </Tabs>
    </div>
  );
}