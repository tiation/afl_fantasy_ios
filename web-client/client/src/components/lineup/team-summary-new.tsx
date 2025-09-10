import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { ChevronDown, ChevronUp, Info, Award, BarChart2, ArrowRight, ArrowRightLeft, Brain } from "lucide-react";
import { useState } from "react";
import { formatCurrency, formatScore, getPositionColor } from "@/lib/utils";

type TeamPlayer = {
  id: number;
  name: string;
  position: string;
  team?: string;
  isCaptain?: boolean;
  price?: number;
  breakEven?: number;
  lastScore?: number;
  averagePoints?: number;
  liveScore?: number;
  secondaryPositions?: string[];
  isOnBench?: boolean;
  projScore?: number;
  nextOpponent?: string;
  l3Average?: number;
  roundsPlayed?: number;
};

// Create placeholder players when not enough actual players are available
const getPlaceholders = (position: string, count: number, startId: number) => {
  return Array(count).fill(null).map((_, i) => ({
    id: startId + i,
    name: `Player ${String.fromCharCode(65 + i)}`,
    position,
    team: "TBD",
    price: 500000,
    breakEven: 80,
    lastScore: 70,
    averagePoints: 75,
    liveScore: 0,
    isOnBench: false,
    nextOpponent: "BYE",
    l3Average: 72,
    roundsPlayed: 6
  }));
};

type PositionSectionProps = {
  title: string;
  shortCode: string;
  fieldPlayers: TeamPlayer[];
  benchPlayers: TeamPlayer[];
  requiredFieldCount: number;
  requiredBenchCount: number;
  color: string;
  hasBorder?: boolean;
  onPlayerClick?: (player: TeamPlayer) => void;
};

const PositionSection = ({ 
  title, 
  shortCode, 
  fieldPlayers, 
  benchPlayers, 
  requiredFieldCount,
  requiredBenchCount,
  color,
  hasBorder = true,
  onPlayerClick
}: PositionSectionProps) => {
  const [expanded, setExpanded] = useState(true);
  
  // Fill with placeholders if needed
  const paddedFieldPlayers = [...fieldPlayers];
  const paddedBenchPlayers = [...benchPlayers];
  
  if (paddedFieldPlayers.length < requiredFieldCount) {
    paddedFieldPlayers.push(...getPlaceholders(shortCode, requiredFieldCount - paddedFieldPlayers.length, 10000 + paddedFieldPlayers.length));
  }
  
  if (paddedBenchPlayers.length < requiredBenchCount) {
    paddedBenchPlayers.push(...getPlaceholders(shortCode, requiredBenchCount - paddedBenchPlayers.length, 20000 + paddedBenchPlayers.length));
  }
  
  // Take only required number of players
  const displayFieldPlayers = paddedFieldPlayers.slice(0, requiredFieldCount);
  const displayBenchPlayers = paddedBenchPlayers.slice(0, requiredBenchCount);
  
  return (
    <div className={`${hasBorder ? 'border-b border-gray-200 pb-3 mb-3' : 'mb-3'}`}>
      <button 
        className="w-full flex items-center justify-between font-medium p-2 cursor-pointer rounded-t-md text-white"
        style={{ backgroundColor: color }}
        onClick={() => setExpanded(!expanded)}
      >
        <h3 className="font-medium text-sm">{title}</h3>
        {expanded ? <ChevronUp className="h-4 w-4" /> : <ChevronDown className="h-4 w-4" />}
      </button>
      
      {expanded && (
        <>
          <div className={`bg-gray-900 border-2 ${color} rounded-lg`}>
            <div className="grid grid-cols-10 gap-1 items-center border-b border-gray-700 py-2 px-2 bg-gray-800 text-xs font-medium text-white">
              <div className="col-span-2 pl-1">Player</div>
              <div className="col-span-1 text-center border-l border-gray-600 pl-1">Next</div>
              <div className="col-span-1 text-center border-l border-gray-600 pl-1">Live</div>
              <div className="col-span-1 text-center border-l border-gray-600 pl-1">Avg</div>  
              <div className="col-span-1 text-center border-l border-gray-600 pl-1">L3</div>
              <div className="col-span-1 text-center border-l border-gray-600 pl-1">BE</div>
              <div className="col-span-1 text-center border-l border-gray-600 pl-1">Last</div>
              <div className="col-span-2 text-right border-l border-gray-600 pr-1">Price</div>
            </div>
            
            {displayFieldPlayers.map((player, index) => {
              const nameParts = player.name.split(' ');
              const firstName = nameParts[0];
              const lastName = nameParts.slice(1).join(' ');
              
              return (
                <div key={player.id} className="grid grid-cols-10 gap-1 items-center border-b border-gray-700 py-2 px-2 hover:bg-gray-800 text-white">
                  <div className="col-span-2 flex items-center gap-1 pl-1">
                    {player.isCaptain && (
                      <span className="px-1 text-xs bg-yellow-500 text-white rounded-sm flex-shrink-0">C</span>
                    )}
                    <div className="min-w-0 flex-1">
                      <div 
                        className="font-medium cursor-pointer hover:text-primary text-xs leading-tight"
                        onClick={() => onPlayerClick && onPlayerClick(player)}
                      >
                        <div className="truncate">{firstName}</div>
                        <div className="truncate">{lastName}</div>
                      </div>
                      <div className="text-xs text-gray-300 leading-tight">
                        {player.team && <span className="text-xs">{player.team}</span>}
                        {player.secondaryPositions?.length ? (
                          <span className="text-blue-400 font-medium text-xs ml-1">
                            {shortCode}/{player.secondaryPositions.join('/')}
                          </span>
                        ) : (
                          <span className="text-xs ml-1">{shortCode}</span>
                        )}
                      </div>
                    </div>
                  </div>
                  <div className="col-span-1 text-center text-xs font-medium border-l border-gray-600 pl-1">
                    {player.nextOpponent || '-'}
                  </div>
                  <div className="col-span-1 text-center text-xs font-medium border-l border-gray-600 pl-1">
                    {player.liveScore || '-'}
                  </div>
                  <div className="col-span-1 text-center text-xs font-medium border-l border-gray-600 pl-1">
                    {player.averagePoints?.toFixed(1) || '-'}
                  </div>
                  <div className="col-span-1 text-center text-xs font-medium border-l border-gray-600 pl-1">
                    {player.l3Average?.toFixed(1) || '-'}
                  </div>
                  <div className="col-span-1 text-center text-xs font-medium border-l border-gray-600 pl-1">
                    {player.breakEven}
                  </div>
                  <div className="col-span-1 text-center text-xs font-medium border-l border-gray-600 pl-1">
                    {formatScore(player.lastScore)}
                  </div>
                  <div className="col-span-2 text-right text-xs font-medium border-l border-gray-600 pr-1">
                    {formatCurrency(player.price || 0)}
                  </div>
                </div>
              );
            })}
          </div>
          
          {displayBenchPlayers.length > 0 && (
            <div className={`bg-gray-900 border-2 ${color} rounded-lg mt-2`}>
              <div className="bg-gray-800 py-1 px-2 text-sm font-medium text-white">
                Bench
              </div>
              {displayBenchPlayers.map((player) => {
                const nameParts = player.name.split(' ');
                const firstName = nameParts[0];
                const lastName = nameParts.slice(1).join(' ');
                
                return (
                  <div key={player.id} className="grid grid-cols-10 gap-1 items-center border-b border-gray-700 py-2 px-2 hover:bg-gray-800 text-white">
                    <div className="col-span-2 flex items-center gap-1 pl-1">
                      {player.isCaptain && (
                        <span className="px-1 text-xs bg-yellow-500 text-white rounded-sm flex-shrink-0">C</span>
                      )}
                      <div className="min-w-0 flex-1">
                        <div 
                          className="font-medium cursor-pointer hover:text-primary text-xs leading-tight"
                          onClick={() => onPlayerClick && onPlayerClick(player)}
                        >
                          <div className="truncate">{firstName}</div>
                          <div className="truncate">{lastName}</div>
                        </div>
                        <div className="text-xs text-gray-300 leading-tight">
                          {player.team && <span className="text-xs">{player.team}</span>}
                          {player.secondaryPositions?.length ? (
                            <span className="text-blue-400 font-medium text-xs ml-1">
                              {shortCode}/{player.secondaryPositions.join('/')}
                            </span>
                          ) : (
                            <span className="text-xs ml-1">{shortCode}</span>
                          )}
                        </div>
                      </div>
                    </div>
                    <div className="col-span-1 text-center text-xs font-medium border-l border-gray-600 pl-1">
                      {player.nextOpponent || '-'}
                    </div>
                    <div className="col-span-1 text-center text-xs font-medium border-l border-gray-600 pl-1">
                      {player.liveScore || '-'}
                    </div>
                    <div className="col-span-1 text-center text-xs font-medium border-l border-gray-600 pl-1">
                      {player.averagePoints?.toFixed(1) || '-'}
                    </div>
                    <div className="col-span-1 text-center text-xs font-medium border-l border-gray-600 pl-1">
                      {player.l3Average?.toFixed(1) || '-'}
                    </div>
                    <div className="col-span-1 text-center text-xs font-medium border-l border-gray-600 pl-1">
                      {player.breakEven}
                    </div>
                    <div className="col-span-1 text-center text-xs font-medium border-l border-gray-600 pl-1">
                      {formatScore(player.lastScore)}
                    </div>
                    <div className="col-span-2 text-right text-xs font-medium border-l border-gray-600 pr-1">
                      {formatCurrency(player.price || 0)}
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </>
      )}
    </div>
  );
};

type TeamSummaryProps = {
  midfielders: TeamPlayer[];
  forwards: TeamPlayer[];
  defenders: TeamPlayer[];
  rucks: TeamPlayer[];
  tradesAvailable: number;
  onMakeTrade: () => void;
  onPlayerClick?: (player: TeamPlayer) => void;
};

export default function TeamSummary({
  midfielders,
  forwards,
  defenders,
  rucks,
  tradesAvailable,
  onMakeTrade,
  onPlayerClick
}: TeamSummaryProps) {
  // Generate Trade Out Priority data from actual team data
  const isPremium = (player: TeamPlayer) => (player.price || 0) >= 900000;
  const isMidPricer = (player: TeamPlayer) => (player.price || 0) >= 450000 && (player.price || 0) < 900000;
  const isRookie = (player: TeamPlayer) => (player.price || 0) >= 230000 && (player.price || 0) < 450000;
  
  // Combine all players from the team
  const allPlayers = [...midfielders, ...defenders, ...rucks, ...forwards];
  
  // Analyze for underperforming premium players (L3 or L5 average below projected score)
  const underperformingPremiums = allPlayers
    .filter(player => isPremium(player))
    .filter(player => {
      // Player is underperforming if L3 average is below projected score or average
      const l3Avg = player.l3Average || 0;
      const projected = player.projScore || player.averagePoints || 0;
      return l3Avg < projected * 0.9; // 10% below projection is underperforming
    })
    .map(player => ({
      id: player.id,
      name: player.name,
      position: player.position,
      team: player.team || '',
      price: player.price || 0,
      breakEven: player.breakEven || 0,
      average: player.averagePoints || 0,
      lastScore: player.lastScore || 0,
      projScore: player.projScore || 0,
      reason: "Underperforming relative to price"
    }));
  
  // Find rookies or mid-pricers who have reached their ceiling (BE >= average)
  const peakedRookies = allPlayers
    .filter(player => isRookie(player) || isMidPricer(player))
    .filter(player => {
      const breakEven = player.breakEven || 0;
      const average = player.averagePoints || 0;
      return breakEven >= average; // BE caught up to average means peaked
    })
    .map(player => ({
      id: player.id,
      name: player.name,
      position: player.position,
      team: player.team || '',
      price: player.price || 0,
      breakEven: player.breakEven || 0,
      average: player.averagePoints || 0,
      lastScore: player.lastScore || 0,
      projScore: player.projScore || 0,
      reason: "BE has caught up to average"
    }));
  
  const tradePriorityData = {
    underperforming: underperformingPremiums,
    rookiesCashedOut: peakedRookies
  };
  const [activeToolCategory, setActiveToolCategory] = useState<string>("trade");
  const [isToolsExpanded, setIsToolsExpanded] = useState<boolean>(false);
  const [activeTab, setActiveTab] = useState<string>("field");
  
  // Mock coach's choice data
  const coachChoiceData = {
    mostTradedIn: [
      { id: 101, name: "Charlie Curnow", position: "FWD", team: "CARL", price: 825000, change: "+24.5k", status: "up", lastScore: 115, avgScore: 92.4 },
      { id: 102, name: "Tim English", position: "RUCK", team: "WB", price: 978000, change: "+18.2k", status: "up", lastScore: 124, avgScore: 115.6 },
      { id: 103, name: "Nick Daicos", position: "MID", team: "COLL", price: 1020000, change: "+12.8k", status: "up", lastScore: 138, avgScore: 128.2 },
      { id: 104, name: "Izak Rankine", position: "FWD", team: "ADEL", price: 745000, change: "+8.3k", status: "up", lastScore: 94, avgScore: 82.5 },
    ],
    mostTradedOut: [
      { id: 201, name: "Toby Greene", position: "FWD", team: "GWS", price: 782000, change: "-15.3k", status: "down", lastScore: 64, avgScore: 88.2 },
      { id: 202, name: "Jordan De Goey", position: "MID/FWD", team: "COLL", price: 735000, change: "-21.7k", status: "down", lastScore: 52, avgScore: 82.6 },
      { id: 203, name: "Sean Darcy", position: "RUCK", team: "FREM", price: 692000, change: "-18.9k", status: "down", lastScore: 45, avgScore: 75.1 },
      { id: 204, name: "Isaac Heeney", position: "MID/FWD", team: "SYD", price: 868000, change: "-10.2k", status: "down", lastScore: 73, avgScore: 92.3 },
    ],
    formPlayers: {
      hot: [
        { id: 301, name: "Errol Gulden", position: "MID", team: "SYD", price: 915000, trend: "Last 3: 132, 145, 128", avgScore: 128.3 },
        { id: 302, name: "Zak Butters", position: "MID", team: "PORT", price: 880000, trend: "Last 3: 126, 118, 135", avgScore: 126.3 },
        { id: 303, name: "Max Gawn", position: "RUCK", team: "MELB", price: 935000, trend: "Last 3: 124, 118, 130", avgScore: 124.0 },
      ],
      cold: [
        { id: 401, name: "Marcus Bontempelli", position: "MID", team: "WB", price: 962000, trend: "Last 3: 78, 82, 75", avgScore: 78.3 },
        { id: 402, name: "Clayton Oliver", position: "MID", team: "MELB", price: 856000, trend: "Last 3: 85, 72, 81", avgScore: 79.3 },
        { id: 403, name: "Caleb Serong", position: "MID", team: "FREM", price: 825000, trend: "Last 3: 73, 81, 79", avgScore: 77.7 },
      ]
    },
    injuries: [
      { id: 501, name: "Patrick Cripps", position: "MID", team: "CARL", status: "Test", details: "Ribs - 1 week" },
      { id: 502, name: "Lachie Neale", position: "MID", team: "BRIS", status: "Out", details: "Hamstring - 2-3 weeks" },
      { id: 503, name: "Jeremy Cameron", position: "FWD", team: "GEEL", status: "Out", details: "Concussion - 1 week" },
      { id: 504, name: "Matt Rowell", position: "MID", team: "GCFC", status: "Test", details: "Ankle - 1 week" },
      { id: 505, name: "Sam Walsh", position: "MID", team: "CARL", status: "Out", details: "Hamstring - 2 weeks" },
    ]
  };
  
  // Separate bench and field players
  const fieldMidfielders = midfielders.filter(p => !p.isOnBench);
  const benchMidfielders = midfielders.filter(p => p.isOnBench || midfielders.indexOf(p) >= 8);
  
  const fieldDefenders = defenders.filter(p => !p.isOnBench);
  const benchDefenders = defenders.filter(p => p.isOnBench || defenders.indexOf(p) >= 6);
  
  const fieldForwards = forwards.filter(p => !p.isOnBench);
  const benchForwards = forwards.filter(p => p.isOnBench || forwards.indexOf(p) >= 6);
  
  const fieldRucks = rucks.filter(p => !p.isOnBench);
  const benchRucks = rucks.filter(p => p.isOnBench || rucks.indexOf(p) >= 2);
  
  // Find utility player (if available)
  const allTeamPlayers = [...midfielders, ...forwards, ...defenders, ...rucks];
  const utilityPlayer = allTeamPlayers.find(p => 
    !fieldMidfielders.includes(p) && 
    !benchMidfielders.includes(p) && 
    !fieldDefenders.includes(p) && 
    !benchDefenders.includes(p) && 
    !fieldForwards.includes(p) && 
    !benchForwards.includes(p) && 
    !fieldRucks.includes(p) && 
    !benchRucks.includes(p)
  );
  
  // Calculate team stats
  const totalValue = allTeamPlayers.reduce((sum, player) => sum + (player.price || 0), 0);
  const avgScore = allTeamPlayers.reduce((sum, player) => sum + (player.lastScore || 0), 0) / allTeamPlayers.length;
  
  // Mock trade history data
  const tradeHistory = [
    {
      round: 3,
      date: "May 2, 2025",
      trades: [
        {
          playerOut: {
            name: "Josh Kelly",
            position: "MID",
            team: "GWS",
            priceBefore: 810000,
            avgBefore: 98.5,
            lastScoreBefore: 78,
            priceAfter: 792000,
            avgAfter: 92.1,
            lastScoreAfter: 65,
            trend: "down"
          },
          playerIn: {
            name: "Zach Merrett",
            position: "MID",
            team: "ESS",
            priceBefore: 905000,
            avgBefore: 108.2,
            lastScoreBefore: 115,
            priceAfter: 932000,
            avgAfter: 112.5,
            lastScoreAfter: 124,
            trend: "up"
          }
        }
      ]
    },
    {
      round: 5,
      date: "May 16, 2025",
      trades: [
        {
          playerOut: {
            name: "Bailey Smith",
            position: "MID",
            team: "WB",
            priceBefore: 750000,
            avgBefore: 89.5,
            lastScoreBefore: 76,
            priceAfter: 718000,
            avgAfter: 85.2,
            lastScoreAfter: 64,
            trend: "down"
          },
          playerIn: {
            name: "Sam Walsh",
            position: "MID",
            team: "CARL",
            priceBefore: 865000,
            avgBefore: 104.8,
            lastScoreBefore: 112,
            priceAfter: 895000,
            avgAfter: 108.3,
            lastScoreAfter: 120,
            trend: "up"
          }
        },
        {
          playerOut: {
            name: "Tom Stewart",
            position: "DEF",
            team: "GEEL",
            priceBefore: 688000,
            avgBefore: 82.1,
            lastScoreBefore: 70,
            priceAfter: 665000,
            avgAfter: 79.4,
            lastScoreAfter: 67,
            trend: "down"
          },
          playerIn: {
            name: "Jordan Ridley",
            position: "DEF",
            team: "ESS",
            priceBefore: 742000,
            avgBefore: 88.5,
            lastScoreBefore: 95,
            priceAfter: 768000,
            avgAfter: 91.7,
            lastScoreAfter: 101,
            trend: "up"
          }
        }
      ]
    }
  ];
  
  // Define the tools data
  const toolsData = {
    trade: [
      { name: "Trade Optimizer", description: "Find best trades based on projections and form" },
      { name: "Trade Calculator", description: "Calculate points impact from potential trades" },
      { name: "One Up One Down Suggester", description: "Find optimal player pair swaps" },
      { name: "Price Difference Delta", description: "Analyze potential value changes" },
      { name: "Value Gain Tracker", description: "Track price changes and value growth" },
      { name: "Trade Burn Risk Analyzer", description: "Analyze risk of using multiple trades" },
      { name: "Trade Return Analyzer", description: "Evaluate long-term trade returns" }
    ],
    captain: [
      { name: "Captain Optimizer", description: "Find optimal captain choices for upcoming round" },
      { name: "Auto Captain Loop", description: "Auto-generate captain loop strategy" },
      { name: "Loop Validity Checker", description: "Check if your loop strategy is valid" },
      { name: "VC Success Rate Calculator", description: "Calculate optimal VC selection" },
      { name: "Captain Ceiling Estimator", description: "Identify high-ceiling captain choices" },
      { name: "Loop Strategy Risk Score", description: "Evaluate risk in your loop strategy" }
    ],
    ai: [
      { name: "AI Trade Suggester", description: "AI-powered trade recommendations" },
      { name: "AI Captain Advisor", description: "AI captain selection assistance" },
      { name: "Team Value Analyzer", description: "Team value and balance analysis" },
      { name: "Ownership Risk Monitor", description: "Track ownership % changes across your team" },
      { name: "Form vs Price Scanner", description: "Identify value opportunities" }
    ]
  };
  
  // Determine active tool interface based on category
  const renderActiveToolInterface = () => {
    const tools = toolsData[activeToolCategory as keyof typeof toolsData] || [];
    
    const toolColor = activeToolCategory === "trade" 
      ? "bg-blue-600" 
      : activeToolCategory === "captain" 
        ? "bg-green-600" 
        : "bg-purple-600";
    
    // Handle tool selection
    const handleToolSelect = (tool: { name: string; description: string }) => {
      // When Trade Calculator is selected, trigger the trade modal
      if (tool.name === "Trade Calculator" && onMakeTrade) {
        onMakeTrade();
      } else {
        // For other tools, just show a notification (placeholder)
        console.log(`Selected tool: ${tool.name}`);
      }
    };
        
    return (
      <div className="py-1">
        {tools.map((tool, index) => (
          <div key={index} className="flex items-center justify-between px-3 py-2 hover:bg-gray-100 cursor-pointer border-b border-gray-100">
            <div className="flex-grow">
              <div className="font-medium text-sm text-center">{tool.name}</div>
              <div className="text-xs text-gray-500 text-center">{tool.description}</div>
            </div>
            <Button 
              size="sm" 
              className={`${toolColor} h-7 text-xs`}
              onClick={() => handleToolSelect(tool)}
            >
              Use
            </Button>
          </div>
        ))}
      </div>
    );
  };

  return (
    <>
            

      
      <Card className="overflow-hidden mb-4 bg-gray-900 border-gray-700">
        <div className="grid grid-cols-3 border-b border-gray-700">
          <button 
            className={`py-2 font-medium text-sm ${activeTab === 'field' ? 'bg-blue-500 text-white' : 'bg-gray-800 text-white'}`}
            onClick={() => setActiveTab('field')}
          >
            FIELD
          </button>
          <button 
            className={`py-2 font-medium text-sm ${activeTab === 'coaches' ? 'bg-green-500 text-white' : 'bg-gray-800 text-white'}`}
            onClick={() => setActiveTab('coaches')}
          >
            COACH
          </button>
          <button 
            className={`py-2 font-medium text-sm ${activeTab === 'history' ? 'bg-green-500 text-white' : 'bg-gray-800 text-white'}`}
            onClick={() => setActiveTab('history')}
          >
            HISTORY
          </button>
        </div>
        
        {activeTab === 'field' && (
          <div className="bg-gray-900 p-3 rounded-lg">
            <PositionSection
              title="Defenders"
              shortCode="DEF"
              fieldPlayers={fieldDefenders}
              benchPlayers={benchDefenders}
              requiredFieldCount={6}
              requiredBenchCount={2}
              color="border-blue-500"
              onPlayerClick={onPlayerClick}
            />
            
            <div className="mt-3">
              <PositionSection
                title="Midfielders"
                shortCode="MID"
                fieldPlayers={fieldMidfielders}
                benchPlayers={benchMidfielders}
                requiredFieldCount={8}
                requiredBenchCount={2}
                color="border-green-500"
                onPlayerClick={onPlayerClick}
              />
            </div>
            
            <div className="mt-3">
              <PositionSection
                title="Rucks"
                shortCode="R"
                fieldPlayers={fieldRucks}
                benchPlayers={benchRucks}
                requiredFieldCount={2}
                requiredBenchCount={1}
                color="border-orange-500"
                onPlayerClick={onPlayerClick}
              />
            </div>
            
            <div className="mt-3">
              <PositionSection
                title="Forwards"
                shortCode="F"
                fieldPlayers={fieldForwards}
                benchPlayers={benchForwards}
                requiredFieldCount={6}
                requiredBenchCount={2}
                color="border-red-500"
                hasBorder={utilityPlayer ? true : false}
                onPlayerClick={onPlayerClick}
              />
            </div>
            
            {utilityPlayer && (
              <div className="bg-gray-900 border-2 border-teal-500 rounded-lg mt-3">
                <div className="bg-gray-800 py-1 px-2 text-sm font-medium text-white">
                  Utility
                </div>
                <div className="grid grid-cols-12 gap-1 items-center border-b border-gray-200 py-1 px-2 bg-gray-200 text-xs font-medium text-gray-600">
                  <div className="col-span-3">Player</div>
                  <div className="col-span-1 text-center">Next</div>
                  <div className="col-span-1 text-center">Live</div>
                  <div className="col-span-1 text-center">Avg</div>  
                  <div className="col-span-1 text-center">L3</div>
                  <div className="col-span-1 text-center">BE</div>
                  <div className="col-span-1 text-center">Last</div>
                  <div className="col-span-1 text-center">GP</div>
                  <div className="col-span-2 text-right">Price</div>
                </div>
                <div className="grid grid-cols-12 gap-1 items-center border-b border-gray-100 py-1.5 px-2 hover:bg-gray-200">
                  <div className="col-span-3 flex items-center gap-1 truncate">
                    {utilityPlayer.isCaptain && (
                      <span className="px-1 text-xs bg-yellow-500 text-white rounded-sm">C</span>
                    )}
                    <div className="truncate text-sm">
                      <div 
                        className="font-medium truncate cursor-pointer hover:text-primary"
                        onClick={() => onPlayerClick && onPlayerClick(utilityPlayer)}
                      >
                        {utilityPlayer.name}
                      </div>
                      <div className="flex items-center text-xs text-gray-600">
                        {utilityPlayer.team && <span>{utilityPlayer.team}</span>}
                        {utilityPlayer.team && utilityPlayer.secondaryPositions?.length && <span className="mx-1">•</span>}
                        {utilityPlayer.secondaryPositions?.length ? (
                          <span className="text-blue-600 font-medium">
                            {utilityPlayer.position}/{utilityPlayer.secondaryPositions.join('/')}
                          </span>
                        ) : (
                          <span>{utilityPlayer.position}</span>
                        )}
                      </div>
                    </div>
                  </div>
                  <div className="col-span-1 text-center text-xs font-medium">
                    {utilityPlayer.nextOpponent || '-'}
                  </div>
                  <div className="col-span-1 text-center text-sm font-medium">
                    {utilityPlayer.liveScore || '-'}
                  </div>
                  <div className="col-span-1 text-center text-sm font-medium">
                    {utilityPlayer.averagePoints?.toFixed(1) || '-'}
                  </div>
                  <div className="col-span-1 text-center text-sm font-medium">
                    {utilityPlayer.l3Average?.toFixed(1) || '-'}
                  </div>
                  <div className="col-span-1 text-center text-sm font-medium">
                    {utilityPlayer.breakEven}
                  </div>
                  <div className="col-span-1 text-center text-sm font-medium">
                    {formatScore(utilityPlayer.lastScore)}
                  </div>
                  <div className="col-span-1 text-center text-sm font-medium">
                    {utilityPlayer.roundsPlayed || '-'}
                  </div>
                  <div className="col-span-2 text-right text-sm font-medium">
                    {formatCurrency(utilityPlayer.price || 0)}
                  </div>
                </div>
              </div>
            )}
            
            {/* Trade Out Priority Section */}
            <div className="mt-4 bg-gray-900 border-2 border-red-500 rounded-lg overflow-hidden">
              <div className="bg-red-600 text-white p-2 font-medium">
                Trade Out Priority
              </div>
              
              <div>
                <div className="px-3 py-2 bg-gray-800 font-medium text-white">
                  Underperforming Players
                </div>
                <div className="divide-y divide-gray-700">
                  {tradePriorityData.underperforming.map(player => (
                    <div key={player.id} className="p-3 hover:bg-gray-800 text-white">
                      <div className="flex items-center justify-between">
                        <div>
                          <div className="font-medium flex items-center">
                            {player.name} 
                            <span className="ml-2 px-1.5 py-0.5 bg-red-100 text-red-600 text-xs rounded">
                              {player.position}
                            </span>
                          </div>
                          <div className="text-xs text-gray-400">{player.team}</div>
                        </div>
                        <div className="text-sm">
                          <div className="font-medium text-white">{formatCurrency(player.price)}</div>
                        </div>
                      </div>
                      <div className="grid grid-cols-3 mt-2 text-xs">
                        <div>
                          <span className="text-gray-400">BE:</span> <span className="font-medium text-red-400">{player.breakEven}</span>
                        </div>
                        <div>
                          <span className="text-gray-400">Avg:</span> <span className="font-medium text-white">{player.average}</span>
                        </div>
                        <div>
                          <span className="text-gray-400">Last:</span> <span className="font-medium text-white">{player.lastScore}</span>
                        </div>
                      </div>
                      <div className="mt-1.5 text-xs text-gray-400">
                        {player.reason}
                      </div>
                    </div>
                  ))}
                </div>
                
                <div className="px-3 py-2 bg-gray-800 font-medium text-white">
                  Rookies to Cash Out
                </div>
                <div className="divide-y divide-gray-700">
                  {tradePriorityData.rookiesCashedOut.map(player => (
                    <div key={player.id} className="p-3 hover:bg-gray-800 text-white">
                      <div className="flex items-center justify-between">
                        <div>
                          <div className="font-medium flex items-center">
                            {player.name} 
                            <span className="ml-2 px-1.5 py-0.5 bg-red-100 text-red-600 text-xs rounded">
                              {player.position}
                            </span>
                          </div>
                          <div className="text-xs text-gray-400">{player.team}</div>
                        </div>
                        <div className="text-sm">
                          <div className="font-medium text-white">{formatCurrency(player.price)}</div>
                        </div>
                      </div>
                      <div className="grid grid-cols-3 mt-2 text-xs">
                        <div>
                          <span className="text-gray-400">BE:</span> <span className="font-medium text-amber-400">{player.breakEven}</span>
                        </div>
                        <div>
                          <span className="text-gray-400">Avg:</span> <span className="font-medium text-white">{player.average}</span>
                        </div>
                        <div>
                          <span className="text-gray-400">Last:</span> <span className="font-medium text-white">{player.lastScore}</span>
                        </div>
                      </div>
                      <div className="mt-1.5 text-xs text-gray-400">
                        {player.reason}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        )}
        
        {activeTab === 'coaches' && (
          <div className="p-4">
            <div className="mb-6">
              <h3 className="font-semibold text-lg mb-4 text-white">Most Traded This Week</h3>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                <div className="border rounded-lg overflow-hidden">
                  <div className="bg-green-600 text-white p-2 font-medium">
                    Most Traded In
                  </div>
                  <div className="divide-y">
                    {coachChoiceData.mostTradedIn.map(player => (
                      <div key={player.id} className="p-3 hover:bg-gray-800 text-white">
                        <div className="flex items-center justify-between">
                          <div>
                            <div className="font-medium text-white">{player.name}</div>
                            <div className="text-xs text-gray-400">{player.team} | {player.position}</div>
                          </div>
                          <div className="text-sm">
                            <div className="font-medium text-white">{formatCurrency(player.price)}</div>
                            <div className="text-green-400 text-xs font-medium">{player.change} ↑</div>
                          </div>
                        </div>
                        <div className="flex justify-between mt-1.5 text-xs">
                          <div className="text-gray-400">
                            Last: <span className="font-medium text-white">{player.lastScore}</span>
                          </div>
                          <div className="text-gray-400">
                            Avg: <span className="font-medium text-white">{player.avgScore}</span>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
                
                <div className="border border-gray-600 rounded-lg overflow-hidden bg-gray-900">
                  <div className="bg-red-600 text-white p-2 font-medium">
                    Most Traded Out
                  </div>
                  <div className="divide-y divide-gray-700">
                    {coachChoiceData.mostTradedOut.map(player => (
                      <div key={player.id} className="p-3 hover:bg-gray-800 text-white">
                        <div className="flex items-center justify-between">
                          <div>
                            <div className="font-medium text-white">{player.name}</div>
                            <div className="text-xs text-gray-400">{player.team} | {player.position}</div>
                          </div>
                          <div className="text-sm">
                            <div className="font-medium text-white">{formatCurrency(player.price)}</div>
                            <div className="text-red-400 text-xs font-medium">{player.change} ↓</div>
                          </div>
                        </div>
                        <div className="flex justify-between mt-1.5 text-xs">
                          <div className="text-gray-400">
                            Last: <span className="font-medium text-white">{player.lastScore}</span>
                          </div>
                          <div className="text-gray-400">
                            Avg: <span className="font-medium text-white">{player.avgScore}</span>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </div>
            
            <div className="mb-6">
              <h3 className="font-semibold text-lg mb-4 text-white">Form Guide</h3>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                <div className="border border-gray-600 rounded-lg overflow-hidden bg-gray-900">
                  <div className="bg-amber-500 text-white p-2 font-medium">
                    Running Hot 🔥
                  </div>
                  <div className="divide-y divide-gray-700">
                    {coachChoiceData.formPlayers.hot.map(player => (
                      <div key={player.id} className="p-3 hover:bg-gray-800 text-white">
                        <div className="flex items-center justify-between">
                          <div>
                            <div className="font-medium text-white">{player.name}</div>
                            <div className="text-xs text-gray-400">{player.team} | {player.position}</div>
                          </div>
                          <div className="text-sm">
                            <div className="font-medium text-white">{formatCurrency(player.price)}</div>
                            <div className="text-amber-400 text-xs font-medium">Avg: {player.avgScore} ⭐</div>
                          </div>
                        </div>
                        <div className="mt-1.5 text-xs text-gray-400">
                          <span className="font-medium text-white">{player.trend}</span>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
                
                <div className="border border-gray-600 rounded-lg overflow-hidden bg-gray-900">
                  <div className="bg-blue-500 text-white p-2 font-medium">
                    Gone Cold ❄️
                  </div>
                  <div className="divide-y divide-gray-700">
                    {coachChoiceData.formPlayers.cold.map(player => (
                      <div key={player.id} className="p-3 hover:bg-gray-800 text-white">
                        <div className="flex items-center justify-between">
                          <div>
                            <div className="font-medium text-white">{player.name}</div>
                            <div className="text-xs text-gray-400">{player.team} | {player.position}</div>
                          </div>
                          <div className="text-sm">
                            <div className="font-medium text-white">{formatCurrency(player.price)}</div>
                            <div className="text-blue-400 text-xs font-medium">Avg: {player.avgScore} ⬇</div>
                          </div>
                        </div>
                        <div className="mt-1.5 text-xs text-gray-400">
                          <span className="font-medium text-white">{player.trend}</span>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </div>
            
            <div className="mb-4">
              <h3 className="font-semibold text-lg mb-4 text-white">Injury Update</h3>
              
              <div className="border border-gray-600 rounded-lg overflow-hidden bg-gray-900">
                <div className="bg-gray-700 text-white p-2 font-medium">
                  Latest Injury News
                </div>
                <div className="divide-y divide-gray-700">
                  {coachChoiceData.injuries.map(player => (
                    <div key={player.id} className="p-3 hover:bg-gray-800 flex items-center justify-between text-white">
                      <div>
                        <div className="font-medium text-white">{player.name}</div>
                        <div className="text-xs text-gray-400">{player.team} | {player.position}</div>
                      </div>
                      <div className="text-sm">
                        <div className={`font-medium ${player.status === 'Out' ? 'text-red-400' : 'text-amber-400'}`}>
                          {player.status}
                        </div>
                        <div className="text-xs text-gray-400">
                          {player.details}
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        )}
        
        {activeTab === 'history' && (
          <div className="p-4">
            <h3 className="font-semibold text-lg mb-4 text-white">Trade History</h3>
            
            {tradeHistory.length > 0 ? (
              tradeHistory.map((roundData, roundIndex) => (
                <div key={roundIndex} className="mb-6">
                  <div className="flex items-center mb-2">
                    <div className="bg-green-500 text-white font-medium px-2 py-1 rounded text-sm">
                      Round {roundData.round}
                    </div>
                    <div className="ml-2 text-sm text-gray-400">{roundData.date}</div>
                  </div>
                  
                  {roundData.trades.map((trade, tradeIndex) => (
                    <div key={tradeIndex} className="border border-gray-600 rounded-lg overflow-hidden mb-3 shadow-sm bg-gray-900">
                      <div className="grid grid-cols-2 bg-gray-800">
                        <div className="p-3 border-r border-gray-600 border-b border-gray-600">
                          <div className="flex items-center">
                            <div className="bg-red-900 rounded-full p-1.5">
                              <ArrowRightLeft className="h-4 w-4 text-red-400" />
                            </div>
                            <span className="ml-2 font-medium text-red-400">TRADED OUT</span>
                          </div>
                        </div>
                        <div className="p-3 border-b border-gray-600">
                          <div className="flex items-center">
                            <div className="bg-green-900 rounded-full p-1.5">
                              <ArrowRightLeft className="h-4 w-4 text-green-400" />
                            </div>
                            <span className="ml-2 font-medium text-green-400">TRADED IN</span>
                          </div>
                        </div>
                      </div>
                      
                      <div className="grid grid-cols-2">
                        {/* Player Out */}
                        <div className="p-3 border-r border-gray-600">
                          <div className="font-semibold text-base text-white">{trade.playerOut.name}</div>
                          <div className="text-sm text-gray-400 mb-2">
                            {trade.playerOut.team} | {trade.playerOut.position}
                          </div>
                          
                          <div className="grid grid-cols-3 gap-2 text-sm mb-3">
                            <div>
                              <div className="text-gray-400">Price</div>
                              <div className="font-medium text-white">{formatCurrency(trade.playerOut.priceBefore)}</div>
                            </div>
                            <div>
                              <div className="text-gray-400">Avg</div>
                              <div className="font-medium text-white">{trade.playerOut.avgBefore}</div>
                            </div>
                            <div>
                              <div className="text-gray-400">Last</div>
                              <div className="font-medium text-white">{trade.playerOut.lastScoreBefore}</div>
                            </div>
                          </div>
                          
                          <div className="text-sm font-medium">
                            <div className="mb-1 text-white">After Trade Performance:</div>
                            <div className="flex items-center gap-2">
                              <div className={`${trade.playerOut.trend === 'up' ? 'text-green-400' : 'text-red-400'} flex items-center`}>
                                {trade.playerOut.trend === 'up' ? (
                                  <ArrowRight className="h-3 w-3 rotate-45" />
                                ) : (
                                  <ArrowRight className="h-3 w-3 -rotate-45" />
                                )}
                                <span>${((trade.playerOut.priceAfter - trade.playerOut.priceBefore) / 1000).toFixed(1)}K</span>
                              </div>
                              <div className="text-gray-400">|</div>
                              <div className="text-white">Avg: {trade.playerOut.avgAfter}</div>
                            </div>
                          </div>
                        </div>
                        
                        {/* Player In */}
                        <div className="p-3">
                          <div className="font-semibold text-base text-white">{trade.playerIn.name}</div>
                          <div className="text-sm text-gray-400 mb-2">
                            {trade.playerIn.team} | {trade.playerIn.position}
                          </div>
                          
                          <div className="grid grid-cols-3 gap-2 text-sm mb-3">
                            <div>
                              <div className="text-gray-400">Price</div>
                              <div className="font-medium text-white">{formatCurrency(trade.playerIn.priceBefore)}</div>
                            </div>
                            <div>
                              <div className="text-gray-400">Avg</div>
                              <div className="font-medium text-white">{trade.playerIn.avgBefore}</div>
                            </div>
                            <div>
                              <div className="text-gray-400">Last</div>
                              <div className="font-medium text-white">{trade.playerIn.lastScoreBefore}</div>
                            </div>
                          </div>
                          
                          <div className="text-sm font-medium">
                            <div className="mb-1 text-white">Current Performance:</div>
                            <div className="flex items-center gap-2">
                              <div className={`${trade.playerIn.trend === 'up' ? 'text-green-400' : 'text-red-400'} flex items-center`}>
                                {trade.playerIn.trend === 'up' ? (
                                  <ArrowRight className="h-3 w-3 rotate-45" />
                                ) : (
                                  <ArrowRight className="h-3 w-3 -rotate-45" />
                                )}
                                <span>${((trade.playerIn.priceAfter - trade.playerIn.priceBefore) / 1000).toFixed(1)}K</span>
                              </div>
                              <div className="text-gray-400">|</div>
                              <div className="text-white">Avg: {trade.playerIn.avgAfter}</div>
                            </div>
                          </div>
                        </div>
                      </div>
                      
                      <div className="bg-gray-800 p-3 border-t border-gray-600">
                        <div className="flex justify-between items-center">
                          <div className="text-sm">
                            <span className="font-medium text-white">Net value change: </span>
                            <span className={`${trade.playerIn.priceAfter - trade.playerOut.priceAfter > 0 ? 'text-green-400' : 'text-red-400'} font-medium`}>
                              {formatCurrency((trade.playerIn.priceAfter - trade.playerOut.priceAfter))}
                            </span>
                          </div>
                          <div className="text-sm">
                            <span className="font-medium text-white">Avg score difference: </span>
                            <span className={`${trade.playerIn.avgAfter - trade.playerOut.avgAfter > 0 ? 'text-green-400' : 'text-red-400'} font-medium`}>
                              {(trade.playerIn.avgAfter - trade.playerOut.avgAfter).toFixed(1)}
                            </span>
                          </div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              ))
            ) : (
              <div className="text-center p-6 bg-gray-900 border border-gray-600 rounded-lg">
                <div className="text-gray-400 mb-2">
                  <ArrowRightLeft className="h-12 w-12 mx-auto" />
                </div>
                <h3 className="text-lg font-medium text-white mb-1">No trade history</h3>
                <p className="text-gray-400">You haven't made any trades yet this season.</p>
              </div>
            )}
          </div>
        )}
      </Card>
    </>
  );
}