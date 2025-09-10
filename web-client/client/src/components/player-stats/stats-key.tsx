import { useState } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { ChevronDown, ChevronUp } from "lucide-react";
import { StatsCategory } from "./player-types";

type StatsKeyProps = {
  category: StatsCategory;
};

export default function StatsKey({ category }: StatsKeyProps) {
  const [isExpanded, setIsExpanded] = useState(false);

  const toggleExpand = () => {
    setIsExpanded(!isExpanded);
  };

  const renderCategoryAbbreviations = () => {
    switch (category) {
      case 'basic':
        return (
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div>
              <p><span className="font-semibold">K:</span> Kicks</p>
              <p><span className="font-semibold">HB:</span> Handballs</p>
              <p><span className="font-semibold">D:</span> Disposals</p>
            </div>
            <div>
              <p><span className="font-semibold">M:</span> Marks</p>
              <p><span className="font-semibold">T:</span> Tackles</p>
              <p><span className="font-semibold">C:</span> Clearances</p>
            </div>
            <div>
              <p><span className="font-semibold">FF:</span> Free Kicks For</p>
              <p><span className="font-semibold">FA:</span> Free Kicks Against</p>
              <p><span className="font-semibold">HO:</span> Hitouts</p>
            </div>
            <div>
              <p><span className="font-semibold">CBA%:</span> Center Bounce Attendance %</p>
              <p><span className="font-semibold">KI:</span> Kick-Ins</p>
              <p><span className="font-semibold">CM:</span> Contested Marks</p>
            </div>
          </div>
        );
      case 'fantasy':
        return (
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div>
              <p><span className="font-semibold">Avg:</span> Average Score</p>
              <p><span className="font-semibold">L3 Avg:</span> Last 3 Games Average</p>
              <p><span className="font-semibold">L5 Avg:</span> Last 5 Games Average</p>
            </div>
            <div>
              <p><span className="font-semibold">BE:</span> Break Even</p>
              <p><span className="font-semibold">$/Point:</span> Price per Point</p>
              <p><span className="font-semibold">Own %:</span> Selection Percentage</p>
            </div>
            <div>
              <p><span className="font-semibold">Last Rd:</span> Last Round Score</p>
              <p><span className="font-semibold">Total:</span> Total Points</p>
              <p><span className="font-semibold">GP:</span> Games Played</p>
            </div>
            <div>
              <p><span className="font-semibold">Price:</span> Current Player Value</p>
              <p><span className="font-semibold">$ Ch:</span> Price Change</p>
              <p><span className="font-semibold">INJ:</span> Injured</p>
            </div>
          </div>
        );
      case 'value':
        return (
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div>
              <p><span className="font-semibold">Value:</span> Current Price</p>
              <p><span className="font-semibold">BE:</span> Break Even</p>
              <p><span className="font-semibold">BE%:</span> Break Even as % of Avg</p>
            </div>
            <div>
              <p><span className="font-semibold">Proj Score:</span> Projected Score</p>
              <p><span className="font-semibold">Proj $ Ch:</span> Projected Price Change</p>
              <p><span className="font-semibold">Proj Own %:</span> Projected Ownership Change</p>
            </div>
            <div>
              <p><span className="text-green-600 font-semibold">Green BE%:</span> Good value (under 40%)</p>
              <p><span className="text-red-600 font-semibold">Red BE%:</span> Poor value (over 80%)</p>
            </div>
            <div>
              <p><span className="text-green-600 font-semibold">Green $ Ch:</span> Price increase</p>
              <p><span className="text-red-600 font-semibold">Red $ Ch:</span> Price decrease</p>
            </div>
          </div>
        );
      case 'consistency':
        return (
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div>
              <p><span className="font-semibold">GP:</span> Games Played</p>
              <p><span className="font-semibold">Avg:</span> Average Score</p>
              <p><span className="font-semibold">Std Dev:</span> Standard Deviation</p>
            </div>
            <div>
              <p><span className="font-semibold">High:</span> Highest Score</p>
              <p><span className="font-semibold">Low:</span> Lowest Score</p>
              <p><span className="font-semibold">% Below Avg:</span> % of Games Below Average</p>
            </div>
            <div>
              <p><span className="text-green-600 font-semibold">Green Std Dev:</span> Very consistent (&lt;20% of avg)</p>
              <p><span className="text-red-600 font-semibold">Red Std Dev:</span> Inconsistent (&gt;40% of avg)</p>
            </div>
            <div>
              <p><span className="text-green-600 font-semibold">Green % Below:</span> Reliable (&lt;25%)</p>
              <p><span className="text-red-600 font-semibold">Red % Below:</span> Unreliable (&gt;50%)</p>
            </div>
          </div>
        );
      case 'opposition':
        return (
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div>
              <p><span className="font-semibold">Next Opp:</span> Next Opponent</p>
              <p><span className="font-semibold">Avg vs Opp:</span> Average Against Opponent</p>
              <p><span className="font-semibold">3R Diff:</span> 3-Round Difficulty Rating</p>
            </div>
            <div>
              <p><span className="font-semibold">Score Impact:</span> Projected Impact on Score</p>
              <p><span className="font-semibold">Proj Avg:</span> Projected Average</p>
            </div>
            <div>
              <p><span className="text-green-600 font-semibold">Green Diff:</span> Easy fixture (&lt;4/10)</p>
              <p><span className="text-red-600 font-semibold">Red Diff:</span> Hard fixture (&gt;7/10)</p>
            </div>
            <div>
              <p><span className="text-green-600 font-semibold">Green Impact:</span> Positive impact</p>
              <p><span className="text-red-600 font-semibold">Red Impact:</span> Negative impact</p>
            </div>
          </div>
        );
      case 'venue':
        return (
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div>
              <p><span className="font-semibold">Next Venue:</span> Next Match Venue</p>
              <p><span className="font-semibold">Avg at Venue:</span> Average at Venue</p>
              <p><span className="font-semibold">3R Venue Avg:</span> 3-Round Venue Average</p>
            </div>
            <div>
              <p><span className="font-semibold">3R Diff Rating:</span> 3-Round Difficulty Rating</p>
              <p><span className="font-semibold">Venue Variance:</span> Score Variance at Venue</p>
            </div>
            <div>
              <p><span className="text-green-600 font-semibold">Green Venue Var:</span> Consistent at venue (&lt;10)</p>
              <p><span className="text-red-600 font-semibold">Red Venue Var:</span> Inconsistent at venue (&gt;20)</p>
            </div>
            <div>
              <p><span className="text-green-600 font-semibold">Green Diff:</span> Easy fixture (&lt;4/10)</p>
              <p><span className="text-red-600 font-semibold">Red Diff:</span> Hard fixture (&gt;7/10)</p>
            </div>
          </div>
        );
      default:
        return null;
    }
  };

  const getCategoryTitle = () => {
    switch (category) {
      case 'basic': return 'Basic Stats';
      case 'fantasy': return 'Fantasy Scores';
      case 'value': return 'Value Predictor';
      case 'consistency': return 'Consistency Metrics';
      case 'opposition': return 'Opposition Analysis';
      case 'venue': return 'Venue History';
      default: return 'Statistics Key';
    }
  };

  return (
    <Card className="mb-4">
      <CardContent className="p-4">
        <div
          className="flex justify-between items-center cursor-pointer"
          onClick={toggleExpand}
        >
          <h3 className="font-semibold text-lg">{getCategoryTitle()} - Statistics Key</h3>
          <Button variant="ghost" size="sm">
            {isExpanded ? (
              <ChevronUp className="h-5 w-5" />
            ) : (
              <ChevronDown className="h-5 w-5" />
            )}
          </Button>
        </div>
        
        {isExpanded && (
          <div className="mt-4 text-sm">
            {renderCategoryAbbreviations()}
          </div>
        )}
      </CardContent>
    </Card>
  );
}