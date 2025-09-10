import { Link } from "wouter";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { ArrowLeft, Phone, Mail, MapPin } from "lucide-react";

export default function ContactUs() {
  return (
    <div className="min-h-screen bg-gray-900 text-white p-6">
      <div className="max-w-4xl mx-auto">
        <div className="flex items-center gap-4 mb-8">
          <Link href="/">
            <Button variant="ghost" size="sm" className="text-white hover:text-gray-300">
              <ArrowLeft className="h-4 w-4 mr-2" />
              Back to DiceRealm
            </Button>
          </Link>
          <div>
            <h1 className="text-3xl font-bold">Contact Us</h1>
            <p className="text-gray-400 mt-2">We're here to help and answer any questions you might have.</p>
          </div>
        </div>

        <div className="space-y-6">
          <Card className="bg-gray-800 border-gray-700">
            <CardHeader>
              <CardTitle className="text-white">
                <Phone className="h-5 w-5 mr-2" />
                Phone Support
              </CardTitle>
              <CardDescription className="text-gray-400">
                Call us for immediate assistance from our support team.
              </CardDescription>
            </CardHeader>
            <CardContent>
              <p className="text-gray-300">
                <strong>Phone:</strong> <a href="tel:+1234567890" className="text-blue-400 hover:text-blue-300">(123) 456-7890</a>
              </p>
              <p className="mt-2 text-sm text-gray-400">
                Available Monday to Friday, 9am - 5pm.
              </p>
            </CardContent>
          </Card>

          <Card className="bg-gray-800 border-gray-700">
            <CardHeader>
              <CardTitle className="text-white">
                <Mail className="h-5 w-5 mr-2" />
                Email Support
              </CardTitle>
              <CardDescription className="text-gray-400">
                Reach out to us via email for help with any issue.
              </CardDescription>
            </CardHeader>
            <CardContent>
              <p className="text-gray-300">
                <strong>Email:</strong> <a href="mailto:support@dicerealm.com" className="text-blue-400 hover:text-blue-300">support@dicerealm.com</a>
              </p>
              <p className="mt-2 text-sm text-gray-400">
                We aim to respond to all queries within 24 hours.
              </p>
            </CardContent>
          </Card>

          <Card className="bg-gray-800 border-gray-700">
            <CardHeader>
              <CardTitle className="text-white">
                <MapPin className="h-5 w-5 mr-2" />
                Visit Us
              </CardTitle>
              <CardDescription className="text-gray-400">
                Drop by our office for in-person inquiries and assistance.
              </CardDescription>
            </CardHeader>
            <CardContent>
              <p className="text-gray-300">
                <strong>Address:</strong> 123 Fantasy Ave, Suite 100, Imaginary City, DIC 01234
              </p>
              <p className="mt-2 text-sm text-gray-400">
                Open Monday to Friday, 9am - 5pm.
              </p>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
