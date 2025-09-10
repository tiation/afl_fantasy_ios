import { useEffect, useState } from "react";
import { Link } from "wouter";
import { apiRequest } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { Button } from "@/components/ui/button";
import { Loader2 } from "lucide-react";

type Tool = {
  id: string;
  name: string;
  description: string;
};

type ToolCategory = {
  id: string;
  name: string;
  description: string;
  tools: Tool[];
};

export default function FantasyToolsPage() {
  const [categories, setCategories] = useState<ToolCategory[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedCategory, setSelectedCategory] = useState<string>("");
  const [selectedTool, setSelectedTool] = useState<string>("");
  const { toast } = useToast();

  useEffect(() => {
    async function fetchTools() {
      try {
        setLoading(true);
        const response = await apiRequest("GET", "/api/fantasy/tools");
        const data = await response.json();
        setCategories(data);
        setSelectedCategory(data.length > 0 ? data[0].id : "");
      } catch (error) {
        console.error("Error fetching fantasy tools:", error);
        toast({
          title: "Error",
          description: "Failed to load fantasy tools. Please try again later.",
          variant: "destructive",
        });
      } finally {
        setLoading(false);
      }
    }

    fetchTools();
  }, [toast]);

  const handleToolClick = (toolId: string) => {
    setSelectedTool(toolId);
  };

  // Filter implemented tools - we'll expand this as we implement more tools
  const implementedTools = [
    "trade_score_calculator",
    "trade_optimizer",
    "one_up_one_down_suggester", 
    "price_difference_delta",
    "value_gain_tracker",
    "trade_burn_risk_analyzer",
    "trade_return_analyzer",
    "cash_generation_tracker",
    "rookie_price_curve_model",
    "downgrade_target_finder",
    "cash_gen_ceiling_floor",
    "price_predictor_calculator",
    "price_ceiling_floor_estimator"
  ];

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen">
        <Loader2 className="h-12 w-12 animate-spin text-primary" />
        <p className="mt-4 text-lg font-semibold">Loading AFL Fantasy Tools...</p>
      </div>
    );
  }

  return (
    <div className="container py-8">
      <h1 className="text-3xl font-bold mb-2">AFL Fantasy Tools</h1>
      <p className="text-muted-foreground mb-8">
        Advanced analytics and tools to optimize your AFL Fantasy team
      </p>

      <Tabs value={selectedCategory} onValueChange={setSelectedCategory}>
        <TabsList className="mb-6 grid grid-cols-2 md:grid-cols-4 lg:grid-cols-8">
          {categories.map((category) => (
            <TabsTrigger key={category.id} value={category.id}>
              {category.name}
            </TabsTrigger>
          ))}
        </TabsList>

        {categories.map((category) => (
          <TabsContent key={category.id} value={category.id}>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {category.tools.map((tool) => (
                <Card
                  key={tool.id}
                  className={`cursor-pointer transition-all ${
                    implementedTools.includes(tool.id) 
                      ? "hover:shadow-md hover:border-primary" 
                      : "opacity-60"
                  }`}
                  onClick={() => implementedTools.includes(tool.id) && handleToolClick(tool.id)}
                >
                  <CardHeader>
                    <CardTitle>{tool.name}</CardTitle>
                    <CardDescription>{tool.description}</CardDescription>
                  </CardHeader>
                  <CardContent>
                    {implementedTools.includes(tool.id) ? (
                      <Link href={`/fantasy-tools/${tool.id}`}>
                        <Button variant="default">Use Tool</Button>
                      </Link>
                    ) : (
                      <Button variant="outline" disabled>
                        Coming Soon
                      </Button>
                    )}
                  </CardContent>
                </Card>
              ))}
            </div>
          </TabsContent>
        ))}
      </Tabs>

      {/* Customized tools description section */}
      <div className="mt-16">
        <h2 className="text-2xl font-bold mb-4">About AFL Fantasy Tools</h2>
        <Separator className="mb-6" />
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          <div>
            <h3 className="text-xl font-semibold mb-2">Trading Intelligence</h3>
            <p className="text-muted-foreground">
              Our trade analysis tools use actual player data, price trends, and projected scores to evaluate trade options. 
              Each trade is scored based on immediate impact, projected value changes, and season context.
            </p>
          </div>
          <div>
            <h3 className="text-xl font-semibold mb-2">Cash Generation</h3>
            <p className="text-muted-foreground">
              Maximize your team value with tools that track price changes, identify optimal downgrade targets, and predict when rookies will peak in value.
            </p>
          </div>
          <div>
            <h3 className="text-xl font-semibold mb-2">Price Prediction</h3>
            <p className="text-muted-foreground">
              Our price prediction tools use AFL Fantasy's pricing algorithm to project future player prices based on expected performance, breakeven scores, and historical trends.
            </p>
          </div>
          <div>
            <h3 className="text-xl font-semibold mb-2">Risk Analysis</h3>
            <p className="text-muted-foreground">
              Evaluate the risk of using trades, monitor tag threats, assess injury risks, and measure player consistency with our advanced risk analysis tools.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}