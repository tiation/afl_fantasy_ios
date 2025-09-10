import { TradeAnalyzer } from "@/components/trade-analyzer/trade-analyzer";

export default function TradeAnalyzerPage() {
  return (
    <div className="container mx-auto">
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-3xl font-bold tracking-tight">Trade Analyzer</h2>
      </div>
      <div className="bg-white rounded-lg shadow-md p-4">
        <TradeAnalyzer />
      </div>
    </div>
  );
}