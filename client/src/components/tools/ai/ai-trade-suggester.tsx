import { useEffect, useState } from "react";
import { apiRequest } from "@/lib/queryClient";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { CircleDollarSign, ArrowUpDown, CheckCircle2 } from "lucide-react";
import { Button } from "@/components/ui/button";

type TradeSuggestion = {
  downgrade_out: {
    name: string;
    team: string;
    position: string;
    price: number;
    breakeven: number;
    average: number;
  };
  upgrade_in: {
    name: string;
    team: string;
    position: string;
    price: number;
    breakeven: number;
    average: number;
  };
};

export default function AITradeSuggester() {
  const [suggestion, setSuggestion] = useState<TradeSuggestion | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  async function loadSuggestion() {
    try {
      setLoading(true);
      setError(null);
      
      const response = await apiRequest("GET", "/api/fantasy/tools/ai/ai_trade_suggester");
      const data = await response.json();
      
      if (data.status === "ok" && data.downgrade_out && data.upgrade_in) {
        setSuggestion({
          downgrade_out: data.downgrade_out,
          upgrade_in: data.upgrade_in
        });
      } else {
        setError("Failed to load trade suggestion");
      }
    } catch (err) {
      console.error("Error loading trade suggestion:", err);
      setError("Failed to load trade suggestion");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadSuggestion();
  }, []);

  // Format price for display
  const formatPrice = (price: number) => {
    return `$${(price / 1000).toFixed(0)}K`;
  };

  if (loading) {
    return <div>Loading AI trade suggestion...</div>;
  }

  if (error) {
    return (
      <div className="space-y-4">
        <div className="text-red-500">{error}</div>
        <Button onClick={loadSuggestion}>Try Again</Button>
      </div>
    );
  }

  if (!suggestion) {
    return (
      <div className="space-y-4">
        <div>No trade suggestion available.</div>
        <Button onClick={loadSuggestion}>Generate Suggestion</Button>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-semibold mb-2">AI Recommended Trade</h3>
        <p className="text-sm text-gray-500 mb-4">
          Based on current player data, our AI recommends the following trade to optimize your team value and scoring potential.
        </p>
      </div>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Downgrade player card */}
        <Card className="border-red-200 shadow-sm">
          <CardContent className="pt-6">
            <div className="flex items-center justify-between mb-2">
              <Badge variant="destructive" className="mb-2">Downgrade</Badge>
              <ArrowUpDown className="h-5 w-5 text-gray-400" />
            </div>
            
            <div className="space-y-4">
              <div>
                <h3 className="text-xl font-bold">{suggestion.downgrade_out.name}</h3>
                <div className="text-sm text-gray-500">
                  {suggestion.downgrade_out.team} · {suggestion.downgrade_out.position}
                </div>
              </div>
              
              <div className="grid grid-cols-3 gap-2">
                <div className="bg-gray-50 p-2 rounded-md">
                  <div className="text-xs text-gray-500">Price</div>
                  <div className="text-lg font-semibold text-gray-900">
                    {formatPrice(suggestion.downgrade_out.price)}
                  </div>
                </div>
                <div className="bg-gray-50 p-2 rounded-md">
                  <div className="text-xs text-gray-500">BE</div>
                  <div className="text-lg font-semibold text-gray-900">
                    {suggestion.downgrade_out.breakeven}
                  </div>
                </div>
                <div className="bg-gray-50 p-2 rounded-md">
                  <div className="text-xs text-gray-500">Avg</div>
                  <div className="text-lg font-semibold text-gray-900">
                    {suggestion.downgrade_out.average?.toFixed(1) || "N/A"}
                  </div>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
        
        {/* Upgrade player card */}
        <Card className="border-green-200 shadow-sm">
          <CardContent className="pt-6">
            <div className="flex items-center justify-between mb-2">
              <Badge variant="success" className="bg-green-600 mb-2">Upgrade</Badge>
              <CheckCircle2 className="h-5 w-5 text-green-500" />
            </div>
            
            <div className="space-y-4">
              <div>
                <h3 className="text-xl font-bold">{suggestion.upgrade_in.name}</h3>
                <div className="text-sm text-gray-500">
                  {suggestion.upgrade_in.team} · {suggestion.upgrade_in.position}
                </div>
              </div>
              
              <div className="grid grid-cols-3 gap-2">
                <div className="bg-gray-50 p-2 rounded-md">
                  <div className="text-xs text-gray-500">Price</div>
                  <div className="text-lg font-semibold text-gray-900">
                    {formatPrice(suggestion.upgrade_in.price)}
                  </div>
                </div>
                <div className="bg-gray-50 p-2 rounded-md">
                  <div className="text-xs text-gray-500">BE</div>
                  <div className="text-lg font-semibold text-gray-900">
                    {suggestion.upgrade_in.breakeven}
                  </div>
                </div>
                <div className="bg-gray-50 p-2 rounded-md">
                  <div className="text-xs text-gray-500">Avg</div>
                  <div className="text-lg font-semibold text-gray-900">
                    {suggestion.upgrade_in.average?.toFixed(1) || "N/A"}
                  </div>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
      
      <div className="text-center pt-4">
        <Button 
          onClick={loadSuggestion}
          className="mx-auto"
        >
          Generate New Suggestion
        </Button>
      </div>
    </div>
  );
}