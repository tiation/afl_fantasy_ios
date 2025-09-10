import { Link } from "wouter";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { ArrowLeft, TrendingUp, BarChart3, Users, Zap, Brain, Target, Calendar, Shield } from "lucide-react";

export default function Features() {
  const features = [
    {
      icon: <BarChart3 className="h-6 w-6" />,
      title: "Advanced Analytics",
      description: "Deep dive into player statistics with comprehensive analytics and performance tracking.",
      highlights: ["Heat map visualizations", "Trend analysis", "Performance predictions", "Historical comparisons"],
      category: "Analytics"
    },
    {
      icon: <TrendingUp className="h-6 w-6" />,
      title: "Team Performance Tracking",
      description: "Monitor your team's progress with detailed performance charts and metrics.",
      highlights: ["Real-time score updates", "Rank tracking", "Value analysis", "Season progression"],
      category: "Performance"
    },
    {
      icon: <Brain className="h-6 w-6" />,
      title: "AI-Powered Insights",
      description: "Get intelligent recommendations powered by machine learning algorithms.",
      highlights: ["Trade suggestions", "Captain recommendations", "Risk analysis", "Lineup optimization"],
      category: "AI Tools"
    },
    {
      icon: <Target className="h-6 w-6" />,
      title: "Strategic Tools", 
      description: "Comprehensive suite of tools to optimize your fantasy strategy.",
      highlights: ["Cash generation tracking", "Breakeven analysis", "Price prediction", "Value finder"],
      category: "Strategy"
    },
    {
      icon: <Calendar className="h-6 w-6" />,
      title: "Fixture Analysis",
      description: "Analyze upcoming fixtures and plan your trades accordingly.",
      highlights: ["Difficulty ratings", "Bye round planning", "Venue analysis", "Weather impacts"],
      category: "Planning"
    },
    {
      icon: <Users className="h-6 w-6" />,
      title: "League Management",
      description: "Manage multiple leagues and compare performance across competitions.",
      highlights: ["Multi-league support", "Head-to-head tracking", "League standings", "Performance comparison"],
      category: "Social"
    },
    {
      icon: <Zap className="h-6 w-6" />,
      title: "Real-Time Updates",
      description: "Stay updated with live scores and instant notifications.",
      highlights: ["Live scoring", "Price changes", "Injury updates", "Late outs alerts"],
      category: "Live Data"
    },
    {
      icon: <Shield className="h-6 w-6" />,
      title: "Risk Management",
      description: "Identify and manage risks in your fantasy team selection.",
      highlights: ["Injury risk analysis", "Volatility tracking", "Consistency scores", "Form analysis"],
      category: "Risk"
    }
  ];

  const getCategoryColor = (category: string) => {
    const colors = {
      "Analytics": "bg-blue-600",
      "Performance": "bg-green-600", 
      "AI Tools": "bg-purple-600",
      "Strategy": "bg-orange-600",
      "Planning": "bg-cyan-600",
      "Social": "bg-pink-600",
      "Live Data": "bg-red-600",
      "Risk": "bg-yellow-600"
    };
    return colors[category as keyof typeof colors] || "bg-gray-600";
  };

  return (
    <div className="min-h-screen bg-gray-900 text-white p-6">
      <div className="max-w-6xl mx-auto">
        {/* Header with back navigation */}
        <div className="flex items-center gap-4 mb-8">
          <Link href="/">
            <Button variant="ghost" size="sm" className="text-white hover:text-gray-300">
              <ArrowLeft className="h-4 w-4 mr-2" />
              Back to DiceRealm
            </Button>
          </Link>
          <div>
            <h1 className="text-3xl font-bold">Features</h1>
            <p className="text-gray-400 mt-2">Discover all the powerful tools and features that make DiceRealm the ultimate AFL Fantasy companion</p>
          </div>
        </div>

        {/* Features Grid */}
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {features.map((feature, index) => (
            <Card key={index} className="bg-gray-800 border-gray-700 hover:border-gray-600 transition-colors">
              <CardHeader>
                <div className="flex items-center justify-between mb-2">
                  <div className="flex items-center gap-3">
                    <div className="p-2 bg-gray-700 rounded-lg text-blue-400">
                      {feature.icon}
                    </div>
                    <Badge className={`${getCategoryColor(feature.category)} text-white text-xs`}>
                      {feature.category}
                    </Badge>
                  </div>
                </div>
                <CardTitle className="text-white">{feature.title}</CardTitle>
                <CardDescription className="text-gray-400">
                  {feature.description}
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-2">
                  <h4 className="font-medium text-white text-sm">Key Features:</h4>
                  <ul className="space-y-1">
                    {feature.highlights.map((highlight, highlightIndex) => (
                      <li key={highlightIndex} className="text-sm text-gray-300 flex items-center gap-2">
                        <div className="w-1.5 h-1.5 bg-blue-400 rounded-full flex-shrink-0"></div>
                        {highlight}
                      </li>
                    ))}
                  </ul>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>

        {/* Call to Action */}
        <Card className="bg-gray-800 border-gray-700 mt-8">
          <CardContent className="p-8">
            <div className="text-center space-y-4">
              <h2 className="text-2xl font-bold text-white">Ready to Elevate Your Fantasy Game?</h2>
              <p className="text-gray-400 max-w-2xl mx-auto">
                Join thousands of AFL Fantasy managers who use DiceRealm to gain a competitive edge. 
                Start exploring our comprehensive suite of tools and analytics today.
              </p>
              <div className="flex justify-center gap-4 mt-6">
                <Link href="/">
                  <Button className="bg-blue-600 hover:bg-blue-700">
                    Start Using DiceRealm
                  </Button>
                </Link>
                <Link href="/guild-codex">
                  <Button variant="outline" className="border-gray-600 text-white hover:bg-gray-700">
                    Learn More
                  </Button>
                </Link>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Additional Resources */}
        <div className="grid gap-4 md:grid-cols-3 mt-8">
          <Link href="/support">
            <Card className="bg-gray-800 border-gray-700 hover:border-gray-600 transition-colors cursor-pointer">
              <CardContent className="p-6 text-center">
                <h3 className="font-semibold text-white mb-2">Need Help?</h3>
                <p className="text-sm text-gray-400">Get support and answers to your questions</p>
              </CardContent>
            </Card>
          </Link>
          
          <Link href="/release-notes">
            <Card className="bg-gray-800 border-gray-700 hover:border-gray-600 transition-colors cursor-pointer">
              <CardContent className="p-6 text-center">
                <h3 className="font-semibold text-white mb-2">What's New?</h3>
                <p className="text-sm text-gray-400">Check out the latest updates and improvements</p>
              </CardContent>
            </Card>
          </Link>
          
          <Link href="/contact-us">
            <Card className="bg-gray-800 border-gray-700 hover:border-gray-600 transition-colors cursor-pointer">
              <CardContent className="p-6 text-center">
                <h3 className="font-semibold text-white mb-2">Got Feedback?</h3>
                <p className="text-sm text-gray-400">Share your ideas and suggestions with us</p>
              </CardContent>
            </Card>
          </Link>
        </div>
      </div>
    </div>
  );
}
