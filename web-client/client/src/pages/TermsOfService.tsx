import { Link } from "wouter";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { ArrowLeft, FileText, Users, Shield, AlertTriangle, Scale, Mail } from "lucide-react";

export default function TermsOfService() {
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
            <h1 className="text-3xl font-bold">Terms of Service</h1>
            <p className="text-gray-400 mt-2">Last updated: January 15, 2024</p>
          </div>
        </div>

        <div className="space-y-6">
          {/* Introduction */}
          <Card className="bg-gray-800 border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-white">
                <FileText className="h-5 w-5" />
                Agreement to Terms
              </CardTitle>
            </CardHeader>
            <CardContent className="text-gray-300 space-y-4">
              <p>
                Welcome to DiceRealm! These Terms of Service ("Terms") govern your use of our 
                AFL Fantasy management platform and services. By accessing or using DiceRealm, 
                you agree to be bound by these Terms.
              </p>
              <p>
                If you do not agree to these Terms, please do not access or use our services. 
                We may modify these Terms at any time, and such modifications will be effective 
                immediately upon posting.
              </p>
            </CardContent>
          </Card>

          {/* Account Responsibilities */}
          <Card className="bg-gray-800 border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-white">
                <Users className="h-5 w-5" />
                User Accounts and Responsibilities
              </CardTitle>
            </CardHeader>
            <CardContent className="text-gray-300 space-y-4">
              <div className="space-y-4">
                <div>
                  <h4 className="font-semibold text-white mb-2">Account Creation</h4>
                  <ul className="list-disc list-inside space-y-1 text-sm">
                    <li>You must provide accurate and complete information</li>
                    <li>You are responsible for maintaining account security</li>
                    <li>You must be at least 13 years old to create an account</li>
                    <li>One account per person is permitted</li>
                  </ul>
                </div>
                <div>
                  <h4 className="font-semibold text-white mb-2">Account Security</h4>
                  <ul className="list-disc list-inside space-y-1 text-sm">
                    <li>Keep your login credentials confidential</li>
                    <li>Notify us immediately of any unauthorized access</li>
                    <li>You are liable for all activities under your account</li>
                    <li>Use strong passwords and enable two-factor authentication when available</li>
                  </ul>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Acceptable Use */}
          <Card className="bg-gray-800 border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-white">
                <Shield className="h-5 w-5" />
                Acceptable Use Policy
              </CardTitle>
            </CardHeader>
            <CardContent className="text-gray-300 space-y-4">
              <div className="space-y-4">
                <div>
                  <h4 className="font-semibold text-white mb-2">Permitted Uses</h4>
                  <ul className="list-disc list-inside space-y-1 text-sm">
                    <li>Manage your AFL Fantasy teams and analyze performance</li>
                    <li>Access player statistics and analytics tools</li>
                    <li>Share insights with other users in accordance with these Terms</li>
                    <li>Use the platform for personal, non-commercial purposes</li>
                  </ul>
                </div>
                <div>
                  <h4 className="font-semibold text-white mb-2">Prohibited Activities</h4>
                  <ul className="list-disc list-inside space-y-1 text-sm">
                    <li>Attempt to gain unauthorized access to our systems</li>
                    <li>Use automated tools to scrape or extract data</li>
                    <li>Share or redistribute our proprietary algorithms or data</li>
                    <li>Engage in any activity that could harm or interfere with our services</li>
                    <li>Violate any applicable laws or regulations</li>
                  </ul>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Intellectual Property */}
          <Card className="bg-gray-800 border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-white">
                <Scale className="h-5 w-5" />
                Intellectual Property Rights
              </CardTitle>
            </CardHeader>
            <CardContent className="text-gray-300 space-y-4">
              <div className="space-y-4">
                <div>
                  <h4 className="font-semibold text-white mb-2">Our Content</h4>
                  <p className="text-sm">
                    All content, features, and functionality of DiceRealm, including but not limited to 
                    text, graphics, logos, algorithms, and software, are owned by us and protected by 
                    intellectual property laws.
                  </p>
                </div>
                <div>
                  <h4 className="font-semibold text-white mb-2">Your Content</h4>
                  <p className="text-sm">
                    You retain ownership of any content you create or upload. By using our services, 
                    you grant us a limited license to use, display, and distribute your content as 
                    necessary to provide our services.
                  </p>
                </div>
                <div>
                  <h4 className="font-semibold text-white mb-2">Third-Party Data</h4>
                  <p className="text-sm">
                    AFL player statistics and related data are sourced from official AFL sources and 
                    third-party providers. This data is subject to their respective terms and conditions.
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Service Availability */}
          <Card className="bg-gray-800 border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-white">
                <AlertTriangle className="h-5 w-5" />
                Service Availability and Limitations
              </CardTitle>
            </CardHeader>
            <CardContent className="text-gray-300 space-y-4">
              <div className="space-y-4">
                <div>
                  <h4 className="font-semibold text-white mb-2">Service Availability</h4>
                  <ul className="list-disc list-inside space-y-1 text-sm">
                    <li>We strive for 99.9% uptime but cannot guarantee uninterrupted service</li>
                    <li>Scheduled maintenance may temporarily affect service availability</li>
                    <li>We reserve the right to modify or discontinue features with notice</li>
                  </ul>
                </div>
                <div>
                  <h4 className="font-semibold text-white mb-2">Disclaimers</h4>
                  <ul className="list-disc list-inside space-y-1 text-sm">
                    <li>DiceRealm is provided "as is" without warranties of any kind</li>
                    <li>We do not guarantee the accuracy of all data or predictions</li>
                    <li>Fantasy sports involve risk and we are not responsible for any losses</li>
                    <li>Use our tools and analytics at your own discretion</li>
                  </ul>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Privacy and Data */}
          <Card className="bg-gray-800 border-gray-700">
            <CardHeader>
              <CardTitle className="text-white">Privacy and Data Protection</CardTitle>
            </CardHeader>
            <CardContent className="text-gray-300 space-y-4">
              <p>
                Your privacy is important to us. Our collection, use, and protection of your personal 
                information is governed by our Privacy Policy, which is incorporated into these Terms by reference.
              </p>
              <div className="space-y-2">
                <p className="text-sm">
                  <strong>Key Privacy Points:</strong>
                </p>
                <ul className="list-disc list-inside space-y-1 text-sm">
                  <li>We collect only necessary information to provide our services</li>
                  <li>We do not sell your personal data to third parties</li>
                  <li>We implement security measures to protect your information</li>
                  <li>You have rights regarding your personal data</li>
                </ul>
              </div>
              <Link href="/privacy-policy">
                <Button variant="outline" className="border-gray-600 text-white hover:bg-gray-700">
                  View Privacy Policy
                </Button>
              </Link>
            </CardContent>
          </Card>

          {/* Limitation of Liability */}
          <Card className="bg-gray-800 border-gray-700">
            <CardHeader>
              <CardTitle className="text-white">Limitation of Liability</CardTitle>
            </CardHeader>
            <CardContent className="text-gray-300 space-y-4">
              <p>
                To the fullest extent permitted by law, DiceRealm and its creators shall not be liable 
                for any indirect, incidental, special, consequential, or punitive damages, including 
                but not limited to loss of profits, data, or use.
              </p>
              <div className="bg-gray-700 p-4 rounded-lg">
                <p className="text-sm">
                  <strong>Important:</strong> Fantasy sports involve skill and chance. Past performance 
                  does not guarantee future results. Please participate responsibly and within your means.
                </p>
              </div>
            </CardContent>
          </Card>

          {/* Termination */}
          <Card className="bg-gray-800 border-gray-700">
            <CardHeader>
              <CardTitle className="text-white">Account Termination</CardTitle>
            </CardHeader>
            <CardContent className="text-gray-300 space-y-4">
              <div className="space-y-4">
                <div>
                  <h4 className="font-semibold text-white mb-2">Termination by You</h4>
                  <p className="text-sm">
                    You may terminate your account at any time by contacting us or using account 
                    deletion features when available.
                  </p>
                </div>
                <div>
                  <h4 className="font-semibold text-white mb-2">Termination by Us</h4>
                  <p className="text-sm">
                    We may suspend or terminate your account if you violate these Terms, engage in 
                    fraudulent activity, or for any other reason at our sole discretion.
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Contact Information */}
          <Card className="bg-gray-800 border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-white">
                <Mail className="h-5 w-5" />
                Contact Information
              </CardTitle>
            </CardHeader>
            <CardContent className="text-gray-300 space-y-4">
              <p>
                If you have questions about these Terms of Service, please contact us:
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
                <Link href="/privacy-policy">
                  <Button variant="outline" className="border-gray-600 text-white hover:bg-gray-700">
                    Privacy Policy
                  </Button>
                </Link>
              </div>
            </CardContent>
          </Card>

          {/* Changes to Terms */}
          <Card className="bg-gray-800 border-gray-700">
            <CardHeader>
              <CardTitle className="text-white">Changes to These Terms</CardTitle>
            </CardHeader>
            <CardContent className="text-gray-300 space-y-4">
              <p>
                We reserve the right to modify these Terms at any time. We will notify users of any 
                material changes by posting the updated Terms on our platform and updating the 
                "Last updated" date.
              </p>
              <p>
                Your continued use of DiceRealm after any changes constitutes acceptance of the new Terms. 
                If you do not agree to the modified Terms, you should discontinue use of our services.
              </p>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
