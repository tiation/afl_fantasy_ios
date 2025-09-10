import { useState, useEffect } from "react";
import { Bell, Search, UserCircle, Command } from "lucide-react";
import { Input } from "@/components/ui/input";
import { useLocation, Link } from "wouter";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { GlobalSearch } from "@/components/search/global-search";

export default function Header() {
  const [isSearchOpen, setIsSearchOpen] = useState(false);
  const [, navigate] = useLocation();

  // Global Cmd+K shortcut
  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      if ((event.metaKey || event.ctrlKey) && event.key === 'k') {
        event.preventDefault();
        setIsSearchOpen(true);
      }
    };

    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, []);

  return (
    <>
      <div className="bg-gray-900 border-b border-gray-700 px-4 py-2 flex items-center">
        {/* Search Trigger */}
        <button
          onClick={() => setIsSearchOpen(true)}
          className="relative flex-1 max-w-xl group"
        >
          <div className="w-full pl-10 pr-16 py-2 bg-gray-800 border border-gray-600 text-left text-gray-400 placeholder-gray-400 focus:border-green-500 rounded-md hover:bg-gray-700 transition-colors">
            Search players, teams...
          </div>
          <div className="absolute left-3 top-2.5 text-gray-400 group-hover:text-gray-300">
            <Search className="h-5 w-5" />
          </div>
          <div className="absolute right-3 top-2 text-xs text-gray-500 group-hover:text-gray-400">
            <kbd className="px-2 py-1 bg-gray-700 rounded border border-gray-600">
              ⌘K
            </kbd>
          </div>
        </button>
        
        {/* Notifications */}
        <div className="ml-4 relative">
          <button className="text-gray-400 hover:text-white focus:outline-none transition-colors">
            <Bell className="h-6 w-6" />
            <span className="absolute top-0 right-0 w-2 h-2 bg-red-500 rounded-full"></span>
          </button>
        </div>
        
        {/* User Profile */}
        <div className="ml-4">
          <Link href="/profile">
            <div className="cursor-pointer">
              <Avatar className="w-10 h-10 bg-green-500 text-white hover:bg-green-600 transition-colors">
                <AvatarFallback>TE</AvatarFallback>
              </Avatar>
            </div>
          </Link>
        </div>
      </div>
      
      {/* Global Search Modal */}
      <GlobalSearch 
        isOpen={isSearchOpen} 
        onClose={() => setIsSearchOpen(false)} 
      />
    </>
  );
}
