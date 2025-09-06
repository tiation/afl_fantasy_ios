import React, { useState, useEffect } from 'react';
import { fetchContractMotivation } from '@/services/contextService';
import { SortableTable } from '../sortable-table';
import { Button } from '@/components/ui/button';
import { Loader2, Star, Award } from 'lucide-react';
import { Badge } from '@/components/ui/badge';

type ContractData = {
  player: string;
  status: string;
};

export function ContractYearMotivationChecker() {
  const [contractData, setContractData] = useState<ContractData[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  async function loadData() {
    setLoading(true);
    try {
      const response = await fetchContractMotivation();
      if (response.status === 'ok' && response.data) {
        setContractData(response.data);
      } else {
        setError('Failed to load contract motivation data');
      }
    } catch (err) {
      setError('Error fetching contract motivation data');
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadData();
  }, []);

  // Check if status indicates free agency
  const isFreeAgent = (status: string) => {
    return status.toLowerCase().includes('free agent');
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
      key: 'status',
      label: 'Contract Status',
      sortable: true,
      render: (value: string, item: ContractData) => (
        <div className="flex items-center">
          {isFreeAgent(item.status) ? (
            <Star className="h-4 w-4 text-yellow-500 mr-2" />
          ) : (
            <Award className="h-4 w-4 text-blue-500 mr-2" />
          )}
          <Badge 
            variant="outline" 
            className={isFreeAgent(item.status) ? 'bg-yellow-50 text-yellow-800' : 'bg-blue-50 text-blue-800'}
          >
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
        <p className="text-sm text-muted-foreground">Loading contract motivation data...</p>
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

  // Separate free agents from other contract situations
  const freeAgents = contractData.filter(p => isFreeAgent(p.status));
  const otherContracts = contractData.filter(p => !isFreeAgent(p.status));

  return (
    <div className="w-full space-y-4">
      <div className="rounded-md border px-4 py-3 bg-yellow-50">
        <h3 className="font-medium text-sm">Contract Year Motivation Checker</h3>
        <p className="text-sm text-muted-foreground mt-1">
          This tool identifies players in contract years who may have extra motivation to perform.
          Players in contract years often put in their best performances to secure their next deal.
        </p>
      </div>
      
      <div>
        <h4 className="text-sm font-medium mb-2 flex items-center">
          <Star className="h-4 w-4 text-yellow-500 mr-2" />
          Free Agents & Contract Year Players
        </h4>
        <div className="rounded-md border">
          <SortableTable
            data={freeAgents}
            columns={columns}
            emptyMessage="No free agent data available"
          />
        </div>
      </div>

      <div>
        <h4 className="text-sm font-medium mb-2 flex items-center">
          <Award className="h-4 w-4 text-blue-500 mr-2" />
          Other Contract Situations
        </h4>
        <div className="rounded-md border">
          <SortableTable
            data={otherContracts}
            columns={columns}
            emptyMessage="No additional contract data available"
          />
        </div>
      </div>

      <div className="mt-4 text-sm text-muted-foreground">
        <p><span className="font-medium">Strategy Tip:</span> Players in contract years often outperform 
        their career averages. Consider these players as value picks, especially if they're trying to 
        secure a big contract or prove their worth.</p>
      </div>
    </div>
  );
}