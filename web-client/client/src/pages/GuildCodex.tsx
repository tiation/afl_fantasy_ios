import React from 'react';
import { Link } from 'wouter';
import Container from '@/components/Container';
import GradientText from '@/components/GradientText';
import FantasyHeading from '@/components/FantasyHeading';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Separator } from '@/components/ui/separator';
import { Button } from '@/components/ui/button';
import { ScrollText, Users, GitPullRequest, Mail, Shield, Sparkles, ArrowLeft } from 'lucide-react';

const GuildCodex = () => {
  return (
    <Container size="lg" className="py-12">
      {/* Hero Section */}
      <div className="text-center mb-16">
        <FantasyHeading as="h1" size="2xl" className="mb-4">
          <GradientText variant="fantasy">
            Guild Codex
          </GradientText>
        </FantasyHeading>
        <p className="text-xl text-muted-foreground max-w-3xl mx-auto leading-relaxed">
          Your comprehensive guide to the realm of fantasy gaming excellence. 
          Discover the lore, master the etiquette, and contribute to our growing community.
        </p>
      </div>

      {/* Lore / About the App Section */}
      <section id="lore" className="mb-16">
        <div className="flex items-center gap-3 mb-6">
          <ScrollText className="h-8 w-8 text-purple-500" />
          <FantasyHeading as="h2" size="xl">
            <GradientText variant="fantasy">The Chronicles of Our Realm</GradientText>
          </FantasyHeading>
        </div>
        
        <Card className="bg-gradient-to-br from-purple-900/20 to-pink-900/20 border-purple-500/30">
          <CardContent className="p-8">
            <div className="grid md:grid-cols-2 gap-8">
              <div>
                <h3 className="text-2xl font-bold mb-4 text-purple-300">Our Origin Story</h3>
                <p className="text-muted-foreground leading-relaxed mb-4">
                  Born from the passion for strategic gaming and fantasy adventures, this application 
                  serves as your digital companion in the world of tabletop gaming. Whether you're 
                  rolling dice for critical hits or managing complex fantasy scenarios, we provide 
                  the tools you need for epic adventures.
                </p>
                <p className="text-muted-foreground leading-relaxed">
                  Our mission is to enhance your gaming experience with intelligent tools, 
                  comprehensive analytics, and a supportive community of fellow adventurers.
                </p>
              </div>
              <div>
                <h3 className="text-2xl font-bold mb-4 text-pink-300">What We Offer</h3>
                <ul className="space-y-3">
                  <li className="flex items-start gap-2">
                    <Sparkles className="h-5 w-5 text-yellow-400 mt-0.5 flex-shrink-0" />
                    <span className="text-muted-foreground">Advanced dice rolling mechanics and statistics</span>
                  </li>
                  <li className="flex items-start gap-2">
                    <Sparkles className="h-5 w-5 text-yellow-400 mt-0.5 flex-shrink-0" />
                    <span className="text-muted-foreground">Fantasy character management and progression</span>
                  </li>
                  <li className="flex items-start gap-2">
                    <Sparkles className="h-5 w-5 text-yellow-400 mt-0.5 flex-shrink-0" />
                    <span className="text-muted-foreground">Campaign tracking and session management</span>
                  </li>
                  <li className="flex items-start gap-2">
                    <Sparkles className="h-5 w-5 text-yellow-400 mt-0.5 flex-shrink-0" />
                    <span className="text-muted-foreground">Community features and guild collaboration</span>
                  </li>
                </ul>
              </div>
            </div>
          </CardContent>
        </Card>
      </section>

      {/* Party Etiquette Section */}
      <section id="etiquette" className="mb-16">
        <div className="flex items-center gap-3 mb-6">
          <Users className="h-8 w-8 text-blue-500" />
          <FantasyHeading as="h2" size="xl">
            <GradientText variant="primary">Party Etiquette & Community Rules</GradientText>
          </FantasyHeading>
        </div>

        <div className="grid md:grid-cols-2 gap-6">
          <Card className="bg-gradient-to-br from-blue-900/20 to-cyan-900/20 border-blue-500/30">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Shield className="h-6 w-6 text-blue-400" />
                Core Principles
              </CardTitle>
            </CardHeader>
            <CardContent>
              <ul className="space-y-3">
                <li className="flex items-start gap-2">
                  <span className="text-blue-400 font-bold">•</span>
                  <span className="text-muted-foreground">Respect all party members and their gaming styles</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-blue-400 font-bold">•</span>
                  <span className="text-muted-foreground">Share knowledge and help newcomers learn</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-blue-400 font-bold">•</span>
                  <span className="text-muted-foreground">Maintain fair play and sportsmanship</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-blue-400 font-bold">•</span>
                  <span className="text-muted-foreground">Keep discussions constructive and inclusive</span>
                </li>
              </ul>
            </CardContent>
          </Card>

          <Card className="bg-gradient-to-br from-green-900/20 to-emerald-900/20 border-green-500/30">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Users className="h-6 w-6 text-green-400" />
                Community Guidelines
              </CardTitle>
            </CardHeader>
            <CardContent>
              <ul className="space-y-3">
                <li className="flex items-start gap-2">
                  <span className="text-green-400 font-bold">•</span>
                  <span className="text-muted-foreground">No harassment, toxicity, or discriminatory behavior</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-green-400 font-bold">•</span>
                  <span className="text-muted-foreground">Respect intellectual property and game rules</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-green-400 font-bold">•</span>
                  <span className="text-muted-foreground">Report bugs and issues constructively</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-green-400 font-bold">•</span>
                  <span className="text-muted-foreground">Contribute positively to discussions and feedback</span>
                </li>
              </ul>
            </CardContent>
          </Card>
        </div>
      </section>

      {/* Contribution Guide Section */}
      <section id="contribution" className="mb-16">
        <div className="flex items-center gap-3 mb-6">
          <GitPullRequest className="h-8 w-8 text-orange-500" />
          <FantasyHeading as="h2" size="xl">
            <GradientText variant="warning">Contribution Guide</GradientText>
          </FantasyHeading>
        </div>

        <Card className="bg-gradient-to-br from-orange-900/20 to-yellow-900/20 border-orange-500/30">
          <CardContent className="p-8">
            <div className="grid md:grid-cols-3 gap-8">
              <div>
                <h3 className="text-xl font-bold mb-4 text-orange-300">Code Contributions</h3>
                <ul className="space-y-2 text-muted-foreground">
                  <li>• Submit pull requests with clear descriptions</li>
                  <li>• Follow established coding standards</li>
                  <li>• Include tests for new features</li>
                  <li>• Document your changes thoroughly</li>
                </ul>
              </div>
              <div>
                <h3 className="text-xl font-bold mb-4 text-yellow-300">Content Creation</h3>
                <ul className="space-y-2 text-muted-foreground">
                  <li>• Share custom dice sets and mechanics</li>
                  <li>• Create tutorials and guides</li>
                  <li>• Suggest new features and improvements</li>
                  <li>• Report and help fix bugs</li>
                </ul>
              </div>
              <div>
                <h3 className="text-xl font-bold mb-4 text-red-300">Community Support</h3>
                <ul className="space-y-2 text-muted-foreground">
                  <li>• Help answer questions in forums</li>
                  <li>• Mentor new users and players</li>
                  <li>• Organize community events</li>
                  <li>• Provide feedback and suggestions</li>
                </ul>
              </div>
            </div>
            <Separator className="my-6" />
            <div className="text-center">
              <p className="text-muted-foreground mb-4">
                Ready to contribute? Check out our development repository and join the community!
              </p>
              <Button className="bg-gradient-to-r from-orange-500 to-red-500 hover:from-orange-600 hover:to-red-600">
                Get Started Contributing
              </Button>
            </div>
          </CardContent>
        </Card>
      </section>

      {/* Contact Section */}
      <section id="contact" className="mb-16">
        <div className="flex items-center gap-3 mb-6">
          <Mail className="h-8 w-8 text-emerald-500" />
          <FantasyHeading as="h2" size="xl">
            <GradientText variant="success">Contact the Guild Masters</GradientText>
          </FantasyHeading>
        </div>

        <div className="grid md:grid-cols-2 gap-6">
          <Card className="bg-gradient-to-br from-emerald-900/20 to-teal-900/20 border-emerald-500/30">
            <CardHeader>
              <CardTitle className="text-emerald-300">Garrett Dillman</CardTitle>
              <CardDescription>Lead Developer & Platform Architect</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                <div className="flex items-center gap-2">
                  <Mail className="h-4 w-4 text-emerald-400" />
                  <a href="mailto:garrett.dillman@gmail.com" className="text-emerald-300 hover:text-emerald-200 transition-colors">
                    garrett.dillman@gmail.com
                  </a>
                </div>
                <div className="flex items-center gap-2">
                  <Mail className="h-4 w-4 text-emerald-400" />
                  <a href="mailto:garrett@sxc.codes" className="text-emerald-300 hover:text-emerald-200 transition-colors">
                    garrett@sxc.codes
                  </a>
                </div>
                <p className="text-sm text-muted-foreground mt-4">
                  Specializes in backend systems, API development, and platform architecture. 
                  Reach out for technical discussions and development inquiries.
                </p>
              </div>
            </CardContent>
          </Card>

          <Card className="bg-gradient-to-br from-purple-900/20 to-violet-900/20 border-purple-500/30">
            <CardHeader>
              <CardTitle className="text-purple-300">Tia</CardTitle>
              <CardDescription>Community Manager & Developer</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                <div className="flex items-center gap-2">
                  <Mail className="h-4 w-4 text-purple-400" />
                  <a href="mailto:tiatheone@protonmail.com" className="text-purple-300 hover:text-purple-200 transition-colors">
                    tiatheone@protonmail.com
                  </a>
                </div>
                <p className="text-sm text-muted-foreground mt-4">
                  Focuses on community engagement, user experience, and feature development. 
                  Perfect contact for feedback, suggestions, and community-related inquiries.
                </p>
              </div>
            </CardContent>
          </Card>
        </div>
      </section>

      {/* Footer */}
      <div className="text-center pt-8 border-t border-gray-800">
        <p className="text-muted-foreground">
          May your dice always roll high and your adventures be legendary! 🎲✨
        </p>
      </div>
    </Container>
  );
};

export default GuildCodex;
