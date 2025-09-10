/**
 * Progressive Page Update Example
 * 
 * This demonstrates how pages can be updated progressively now that
 * the Layout component handles all the common structure.
 */

import React from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { CheckCircle, Clock, ArrowRight } from 'lucide-react';

// Example of a progressively updated page component
export default function ProgressivePageExample() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-white mb-2">Progressive Page Updates</h1>
        <p className="text-gray-400">
          This page demonstrates how easy it is to update pages now that Layout handles all the common structure.
        </p>
      </div>

      {/* Before/After Comparison */}
      <div className="grid lg:grid-cols-2 gap-6">
        <Card className="bg-gray-800 border-gray-700">
          <CardHeader>
            <CardTitle className="text-white flex items-center gap-2">
              <Clock className="h-5 w-5 text-orange-500" />
              Before: Complex Layout Management
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="bg-gray-900 p-4 rounded-lg">
              <pre className="text-sm text-gray-300 overflow-x-auto">
{`// Old page structure - lots of layout code
export default function MyPage() {
  const isMobile = useIsMobile();
  
  return (
    <div className="flex min-h-screen bg-gray-900">
      {!isMobile && <Sidebar />}
      <div className="flex-1 overflow-auto">
        <Header />
        <div className="p-4 bg-gray-900">
          <TooltipProvider>
            {/* Actual page content */}
            <h1>My Page</h1>
            <p>Content here...</p>
          </TooltipProvider>
        </div>
      </div>
      <BottomNav />
    </div>
  );
}`}
              </pre>
            </div>
            <Badge variant="destructive">Repetitive</Badge>
            <Badge variant="destructive">Hard to maintain</Badge>
            <Badge variant="destructive">Inconsistent</Badge>
          </CardContent>
        </Card>

        <Card className="bg-gray-800 border-gray-700">
          <CardHeader>
            <CardTitle className="text-white flex items-center gap-2">
              <CheckCircle className="h-5 w-5 text-green-500" />
              After: Clean & Simple
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="bg-gray-900 p-4 rounded-lg">
              <pre className="text-sm text-gray-300 overflow-x-auto">
{`// New page structure - only content matters
export default function MyPage() {
  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold">My Page</h1>
      <p className="text-gray-400">
        Content here... Layout is handled automatically!
      </p>
      
      {/* Page-specific components */}
      <MyPageContent />
    </div>
  );
}`}
              </pre>
            </div>
            <Badge variant="secondary" className="bg-green-500/20 text-green-300">Clean</Badge>
            <Badge variant="secondary" className="bg-green-500/20 text-green-300">Maintainable</Badge>
            <Badge variant="secondary" className="bg-green-500/20 text-green-300">Consistent</Badge>
          </CardContent>
        </Card>
      </div>

      {/* Benefits */}
      <Card className="bg-gray-800 border-gray-700">
        <CardHeader>
          <CardTitle className="text-white">Benefits of the Layout Component</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
            {[
              {
                title: "Automatic TooltipProvider",
                description: "Every page gets tooltip functionality without extra imports"
              },
              {
                title: "Quick Links Navigation",
                description: "Consistent navigation bar across all pages"
              },
              {
                title: "Responsive Design",
                description: "Sidebar on desktop, bottom nav on mobile - automatically handled"
              },
              {
                title: "DRY Principle",
                description: "No duplicate layout code across pages"
              },
              {
                title: "Easy Maintenance", 
                description: "Layout changes only need to be made in one place"
              },
              {
                title: "Progressive Updates",
                description: "Existing pages work without modification"
              }
            ].map((benefit, index) => (
              <div key={index} className="p-4 bg-gray-900 rounded-lg">
                <h3 className="font-semibold text-white mb-2 flex items-center gap-2">
                  <ArrowRight className="h-4 w-4 text-blue-400" />
                  {benefit.title}
                </h3>
                <p className="text-gray-400 text-sm">{benefit.description}</p>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Implementation Status */}
      <Card className="bg-gray-800 border-gray-700">
        <CardHeader>
          <CardTitle className="text-white">Implementation Status</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            {[
              "Layout component created with TooltipProvider wrapper",
              "Enhanced Navbar with Quick Links added",
              "All routes updated to use Layout component",
              "Build tested and working successfully",
              "Ready for progressive page updates"
            ].map((item, index) => (
              <div key={index} className="flex items-center gap-3">
                <CheckCircle className="h-5 w-5 text-green-500 flex-shrink-0" />
                <span className="text-gray-300">{item}</span>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
