import { useState } from "react";
import { Bell, Search, UserCircle } from "lucide-react";
import { Input } from "@/components/ui/input";
import { useLocation, Link } from "wouter";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";

export default function Header() {
  const [searchQuery, setSearchQuery] = useState("");
  const [, navigate] = useLocation();

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    if (searchQuery.trim()) {
      navigate(`/player-stats?q=${encodeURIComponent(searchQuery)}`);
    }
  };

  return (
    <div className="bg-gray-900 border-b border-gray-700 px-4 py-2 flex items-center">
      {/* Search Bar */}
      <form className="relative flex-1 max-w-xl" onSubmit={handleSearch}>
        <Input 
          type="text" 
          placeholder="Search players, teams..." 
          className="w-full pl-10 pr-4 py-2 bg-gray-800 border-gray-600 text-white placeholder-gray-400 focus:border-green-500"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
        />
        <div className="absolute left-3 top-2.5 text-gray-400">
          <Search className="h-5 w-5" />
        </div>
      </form>
      
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
  );
}
