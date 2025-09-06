import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { ChevronDown, ChevronUp, Activity, Zap, Brain, TrendingUp, Award, DollarSign, AlertCircle, BarChart4 } from "lucide-react";
import { useState } from "react";
import { formatCurrency, formatScore } from "@/lib/utils";

type TeamPlayer = {
  id: number;
  name: string;
  position: string;
  isCaptain?: boolean;
  price?: number;
  breakEven?: number;
  lastScore?: number;
  averagePoints?: number;
  liveScore?: number;
  secondaryPositions?: string[];
  isOnBench?: boolean;
  team?: string;  // AFL team like 'HAW', 'COL', etc.
};

// Match the same structure as the screenshots
const LINE_POSITIONS = {
  DEFENDER: {color: "#e63946", bgColor: "#ffd7db", shortCode: "D", title: "Defenders", fieldCount: 6, benchCount: 2},
  MIDFIELDER: {color: "#457b9d", bgColor: "#d7e3ff", shortCode: "M", title: "Midfielders", fieldCount: 8, benchCount: 2},
  RUCK: {color: "#6a0dad", bgColor: "#e7d7ff", shortCode: "R", title: "Rucks", fieldCount: 2, benchCount: 1},
  FORWARD: {color: "#2a9d8f", bgColor: "#d7fff0", shortCode: "F", title: "Forwards", fieldCount: 6, benchCount: 2},
  UTILITY: {color: "#e9c46a", bgColor: "#fff8d7", shortCode: "U", title: "Utility", fieldCount: 0, benchCount: 1},
};

type SinglePlayerDisplayProps = {
  player: TeamPlayer;
  position: keyof typeof LINE_POSITIONS;
  showScore?: boolean;
  showDetails?: boolean;
};

const SinglePlayerDisplay = ({ player, position, showScore = true, showDetails = true }: SinglePlayerDisplayProps) => {
  if (!player) return null;
  
  const posConfig = LINE_POSITIONS[position];
  const isBench = player.isOnBench;
  
  return (
    <div className={`flex items-center justify-between p-2 ${isBench ? 'bg-gray-50' : `bg-white border-l-4 border-${posConfig.color.replace('#', '')}`} rounded-md mb-1 shadow-sm`}>
      <div className="flex items-center gap-2">
        {player.team && (
          <div className="h-8 w-8 rounded-full flex items-center justify-center text-xs font-bold" 
               style={{ backgroundColor: posConfig.bgColor, color: posConfig.color }}>
            {player.team?.substring(0, 2)}
          </div>
        )}
        <div className="flex flex-col">
          <div className="flex items-center gap-1">
            <span className="font-medium text-sm truncate max-w-[120px]">{player.name || 'Empty'}</span>
            {player.isCaptain && <span className="text-xs px-1 bg-yellow-500 text-white rounded">C</span>}
            {player.secondaryPositions && player.secondaryPositions.length > 0 && (
              <span className="text-xs px-1 bg-gray-100 text-gray-600 rounded">DPP</span>
            )}
          </div>
          {showDetails && (
            <div className="flex text-xs text-gray-500 gap-1">
              <span className={`px-1 rounded text-white`} style={{ backgroundColor: posConfig.color }}>{posConfig.shortCode}</span>
              {player.secondaryPositions?.map(pos => (
                <span key={pos} className="px-1 rounded bg-gray-200">{pos}</span>
              ))}
            </div>
          )}
        </div>
      </div>
      
      {showScore && (
        <div className="flex flex-col items-end">
          <div className="text-lg font-bold">{player.liveScore || player.lastScore || '-'}</div>
          <div className="text-xs text-gray-500">
            BE: <span className={player.breakEven && player.breakEven < 0 ? 'text-red-500' : ''}>
              {player.breakEven || '-'}
            </span>
          </div>
        </div>
      )}
    </div>
  );
};

type PositionGroupProps = {
  position: keyof typeof LINE_POSITIONS;
  players: TeamPlayer[];
  showScores?: boolean;
};

const PositionGroup = ({ position, players, showScores = true }: PositionGroupProps) => {
  const [expanded, setExpanded] = useState(true);
  const posConfig = LINE_POSITIONS[position];
  
  // Filter field and bench players
  const fieldPlayers = players.filter(p => !p.isOnBench).slice(0, posConfig.fieldCount);
  const benchPlayers = players.filter(p => p.isOnBench || players.indexOf(p) >= posConfig.fieldCount).slice(0, posConfig.benchCount);
  
  // Fill with empty players if needed
  while (fieldPlayers.length < posConfig.fieldCount) {
    fieldPlayers.push({
      id: -fieldPlayers.length - 1,
      name: "Empty",
      position: posConfig.shortCode,
      isOnBench: false
    });
  }
  
  while (benchPlayers.length < posConfig.benchCount) {
    benchPlayers.push({
      id: -benchPlayers.length - 100,
      name: "Empty",
      position: posConfig.shortCode,
      isOnBench: true
    });
  }
  
  return (
    <div className="mb-4">
      <div 
        className="flex items-center justify-between p-2 rounded-md cursor-pointer"
        style={{ backgroundColor: posConfig.bgColor }}
        onClick={() => setExpanded(!expanded)}
      >
        <h3 className="flex items-center gap-2 font-bold" style={{ color: posConfig.color }}>
          {posConfig.title}
        </h3>
        {expanded ? <ChevronUp className="h-4 w-4" /> : <ChevronDown className="h-4 w-4" />}
      </div>
      
      {expanded && (
        <div className="mt-2">
          <div className="grid grid-cols-1 gap-1">
            {fieldPlayers.map((player, index) => (
              <SinglePlayerDisplay 
                key={`field-${position}-${player.id || index}`}
                player={player}
                position={position}
                showScore={showScores}
              />
            ))}
          </div>
          
          {benchPlayers.length > 0 && (
            <div className="mt-3">
              <div className="p-1 px-2 text-sm font-medium text-gray-600 bg-gray-100 rounded-md">
                Bench
              </div>
              <div className="mt-1 grid grid-cols-1 gap-1">
                {benchPlayers.map((player, index) => (
                  <SinglePlayerDisplay 
                    key={`bench-${position}-${player.id || index}`}
                    player={player}
                    position={position}
                    showScore={showScores}
                  />
                ))}
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  );
};

type DetailedTablesViewProps = {
  midfielders: TeamPlayer[];
  forwards: TeamPlayer[];
  defenders: TeamPlayer[];
  rucks: TeamPlayer[];
  utility?: TeamPlayer[];
};

// The more detailed table view similar to other screens with columns
const DetailedTablesView = ({ midfielders, forwards, defenders, rucks, utility = [] }: DetailedTablesViewProps) => {
  const positions = [
    { key: "defenders", title: "Defenders", shortCode: "D", color: "#e63946", players: defenders },
    { key: "midfielders", title: "Midfielders", shortCode: "M", color: "#457b9d", players: midfielders },
    { key: "rucks", title: "Rucks", shortCode: "R", color: "#6a0dad", players: rucks },
    { key: "forwards", title: "Forwards", shortCode: "F", color: "#2a9d8f", players: forwards },
  ];
  
  return (
    <div className="space-y-4">
      {positions.map(position => (
        <div key={position.key} className="overflow-hidden rounded-md border">
          <div className="px-3 py-2 font-bold text-white" style={{ backgroundColor: position.color }}>
            {position.title}
          </div>
          <div className="p-0">
            <div className="text-xs border-b border-gray-200 py-1 grid grid-cols-12 gap-1 px-2">
              <div className="col-span-3 font-medium">Player</div>
              <div className="col-span-1 text-center font-medium">Pos</div>
              <div className="col-span-2 text-right font-medium">Price</div>
              <div className="col-span-1 text-center font-medium">BE</div>
              <div className="col-span-1 text-center font-medium">Avg</div>
              <div className="col-span-1 text-center font-medium">Last</div>
              <div className="col-span-1 text-center font-medium">Live</div>
              <div className="col-span-2 text-center font-medium">DPP</div>
            </div>
            
            <div className="divide-y divide-gray-100">
              {position.players.map((player, idx) => (
                <div 
                  key={`${position.key}-${player.id || idx}`} 
                  className={`text-sm grid grid-cols-12 gap-1 items-center py-1 px-2 ${idx % 2 === 0 ? 'bg-gray-50' : 'bg-white'}`}
                >
                  <div className="col-span-3 flex items-center gap-1 truncate">
                    {player.isCaptain && (
                      <span className="px-1 text-xs bg-yellow-500 text-white rounded-sm">C</span>
                    )}
                    <span className="truncate">{player.name}</span>
                  </div>
                  <div className="col-span-1 text-center text-xs">
                    <span className="inline-block px-1 rounded-sm text-white" style={{ backgroundColor: position.color }}>
                      {position.shortCode}
                    </span>
                  </div>
                  <div className="col-span-2 text-right text-xs">{formatCurrency(player.price || 0)}</div>
                  <div className={`col-span-1 text-center text-xs ${(player.breakEven || 0) < 0 ? 'text-red-500' : ''}`}>
                    {player.breakEven || 0}
                  </div>
                  <div className="col-span-1 text-center text-xs">{player.averagePoints?.toFixed(1) || '-'}</div>
                  <div className="col-span-1 text-center text-xs">{formatScore(player.lastScore)}</div>
                  <div className="col-span-1 text-center text-xs font-medium">
                    {player.liveScore || '-'}
                  </div>
                  <div className="col-span-2 text-center text-xs">
                    {player.secondaryPositions?.map(pos => (
                      <span key={pos} className="mx-0.5 px-1 bg-gray-100 rounded-sm">{pos}</span>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      ))}
      
      {utility && utility.length > 0 && (
        <div className="overflow-hidden rounded-md border">
          <div className="px-3 py-2 font-bold text-white bg-yellow-500">
            Utility
          </div>
          <div className="divide-y divide-gray-100">
            {utility.map((player, idx) => (
              <div 
                key={`utility-${player.id || idx}`} 
                className={`text-sm grid grid-cols-12 gap-1 items-center py-1 px-2 ${idx % 2 === 0 ? 'bg-gray-50' : 'bg-white'}`}
              >
                <div className="col-span-3 flex items-center gap-1 truncate">
                  {player.isCaptain && (
                    <span className="px-1 text-xs bg-yellow-500 text-white rounded-sm">C</span>
                  )}
                  <span className="truncate">{player.name}</span>
                </div>
                <div className="col-span-1 text-center text-xs">
                  <span className="inline-block px-1 rounded-sm bg-yellow-500 text-white">
                    U
                  </span>
                </div>
                <div className="col-span-2 text-right text-xs">{formatCurrency(player.price || 0)}</div>
                <div className={`col-span-1 text-center text-xs ${(player.breakEven || 0) < 0 ? 'text-red-500' : ''}`}>
                  {player.breakEven || 0}
                </div>
                <div className="col-span-1 text-center text-xs">{player.averagePoints?.toFixed(1) || '-'}</div>
                <div className="col-span-1 text-center text-xs">{formatScore(player.lastScore)}</div>
                <div className="col-span-1 text-center text-xs font-medium">
                  {player.liveScore || '-'}
                </div>
                <div className="col-span-2 text-center text-xs">
                  {player.secondaryPositions?.map(pos => (
                    <span key={pos} className="mx-0.5 px-1 bg-gray-100 rounded-sm">{pos}</span>
                  ))}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

// This is for the dropdown tools menu items
type ToolItem = {
  id: string;
  name: string;
  icon: React.ReactNode;
  description: string;
};

// Group the tools by categories
const toolGroups = {
  trade: [
    { id: 'trade_optimizer', name: 'Trade Optimizer', icon: <TrendingUp className="h-4 w-4" />, description: 'Find optimal trade combinations for your team' },
    { id: 'trade_analyzer', name: 'Trade Impact Analyzer', icon: <Activity className="h-4 w-4" />, description: 'Analyze potential score impact from trades' },
    { id: 'value_tracker', name: 'Value Gain Tracker', icon: <DollarSign className="h-4 w-4" />, description: 'Track projected price changes and value gains' },
  ],
  captain: [
    { id: 'captain_analyzer', name: 'Captain Match Analysis', icon: <Award className="h-4 w-4" />, description: 'Find best captain based on matchup data' },
    { id: 'captain_projector', name: 'Captain Score Projector', icon: <BarChart4 className="h-4 w-4" />, description: 'Project captain scores based on past performance' },
    { id: 'captain_history', name: 'Captain History', icon: <Activity className="h-4 w-4" />, description: 'View historical captain performance' },
  ],
  ai: [
    { id: 'team_analyzer', name: 'Team Analyzer', icon: <Zap className="h-4 w-4" />, description: 'Get AI analysis of team structure and balance' },
    { id: 'trade_assistant', name: 'Trade Assistant', icon: <Brain className="h-4 w-4" />, description: 'AI recommendations for trades' },
    { id: 'injury_monitor', name: 'Injury Risk Monitor', icon: <AlertCircle className="h-4 w-4" />, description: 'Monitor injury risks in your team' },
  ],
};

// Dashboard-style summary stats
type TeamStatsSummaryProps = {
  trades: number;
  salary: number;
  liveScore: number;
  projectedScore: number;
};

const TeamStatsSummary = ({ trades, salary, liveScore, projectedScore }: TeamStatsSummaryProps) => (
  <div className="grid grid-cols-4 gap-2 mb-4">
    <div className="bg-white rounded-md p-3 shadow-sm">
      <div className="text-xs text-gray-500">Live Score</div>
      <div className="text-2xl font-bold">{liveScore}</div>
    </div>
    <div className="bg-white rounded-md p-3 shadow-sm">
      <div className="text-xs text-gray-500">Salary Left</div>
      <div className="text-2xl font-bold">{formatCurrency(salary)}</div>
    </div>
    <div className="bg-white rounded-md p-3 shadow-sm">
      <div className="text-xs text-gray-500">Trades</div>
      <div className="text-2xl font-bold">{trades}</div>
    </div>
    <div className="bg-white rounded-md p-3 shadow-sm">
      <div className="text-xs text-gray-500">Proj. Score</div>
      <div className="text-2xl font-bold">{projectedScore}</div>
    </div>
  </div>
);

type TeamSummaryProps = {
  midfielders: TeamPlayer[];
  forwards: TeamPlayer[];
  defenders: TeamPlayer[];
  rucks: TeamPlayer[];
  tradesAvailable: number;
  onMakeTrade: () => void;
};

export default function TeamSummary({
  midfielders,
  forwards,
  defenders,
  rucks,
  tradesAvailable,
  onMakeTrade
}: TeamSummaryProps) {
  const [viewMode, setViewMode] = useState<"field" | "list">("field");
  const [currentToolCategory, setCurrentToolCategory] = useState<"trade" | "captain" | "ai" | null>(null);
  const [activeTool, setActiveTool] = useState<string | null>(null);
  
  // Compute total salary 
  const totalSalary = [...midfielders, ...forwards, ...defenders, ...rucks]
    .reduce((sum, player) => sum + (player.price || 0), 0);
  
  // Simulate some free salary for display (1.5M total)
  const salaryCap = 15000000;
  const salaryRemaining = salaryCap - totalSalary;
  
  // Get live scores
  const liveScore = [...midfielders, ...forwards, ...defenders, ...rucks]
    .reduce((sum, player) => sum + (player.liveScore || 0), 0);
  
  // Get projected scores
  const projectedScore = Math.floor(liveScore * 1.05); // Just for demo
  
  // Ensure we have necessary players for utility
  const allPlayers = [...midfielders, ...forwards, ...defenders, ...rucks];
  
  // Get one player for utility (not used in other positions)
  const posConfig = LINE_POSITIONS;
  const usedPlayers = [
    ...midfielders.slice(0, posConfig.MIDFIELDER.fieldCount + posConfig.MIDFIELDER.benchCount),
    ...defenders.slice(0, posConfig.DEFENDER.fieldCount + posConfig.DEFENDER.benchCount),
    ...forwards.slice(0, posConfig.FORWARD.fieldCount + posConfig.FORWARD.benchCount),
    ...rucks.slice(0, posConfig.RUCK.fieldCount + posConfig.RUCK.benchCount)
  ];
  
  const utilityPlayer = allPlayers.find(p => !usedPlayers.some(up => up.id === p.id)) || {
    id: -999,
    name: "Empty Utility",
    position: "U",
    isOnBench: true
  };
  
  // Handle tool selection
  const handleSelectTool = (category: "trade" | "captain" | "ai", toolId: string) => {
    setActiveTool(toolId);
  };
  
  return (
    <div className="space-y-4">
      {/* Team Stats Summary */}
      <TeamStatsSummary 
        trades={tradesAvailable}
        salary={salaryRemaining}
        liveScore={liveScore}
        projectedScore={projectedScore}
      />
      
      {/* Tool Selector */}
      <div className="grid grid-cols-1 gap-2">
        {/* Trade Tools Dropdown */}
        <div className="rounded-md overflow-hidden border border-gray-200">
          <div 
            className="flex justify-between items-center px-3 py-2 bg-blue-50 cursor-pointer"
            onClick={() => setCurrentToolCategory(currentToolCategory === "trade" ? null : "trade")}
          >
            <div className="flex items-center gap-2">
              <TrendingUp className="h-5 w-5 text-blue-600" />
              <span className="font-bold text-blue-700">Trade Tools</span>
            </div>
            {currentToolCategory === "trade" ? 
              <ChevronUp className="h-4 w-4 text-blue-700" /> : 
              <ChevronDown className="h-4 w-4 text-blue-700" />
            }
          </div>
          
          {currentToolCategory === "trade" && (
            <div className="p-2 bg-white">
              <div className="grid gap-1">
                {toolGroups.trade.map(tool => (
                  <div 
                    key={tool.id}
                    className={`p-2 rounded-md cursor-pointer ${activeTool === tool.id ? 'bg-blue-50 border border-blue-200' : 'hover:bg-gray-50'}`}
                    onClick={() => handleSelectTool("trade", tool.id)}
                  >
                    <div className="flex items-center gap-2">
                      <div className="text-blue-600">{tool.icon}</div>
                      <div className="font-medium text-sm text-white">{tool.name}</div>
                    </div>
                    <div className="text-xs text-white mt-1 ml-6">
                      {tool.description}
                    </div>
                  </div>
                ))}
                
                <Button 
                  className="w-full mt-2 bg-blue-600 hover:bg-blue-700 text-white"
                  onClick={onMakeTrade}
                >
                  Make Trade
                </Button>
              </div>
            </div>
          )}
        </div>
        
        {/* Captain Tools Dropdown */}
        <div className="rounded-md overflow-hidden border border-gray-200">
          <div 
            className="flex justify-between items-center px-3 py-2 bg-yellow-50 cursor-pointer"
            onClick={() => setCurrentToolCategory(currentToolCategory === "captain" ? null : "captain")}
          >
            <div className="flex items-center gap-2">
              <Award className="h-5 w-5 text-yellow-600" />
              <span className="font-bold text-yellow-700">Captain Tools</span>
            </div>
            {currentToolCategory === "captain" ? 
              <ChevronUp className="h-4 w-4 text-yellow-700" /> : 
              <ChevronDown className="h-4 w-4 text-yellow-700" />
            }
          </div>
          
          {currentToolCategory === "captain" && (
            <div className="p-2 bg-white">
              <div className="grid gap-1">
                {toolGroups.captain.map(tool => (
                  <div 
                    key={tool.id}
                    className={`p-2 rounded-md cursor-pointer ${activeTool === tool.id ? 'bg-yellow-50 border border-yellow-200' : 'hover:bg-gray-50'}`}
                    onClick={() => handleSelectTool("captain", tool.id)}
                  >
                    <div className="flex items-center gap-2">
                      <div className="text-yellow-600">{tool.icon}</div>
                      <div className="font-medium text-sm text-white">{tool.name}</div>
                    </div>
                    <div className="text-xs text-white mt-1 ml-6">
                      {tool.description}
                    </div>
                  </div>
                ))}
                
                <Button 
                  className="w-full mt-2 bg-yellow-600 hover:bg-yellow-700 text-white"
                >
                  Set Captain
                </Button>
              </div>
            </div>
          )}
        </div>
        
        {/* AI Assistant Tools Dropdown */}
        <div className="rounded-md overflow-hidden border border-gray-200">
          <div 
            className="flex justify-between items-center px-3 py-2 bg-green-50 cursor-pointer"
            onClick={() => setCurrentToolCategory(currentToolCategory === "ai" ? null : "ai")}
          >
            <div className="flex items-center gap-2">
              <Brain className="h-5 w-5 text-green-600" />
              <span className="font-bold text-green-700">AI Assistant</span>
            </div>
            {currentToolCategory === "ai" ? 
              <ChevronUp className="h-4 w-4 text-green-700" /> : 
              <ChevronDown className="h-4 w-4 text-green-700" />
            }
          </div>
          
          {currentToolCategory === "ai" && (
            <div className="p-2 bg-white">
              <div className="grid gap-1">
                {toolGroups.ai.map(tool => (
                  <div 
                    key={tool.id}
                    className={`p-2 rounded-md cursor-pointer ${activeTool === tool.id ? 'bg-green-50 border border-green-200' : 'hover:bg-gray-50'}`}
                    onClick={() => handleSelectTool("ai", tool.id)}
                  >
                    <div className="flex items-center gap-2">
                      <div className="text-green-600">{tool.icon}</div>
                      <div className="font-medium text-sm text-white">{tool.name}</div>
                    </div>
                    <div className="text-xs text-white mt-1 ml-6">
                      {tool.description}
                    </div>
                  </div>
                ))}
                
                <div className="mt-2 p-2 bg-gray-50 rounded-md">
                  <div className="text-xs text-white mb-2">Ask the AI Assistant:</div>
                  <div className="bg-white border border-gray-200 rounded-md p-2 text-sm">
                    Type your question here...
                  </div>
                  <Button className="w-full mt-2 bg-green-600 hover:bg-green-700 text-white">
                    Get Advice
                  </Button>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
      
      {/* Team View Selector */}
      <div className="border rounded-md overflow-hidden">
        <Tabs value={viewMode} onValueChange={(v) => setViewMode(v as "field" | "list")}>
          <div className="bg-gray-100">
            <TabsList className="w-full grid grid-cols-2 bg-transparent">
              <TabsTrigger 
                value="field" 
                className="data-[state=active]:bg-lime-500 data-[state=active]:text-white"
              >
                Field View
              </TabsTrigger>
              <TabsTrigger 
                value="list"
                className="data-[state=active]:bg-white"
              >
                List View
              </TabsTrigger>
            </TabsList>
          </div>
          
          <TabsContent value="field" className="p-3 bg-white">
            <div className="space-y-3">
              <PositionGroup 
                position="DEFENDER"
                players={defenders}
                showScores={true}
              />
              
              <PositionGroup 
                position="MIDFIELDER"
                players={midfielders}
                showScores={true}
              />
              
              <PositionGroup 
                position="RUCK"
                players={rucks}
                showScores={true}
              />
              
              <PositionGroup 
                position="FORWARD"
                players={forwards}
                showScores={true}
              />
              
              <PositionGroup 
                position="UTILITY"
                players={[utilityPlayer]}
                showScores={true}
              />
            </div>
          </TabsContent>
          
          <TabsContent value="list" className="p-3 bg-white">
            <DetailedTablesView 
              midfielders={midfielders}
              forwards={forwards}
              defenders={defenders}
              rucks={rucks}
              utility={[utilityPlayer]}
            />
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
}
