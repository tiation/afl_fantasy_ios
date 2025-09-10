import React, { useState } from "react";
import { 
  ArrowRightCircle, 
  TrendingUp, 
  LayoutGrid, 
  FileBarChart 
} from "lucide-react";

// Import role tool components
import {
  RoleChangeDetector,
  CBATrendAnalyzer,
  PositionalImpactScoring,
  PossessionTypeProfiler
} from "@/pages/tools";

// Define tool types
type RoleTool = {
  id: string;
  name: string;
  icon: React.ReactNode;
  component: React.ReactNode;
  description: string;
};

export default function RoleToolsDashboard() {
  const [selectedTool, setSelectedTool] = useState<string>("role_change_detector");

  // Define role tools
  const roleTools: RoleTool[] = [
    { 
      id: "role_change_detector", 
      name: "Role Change Detector", 
      icon: <ArrowRightCircle className="h-4 w-4 mr-2" />,
      component: <RoleChangeDetector />,
      description: "Detect significant changes in player roles and their fantasy impact" 
    },
    { 
      id: "cba_trend_analyzer", 
      name: "CBA Trend Analyzer", 
      icon: <TrendingUp className="h-4 w-4 mr-2" />,
      component: <CBATrendAnalyzer />,
      description: "Analyze Centre Bounce Attendance trends and their fantasy implications" 
    },
    { 
      id: "positional_impact_scoring", 
      name: "Positional Impact Scoring", 
      icon: <LayoutGrid className="h-4 w-4 mr-2" />,
      component: <PositionalImpactScoring />,
      description: "Analyze how positional changes affect fantasy scoring" 
    },
    { 
      id: "possession_type_profiler", 
      name: "Possession Type Profiler", 
      icon: <FileBarChart className="h-4 w-4 mr-2" />,
      component: <PossessionTypeProfiler />,
      description: "Profile players based on possession types and fantasy scoring" 
    }
  ];

  // Find the selected tool
  const currentTool = roleTools.find(tool => tool.id === selectedTool);

  return (
    <div>
      <div className="mb-4">
        <h3 className="mb-2 font-medium">Role Analysis Tools</h3>
        <p className="text-sm text-gray-600 mb-4">
          These tools help you analyze player roles, positional changes, and their fantasy impacts.
        </p>
        
        <div className="flex flex-wrap gap-2 mb-6">
          {roleTools.map(tool => (
            <button
              key={tool.id}
              className={`flex items-center px-3 py-2 rounded-md text-sm ${
                selectedTool === tool.id
                  ? "bg-primary text-primary-foreground"
                  : "bg-gray-100 hover:bg-gray-200 text-gray-700"
              }`}
              onClick={() => setSelectedTool(tool.id)}
            >
              {tool.icon}
              {tool.name}
            </button>
          ))}
        </div>
      </div>

      {currentTool && (
        <div className="bg-white p-4 rounded-md">
          {currentTool.component}
        </div>
      )}
    </div>
  );
}