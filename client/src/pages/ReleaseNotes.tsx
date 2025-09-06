import { Link } from "wouter";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { ArrowLeft, Calendar, Plus, Bug, Zap, Star } from "lucide-react";

export default function ReleaseNotes() {
  const releases = [
    {
      version: "2.1.0",
      date: "2024-01-15",
      type: "feature",
      title: "Enhanced Player Analytics",
      description: "Major update with improved player comparison tools and advanced statistics.",
      items: [
        { type: "feature", text: "New heat map visualization for player performance" },
        { type: "feature", text: "Advanced filtering options in player stats" },
        { type: "feature", text: "Cross-position player comparison tool" },
        { type: "improvement", text: "Faster data loading and improved caching" },
        { type: "fix", text: "Fixed issue with captain score calculations" }
      ]
    },
    {
      version: "2.0.5",
      date: "2024-01-08",
      type: "fix",
      title: "Bug Fixes & Performance",
      description: "Critical fixes and performance improvements.",
      items: [
        { type: "fix", text: "Resolved trade calculator accuracy issues" },
        { type: "fix", text: "Fixed mobile navigation menu overlapping" },
        { type: "improvement", text: "Optimized database queries for faster loading" },
        { type: "fix", text: "Corrected team value calculations for bench players" }
      ]
    },
    {
      version: "2.0.0",
      date: "2024-01-01",
      type: "major",
      title: "New Year, New Interface",
      description: "Complete redesign with modern UI and enhanced user experience.",
      items: [
        { type: "feature", text: "Brand new dashboard with real-time updates" },
        { type: "feature", text: "Redesigned navigation with improved mobile support" },
        { type: "feature", text: "New team structure visualization" },
        { type: "feature", text: "Enhanced trade analysis tools" },
        { type: "feature", text: "Improved performance charts and analytics" },
        { type: "improvement", text: "Better responsive design for all devices" }
      ]
    },
    {
      version: "1.8.2",
      date: "2023-12-20",
      type: "feature",
      title: "Holiday Update",
      description: "New features and improvements for the holiday season.",
      items: [
        { type: "feature", text: "Added fixture difficulty analysis" },
        { type: "feature", text: "New bye round planning tools" },
        { type: "improvement", text: "Enhanced price prediction algorithms" },
        { type: "fix", text: "Fixed issues with player price tracking" }
      ]
    }
  ];

  const getTypeColor = (type: string) => {
    switch (type) {
      case "feature": return "bg-green-600";
      case "fix": return "bg-red-600";
      case "improvement": return "bg-blue-600";
      case "major": return "bg-purple-600";
      default: return "bg-gray-600";
    }
  };

  const getTypeIcon = (type: string) => {
    switch (type) {
      case "feature": return <Plus className="h-3 w-3" />;
      case "fix": return <Bug className="h-3 w-3" />;
      case "improvement": return <Zap className="h-3 w-3" />;
      case "major": return <Star className="h-3 w-3" />;
      default: return null;
    }
  };

  return (
    <div className="min-h-screen bg-gray-900 text-white p-6">
      <div className="max-w-4xl mx-auto">
        {/* Header with back navigation */}
        <div className="flex items-center gap-4 mb-8">
          <Link href="/">
            <Button variant="ghost" size="sm" className="text-white hover:text-gray-300">
              <ArrowLeft className="h-4 w-4 mr-2" />
              Back to DiceRealm
            </Button>
          </Link>
          <div>
            <h1 className="text-3xl font-bold">Release Notes</h1>
            <p className="text-gray-400 mt-2">Stay up to date with the latest features and improvements</p>
          </div>
        </div>

        {/* Release Timeline */}
        <div className="space-y-6">
          {releases.map((release, index) => (
            <Card key={release.version} className="bg-gray-800 border-gray-700">
              <CardHeader>
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <Badge className={`${getTypeColor(release.type)} text-white`}>
                      {getTypeIcon(release.type)}
                      <span className="ml-1">v{release.version}</span>
                    </Badge>
                    <div className="flex items-center gap-2 text-gray-400">
                      <Calendar className="h-4 w-4" />
                      <span className="text-sm">{release.date}</span>
                    </div>
                  </div>
                  {index === 0 && (
                    <Badge variant="outline" className="text-green-400 border-green-400">
                      Latest
                    </Badge>
                  )}
                </div>
                <CardTitle className="text-white">{release.title}</CardTitle>
                <CardDescription className="text-gray-400">
                  {release.description}
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  {release.items.map((item, itemIndex) => (
                    <div key={itemIndex} className="flex items-start gap-3">
                      <div className={`p-1 rounded ${getTypeColor(item.type)} flex-shrink-0 mt-0.5`}>
                        {getTypeIcon(item.type)}
                      </div>
                      <span className="text-gray-300 text-sm">{item.text}</span>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          ))}
        </div>

        {/* Footer */}
        <Card className="bg-gray-800 border-gray-700 mt-8">
          <CardContent className="p-6">
            <div className="text-center space-y-4">
              <h3 className="text-lg font-semibold text-white">Want to suggest a feature?</h3>
              <p className="text-gray-400">
                We're always looking to improve DiceRealm. Send us your ideas and feedback!
              </p>
              <div className="flex justify-center gap-4">
                <Link href="/support">
                  <Button className="bg-blue-600 hover:bg-blue-700">
                    Contact Support
                  </Button>
                </Link>
                <Link href="/contact-us">
                  <Button variant="outline" className="border-gray-600 text-white hover:bg-gray-700">
                    Send Feedback
                  </Button>
                </Link>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
