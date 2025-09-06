import React from 'react';
import { Link, useLocation } from 'wouter';
import { TooltipProvider } from '@/components/ui/tooltip';
import { useIsMobile } from '@/hooks/use-mobile';
import Sidebar from '@/components/layout/sidebar';
import Header from '@/components/layout/header';
import BottomNav from '@/components/layout/bottom-nav';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';
import {
  Home,
  BarChart2,
  List,
  Users,
  Activity,
  ArrowLeftRight,
  UserIcon,
  Zap,
  TrendingUp,
  Shield
} from 'lucide-react';

interface LayoutProps {
  children: React.ReactNode;
}

// Quick Links Navigation Component
const QuickLinks = () => {
  const [location] = useLocation();
  
  const quickLinks = [
    { href: '/', icon: Home, label: 'Dashboard' },
    { href: '/lineup', icon: List, label: 'Lineup' },
    { href: '/player-stats', icon: BarChart2, label: 'Stats' },
    { href: '/tools-simple', icon: Activity, label: 'Tools' },
    { href: '/trade-analyzer', icon: ArrowLeftRight, label: 'Trades' },
    { href: '/leagues', icon: Users, label: 'Leagues' }
  ];

  return (
    <div className="flex items-center gap-2 py-2 px-4 bg-gray-800/50 border-b border-gray-700">
      <div className="flex items-center gap-1 text-sm text-gray-400 mr-4">
        <Zap className="h-4 w-4 text-blue-400" />
        <span className="font-medium">Quick Links:</span>
      </div>
      <div className="flex items-center gap-1 flex-wrap">
        {quickLinks.map(({ href, icon: Icon, label }) => {
          const isActive = location === href;
          return (
            <Link key={href} href={href}>
              <Button
                variant="ghost"
                size="sm"
                className={cn(
                  "h-8 px-3 text-xs font-medium transition-all duration-200",
                  "hover:bg-blue-500/20 hover:text-blue-300",
                  isActive 
                    ? "bg-blue-500/30 text-blue-300 border border-blue-500/50" 
                    : "text-gray-400 hover:text-gray-200"
                )}
              >
                <Icon className="h-3 w-3 mr-1.5" />
                {label}
              </Button>
            </Link>
          );
        })}
      </div>
    </div>
  );
};

// Enhanced Navbar component that includes Quick Links
const Navbar = () => {
  return (
    <div className="bg-gray-900 border-b border-gray-700">
      <Header />
      <QuickLinks />
    </div>
  );
};

// Main Layout Component
const Layout: React.FC<LayoutProps> = ({ children }) => {
  const isMobile = useIsMobile();

  return (
    <TooltipProvider>
      <div className="flex min-h-screen bg-gray-900 text-white">
        {/* Sidebar for desktop */}
        {!isMobile && <Sidebar />}
        
        {/* Main content area */}
        <div className="flex-1 overflow-auto">
          {/* Enhanced Navbar with Quick Links */}
          <Navbar />
          
          {/* Page content */}
          <div className={`p-4 ${isMobile ? 'pb-20' : ''} bg-gray-900`}>
            {children}
          </div>
        </div>
        
        {/* Bottom navigation for mobile */}
        <BottomNav />
      </div>
    </TooltipProvider>
  );
};

export default Layout;
