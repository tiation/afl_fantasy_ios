import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue
} from "@/components/ui/select";
import { StatsCategory } from "./player-types";
import { ChartBarIcon } from "lucide-react";

type CategorySelectorProps = {
  category: StatsCategory;
  onCategoryChange: (category: StatsCategory) => void;
};

export default function CategorySelector({ category, onCategoryChange }: CategorySelectorProps) {
  // Category display labels
  const categoryLabels = {
    basic: "Basic Stats",
    fantasy: "Fantasy Scores",
    value: "Value Predictor",
    consistency: "Consistency Metrics",
    opposition: "Opposition Analysis",
    venue: "Venue History"
  };

  return (
    <div className="mb-4">
      <Select
        value={category}
        onValueChange={(value) => onCategoryChange(value as StatsCategory)}
      >
        <SelectTrigger className="w-full bg-white">
          <div className="flex items-center">
            <ChartBarIcon className="mr-2 h-4 w-4 text-primary" />
            <span className="font-medium">{categoryLabels[category]}</span>
          </div>
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="basic">Basic Stats</SelectItem>
          <SelectItem value="fantasy">Fantasy Scores</SelectItem>
          <SelectItem value="value">Value Predictor</SelectItem>
          <SelectItem value="consistency">Consistency Metrics</SelectItem>
          <SelectItem value="opposition">Opposition Analysis</SelectItem>
          <SelectItem value="venue">Venue History</SelectItem>
        </SelectContent>
      </Select>
    </div>
  );
}