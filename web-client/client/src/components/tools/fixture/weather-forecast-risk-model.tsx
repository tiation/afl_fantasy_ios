import React, { useState, useEffect } from 'react';
import { fetchWeatherRisk } from '@/services/fixtureService';
import { SortableTable } from '../sortable-table';
import { Button } from '@/components/ui/button';
import { Loader2, CloudRain, Wind } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Progress } from '@/components/ui/progress';

type WeatherRisk = {
  round: number;
  home_team: string;
  away_team: string;
  venue: string;
  date: string;
  rain_chance: number;
  wind_chance: number;
  weather_risk: number;
  score_impact: string;
};

export function WeatherForecastRiskModel() {
  const [weatherData, setWeatherData] = useState<WeatherRisk[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filters, setFilters] = useState({
    round: 'all',
    team: 'all',
    risk: 'all'
  });

  async function loadData() {
    setLoading(true);
    try {
      const response = await fetchWeatherRisk();
      if (response.status === 'ok' && response.data) {
        setWeatherData(response.data);
      } else {
        setError('Failed to load weather risk data');
      }
    } catch (err) {
      setError('Error fetching weather risk data');
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadData();
  }, []);

  // Get risk color
  const getRiskColor = (risk: number) => {
    if (risk >= 7) return 'bg-red-100 text-red-800';
    if (risk >= 4) return 'bg-orange-100 text-orange-800';
    if (risk >= 2) return 'bg-yellow-100 text-yellow-800';
    return 'bg-green-100 text-green-800';
  };

  // Get impact styles
  const getImpactStyles = (impact: string) => {
    if (impact.includes('High')) return 'text-red-600 font-medium';
    if (impact.includes('Medium')) return 'text-orange-600';
    return 'text-green-600';
  };

  // Get round numbers for filter
  const rounds = weatherData.length > 0 
    ? Array.from(new Set(weatherData.map(game => game.round))).sort((a, b) => a - b)
    : [];

  // Get teams for filter
  const teams = weatherData.length > 0
    ? Array.from(new Set([
        ...weatherData.map(game => game.home_team),
        ...weatherData.map(game => game.away_team)
      ])).sort()
    : [];

  // Apply filters
  const filteredData = weatherData.filter(game => {
    if (filters.round !== 'all' && game.round !== parseInt(filters.round)) return false;
    if (filters.team !== 'all' && game.home_team !== filters.team && game.away_team !== filters.team) return false;
    if (filters.risk !== 'all') {
      if (filters.risk === 'high' && game.weather_risk < 7) return false;
      if (filters.risk === 'medium' && (game.weather_risk < 4 || game.weather_risk >= 7)) return false;
      if (filters.risk === 'low' && game.weather_risk >= 4) return false;
    }
    return true;
  });

  // Table columns
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
      key: 'date',
      label: 'Date',
      sortable: true,
      render: (value: string) => {
        const date = new Date(value);
        return (
          <div className="text-center">
            {date.toLocaleDateString('en-AU', { day: 'numeric', month: 'short' })}
          </div>
        );
      },
    },
    {
      key: 'home_team',
      label: 'Home Team',
      sortable: true,
    },
    {
      key: 'away_team',
      label: 'Away Team',
      sortable: true,
    },
    {
      key: 'venue',
      label: 'Venue',
      sortable: true,
    },
    {
      key: 'rain_chance',
      label: 'Rain',
      sortable: true,
      render: (value: number) => (
        <div className="flex items-center space-x-1 justify-center">
          <CloudRain className={`h-4 w-4 ${value >= 40 ? 'text-blue-600' : 'text-gray-400'}`} />
          <span>{value}%</span>
        </div>
      ),
    },
    {
      key: 'wind_chance',
      label: 'Wind',
      sortable: true,
      render: (value: number) => (
        <div className="flex items-center space-x-1 justify-center">
          <Wind className={`h-4 w-4 ${value >= 40 ? 'text-purple-600' : 'text-gray-400'}`} />
          <span>{value}%</span>
        </div>
      ),
    },
    {
      key: 'weather_risk',
      label: 'Risk',
      sortable: true,
      render: (value: number) => (
        <div className="text-center">
          <Badge variant="outline" className={getRiskColor(value)}>
            {value.toFixed(1)}
          </Badge>
        </div>
      ),
    },
    {
      key: 'score_impact',
      label: 'Impact',
      sortable: true,
      render: (value: string) => (
        <div className={`text-center ${getImpactStyles(value)}`}>
          {value}
        </div>
      ),
    },
  ];

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center py-8">
        <Loader2 className="h-8 w-8 animate-spin text-purple-600 mb-2" />
        <p className="text-sm text-muted-foreground">Loading weather risk data...</p>
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
        <h3 className="font-medium text-sm">Weather Forecast Risk Model</h3>
        <p className="text-sm text-muted-foreground mt-1">
          This tool analyzes weather risks for upcoming fixtures which can impact player scoring.
          Fixtures with high weather risk typically result in lower fantasy scores, especially for outside players.
          Use the filters below to find relevant matches.
        </p>
      </div>
      
      <div className="flex flex-wrap gap-2 mb-4">
        <div className="flex items-center space-x-2">
          <label className="text-sm font-medium">Round:</label>
          <select 
            className="h-8 rounded-md border border-input px-3 py-1 text-sm"
            value={filters.round}
            onChange={(e) => setFilters({...filters, round: e.target.value})}
          >
            <option value="all">All Rounds</option>
            {rounds.map(round => (
              <option key={round} value={round}>{round}</option>
            ))}
          </select>
        </div>

        <div className="flex items-center space-x-2">
          <label className="text-sm font-medium">Team:</label>
          <select 
            className="h-8 rounded-md border border-input px-3 py-1 text-sm"
            value={filters.team}
            onChange={(e) => setFilters({...filters, team: e.target.value})}
          >
            <option value="all">All Teams</option>
            {teams.map(team => (
              <option key={team} value={team}>{team}</option>
            ))}
          </select>
        </div>

        <div className="flex items-center space-x-2">
          <label className="text-sm font-medium">Risk Level:</label>
          <select 
            className="h-8 rounded-md border border-input px-3 py-1 text-sm"
            value={filters.risk}
            onChange={(e) => setFilters({...filters, risk: e.target.value})}
          >
            <option value="all">All Levels</option>
            <option value="high">High Risk</option>
            <option value="medium">Medium Risk</option>
            <option value="low">Low Risk</option>
          </select>
        </div>
      </div>
      
      <div className="rounded-md border">
        <SortableTable
          data={filteredData}
          columns={columns}
          emptyMessage="No weather risk data available"
        />
      </div>
    </div>
  );
}