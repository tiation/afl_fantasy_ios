import { Card, CardContent } from "@/components/ui/card";

export type LeagueTeam = {
  id: number;
  teamId: number;
  name: string;
  wins: number;
  losses: number;
  pointsFor: number;
};

type LeagueLadderProps = {
  teams: LeagueTeam[];
  isLoading: boolean;
};

export default function LeagueLadder({ teams, isLoading }: LeagueLadderProps) {
  return (
    <Card className="bg-transparent border-none">
      <CardContent className="p-4">
        <h2 className="text-lg font-medium mb-4 text-white">League Standings</h2>
        
        {isLoading ? (
          <div className="text-center py-4 text-gray-300">Loading league standings...</div>
        ) : teams.length === 0 ? (
          <div className="text-center py-4 text-gray-300">No teams found in this league.</div>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-700">
              <thead className="bg-gray-800">
                <tr>
                  <th scope="col" className="px-3 py-3 text-left text-xs font-medium text-white uppercase tracking-wider">
                    Rank
                  </th>
                  <th scope="col" className="px-3 py-3 text-left text-xs font-medium text-white uppercase tracking-wider">
                    Team
                  </th>
                  <th scope="col" className="px-3 py-3 text-left text-xs font-medium text-white uppercase tracking-wider">
                    W
                  </th>
                  <th scope="col" className="px-3 py-3 text-left text-xs font-medium text-white uppercase tracking-wider">
                    L
                  </th>
                  <th scope="col" className="px-3 py-3 text-left text-xs font-medium text-white uppercase tracking-wider">
                    Points For
                  </th>
                </tr>
              </thead>
              <tbody className="bg-gray-900/50 divide-y divide-gray-700">
                {teams.map((team, index) => (
                  <tr key={team.id} className="hover:bg-gray-800/50">
                    <td className="px-3 py-3 whitespace-nowrap">
                      <div className="text-sm text-white">{index + 1}</div>
                    </td>
                    <td className="px-3 py-3 whitespace-nowrap">
                      <div className="text-sm font-medium text-white">{team.name}</div>
                    </td>
                    <td className="px-3 py-3 whitespace-nowrap">
                      <div className="text-sm text-white">{team.wins}</div>
                    </td>
                    <td className="px-3 py-3 whitespace-nowrap">
                      <div className="text-sm text-white">{team.losses}</div>
                    </td>
                    <td className="px-3 py-3 whitespace-nowrap">
                      <div className="text-sm text-white">{team.pointsFor}</div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </CardContent>
    </Card>
  );
}
