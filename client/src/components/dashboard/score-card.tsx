import { Card, CardContent } from "@/components/ui/card";
import { ArrowUp, Award, BarChart2, TrendingUp } from "lucide-react";
import { cn } from "@/lib/utils";

export type ScoreCardProps = {
  title: string;
  value: string;
  change?: string;
  icon?: "chart" | "award" | "trend-up" | "arrow-up";
  isPositive?: boolean;
  className?: string;
  borderColor?: string;
};

export default function ScoreCard({ 
  title, 
  value, 
  change, 
  icon = "trend-up",
  isPositive = true,
  className,
  borderColor = "border-blue-500"
}: ScoreCardProps) {
  return (
    <Card className={cn("h-full bg-gray-800 border-2", borderColor, className)}>
      <CardContent className="p-4">
        <div className="flex justify-between items-start mb-2">
          <h2 className="text-lg font-medium text-white">{title}</h2>
          <div className="text-gray-400">
            {icon === "chart" && <BarChart2 className="h-5 w-5" />}
            {icon === "award" && <Award className="h-5 w-5" />}
            {icon === "trend-up" && <TrendingUp className="h-5 w-5" />}
            {icon === "arrow-up" && <ArrowUp className="h-5 w-5" />}
          </div>
        </div>
        <div className="text-3xl font-bold text-white">{value}</div>
        {change && (
          <div className={cn(
            "text-sm mt-1", 
            isPositive ? "text-green-400" : "text-red-400"
          )}>
            {change}
          </div>
        )}
      </CardContent>
    </Card>
  );
}
