/**
 * StatBadge Component
 * 
 * Displays statistical information with consistent styling
 * and semantic meaning through color coding and icons.
 */

import { cn } from "@/lib/utils";
import { cva, type VariantProps } from "class-variance-authority";
import { 
  TrendingUp, 
  TrendingDown, 
  Minus, 
  Activity,
  Award,
  Target,
  BarChart3,
  DollarSign,
  Users,
  Clock
} from "lucide-react";

const statBadgeVariants = cva(
  [
    // Base styles
    "inline-flex items-center gap-1.5 rounded-full font-medium",
    "transition-all duration-200 ease-in-out",
    "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2",
    
    // Motion preferences
    "motion-reduce:transition-none",
  ],
  {
    variants: {
      variant: {
        // Semantic variants
        positive: [
          "bg-emerald-100 text-emerald-800 border border-emerald-200",
          "dark:bg-emerald-900/20 dark:text-emerald-300 dark:border-emerald-800"
        ],
        negative: [
          "bg-red-100 text-red-800 border border-red-200",
          "dark:bg-red-900/20 dark:text-red-300 dark:border-red-800"
        ],
        neutral: [
          "bg-gray-100 text-gray-800 border border-gray-200",
          "dark:bg-gray-800 dark:text-gray-300 dark:border-gray-700"
        ],
        warning: [
          "bg-amber-100 text-amber-800 border border-amber-200",
          "dark:bg-amber-900/20 dark:text-amber-300 dark:border-amber-800"
        ],
        info: [
          "bg-blue-100 text-blue-800 border border-blue-200",
          "dark:bg-blue-900/20 dark:text-blue-300 dark:border-blue-800"
        ],
        
        // Position variants (AFL Fantasy specific)
        defender: [
          "bg-blue-100 text-blue-800 border border-blue-200",
          "dark:bg-blue-900/20 dark:text-blue-300 dark:border-blue-800"
        ],
        midfielder: [
          "bg-emerald-100 text-emerald-800 border border-emerald-200",
          "dark:bg-emerald-900/20 dark:text-emerald-300 dark:border-emerald-800"
        ],
        ruck: [
          "bg-purple-100 text-purple-800 border border-purple-200",
          "dark:bg-purple-900/20 dark:text-purple-300 dark:border-purple-800"
        ],
        forward: [
          "bg-red-100 text-red-800 border border-red-200",
          "dark:bg-red-900/20 dark:text-red-300 dark:border-red-800"
        ],
      },
      size: {
        sm: "px-2 py-1 text-xs",
        md: "px-3 py-1.5 text-sm",
        lg: "px-4 py-2 text-base",
      },
      interactive: {
        true: "cursor-pointer hover:scale-105 active:scale-95",
        false: "",
      }
    },
    defaultVariants: {
      variant: "neutral",
      size: "md",
      interactive: false,
    },
  }
);

type IconType = 
  | "trending-up"
  | "trending-down"
  | "neutral"
  | "activity"
  | "award"
  | "target"
  | "chart"
  | "dollar"
  | "users"
  | "clock"
  | "none";

const iconMap = {
  "trending-up": TrendingUp,
  "trending-down": TrendingDown,
  "neutral": Minus,
  "activity": Activity,
  "award": Award,
  "target": Target,
  "chart": BarChart3,
  "dollar": DollarSign,
  "users": Users,
  "clock": Clock,
  "none": null,
} as const;

export interface StatBadgeProps
  extends React.HTMLAttributes<HTMLSpanElement>,
    VariantProps<typeof statBadgeVariants> {
  /**
   * The statistical value to display
   */
  value: string | number;
  
  /**
   * Optional label for the statistic
   */
  label?: string;
  
  /**
   * Icon to display alongside the stat
   */
  icon?: IconType;
  
  /**
   * Whether to show trend indicators for numeric changes
   */
  showTrend?: boolean;
  
  /**
   * Previous value for trend calculation
   */
  previousValue?: number;
  
  /**
   * Custom tooltip text
   */
  tooltip?: string;
  
  /**
   * Click handler for interactive badges
   */
  onClick?: () => void;
}

/**
 * StatBadge Component
 */
function StatBadge({
  value,
  label,
  icon = "none",
  variant,
  size,
  interactive,
  showTrend = false,
  previousValue,
  tooltip,
  onClick,
  className,
  ...props
}: StatBadgeProps) {
  const IconComponent = icon !== "none" ? iconMap[icon] : null;
  const isInteractive = interactive || !!onClick;
  
  return (
    <span
      className={cn(
        statBadgeVariants({ 
          variant, 
          size, 
          interactive: isInteractive 
        }), 
        className
      )}
      onClick={onClick}
      role={isInteractive ? "button" : undefined}
      tabIndex={isInteractive ? 0 : undefined}
      onKeyDown={isInteractive ? (e) => e.key === "Enter" && onClick?.() : undefined}
      title={tooltip}
      {...props}
    >
      {IconComponent && (
        <IconComponent className={cn(
          size === "sm" ? "h-3 w-3" : size === "lg" ? "h-5 w-5" : "h-4 w-4"
        )} />
      )}
      
      <span className="font-semibold">
        {typeof value === "number" ? value.toLocaleString() : value}
      </span>
      
      {label && (
        <span className={cn(
          "font-normal opacity-90",
          size === "sm" && "hidden"
        )}>
          {label}
        </span>
      )}
    </span>
  );
}

/**
 * AFL Fantasy specific stat badges
 */

/**
 * Player price badge
 */
function PriceBadge({
  price,
  change,
  ...props
}: Omit<StatBadgeProps, "value" | "icon"> & {
  price: number;
  change?: number;
}) {
  const formattedPrice = `$${(price / 1000).toFixed(0)}k`;
  
  return (
    <StatBadge
      value={formattedPrice}
      icon="dollar"
      variant={change ? (change > 0 ? "positive" : change < 0 ? "negative" : "neutral") : "neutral"}
      tooltip={`Price: $${price.toLocaleString()}${change ? ` (${change > 0 ? "+" : ""}${change})` : ""}`}
      {...props}
    />
  );
}

/**
 * Player score badge
 */
function ScoreBadge({
  score,
  average,
  ...props
}: Omit<StatBadgeProps, "value" | "icon"> & {
  score: number;
  average?: number;
}) {
  return (
    <StatBadge
      value={score}
      icon="chart"
      variant={average ? (score > average ? "positive" : score < average ? "negative" : "neutral") : "neutral"}
      tooltip={`Score: ${score}${average ? ` (avg: ${average.toFixed(1)})` : ""}`}
      {...props}
    />
  );
}

/**
 * Position badge
 */
function PositionBadge({
  position,
  ...props
}: Omit<StatBadgeProps, "value" | "variant"> & {
  position: "DEF" | "MID" | "RUC" | "FWD";
}) {
  const variantMap = {
    "DEF": "defender",
    "MID": "midfielder", 
    "RUC": "ruck",
    "FWD": "forward",
  } as const;
  
  return (
    <StatBadge
      value={position}
      variant={variantMap[position]}
      size="sm"
      {...props}
    />
  );
}

/**
 * Ownership percentage badge
 */
function OwnershipBadge({
  percentage,
  ...props
}: Omit<StatBadgeProps, "value" | "icon"> & {
  percentage: number;
}) {
  return (
    <StatBadge
      value={`${percentage.toFixed(1)}%`}
      icon="users"
      variant={percentage > 50 ? "warning" : percentage > 20 ? "info" : "neutral"}
      tooltip={`Owned by ${percentage.toFixed(1)}% of teams`}
      {...props}
    />
  );
}

export {
  StatBadge,
  PriceBadge,
  ScoreBadge,
  PositionBadge,
  OwnershipBadge,
};
