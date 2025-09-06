import React, { useState, useEffect } from 'react';
import { fetchFixtureDifficulty } from '@/services/fixtureService';
import { SortableTable } from '../sortable-table';
import { Button } from '@/components/ui/button';
import { Loader2 } from 'lucide-react';
import { Badge } from '@/components/ui/badge';

type TeamFixture = {
  round: number;
  opponent: string;
  is_home: boolean;
  difficulty: number;
};

type TeamDifficulty = {
  team: string;
  fixtures: TeamFixture[];
  avg_difficulty: number;
};

export function FixtureDifficultyScanner() {
  const [teamDifficulties, setTeamDifficulties] = useState<TeamDifficulty[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedTeam, setSelectedTeam] = useState<string | null>(null);

  async function loadData() {
    setLoading(true);
    try {
      const response = await fetchFixtureDifficulty();
      if (response.status === 'ok' && response.data) {
        setTeamDifficulties(response.data);
      } else {
        setError('Failed to load fixture difficulty data');
      }
    } catch (err) {
      setError('Error fetching fixture difficulty data');
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

  // Table columns for teams overview
  const teamColumns = [
    {
      key: 'team',
      label: 'Team',
      sortable: true,
      render: (value: string) => (
        <div 
          className={`font-medium cursor-pointer ${selectedTeam === value ? 'text-blue-600' : ''}`}
          onClick={() => setSelectedTeam(value === selectedTeam ? null : value)}
        >
          {value}
        </div>
      ),
    },
    {
      key: 'avg_difficulty',
      label: 'Avg Difficulty',
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
      key: 'fixtures',
      label: 'Next 5 Rounds',
      sortable: false,
      render: (value: TeamFixture[]) => (
        <div className="flex space-x-1">
          {value.slice(0, 5).map((fixture, idx) => (
            <Badge 
              key={idx}
              variant="outline" 
              className={getDifficultyColor(fixture.difficulty)}
              title={`${fixture.is_home ? 'vs' : '@'} ${fixture.opponent} (R${fixture.round})`}
            >
              {fixture.difficulty.toFixed(1)}
            </Badge>
          ))}
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
    ? teamDifficulties.find(team => team.team === selectedTeam)?.fixtures || []
    : [];

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center py-8">
        <Loader2 className="h-8 w-8 animate-spin text-purple-600 mb-2" />
        <p className="text-sm text-muted-foreground">Loading fixture difficulty data...</p>
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
        <h3 className="font-medium text-sm">Fixture Difficulty Scanner</h3>
        <p className="text-sm text-muted-foreground mt-1">
          This tool analyzes fixture difficulty for each team over upcoming rounds.
          Teams are ranked by average difficulty (1-10 scale) with 10 being the most difficult.
          Click on a team to see their full fixture details.
        </p>
      </div>
      
      <div className="rounded-md border">
        <SortableTable
          data={teamDifficulties}
          columns={teamColumns}
          emptyMessage="No fixture difficulty data available"
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