import { Card, CardContent } from "@/components/ui/card";

export type Matchup = {
  id: number;
  round: number;
  team1: {
    id: number;
    name: string;
    score: number;
  };
  team2: {
    id: number;
    name: string;
    score: number;
  };
};

type LiveMatchupsProps = {
  matchups: Matchup[];
  round: number;
  isLoading: boolean;
};

export default function LiveMatchups({ matchups, round, isLoading }: LiveMatchupsProps) {
  return (
    <Card className="bg-transparent border-none">
      <CardContent className="p-4">
        <h2 className="text-lg font-medium mb-4 text-white">Current Round Matchups</h2>
        
        {isLoading ? (
          <div className="text-center py-4 text-gray-300">Loading matchups...</div>
        ) : matchups.length === 0 ? (
          <div className="text-center py-4 text-gray-300">No matchups scheduled for round {round}.</div>
        ) : (
          <div className="space-y-4">
            {matchups.map((matchup) => (
              <div 
                key={matchup.id}
                className="border border-gray-700 bg-gray-800/50 rounded-lg p-4 flex justify-between items-center"
              >
                <div className="text-center">
                  <div className="font-medium text-white">{matchup.team1.name}</div>
                  <div className={`text-lg font-semibold ${matchup.team1.score > matchup.team2.score ? "text-primary" : "text-gray-300"}`}>
                    ({matchup.team1.score})
                  </div>
                </div>
                
                <div className="text-gray-400 font-medium">vs</div>
                
                <div className="text-center">
                  <div className="font-medium text-white">{matchup.team2.name}</div>
                  <div className={`text-lg font-semibold ${matchup.team2.score > matchup.team1.score ? "text-primary" : "text-gray-300"}`}>
                    ({matchup.team2.score})
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  );
}
