import { Link } from "wouter";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { ArrowLeft, Shield, Eye, Lock, Database, User, Mail } from "lucide-react";

export default function PrivacyPolicy() {
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
            <h1 className="text-3xl font-bold">Privacy Policy</h1>
            <p className="text-gray-400 mt-2">Last updated: January 15, 2024</p>
          </div>
        </div>

        <div className="space-y-6">
          {/* Introduction */}
          <Card className="bg-gray-800 border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-white">
                <Shield className="h-5 w-5" />
                Our Commitment to Privacy
              </CardTitle>
            </CardHeader>
            <CardContent className="text-gray-300 space-y-4">
              <p>
                At DiceRealm, we are committed to protecting your privacy and personal information. 
                This Privacy Policy explains how we collect, use, disclose, and safeguard your information 
                when you use our AFL Fantasy management platform.
              </p>
              <p>
                By using DiceRealm, you agree to the collection and use of information in accordance 
                with this policy. If you do not agree with our policies and practices, do not use our service.
              </p>
            </CardContent>
          </Card>

          {/* Information We Collect */}
          <Card className="bg-gray-800 border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-white">
                <Database className="h-5 w-5" />
                Information We Collect
              </CardTitle>
            </CardHeader>
            <CardContent className="text-gray-300 space-y-4">
              <div className="space-y-4">
                <div>
                  <h4 className="font-semibold text-white mb-2">Personal Information</h4>
                  <ul className="list-disc list-inside space-y-1 text-sm">
                    <li>Email address and contact information</li>
                    <li>Username and profile information</li>
                    <li>AFL Fantasy team data and preferences</li>
                    <li>Usage patterns and app interactions</li>
                  </ul>
                </div>
                <div>
                  <h4 className="font-semibold text-white mb-2">Automatically Collected Information</h4>
                  <ul className="list-disc list-inside space-y-1 text-sm">
                    <li>Device information and identifiers</li>
                    <li>IP address and location data</li>
                    <li>Browser type and version</li>
                    <li>Pages visited and time spent on the platform</li>
                  </ul>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* How We Use Information */}
          <Card className="bg-gray-800 border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-white">
                <Eye className="h-5 w-5" />
                How We Use Your Information
              </CardTitle>
            </CardHeader>
            <CardContent className="text-gray-300 space-y-4">
              <ul className="list-disc list-inside space-y-2 text-sm">
                <li>Provide and maintain our AFL Fantasy management services</li>
                <li>Personalize your experience and improve our platform</li>
                <li>Send you technical notices and support messages</li>
                <li>Analyze usage patterns to enhance platform performance</li>
                <li>Communicate with you about updates and new features</li>
                <li>Prevent fraud and ensure platform security</li>
              </ul>
            </CardContent>
          </Card>

          {/* Information Sharing */}
          <Card className="bg-gray-800 border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-white">
                <User className="h-5 w-5" />
                Information Sharing and Disclosure
              </CardTitle>
            </CardHeader>
            <CardContent className="text-gray-300 space-y-4">
              <p>
                We do not sell, trade, or rent your personal information to third parties. 
                We may share your information only in the following circumstances:
              </p>
              <ul className="list-disc list-inside space-y-2 text-sm">
                <li>With your explicit consent</li>
                <li>To comply with legal obligations or court orders</li>
                <li>To protect our rights, property, or safety</li>
                <li>With service providers who assist in operating our platform</li>
                <li>In connection with a business transfer or acquisition</li>
              </ul>
            </CardContent>
          </Card>

          {/* Data Security */}
          <Card className="bg-gray-800 border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-white">
                <Lock className="h-5 w-5" />
                Data Security
              </CardTitle>
            </CardHeader>
            <CardContent className="text-gray-300 space-y-4">
              <p>
                We implement appropriate technical and organizational security measures to protect 
                your personal information against unauthorized access, alteration, disclosure, or destruction.
              </p>
              <div className="grid gap-4 md:grid-cols-2">
                <div>
                  <h4 className="font-semibold text-white mb-2">Technical Safeguards</h4>
                  <ul className="list-disc list-inside space-y-1 text-sm">
                    <li>SSL/TLS encryption for data transmission</li>
                    <li>Secure database storage</li>
                    <li>Regular security audits and updates</li>
                    <li>Access controls and authentication</li>
                  </ul>
                </div>
                <div>
                  <h4 className="font-semibold text-white mb-2">Organizational Measures</h4>
                  <ul className="list-disc list-inside space-y-1 text-sm">
                    <li>Limited access to personal data</li>
                    <li>Staff training on data protection</li>
                    <li>Incident response procedures</li>
                    <li>Regular policy reviews and updates</li>
                  </ul>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Your Rights */}
          <Card className="bg-gray-800 border-gray-700">
            <CardHeader>
              <CardTitle className="text-white">Your Privacy Rights</CardTitle>
            </CardHeader>
            <CardContent className="text-gray-300 space-y-4">
              <p>You have the following rights regarding your personal information:</p>
              <ul className="list-disc list-inside space-y-2 text-sm">
                <li><strong>Access:</strong> Request access to your personal data</li>
                <li><strong>Rectification:</strong> Request correction of inaccurate data</li>
                <li><strong>Erasure:</strong> Request deletion of your personal data</li>
                <li><strong>Portability:</strong> Request transfer of your data</li>
                <li><strong>Objection:</strong> Object to processing of your data</li>
                <li><strong>Restriction:</strong> Request restriction of data processing</li>
              </ul>
            </CardContent>
          </Card>

          {/* Contact Information */}
          <Card className="bg-gray-800 border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-white">
                <Mail className="h-5 w-5" />
                Contact Us
              </CardTitle>
            </CardHeader>
            <CardContent className="text-gray-300 space-y-4">
              <p>
                If you have any questions about this Privacy Policy or our data practices, 
                please contact us:
              </p>
              <div className="space-y-2">
                <p><strong>Email:</strong> 
                  <a href="mailto:garrett.dillman@gmail.com" className="text-blue-400 hover:text-blue-300 ml-2">
                    garrett.dillman@gmail.com
                  </a>
                </p>
                <p><strong>Email:</strong> 
                  <a href="mailto:tiatheone@protonmail.com" className="text-blue-400 hover:text-blue-300 ml-2">
                    tiatheone@protonmail.com
                  </a>
                </p>
              </div>
              <div className="flex gap-4 mt-4">
                <Link href="/support">
                  <Button className="bg-blue-600 hover:bg-blue-700">
                    Contact Support
                  </Button>
                </Link>
                <Link href="/terms-of-service">
                  <Button variant="outline" className="border-gray-600 text-white hover:bg-gray-700">
                    Terms of Service
                  </Button>
                </Link>
              </div>
            </CardContent>
          </Card>

          {/* Updates */}
          <Card className="bg-gray-800 border-gray-700">
            <CardHeader>
              <CardTitle className="text-white">Policy Updates</CardTitle>
            </CardHeader>
            <CardContent className="text-gray-300 space-y-4">
              <p>
                We may update this Privacy Policy from time to time. We will notify you of any changes 
                by posting the new Privacy Policy on this page and updating the "Last updated" date.
              </p>
              <p>
                We recommend reviewing this Privacy Policy periodically for any changes. 
                Changes to this Privacy Policy are effective when they are posted on this page.
              </p>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
