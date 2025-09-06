import { useState } from "react";
import { ChevronDown, ChevronUp } from "lucide-react";
import { statsKeyExplanations } from "./category-header-mapper";

interface CollapsibleStatsKeyProps {
  activeCategory: string;
}

export default function CollapsibleStatsKey({ activeCategory }: CollapsibleStatsKeyProps) {
  const [isExpanded, setIsExpanded] = useState(false);
  
  const keyExplanations = statsKeyExplanations[activeCategory] || {};
  
  return (
    <div className="w-full bg-amber-100 border-b border-amber-300 mb-2">
      <div 
        className="flex items-center justify-between p-2 cursor-pointer"
        onClick={() => setIsExpanded(!isExpanded)}
      >
        <div className="font-semibold text-gray-800">STATS KEY</div>
        {isExpanded ? (
          <ChevronUp className="h-4 w-4 text-gray-800" />
        ) : (
          <ChevronDown className="h-4 w-4 text-gray-800" />
        )}
      </div>
      
      {isExpanded && (
        <div className="p-2 text-xs border-t border-amber-300 grid grid-cols-2 md:grid-cols-4 gap-2">
          {Object.entries(keyExplanations).map(([abbr, explanation]) => (
            <div key={abbr} className="flex flex-col">
              <span className="font-semibold">{abbr}:</span>
              <span className="text-gray-700">{explanation}</span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}