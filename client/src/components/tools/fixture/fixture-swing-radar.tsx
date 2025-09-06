import React, { useState, useEffect } from 'react';
import { fetchFixtureSwing } from '@/services/fixtureService';
import { SortableTable } from '../sortable-table';
import { Button } from '@/components/ui/button';
import { Loader2, TrendingDown, TrendingUp } from 'lucide-react';
import { Badge } from '@/components/ui/badge';

type TeamFixture = {
  round: number;
  opponent: string;
  is_home: boolean;
  difficulty: number;
};

type FixtureSwing = {
  team: string;
  early_avg: number;
  late_avg: number;
  swing: number;
  direction: "Easier" | "Harder";
  fixtures: TeamFixture[];
};

export function FixtureSwingRadar() {
  const [fixtureSwings, setFixtureSwings] = useState<FixtureSwing[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedTeam, setSelectedTeam] = useState<string | null>(null);

  async function loadData() {
    setLoading(true);
    try {
      const response = await fetchFixtureSwing();
      if (response.status === 'ok' && response.data) {
        setFixtureSwings(response.data);
      } else {
        setError('Failed to load fixture swing data');
      }
    } catch (err) {
      setError('Error fetching fixture swing data');
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadData();
  }, []);

  // Get difficulty color based on rating
  const getDifficultyColor = (difficulty: number) => {
    if (difficulty >= 8) return 'bg-red-100 text-red-800';
    if (difficulty >= 6) return 'bg-orange-100 text-orange-800';
    if (difficulty >= 4) return 'bg-yellow-100 text-yellow-800';
    return 'bg-green-100 text-green-800';
  };

  // Get swing color
  const getSwingColor = (direction: string) => {
    return direction === 'Easier' ? 'text-green-600' : 'text-red-600';
  };

  // Table columns for teams with fixture swings
  const swingColumns = [
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
      key: 'early_avg',
      label: 'Early Rounds',
      sortable: true,
      render: (value: number) => (
        <div className="text-center">
          <Badge variant="outline" className={getDifficultyColor(value)}>
            {value.toFixed(1)}
          </Badge>
        </div>
      ),
    },
    {
      key: 'late_avg',
      label: 'Late Rounds',
      sortable: true,
      render: (value: number) => (
        <div className="text-center">
          <Badge variant="outline" className={getDifficultyColor(value)}>
            {value.toFixed(1)}
          </Badge>
        </div>
      ),
    },
    {
      key: 'swing',
      label: 'Swing',
      sortable: true,
      render: (value: number, item: FixtureSwing) => (
        <div className={`text-center font-medium flex items-center justify-center ${getSwingColor(item.direction)}`}>
          {item.direction === 'Easier' ? (
            <>
              <TrendingDown className="h-4 w-4 mr-1" />
              <span>-{Math.abs(value).toFixed(1)}</span>
            </>
          ) : (
            <>
              <TrendingUp className="h-4 w-4 mr-1" />
              <span>+{Math.abs(value).toFixed(1)}</span>
            </>
          )}
        </div>
      ),
    },
    {
      key: 'direction',
      label: 'Direction',
      sortable: true,
      render: (value: string) => (
        <div className={`text-center ${getSwingColor(value)}`}>
          {value}
        </div>
      ),
    },
  ];

  // Table columns for selected team's fixtures
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
      key: 'difficulty',
      label: 'Difficulty',
      sortable: true,
      render: (value: number) => (
        <div className="text-center">
          <Badge variant="outline" className={getDifficultyColor(value)}>
            {value.toFixed(1)}
          </Badge>
        </div>
      ),
    },
  ];

  // Get the selected team's fixtures
  const selectedTeamFixtures = selectedTeam
    ? fixtureSwings.find(team => team.team === selectedTeam)?.fixtures || []
    : [];

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center py-8">
        <Loader2 className="h-8 w-8 animate-spin text-purple-600 mb-2" />
        <p className="text-sm text-muted-foreground">Loading fixture swing data...</p>
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
        <h3 className="font-medium text-sm">Fixture Swing Radar</h3>
        <p className="text-sm text-muted-foreground mt-1">
          This tool identifies teams with significant changes in fixture difficulty.
          Positive swings indicate fixtures getting harder, negative swings indicate fixtures getting easier.
          This information is valuable for planning trade strategies.
        </p>
      </div>
      
      <div className="rounded-md border">
        <SortableTable
          data={fixtureSwings}
          columns={swingColumns}
          emptyMessage="No fixture swing data available"
        />
      </div>

      {selectedTeam && (
        <div className="mt-6">
          <h3 className="text-md font-semibold mb-2">{selectedTeam} Fixtures</h3>
          <div className="rounded-md border">
            <SortableTable
              data={selectedTeamFixtures}
              columns={fixtureColumns}
              emptyMessage="No fixtures available"
            />
          </div>
        </div>
      )}
    </div>
  );
}