import { useEffect, useState } from "react";
import { fetchCashGenerationTracker } from "@/services/cashService";

export default function CashGenTable() {
  const [data, setData] = useState<any>({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function loadData() {
      try {
        setLoading(true);
        const result = await fetchCashGenerationTracker();
        
        if (result.status === "ok" && result.players) {
          setData(result);
        } else {
          setError("Failed to load cash generation data");
        }
      } catch (err) {
        console.error("Error loading cash generation data:", err);
        setError("Failed to load cash generation data");
      } finally {
        setLoading(false);
      }
    }
    
    loadData();
  }, []);

  // If loading or error, show appropriate message
  if (loading) {
    return <div>Loading cash generation data...</div>;
  }
  
  if (error) {
    return <div className="text-red-500">{error}</div>;
  }
  
  // If no players, show empty message
  if (!data.players || data.players.length === 0) {
    return <div>No cash generation data available.</div>;
  }

  return (
    <table className="min-w-full border-collapse">
      <thead>
        <tr className="bg-gray-100">
          <th className="p-2 text-left">Player</th>
          <th className="p-2 text-left">Team</th>
          <th className="p-2 text-right">Price</th>
          <th className="p-2 text-right">BE</th>
          <th className="p-2 text-right">L3 Avg</th>
          <th className="p-2 text-right">Est. Change</th>
        </tr>
      </thead>
      <tbody>
        {data.players.map((p: any, i: number) => (
          <tr key={i} className={i % 2 === 0 ? "bg-white" : "bg-gray-50"}>
            <td className="p-2 border-t">{p.player}</td>
            <td className="p-2 border-t">{p.team}</td>
            <td className="p-2 border-t text-right">${Math.round(p.price).toLocaleString()}</td>
            <td className="p-2 border-t text-right">{p.breakeven}</td>
            <td className="p-2 border-t text-right">{p["3_game_avg"] || "-"}</td>
            <td className="p-2 border-t text-right">{p.price_change_est}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}