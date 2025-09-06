import { Link, useLocation } from "wouter";
import { cn } from "@/lib/utils";
import { 
  Home,
  BarChart2,
  List,
  Users,
  Settings,
  FileBarChart,
  Activity,
  ArrowLeftRight,
  UserIcon
} from "lucide-react";

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
        "flex items-center px-4 py-3 text-gray-300 hover:bg-blue-500 hover:text-white cursor-pointer transition-colors duration-200 rounded-lg mx-2",
        isActive && "bg-blue-500 text-white"
      )}>
        <div className="h-6 w-6 sidebar-icon">
          {icon}
        </div>
        <span className="ml-3 hidden sm:block font-medium">{label}</span>
      </div>
    </Link>
  );
};

export default function Sidebar() {
  const [location] = useLocation();

  return (
    <div className="w-16 sm:w-64 bg-gray-800 flex flex-col border-r border-gray-700">
      {/* Logo and App Title */}
      <div className="flex items-center p-4 text-white border-b border-gray-700">
        <div className="w-8 h-8 rounded-full bg-blue-500 flex items-center justify-center">
          <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
            <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118l-2.799-2.034c-.784-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
          </svg>
        </div>
        <span className="ml-3 text-lg font-bold hidden sm:block text-blue-400">AFL Fantasy</span>
      </div>

      {/* Navigation Items */}
      <nav className="flex-1 pt-2">
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
          href="/player-stats" 
          icon={<FileBarChart className="h-6 w-6" />} 
          label="Player Stats" 
          isActive={location === "/player-stats"} 
        />
        <NavItem 
          href="/tools-simple" 
          icon={<Activity className="h-6 w-6" />} 
          label="Fantasy Tools" 
          isActive={location === "/tools-simple"} 
        />
        <NavItem 
          href="/trade-analyzer" 
          icon={<ArrowLeftRight className="h-6 w-6" />} 
          label="Trade Analyzer" 
          isActive={location === "/trade-analyzer"} 
        />
        <NavItem 
          href="/leagues" 
          icon={<Users className="h-6 w-6" />} 
          label="Leagues" 
          isActive={location === "/leagues"} 
        />
        <NavItem 
          href="/profile" 
          icon={<UserIcon className="h-6 w-6" />} 
          label="Profile" 
          isActive={location === "/profile"} 
        />
      </nav>
    </div>
  );
}
