import React, { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Textarea } from '@/components/ui/textarea';
import { Card } from '@/components/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';
import { AlertCircle, CheckCircle, Upload, RefreshCw } from 'lucide-react';
import { Badge } from '@/components/ui/badge';

export function TeamUploader() {
  const [teamText, setTeamText] = useState<string>('');
  const [loading, setLoading] = useState<boolean>(false);
  const [success, setSuccess] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const [teamData, setTeamData] = useState<any>(null);
  
  const handleUpload = async () => {
    if (!teamText.trim()) {
      setError('Please enter your team data');
      return;
    }
    
    setLoading(true);
    setError(null);
    setSuccess(false);
    
    try {
      const response = await fetch('/api/team/upload', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ teamText }),
      });
      
      const result = await response.json();
      
      if (result.status === 'ok') {
        setSuccess(true);
        setTeamData(result.data);
      } else {
        setError(result.message || 'Failed to upload team');
      }
    } catch (err) {
      setError('Failed to upload team. Please try again.');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };
  
  const handlePasteExample = () => {
    setTeamText(`Defenders
Harry Sheezel
Jayden Short
Matt Roberts
Riley Bice
Jaxon Prior
Zach Reid
Defenders bench 
Finn O'Sullivan 
Connor Stone 

Midfielders 
Jordan Dawson 
Andrew Brayshaw 
Nick Daicos 
Connor Rozee
Zach Merrett
Clayton Oliver
Levi Ashcroft 
Xavier Lindsay
Midfielders bench 
Hugh Boxshall
Isaac Kako

Rucks 
Tristan Xerri
Tom De Koning 
Bench ruck
Harry Boyd

Forwards 
Isaac Rankine 
Christian Petracca
Bailey Smith 
Jack MacRae
Caleb Daniel
Sam Davidson 
Forward bench
Caiden Cleary
Campbell Gray

Bench utility 
James Leake`);
  };
  
  const loadTeamData = async () => {
    setLoading(true);
    setError(null);
    
    try {
      const response = await fetch('/api/team/data');
      const result = await response.json();
      
      if (result.status === 'ok') {
        setTeamData(result.data);
        setSuccess(true);
      } else {
        setError(result.message || 'Failed to load team data');
      }
    } catch (err) {
      setError('Failed to load team data. Please try again.');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };
  
  // Format position name for display
  const formatPosition = (pos: string) => {
    return pos.charAt(0).toUpperCase() + pos.slice(1);
  };
  
  // Render a player card with accurate data
  const renderPlayerCard = (player: any, isPremium = false) => (
    <div className={`p-2 border rounded-md mb-2 ${isPremium ? 'bg-blue-50' : ''}`}>
      <div className="flex justify-between">
        <span className="font-medium">{player.name}</span>
        {player.price && (
          <span className="text-sm text-gray-600">${(player.price / 1000).toFixed(0)}k</span>
        )}
      </div>
      {player.breakeven !== undefined && (
        <div className="flex justify-between mt-1">
          <span className="text-xs">BE: {player.breakeven}</span>
          {player.last3_avg && (
            <span className="text-xs">L3 Avg: {player.last3_avg}</span>
          )}
        </div>
      )}
    </div>
  );
  
  return (
    <div className="w-full max-w-4xl mx-auto p-4">
      <Card className="p-6 mb-8">
        <h2 className="text-xl font-bold mb-4">Upload Your Team</h2>
        <p className="text-sm text-gray-600 mb-4">
          Paste your team list and we'll match it with accurate data from Footywire and DFS Australia.
          This will enable all tools to work with your actual team data.
        </p>
        
        <div className="mb-4">
          <Textarea 
            placeholder="Paste your team list here..." 
            value={teamText} 
            onChange={(e) => setTeamText(e.target.value)} 
            className="min-h-[200px]"
          />
        </div>
        
        <div className="flex flex-wrap gap-2">
          <Button onClick={handleUpload} disabled={loading} className="bg-blue-600 hover:bg-blue-700">
            {loading ? (
              <>
                <RefreshCw className="mr-2 h-4 w-4 animate-spin" />
                Uploading...
              </>
            ) : (
              <>
                <Upload className="mr-2 h-4 w-4" />
                Upload Team
              </>
            )}
          </Button>
          
          <Button variant="outline" onClick={handlePasteExample}>
            Paste Example
          </Button>
          
          <Button variant="outline" onClick={loadTeamData}>
            Load Saved Team
          </Button>
        </div>
        
        {error && (
          <Alert variant="destructive" className="mt-4">
            <AlertCircle className="h-4 w-4" />
            <AlertTitle>Error</AlertTitle>
            <AlertDescription>
              {error}
            </AlertDescription>
          </Alert>
        )}
        
        {success && (
          <Alert className="mt-4 bg-green-50 border-green-200">
            <CheckCircle className="h-4 w-4 text-green-600" />
            <AlertTitle className="text-green-800">Success</AlertTitle>
            <AlertDescription className="text-green-700">
              Your team has been uploaded and matched with accurate data. All tools will now use your team data.
            </AlertDescription>
          </Alert>
        )}
      </Card>
      
      {teamData && (
        <Card className="p-6">
          <h2 className="text-xl font-bold mb-4">Your Team</h2>
          
          <Tabs defaultValue="defenders">
            <TabsList className="mb-4">
              <TabsTrigger value="defenders">Defenders</TabsTrigger>
              <TabsTrigger value="midfielders">Midfielders</TabsTrigger>
              <TabsTrigger value="rucks">Rucks</TabsTrigger>
              <TabsTrigger value="forwards">Forwards</TabsTrigger>
            </TabsList>
            
            {['defenders', 'midfielders', 'rucks', 'forwards'].map((position) => (
              <TabsContent key={position} value={position} className="space-y-4">
                <div>
                  <h3 className="text-lg font-semibold mb-2">
                    {formatPosition(position)}
                    <Badge className="ml-2 bg-blue-100 text-blue-800 hover:bg-blue-200">
                      {teamData[position]?.length || 0}
                    </Badge>
                  </h3>
                  
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
                    {teamData[position]?.map((player: any, idx: number) => (
                      <div key={idx}>
                        {renderPlayerCard(player, player.price && player.price > 800000)}
                      </div>
                    ))}
                  </div>
                </div>
                
                {teamData.bench && teamData.bench[position] && teamData.bench[position].length > 0 && (
                  <div className="mt-4">
                    <h3 className="text-lg font-semibold mb-2">
                      Bench {formatPosition(position)}
                      <Badge className="ml-2 bg-gray-100 text-gray-800 hover:bg-gray-200">
                        {teamData.bench[position]?.length || 0}
                      </Badge>
                    </h3>
                    
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
                      {teamData.bench[position]?.map((player: any, idx: number) => (
                        <div key={idx}>
                          {renderPlayerCard(player)}
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </TabsContent>
            ))}
          </Tabs>
          
          {teamData.bench && teamData.bench.utility && teamData.bench.utility.length > 0 && (
            <div className="mt-8">
              <h3 className="text-lg font-semibold mb-2">
                Utility
                <Badge className="ml-2 bg-gray-100 text-gray-800 hover:bg-gray-200">
                  {teamData.bench.utility?.length || 0}
                </Badge>
              </h3>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
                {teamData.bench.utility?.map((player: any, idx: number) => (
                  <div key={idx}>
                    {renderPlayerCard(player)}
                  </div>
                ))}
              </div>
            </div>
          )}
        </Card>
      )}
    </div>
  );
}