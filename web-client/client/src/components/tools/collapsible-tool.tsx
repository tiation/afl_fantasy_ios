import { useState, ReactNode } from "react";
import { ChevronDown, ChevronUp } from "lucide-react";

interface CollapsibleToolProps {
  title: string;
  icon?: ReactNode;
  colorClass?: string;
  children: ReactNode;
}

export function CollapsibleTool({ 
  title, 
  icon, 
  colorClass = "text-blue-600", 
  children 
}: CollapsibleToolProps) {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div className="border rounded-lg shadow-sm">
      <div 
        className="p-4 cursor-pointer flex items-center justify-between"
        onClick={() => setIsOpen(!isOpen)}
      >
        <div className="flex items-center">
          {icon && <span className={`mr-2 ${colorClass}`}>{icon}</span>}
          <h3 className="text-lg font-medium text-white">{title}</h3>
        </div>
        <span className={colorClass}>
          {isOpen ? <ChevronUp className="h-5 w-5" /> : <ChevronDown className="h-5 w-5" />}
        </span>
      </div>
      
      {isOpen && (
        <div className="p-4 pt-0 border-t">
          {children}
        </div>
      )}
    </div>
  );
}