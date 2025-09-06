import React, { useState, useEffect } from 'react';
import { fetchTravelImpact } from '@/services/fixtureService';
import { SortableTable } from '../sortable-table';
import { Button } from '@/components/ui/button';
import { Loader2, Plane } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Progress } from '@/components/ui/progress';

type TravelFixture = {
  round: number;
  opponent: string;
  is_home: boolean;
  venue: string;
  travel_distance: number;
  travel_impact: number;
};

type TeamTravel = {
  team: string;
  avg_travel_impact: number;
  travel_fixtures: TravelFixture[];
  interstate_games: number;
};

export function TravelImpactEstimator() {
  const [travelData, setTravelData] = useState<TeamTravel[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedTeam, setSelectedTeam] = useState<string | null>(null);

  async function loadData() {
    setLoading(true);
    try {
      const response = await fetchTravelImpact();
      if (response.status === 'ok' && response.data) {
        setTravelData(response.data);
      } else {
        setError('Failed to load travel impact data');
      }
    } catch (err) {
      setError('Error fetching travel impact data');
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadData();
  }, []);

  // Get travel impact color
  const getTravelImpactColor = (impact: number) => {
    if (impact >= 0.6) return 'bg-red-100 text-red-800';
    if (impact >= 0.4) return 'bg-orange-100 text-orange-800';
    if (impact >= 0.2) return 'bg-yellow-100 text-yellow-800';
    return 'bg-green-100 text-green-800';
  };

  // Table columns for teams overview
  const teamColumns = [
    {
      key: 'team',
      label: 'Team',
      sortable: true,
      render: (value: string) => (
        <div 
          className={`font-medium cursor-pointer ${selectedTeam === value ? 'text-purple-600' : ''}`}
          onClick={() => setSelectedTeam(value === selectedTeam ? null : value)}
        >
          {value}
        </div>
      ),
    },
    {
      key: 'interstate_games',
      label: 'Interstate Games',
      sortable: true,
      render: (value: number) => (
        <div className="text-center font-medium">
          {value}
        </div>
      ),
    },
    {
      key: 'avg_travel_impact',
      label: 'Travel Impact',
      sortable: true,
      render: (value: number) => (
        <div className="w-32 mx-auto">
          <div className="text-center mb-1 text-xs">{value.toFixed(1)}</div>
          <Progress 
            value={value * 100} 
            className={value >= 0.4 ? 'bg-red-200' : 'bg-orange-200'}
          />
        </div>
      ),
    },
    {
      key: 'travel_fixtures',
      label: 'Travel Schedule',
      sortable: false,
      render: (value: TravelFixture[]) => (
        <div className="flex space-x-1">
          {value.slice(0, 5).map((fixture, idx) => (
            <Badge 
              key={idx}
              variant="outline" 
              className={getTravelImpactColor(fixture.travel_impact)}
              title={`@${fixture.opponent} (R${fixture.round}): ${fixture.venue}`}
            >
              {fixture.round}
            </Badge>
          ))}
        </div>
      ),
    },
  ];

  // Table columns for selected team's travel fixtures
  const fixtureColumns = [
    {
      key: 'round',
      label: 'Round',
      sortable: true,
      render: (value: number) => (
        <div className="text-center font-medium">{value}</div>
      ),
    },
    {
      key: 'opponent',
      label: 'Opponent',
      sortable: true,
    },
    {
      key: 'venue',
      label: 'Venue',
      sortable: true,
    },
    {
      key: 'travel_distance',
      label: 'Distance',
      sortable: true,
      render: (value: number) => (
        <div className="flex items-center justify-center space-x-1">
          <Plane className="h-4 w-4 text-purple-500" />
          <span className="font-medium">{value}</span>
        </div>
      ),
    },
    {
      key: 'travel_impact',
      label: 'Impact',
      sortable: true,
      render: (value: number) => (
        <div className="text-center">
          <Badge variant="outline" className={getTravelImpactColor(value)}>
            {value.toFixed(1)}
          </Badge>
        </div>
      ),
    },
  ];

  // Get the selected team's travel fixtures
  const selectedTeamFixtures = selectedTeam
    ? travelData.find(team => team.team === selectedTeam)?.travel_fixtures || []
    : [];

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center py-8">
        <Loader2 className="h-8 w-8 animate-spin text-purple-600 mb-2" />
        <p className="text-sm text-muted-foreground">Loading travel impact data...</p>
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
        <h3 className="font-medium text-sm">Travel Impact Estimator</h3>
        <p className="text-sm text-muted-foreground mt-1">
          This tool estimates the impact of travel on team performance for upcoming fixtures.
          Teams with more interstate games and longer travel distances have higher travel impact scores.
          Consider this factor when selecting players from teams with heavy travel schedules.
        </p>
      </div>
      
      <div className="rounded-md border">
        <SortableTable
          data={travelData}
          columns={teamColumns}
          emptyMessage="No travel impact data available"
        />
      </div>

      {selectedTeam && (
        <div className="mt-6">
          <h3 className="text-md font-semibold mb-2">{selectedTeam} Travel Schedule</h3>
          <div className="rounded-md border">
            <SortableTable
              data={selectedTeamFixtures}
              columns={fixtureColumns}
              emptyMessage="No travel fixtures available"
            />
          </div>
        </div>
      )}
    </div>
  );
}