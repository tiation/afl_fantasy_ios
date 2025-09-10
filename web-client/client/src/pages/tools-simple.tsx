import React from 'react';
import AFLFantasyDashboard from '@/components/AFLFantasyDashboard_simple';

export default function ToolsSimplePage() {
  return (
    <div className="container mx-auto px-3 md:px-6 py-4 md:py-6">
      <h1 className="text-2xl md:text-3xl font-bold mb-2">AFL Fantasy Tools</h1>
      <p className="text-muted-foreground mb-6">
        Maximize your fantasy performance with our suite of advanced analytical tools
      </p>
      <AFLFantasyDashboard />
    </div>
  );
}