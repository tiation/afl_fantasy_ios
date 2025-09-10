import { Link, useLocation } from "wouter";
import { cn } from "@/lib/utils";
import { 
  Home,
  BarChart2,
  List,
  Users,
  Settings,
  FileBarChart,
} from "lucide-react";
import { useIsMobile } from "@/hooks/use-mobile";

type NavItemProps = {
  href: string;
  icon: React.ReactNode;
  label: string;
  isActive: boolean;
};

const NavItem = ({ href, icon, label, isActive }: NavItemProps) => {
  return (
    <Link href={href}>
      <div className={cn(
        "flex flex-col items-center justify-center text-center p-2 text-gray-400 hover:text-blue-400 transition-colors",
        isActive && "text-blue-400"
      )}>
        <div className="h-6 w-6">
          {icon}
        </div>
        <span className="text-xs mt-1 font-medium">{label}</span>
      </div>
    </Link>
  );
};

export default function BottomNav() {
  const [location] = useLocation();
  const isMobile = useIsMobile();

  if (!isMobile) return null;

  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-gray-800 border-t border-gray-700 flex justify-around py-1 z-50">
      <NavItem 
        href="/" 
        icon={<Home className="h-6 w-6" />} 
        label="Dashboard" 
        isActive={location === "/"} 
      />
      <NavItem 
        href="/lineup" 
        icon={<List className="h-6 w-6" />} 
        label="Lineup" 
        isActive={location === "/lineup"} 
      />
      <NavItem 
        href="/stats" 
        icon={<FileBarChart className="h-6 w-6" />} 
        label="Stats" 
        isActive={location === "/stats"} 
      />
      <NavItem 
        href="/leagues" 
        icon={<Users className="h-6 w-6" />} 
        label="Leagues" 
        isActive={location === "/leagues"} 
      />
      <NavItem 
        href="/tools-accordion" 
        icon={<Settings className="h-6 w-6" />} 
        label="Tools" 
        isActive={location === "/tools-accordion"} 
      />
    </nav>
  );
}