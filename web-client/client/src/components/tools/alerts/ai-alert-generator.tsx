import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Switch } from "@/components/ui/switch";
import { Label } from "@/components/ui/label";
import { PlayerAlert } from "./trade-alert";
import { Alert, AlertTitle, AlertDescription } from "@/components/ui/alert";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { 
  MegaphoneIcon, 
  BrainCircuit, 
  BellRing, 
  Clock, 
  AlertTriangle,
  Settings2, 
  Star, 
  TrendingUp 
} from "lucide-react";
import { useState } from "react";

// Types for alert preferences
type AlertPreferences = {
  priceAlerts: boolean;
  priceThreshold: number; // in percentage
  injuryAlerts: boolean;
  selectionAlerts: boolean;
  captainRecommendations: boolean;
  tradeRecommendations: boolean;
  favoritePlayerAlerts: boolean;
  scheduledReports: boolean;
  reportFrequency: "daily" | "weekly" | "matchDay";
  alertVia: "app" | "email" | "both";
};

// Demo favorite players
type FavoritePlayer = {
  id: number;
  name: string;
  team: string;
  position: string;
  added: Date;
};

// AI Alert Generator Component
export function AIAlertGenerator() {
  const [preferences, setPreferences] = useState<AlertPreferences>({
    priceAlerts: true,
    priceThreshold: 3.0, // 3% by default
    injuryAlerts: true,
    selectionAlerts: true,
    captainRecommendations: true,
    tradeRecommendations: true,
    favoritePlayerAlerts: true,
    scheduledReports: false,
    reportFrequency: "weekly",
    alertVia: "app",
  });
  
  const [favoritePlayers, setFavoritePlayers] = useState<FavoritePlayer[]>([
    { id: 1, name: "Marcus Bontempelli", team: "WB", position: "MID", added: new Date() },
    { id: 2, name: "Nick Daicos", team: "COLL", position: "MID", added: new Date() },
  ]);
  
  const [playerSearch, setPlayerSearch] = useState("");
  const [activeTab, setActiveTab] = useState("preferences");
  const [isConfigured, setIsConfigured] = useState(false);
  const [showConfigSuccess, setShowConfigSuccess] = useState(false);
  
  // Search results - would come from API in real app
  const searchResults = playerSearch.length > 0 
    ? [
        { id: 3, name: "Izak Rankine", team: "ADEL", position: "FWD" },
        { id: 4, name: "Errol Gulden", team: "SYD", position: "MID" },
        { id: 5, name: "Isaac Heeney", team: "SYD", position: "MID/FWD" },
      ]
    : [];
  
  // Handle adding a favorite player
  const handleAddFavorite = (player: { id: number; name: string; team: string; position: string }) => {
    if (!favoritePlayers.some(p => p.id === player.id)) {
      setFavoritePlayers([
        ...favoritePlayers,
        { ...player, added: new Date() }
      ]);
    }
    setPlayerSearch("");
  };
  
  // Handle removing a favorite player
  const handleRemoveFavorite = (id: number) => {
    setFavoritePlayers(favoritePlayers.filter(p => p.id !== id));
  };
  
  // Update preferences
  const handlePreferenceChange = (key: keyof AlertPreferences, value: any) => {
    setPreferences({
      ...preferences,
      [key]: value
    });
  };
  
  // Save configuration
  const handleSaveConfig = () => {
    setIsConfigured(true);
    setShowConfigSuccess(true);
    
    // Hide success message after a delay
    setTimeout(() => {
      setShowConfigSuccess(false);
    }, 3000);
    
    // In a real app, we would save to API/backend here
  };
  
  return (
    <div className="space-y-4">
      <div className="flex items-center gap-2 mb-2">
        <BrainCircuit className="h-5 w-5 text-purple-600" />
        <h3 className="text-lg font-medium">AI-Powered Alert Configuration</h3>
      </div>
      
      {showConfigSuccess && (
        <Alert className="bg-green-50 border-green-200 text-green-800">
          <AlertTitle>Configuration Saved</AlertTitle>
          <AlertDescription>
            Your alert preferences have been updated successfully.
          </AlertDescription>
        </Alert>
      )}
      
      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <TabsList className="w-full">
          <TabsTrigger value="preferences" className="flex-1">
            <Settings2 className="h-4 w-4 mr-2" />
            Alert Preferences
          </TabsTrigger>
          <TabsTrigger value="favorites" className="flex-1">
            <Star className="h-4 w-4 mr-2" />
            Favorite Players
          </TabsTrigger>
          <TabsTrigger value="preview" className="flex-1">
            <BellRing className="h-4 w-4 mr-2" />
            Alert Preview
          </TabsTrigger>
        </TabsList>
        
        {/* Preferences Tab */}
        <TabsContent value="preferences" className="pt-4">
          <div className="space-y-4">
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-base flex items-center">
                  <TrendingUp className="h-4 w-4 mr-2 text-green-600" />
                  Price & Value Alerts
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <Label htmlFor="price-alerts" className="flex-1">
                      Enable price change alerts
                    </Label>
                    <Switch
                      id="price-alerts"
                      checked={preferences.priceAlerts}
                      onCheckedChange={(checked) => 
                        handlePreferenceChange("priceAlerts", checked)
                      }
                    />
                  </div>
                  
                  {preferences.priceAlerts && (
                    <div className="pl-1">
                      <Label htmlFor="price-threshold" className="text-sm text-gray-600 mb-1 block">
                        Alert me when price changes by at least:
                      </Label>
                      <div className="flex items-center gap-2">
                        <Input
                          id="price-threshold"
                          type="number"
                          value={preferences.priceThreshold}
                          onChange={(e) => 
                            handlePreferenceChange("priceThreshold", parseFloat(e.target.value))
                          }
                          className="w-20"
                          min={0}
                          step={0.5}
                        />
                        <span className="text-sm">%</span>
                      </div>
                    </div>
                  )}
                </div>
              </CardContent>
            </Card>
            
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-base flex items-center">
                  <AlertTriangle className="h-4 w-4 mr-2 text-amber-500" />
                  Team Status Alerts
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <Label htmlFor="injury-alerts" className="flex-1">
                      Player injury alerts
                    </Label>
                    <Switch
                      id="injury-alerts"
                      checked={preferences.injuryAlerts}
                      onCheckedChange={(checked) => 
                        handlePreferenceChange("injuryAlerts", checked)
                      }
                    />
                  </div>
                  
                  <div className="flex items-center justify-between">
                    <Label htmlFor="selection-alerts" className="flex-1">
                      Team selection changes
                    </Label>
                    <Switch
                      id="selection-alerts"
                      checked={preferences.selectionAlerts}
                      onCheckedChange={(checked) => 
                        handlePreferenceChange("selectionAlerts", checked)
                      }
                    />
                  </div>
                </div>
              </CardContent>
            </Card>
            
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-base flex items-center">
                  <BrainCircuit className="h-4 w-4 mr-2 text-purple-600" />
                  AI Recommendations
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <Label htmlFor="captain-recs" className="flex-1">
                      Captain recommendations
                    </Label>
                    <Switch
                      id="captain-recs"
                      checked={preferences.captainRecommendations}
                      onCheckedChange={(checked) => 
                        handlePreferenceChange("captainRecommendations", checked)
                      }
                    />
                  </div>
                  
                  <div className="flex items-center justify-between">
                    <Label htmlFor="trade-recs" className="flex-1">
                      Trade recommendations
                    </Label>
                    <Switch
                      id="trade-recs"
                      checked={preferences.tradeRecommendations}
                      onCheckedChange={(checked) => 
                        handlePreferenceChange("tradeRecommendations", checked)
                      }
                    />
                  </div>
                  
                  <div className="flex items-center justify-between">
                    <Label htmlFor="favorite-alerts" className="flex-1">
                      Favorite player alerts
                    </Label>
                    <Switch
                      id="favorite-alerts"
                      checked={preferences.favoritePlayerAlerts}
                      onCheckedChange={(checked) => 
                        handlePreferenceChange("favoritePlayerAlerts", checked)
                      }
                    />
                  </div>
                </div>
              </CardContent>
            </Card>
            
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-base flex items-center">
                  <Clock className="h-4 w-4 mr-2 text-blue-600" />
                  Scheduled Reports
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <Label htmlFor="scheduled-reports" className="flex-1">
                      Enable scheduled reports
                    </Label>
                    <Switch
                      id="scheduled-reports"
                      checked={preferences.scheduledReports}
                      onCheckedChange={(checked) => 
                        handlePreferenceChange("scheduledReports", checked)
                      }
                    />
                  </div>
                  
                  {preferences.scheduledReports && (
                    <div className="pl-1 space-y-2">
                      <Label className="text-sm text-gray-600 mb-1 block">
                        Report frequency:
                      </Label>
                      <div className="flex space-x-2">
                        <Button
                          variant={preferences.reportFrequency === "daily" ? "default" : "outline"}
                          size="sm"
                          onClick={() => handlePreferenceChange("reportFrequency", "daily")}
                          className="text-xs px-3"
                        >
                          Daily
                        </Button>
                        <Button
                          variant={preferences.reportFrequency === "weekly" ? "default" : "outline"}
                          size="sm"
                          onClick={() => handlePreferenceChange("reportFrequency", "weekly")}
                          className="text-xs px-3"
                        >
                          Weekly
                        </Button>
                        <Button
                          variant={preferences.reportFrequency === "matchDay" ? "default" : "outline"}
                          size="sm"
                          onClick={() => handlePreferenceChange("reportFrequency", "matchDay")}
                          className="text-xs px-3"
                        >
                          Match Days Only
                        </Button>
                      </div>
                    </div>
                  )}
                </div>
              </CardContent>
            </Card>
            
            <div className="flex justify-end">
              <Button onClick={handleSaveConfig}>
                Save Preferences
              </Button>
            </div>
          </div>
        </TabsContent>
        
        {/* Favorites Tab */}
        <TabsContent value="favorites" className="pt-4">
          <div className="space-y-4">
            <div className="relative">
              <Input
                placeholder="Search for players to add..."
                value={playerSearch}
                onChange={(e) => setPlayerSearch(e.target.value)}
                className="w-full"
              />
              
              {playerSearch.length > 0 && searchResults.length > 0 && (
                <div className="absolute z-10 mt-1 w-full rounded-md bg-white shadow-lg border">
                  <ul className="max-h-60 overflow-auto py-1">
                    {searchResults.map(player => (
                      <li 
                        key={player.id}
                        className="px-3 py-2 hover:bg-gray-100 cursor-pointer flex justify-between items-center"
                        onClick={() => handleAddFavorite(player)}
                      >
                        <div>
                          <div className="font-medium text-sm">{player.name}</div>
                          <div className="text-xs text-gray-500">{player.position} | {player.team}</div>
                        </div>
                        <Button size="sm" variant="ghost" className="h-7 text-xs">
                          Add
                        </Button>
                      </li>
                    ))}
                  </ul>
                </div>
              )}
            </div>
            
            <div className="border rounded-md overflow-hidden">
              <div className="bg-gray-50 px-4 py-2 font-medium text-sm">
                Your Favorite Players
              </div>
              
              {favoritePlayers.length === 0 ? (
                <div className="py-6 text-center text-gray-500">
                  <p className="text-sm">No favorite players added yet</p>
                  <p className="text-xs mt-1">Search above to add players</p>
                </div>
              ) : (
                <ul className="divide-y">
                  {favoritePlayers.map(player => (
                    <li 
                      key={player.id}
                      className="px-4 py-3 flex justify-between items-center"
                    >
                      <div>
                        <div className="font-medium">{player.name}</div>
                        <div className="text-xs text-gray-500">{player.position} | {player.team}</div>
                      </div>
                      <Button 
                        variant="ghost" 
                        size="sm" 
                        className="h-8 text-red-600 hover:text-red-700 hover:bg-red-50"
                        onClick={() => handleRemoveFavorite(player.id)}
                      >
                        Remove
                      </Button>
                    </li>
                  ))}
                </ul>
              )}
            </div>
            
            <Alert>
              <MegaphoneIcon className="h-4 w-4" />
              <AlertTitle>Pro Tip</AlertTitle>
              <AlertDescription>
                Add your favorite players to receive alerts about significant price changes, 
                injuries, and exceptional performances directly to your alert center.
              </AlertDescription>
            </Alert>
            
            <div className="flex justify-end">
              <Button onClick={() => {
                handleSaveConfig();
                setActiveTab("preview");
              }}>
                Save & Continue
              </Button>
            </div>
          </div>
        </TabsContent>
        
        {/* Preview Tab */}
        <TabsContent value="preview" className="pt-4">
          <div className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-base flex items-center">
                  <BellRing className="h-4 w-4 mr-2 text-blue-600" />
                  Alert Preview
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  {isConfigured ? (
                    <div className="space-y-4">
                      <p className="text-sm">
                        You'll receive the following types of alerts based on your preferences:
                      </p>
                      
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                        {preferences.priceAlerts && (
                          <div className="flex items-start gap-2 bg-gray-50 p-3 rounded-md">
                            <TrendingUp className="h-4 w-4 text-green-600 mt-0.5" />
                            <div>
                              <div className="text-sm font-medium">Price Change Alerts</div>
                              <div className="text-xs text-gray-600">
                                Threshold: {preferences.priceThreshold}%
                              </div>
                            </div>
                          </div>
                        )}
                        
                        {preferences.injuryAlerts && (
                          <div className="flex items-start gap-2 bg-gray-50 p-3 rounded-md">
                            <AlertTriangle className="h-4 w-4 text-red-600 mt-0.5" />
                            <div>
                              <div className="text-sm font-medium">Injury Alerts</div>
                              <div className="text-xs text-gray-600">
                                Notifies when players in your team get injured
                              </div>
                            </div>
                          </div>
                        )}
                        
                        {preferences.selectionAlerts && (
                          <div className="flex items-start gap-2 bg-gray-50 p-3 rounded-md">
                            <AlertTriangle className="h-4 w-4 text-amber-500 mt-0.5" />
                            <div>
                              <div className="text-sm font-medium">Selection Changes</div>
                              <div className="text-xs text-gray-600">
                                Alerts when players are dropped or change positions
                              </div>
                            </div>
                          </div>
                        )}
                        
                        {preferences.captainRecommendations && (
                          <div className="flex items-start gap-2 bg-gray-50 p-3 rounded-md">
                            <Star className="h-4 w-4 text-yellow-500 mt-0.5" />
                            <div>
                              <div className="text-sm font-medium">Captain Recommendations</div>
                              <div className="text-xs text-gray-600">
                                AI-driven suggestions for optimal captains each round
                              </div>
                            </div>
                          </div>
                        )}
                        
                        {preferences.tradeRecommendations && (
                          <div className="flex items-start gap-2 bg-gray-50 p-3 rounded-md">
                            <BrainCircuit className="h-4 w-4 text-purple-600 mt-0.5" />
                            <div>
                              <div className="text-sm font-medium">Trade Recommendations</div>
                              <div className="text-xs text-gray-600">
                                Strategic trade suggestions based on form and fixtures
                              </div>
                            </div>
                          </div>
                        )}
                        
                        {preferences.favoritePlayerAlerts && (
                          <div className="flex items-start gap-2 bg-gray-50 p-3 rounded-md">
                            <Star className="h-4 w-4 text-pink-600 mt-0.5" />
                            <div>
                              <div className="text-sm font-medium">Favorite Player Alerts</div>
                              <div className="text-xs text-gray-600">
                                Updates on your {favoritePlayers.length} favorite players
                              </div>
                            </div>
                          </div>
                        )}
                      </div>
                      
                      <div className="text-center">
                        <Button 
                          variant="outline" 
                          className="mt-4"
                          onClick={() => setActiveTab("preferences")}
                        >
                          <Settings2 className="h-4 w-4 mr-2" />
                          Update Preferences
                        </Button>
                      </div>
                    </div>
                  ) : (
                    <div className="text-center py-6">
                      <AlertTriangle className="h-10 w-10 text-amber-500 mx-auto mb-3 opacity-70" />
                      <p className="text-lg font-semibold">No Configuration Found</p>
                      <p className="text-sm text-gray-600 mt-1">
                        Please set up your alert preferences first
                      </p>
                      <Button 
                        className="mt-4"
                        onClick={() => setActiveTab("preferences")}
                      >
                        <Settings2 className="h-4 w-4 mr-2" />
                        Configure Alerts
                      </Button>
                    </div>
                  )}
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>
      </Tabs>
    </div>
  );
}