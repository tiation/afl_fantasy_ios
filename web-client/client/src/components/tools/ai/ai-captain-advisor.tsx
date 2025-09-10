import { useEffect, useState } from "react";
import { apiRequest } from "@/lib/queryClient";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Trophy, Star, Clock } from "lucide-react";

type CaptainRecommendation = {
  name: string;
  team: string;
  position: string;
  price: number;
  l3_avg: number;
  breakeven: number;
  projected_score: number;
  fixture: string;
  confidence: number;
};

export default function AICaptainAdvisor() {
  const [captains, setCaptains] = useState<CaptainRecommendation[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  async function loadCaptainRecommendations() {
    try {
      setLoading(true);
      setError(null);
      
      const response = await apiRequest("GET", "/api/fantasy/tools/ai/ai_captain_advisor");
      const data = await response.json();
      
      if (data.status === "ok" && Array.isArray(data.players)) {
        setCaptains(data.players);
      } else {
        setError("Failed to load captain recommendations");
      }
    } catch (err) {
      console.error("Error loading captain recommendations:", err);
      setError("Failed to load captain recommendations");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadCaptainRecommendations();
  }, []);

  // Format price for display
  const formatPrice = (price: number) => {
    if (!price) return "$0";
    return `$${(price / 1000).toFixed(0)}K`;
  };

  // Get confidence level badge
  const getConfidenceBadge = (confidence: number) => {
    if (confidence >= 80) {
      return <Badge className="bg-green-600">High</Badge>;
    } else if (confidence >= 60) {
      return <Badge className="bg-amber-500">Medium</Badge>;
    } else {
      return <Badge className="bg-gray-500">Low</Badge>;
    }
  };

  if (loading) {
    return <div>Loading captain recommendations...</div>;
  }

  if (error) {
    return (
      <div className="space-y-4">
        <div className="text-red-500">{error}</div>
        <Button onClick={loadCaptainRecommendations}>Try Again</Button>
      </div>
    );
  }

  if (!captains || captains.length === 0) {
    return (
      <div className="space-y-4">
        <div>No captain recommendations available.</div>
        <Button onClick={loadCaptainRecommendations}>Get Recommendations</Button>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-semibold mb-2">AI Captain Recommendations</h3>
        <p className="text-sm text-gray-500 mb-4">
          Our AI analyzes matchups, form, and historical performance to suggest optimal captain picks for this round.
        </p>
      </div>
      
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {captains.slice(0, 3).map((captain, index) => (
          <Card 
            key={index} 
            className={`${index === 0 ? 'border-yellow-300 bg-yellow-50/50' : ''}`}
          >
            <CardHeader className={`pb-2 ${index === 0 ? 'bg-yellow-100/50' : ''}`}>
              <div className="flex justify-between items-center">
                <div className="flex items-center gap-2">
                  {index === 0 && <Trophy className="h-5 w-5 text-yellow-500" />}
                  <CardTitle className="text-lg">{captain.name}</CardTitle>
                </div>
                <div>
                  {getConfidenceBadge(captain.confidence)}
                </div>
              </div>
              <div className="text-sm text-gray-500">
                {captain.team} · {captain.position}
              </div>
            </CardHeader>
            <CardContent className="pt-4">
              <div className="grid grid-cols-2 gap-4 mb-4">
                <div>
                  <div className="text-xs text-gray-500">Projected Score</div>
                  <div className="text-lg font-semibold flex items-center gap-1">
                    {captain.projected_score}
                    {index === 0 && <Star className="h-4 w-4 text-yellow-500 fill-yellow-500" />}
                  </div>
                </div>
                <div>
                  <div className="text-xs text-gray-500">L3 Average</div>
                  <div className="text-lg font-semibold">{captain.l3_avg?.toFixed(1) || 'N/A'}</div>
                </div>
              </div>
              
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <div className="text-xs text-gray-500">Price</div>
                  <div className="text-base font-medium">{formatPrice(captain.price)}</div>
                </div>
                <div>
                  <div className="text-xs text-gray-500">Breakeven</div>
                  <div className="text-base font-medium">{captain.breakeven}</div>
                </div>
              </div>
              
              <div className="mt-4 pt-3 border-t border-gray-100">
                <div className="flex items-center gap-1 text-sm text-gray-600">
                  <Clock className="h-4 w-4" />
                  <span>{captain.fixture || 'Upcoming fixture'}</span>
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
      
      <div className="text-center pt-2">
        <Button 
          onClick={loadCaptainRecommendations}
          className="mx-auto"
        >
          Refresh Recommendations
        </Button>
      </div>
    </div>
  );
}