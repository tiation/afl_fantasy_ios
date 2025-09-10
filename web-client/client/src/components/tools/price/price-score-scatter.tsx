import React, { useState, useEffect } from 'react';
import { fetchPriceScoreScatter } from '@/services/priceService';
import { Button } from '@/components/ui/button';
import { Loader2 } from 'lucide-react';
import { 
  ScatterChart, 
  Scatter, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer,
  ZAxis
} from 'recharts';

type ScatterPoint = {
  player: string;
  position: string;
  x: number; // price
  y: number; // score/average
  label: string;
  z: number; // used for scatter point size
};

export function PriceScoreScatter() {
  const [scatterData, setScatterData] = useState<ScatterPoint[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [positionFilter, setPositionFilter] = useState<string | null>(null);

  async function loadData() {
    setLoading(true);
    try {
      const response = await fetchPriceScoreScatter();
      if (response.status === 'ok' && response.data) {
        setScatterData(response.data);
      } else {
        setError('Failed to load price/score scatter data');
      }
    } catch (err) {
      setError('Error fetching price/score scatter data');
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadData();
  }, []);

  const positionOptions = ['All', 'DEF', 'MID', 'RUC', 'FWD'];
  const positionColors = {
    DEF: '#3182CE', // blue
    MID: '#805AD5', // purple
    RUC: '#DD6B20', // orange
    FWD: '#E53E3E'  // red
  };

  const getPointColor = (position: string) => {
    return positionColors[position as keyof typeof positionColors] || '#718096';
  };

  const filteredData = positionFilter && positionFilter !== 'All'
    ? scatterData.filter(point => point.position === positionFilter)
    : scatterData;

  const formatTooltip = (value: number, name: string) => {
    if (name === 'x') return `$${value.toLocaleString()}`;
    if (name === 'y') return `${value.toFixed(1)} pts`;
    return value;
  };

  const CustomTooltip = ({ active, payload }: any) => {
    if (active && payload && payload.length) {
      const data = payload[0].payload;
      return (
        <div className="bg-white p-2 border rounded shadow-sm text-sm">
          <p className="font-medium">{data.label}</p>
          <p>Position: {data.position}</p>
          <p>Price: ${data.x.toLocaleString()}</p>
          <p>Avg Score: {data.y.toFixed(1)}</p>
        </div>
      );
    }
    return null;
  };

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center py-8">
        <Loader2 className="h-8 w-8 animate-spin text-blue-600 mb-2" />
        <p className="text-sm text-muted-foreground">Loading price/score data...</p>
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
      <div className="rounded-md border px-4 py-3 bg-blue-50">
        <h3 className="font-medium text-sm">Price vs Score Scatter Plot</h3>
        <p className="text-sm text-muted-foreground mt-1">
          This visualization shows the relationship between player price and average scoring.
          Players appearing above the trend line offer better value for their price point.
          Filter by position to find value players in each role.
        </p>
      </div>
      
      <div className="flex justify-center space-x-2 mb-4">
        {positionOptions.map(pos => (
          <Button
            key={pos}
            size="sm"
            variant={positionFilter === pos || (pos === 'All' && !positionFilter) ? "default" : "outline"}
            onClick={() => setPositionFilter(pos === 'All' ? null : pos)}
            className={pos !== 'All' ? `bg-opacity-10 hover:bg-opacity-20` : ''}
            style={{
              backgroundColor: pos !== 'All' ? 
                (positionFilter === pos ? getPointColor(pos) : 'transparent') : 
                (positionFilter === null ? undefined : 'transparent'),
              borderColor: pos !== 'All' ? getPointColor(pos) : undefined,
              color: pos !== 'All' && positionFilter !== pos ? getPointColor(pos) : undefined
            }}
          >
            {pos}
          </Button>
        ))}
      </div>
      
      <div className="rounded-md border p-4" style={{ height: '400px' }}>
        {filteredData.length > 0 ? (
          <ResponsiveContainer width="100%" height="100%">
            <ScatterChart
              margin={{ top: 20, right: 20, bottom: 20, left: 40 }}
            >
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis 
                type="number" 
                dataKey="x" 
                name="Price" 
                domain={['dataMin - 100000', 'dataMax + 100000']}
                tickFormatter={(value) => `$${(value/1000).toFixed(0)}k`}
                label={{ value: 'Price', position: 'bottom', offset: 0 }}
              />
              <YAxis 
                type="number" 
                dataKey="y" 
                name="Score" 
                domain={['dataMin - 10', 'dataMax + 10']}
                label={{ value: 'Average Score', angle: -90, position: 'left' }}
              />
              <ZAxis type="number" dataKey="z" range={[50, 400]} />
              <Tooltip content={<CustomTooltip />} formatter={formatTooltip} />
              <Scatter 
                name="Players" 
                data={filteredData} 
                fill="#8884d8"
                shape="circle"
                strokeWidth={1}
                stroke="#fff"
                fillOpacity={0.8}
              />
            </ScatterChart>
          </ResponsiveContainer>
        ) : (
          <div className="flex items-center justify-center h-full">
            <p className="text-muted-foreground">No scatter data available</p>
          </div>
        )}
      </div>
    </div>
  );
}