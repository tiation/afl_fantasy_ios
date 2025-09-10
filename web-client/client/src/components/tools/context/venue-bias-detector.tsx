import React, { useState, useEffect } from 'react';
import { fetchVenueBias } from '@/services/contextService';
import { SortableTable } from '../sortable-table';
import { Button } from '@/components/ui/button';
import { Loader2, MapPin, PlusCircle, MinusCircle } from 'lucide-react';
import { Badge } from '@/components/ui/badge';

type VenueBiasData = {
  player: string;
  venue: string;
  bias: string;
};

export function VenueBiasDetector() {
  const [venueData, setVenueData] = useState<VenueBiasData[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filterVenue, setFilterVenue] = useState<string>('all');

  async function loadData() {
    setLoading(true);
    try {
      const response = await fetchVenueBias();
      if (response.status === 'ok' && response.data) {
        setVenueData(response.data);
      } else {
        setError('Failed to load venue bias data');
      }
    } catch (err) {
      setError('Error fetching venue bias data');
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadData();
  }, []);

  // Get venues for filter
  const venues = venueData.length > 0
    ? ['all', ...Array.from(new Set(venueData.map(v => v.venue))).sort()]
    : ['all'];

  // Get filtered data based on venue selection
  const filteredData = filterVenue === 'all'
    ? venueData
    : venueData.filter(v => v.venue === filterVenue);

  // Get bias color based on positive or negative
  const getBiasColor = (bias: string) => {
    if (bias.startsWith('+')) {
      return 'bg-green-100 text-green-800';
    } else if (bias.startsWith('-')) {
      return 'bg-red-100 text-red-800';
    }
    return 'bg-gray-100 text-gray-800';
  };

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
      key: 'venue',
      label: 'Venue',
      sortable: true,
      render: (value: string) => (
        <div className="flex items-center">
          <MapPin className="h-4 w-4 text-yellow-600 mr-2" />
          <span>{value}</span>
        </div>
      ),
    },
    {
      key: 'bias',
      label: 'Performance Bias',
      sortable: true,
      render: (value: string) => (
        <div className="flex items-center justify-center">
          {value.startsWith('+') ? (
            <PlusCircle className="h-4 w-4 text-green-600 mr-2" />
          ) : (
            <MinusCircle className="h-4 w-4 text-red-600 mr-2" />
          )}
          <Badge variant="outline" className={getBiasColor(value)}>
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
        <p className="text-sm text-muted-foreground">Loading venue bias data...</p>
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
        <h3 className="font-medium text-sm">Venue Bias Detector</h3>
        <p className="text-sm text-muted-foreground mt-1">
          This tool identifies players who perform significantly better or worse at specific venues.
          Use this when considering captain selections or trading decisions based on upcoming fixtures.
        </p>
      </div>
      
      <div className="flex items-center space-x-2 mb-4">
        <label className="text-sm font-medium">Filter by Venue:</label>
        <select 
          className="h-8 rounded-md border border-input px-3 py-1 text-sm"
          value={filterVenue}
          onChange={(e) => setFilterVenue(e.target.value)}
        >
          {venues.map(venue => (
            <option key={venue} value={venue}>
              {venue === 'all' ? 'All Venues' : venue}
            </option>
          ))}
        </select>
      </div>
      
      <div className="rounded-md border">
        <SortableTable
          data={filteredData}
          columns={columns}
          emptyMessage="No venue bias data available"
        />
      </div>

      <div className="mt-4 text-sm text-muted-foreground">
        <p><span className="font-medium">Strategy Tip:</span> Consider captaining players when they're playing 
        at venues where they have a strong positive bias, especially home-ground specialists.</p>
      </div>
    </div>
  );
}