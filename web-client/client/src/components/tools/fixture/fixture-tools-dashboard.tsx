import React, { useEffect, useState } from "react";
import {
  fetchFixtureDifficulty,
  fetchMatchupDVP,
  fetchFixtureSwing,
  fetchTravelImpact,
  fetchWeatherRisk
} from "@/services/fixtureService";
import { Button } from "@/components/ui/button";
import { Loader2 } from "lucide-react";

// Import components directly to avoid circular dependencies
import { FixtureDifficultyScanner } from "./fixture-difficulty-scanner";
import { MatchupDVPAnalyzer } from "./matchup-dvp-analyzer";
import { FixtureSwingRadar } from "./fixture-swing-radar";
import { TravelImpactEstimator } from "./travel-impact-estimator";
import { WeatherForecastRiskModel } from "./weather-forecast-risk-model";

export function FixtureToolsDashboard() {
  const [activeTab, setActiveTab] = useState<string>("difficulty");

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap gap-2 mb-4">
        <Button 
          variant={activeTab === "difficulty" ? "default" : "outline"} 
          onClick={() => setActiveTab("difficulty")}
          size="sm"
        >
          Fixture Difficulty
        </Button>
        <Button 
          variant={activeTab === "matchup" ? "default" : "outline"} 
          onClick={() => setActiveTab("matchup")}
          size="sm"
        >
          Matchup DVP
        </Button>
        <Button 
          variant={activeTab === "swing" ? "default" : "outline"} 
          onClick={() => setActiveTab("swing")}
          size="sm"
        >
          Fixture Swing
        </Button>
        <Button 
          variant={activeTab === "travel" ? "default" : "outline"} 
          onClick={() => setActiveTab("travel")}
          size="sm"
        >
          Travel Impact
        </Button>
        <Button 
          variant={activeTab === "weather" ? "default" : "outline"} 
          onClick={() => setActiveTab("weather")}
          size="sm"
        >
          Weather Risk
        </Button>
      </div>

      <div className="border rounded-md p-4">
        {activeTab === "difficulty" && <FixtureDifficultyScanner />}
        {activeTab === "matchup" && <MatchupDVPAnalyzer />}
        {activeTab === "swing" && <FixtureSwingRadar />}
        {activeTab === "travel" && <TravelImpactEstimator />}
        {activeTab === "weather" && <WeatherForecastRiskModel />}
      </div>
    </div>
  );
}