import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Search, Globe, Code2, Key, Copy, CheckCircle } from "lucide-react";
import { toast } from "@/hooks/use-toast";

export function ApiFinder() {
  const [copiedUrl, setCopiedUrl] = useState<string | null>(null);

  const handleCopy = (text: string) => {
    navigator.clipboard.writeText(text);
    setCopiedUrl(text);
    toast({
      title: "Copied to clipboard",
      description: "API endpoint copied successfully",
    });
    setTimeout(() => setCopiedUrl(null), 2000);
  };

  const knownAflApis = [
    {
      name: "AFL Tables",
      baseUrl: "https://afltables.com/afl/stats/",
      endpoints: [
        { path: "players.html", description: "Player statistics" },
        { path: "teams/", description: "Team statistics" },
      ],
      auth: false,
    },
    {
      name: "Footywire", 
      baseUrl: "https://www.footywire.com/afl/footy/",
      endpoints: [
        { path: "ft_player_rankings", description: "Player rankings and stats" },
        { path: "dream_team_breakevens", description: "Player breakevens" },
      ],
      auth: false,
    },
    {
      name: "AFL Official (Likely)",
      baseUrl: "https://api.afl.com.au/",
      endpoints: [
        { path: "cfs/afl/playerProfile/", description: "Player profiles" },
        { path: "cfs/afl/matchRoster/", description: "Match data" },
      ],
      auth: true,
    }
  ];

  return (
    <div className="w-full max-w-4xl mx-auto space-y-6">
      <Card className="bg-gray-800 border-gray-700">
        <CardHeader>
          <CardTitle className="flex items-center gap-2 text-white">
            <Search className="h-5 w-5 text-cyan-400" />
            API Finder Guide
          </CardTitle>
          <CardDescription className="text-gray-400">
            Learn how to discover hidden APIs on any website
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Tabs defaultValue="browser" className="w-full">
            <TabsList className="grid w-full grid-cols-3 bg-gray-700">
              <TabsTrigger value="browser">Browser Method</TabsTrigger>
              <TabsTrigger value="patterns">URL Patterns</TabsTrigger>
              <TabsTrigger value="known">Known APIs</TabsTrigger>
            </TabsList>

            <TabsContent value="browser" className="space-y-4 mt-6">
              <div className="space-y-4">
                <h3 className="text-lg font-semibold text-white">Find APIs Using Browser DevTools</h3>
                
                <div className="space-y-3">
                  <div className="flex gap-2">
                    <Badge className="bg-cyan-600">Step 1</Badge>
                    <p className="text-gray-300">Open AFL Fantasy website in your browser</p>
                  </div>
                  
                  <div className="flex gap-2">
                    <Badge className="bg-cyan-600">Step 2</Badge>
                    <p className="text-gray-300">Press F12 to open Developer Tools</p>
                  </div>
                  
                  <div className="flex gap-2">
                    <Badge className="bg-cyan-600">Step 3</Badge>
                    <p className="text-gray-300">Click the "Network" tab</p>
                  </div>
                  
                  <div className="flex gap-2">
                    <Badge className="bg-cyan-600">Step 4</Badge>
                    <p className="text-gray-300">Filter by "XHR" or "Fetch"</p>
                  </div>
                  
                  <div className="flex gap-2">
                    <Badge className="bg-cyan-600">Step 5</Badge>
                    <p className="text-gray-300">Refresh the page or navigate around</p>
                  </div>
                  
                  <div className="flex gap-2">
                    <Badge className="bg-cyan-600">Step 6</Badge>
                    <p className="text-gray-300">Look for requests returning JSON data</p>
                  </div>
                </div>

                <div className="bg-gray-900 p-4 rounded-lg mt-6">
                  <h4 className="text-white font-medium mb-2">What to Look For:</h4>
                  <ul className="space-y-2 text-gray-300 text-sm">
                    <li>• URLs containing: /api/, /data/, /json/</li>
                    <li>• Responses with Content-Type: application/json</li>
                    <li>• GET requests that return player/team data</li>
                    <li>• POST requests for authentication</li>
                  </ul>
                </div>
              </div>
            </TabsContent>

            <TabsContent value="patterns" className="space-y-4 mt-6">
              <div className="space-y-4">
                <h3 className="text-lg font-semibold text-white">Common API URL Patterns</h3>
                
                <div className="grid gap-3">
                  {[
                    "/api/v1/players",
                    "/api/v2/teams", 
                    "/data/fixtures.json",
                    "/rest/players/all",
                    "/_api/stats",
                    "/graphql",
                    "/query?type=players",
                    "api.sitename.com/players"
                  ].map((pattern) => (
                    <div key={pattern} className="flex items-center justify-between bg-gray-900 p-3 rounded">
                      <code className="text-cyan-400">{pattern}</code>
                      <Button
                        size="sm"
                        variant="ghost"
                        onClick={() => handleCopy(pattern)}
                        className="text-gray-400 hover:text-white"
                      >
                        {copiedUrl === pattern ? <CheckCircle className="h-4 w-4" /> : <Copy className="h-4 w-4" />}
                      </Button>
                    </div>
                  ))}
                </div>

                <div className="bg-blue-900/20 border border-blue-600 p-4 rounded-lg mt-4">
                  <h4 className="text-blue-400 font-medium mb-2">Pro Tip:</h4>
                  <p className="text-gray-300 text-sm">
                    Try adding these patterns to the website's base URL. For example:
                    https://fantasy.afl.com.au/api/players
                  </p>
                </div>
              </div>
            </TabsContent>

            <TabsContent value="known" className="space-y-4 mt-6">
              <div className="space-y-4">
                <h3 className="text-lg font-semibold text-white">Known AFL Data Sources</h3>
                
                {knownAflApis.map((api) => (
                  <Card key={api.name} className="bg-gray-900 border-gray-700">
                    <CardHeader className="pb-3">
                      <div className="flex items-center justify-between">
                        <CardTitle className="text-lg text-white flex items-center gap-2">
                          <Globe className="h-4 w-4 text-cyan-400" />
                          {api.name}
                        </CardTitle>
                        {api.auth && (
                          <Badge variant="outline" className="border-yellow-600 text-yellow-400">
                            <Key className="h-3 w-3 mr-1" />
                            Auth Required
                          </Badge>
                        )}
                      </div>
                    </CardHeader>
                    <CardContent className="space-y-2">
                      <div className="flex items-center gap-2 text-sm text-gray-400">
                        <Code2 className="h-3 w-3" />
                        <code>{api.baseUrl}</code>
                      </div>
                      <div className="space-y-1 mt-3">
                        {api.endpoints.map((endpoint) => (
                          <div key={endpoint.path} className="flex items-center justify-between py-1">
                            <div>
                              <code className="text-cyan-400 text-sm">{endpoint.path}</code>
                              <p className="text-xs text-gray-400">{endpoint.description}</p>
                            </div>
                            <Button
                              size="sm"
                              variant="ghost"
                              onClick={() => handleCopy(api.baseUrl + endpoint.path)}
                              className="text-gray-400 hover:text-white"
                            >
                              <Copy className="h-3 w-3" />
                            </Button>
                          </div>
                        ))}
                      </div>
                    </CardContent>
                  </Card>
                ))}
              </div>
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>
    </div>
  );
}