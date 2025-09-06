import { Link } from "wouter";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { ArrowLeft, Mail, MessageCircle, Book, ExternalLink } from "lucide-react";

export default function Support() {
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
            <h1 className="text-3xl font-bold">Support Center</h1>
            <p className="text-gray-400 mt-2">Get help and find answers to your questions</p>
          </div>
        </div>

        <div className="grid gap-6 md:grid-cols-2">
          {/* Contact Support */}
          <Card className="bg-gray-800 border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-white">
                <Mail className="h-5 w-5" />
                Contact Support
              </CardTitle>
              <CardDescription className="text-gray-400">
                Need direct help? Reach out to our support team
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <p className="text-sm text-gray-300">Email us at:</p>
                <a 
                  href="mailto:garrett.dillman@gmail.com" 
                  className="text-blue-400 hover:text-blue-300 transition-colors"
                >
                  garrett.dillman@gmail.com
                </a>
                <br />
                <a 
                  href="mailto:tiatheone@protonmail.com" 
                  className="text-blue-400 hover:text-blue-300 transition-colors"
                >
                  tiatheone@protonmail.com
                </a>
              </div>
              <Button className="w-full bg-blue-600 hover:bg-blue-700">
                <Mail className="h-4 w-4 mr-2" />
                Send Email
              </Button>
            </CardContent>
          </Card>

          {/* Live Chat */}
          <Card className="bg-gray-800 border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-white">
                <MessageCircle className="h-5 w-5" />
                Community Support
              </CardTitle>
              <CardDescription className="text-gray-400">
                Join our community for tips and discussions
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <p className="text-sm text-gray-300">
                Connect with other AFL Fantasy managers and get help from the community.
              </p>
              <Button className="w-full bg-green-600 hover:bg-green-700">
                <MessageCircle className="h-4 w-4 mr-2" />
                Join Community
              </Button>
            </CardContent>
          </Card>

          {/* Documentation */}
          <Card className="bg-gray-800 border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-white">
                <Book className="h-5 w-5" />
                Documentation
              </CardTitle>
              <CardDescription className="text-gray-400">
                Comprehensive guides and tutorials
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Link href="/guild-codex">
                  <Button variant="outline" className="w-full justify-start border-gray-600 text-white hover:bg-gray-700">
                    <Book className="h-4 w-4 mr-2" />
                    Guild Codex
                  </Button>
                </Link>
                <Link href="/features">
                  <Button variant="outline" className="w-full justify-start border-gray-600 text-white hover:bg-gray-700">
                    <ExternalLink className="h-4 w-4 mr-2" />
                    Features Guide
                  </Button>
                </Link>
              </div>
            </CardContent>
          </Card>

          {/* FAQ */}
          <Card className="bg-gray-800 border-gray-700">
            <CardHeader>
              <CardTitle className="text-white">Frequently Asked Questions</CardTitle>
              <CardDescription className="text-gray-400">
                Quick answers to common questions
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-3">
                <div>
                  <h4 className="font-medium text-white">How do I analyze my team's performance?</h4>
                  <p className="text-sm text-gray-400 mt-1">
                    Use our comprehensive dashboard and analytics tools to track your team's progress.
                  </p>
                </div>
                <div>
                  <h4 className="font-medium text-white">Can I compare players across different positions?</h4>
                  <p className="text-sm text-gray-400 mt-1">
                    Yes, our player stats tools allow cross-position comparisons and analysis.
                  </p>
                </div>
                <div>
                  <h4 className="font-medium text-white">How often is the data updated?</h4>
                  <p className="text-sm text-gray-400 mt-1">
                    Player data and scores are updated in real-time during match days.
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Additional Resources */}
        <Card className="bg-gray-800 border-gray-700 mt-6">
          <CardHeader>
            <CardTitle className="text-white">Additional Resources</CardTitle>
            <CardDescription className="text-gray-400">
              More ways to get help and stay informed
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid gap-4 md:grid-cols-3">
              <Link href="/release-notes">
                <Button variant="outline" className="w-full border-gray-600 text-white hover:bg-gray-700">
                  Release Notes
                </Button>
              </Link>
              <Link href="/privacy-policy">
                <Button variant="outline" className="w-full border-gray-600 text-white hover:bg-gray-700">
                  Privacy Policy
                </Button>
              </Link>
              <Link href="/terms-of-service">
                <Button variant="outline" className="w-full border-gray-600 text-white hover:bg-gray-700">
                  Terms of Service
                </Button>
              </Link>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
