import React from 'react';
import { TeamUploader } from '@/components/team-uploader';

export default function TeamPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="mb-6">
        <h1 className="text-2xl md:text-3xl font-bold mb-2">My Team</h1>
        <p className="text-muted-foreground">
          Upload your team with accurate data from FootyWire and DFS Australia
        </p>
      </div>
      
      <TeamUploader />
    </div>
  );
}