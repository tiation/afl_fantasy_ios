/**
 * Enhanced Skeleton Loading Component
 * 
 * Provides consistent loading states across the application
 * with accessibility support and motion preferences.
 */

import { cn } from "@/lib/utils";
import { cva, type VariantProps } from "class-variance-authority";

const skeletonVariants = cva(
  [
    // Base styles
    "animate-pulse rounded-md",
    
    // Light theme gradient
    "bg-gray-200",
    
    // Dark theme gradient
    "dark:bg-gray-700",
    
    // Accessibility
    "motion-reduce:animate-none",
  ],
  {
    variants: {
      variant: {
        default: "bg-gray-200 dark:bg-gray-700",
        shimmer: [
          "bg-gradient-to-r from-gray-200 via-gray-300 to-gray-200",
          "dark:from-gray-700 dark:via-gray-600 dark:to-gray-700",
          "bg-[length:200%_100%]",
          "animate-shimmer",
        ],
        pulse: "animate-pulse bg-gray-300 dark:bg-gray-600",
      },
      size: {
        sm: "h-4",
        md: "h-6", 
        lg: "h-8",
        xl: "h-12",
      },
      rounded: {
        none: "rounded-none",
        sm: "rounded-sm",
        md: "rounded-md", 
        lg: "rounded-lg",
        full: "rounded-full",
      }
    },
    defaultVariants: {
      variant: "default",
      size: "md",
      rounded: "md",
    },
  }
);

export interface SkeletonProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof skeletonVariants> {
  /**
   * Accessible label for screen readers
   */
  "aria-label"?: string;
}

/**
 * Basic Skeleton component
 */
function Skeleton({
  className,
  variant,
  size,
  rounded,
  ...props
}: SkeletonProps) {
  return (
    <div
      className={cn(skeletonVariants({ variant, size, rounded }), className)}
      role="status"
      aria-label={props["aria-label"] || "Loading content"}
      {...props}
    />
  );
}

/**
 * Skeleton for text content with realistic proportions
 */
function SkeletonText({
  lines = 1,
  className,
  lastLineWidth = "75%",
  ...props
}: SkeletonProps & {
  lines?: number;
  lastLineWidth?: string;
}) {
  return (
    <div className={cn("space-y-2", className)} {...props}>
      {Array.from({ length: lines }, (_, i) => (
        <Skeleton
          key={i}
          className={cn(
            "h-4 w-full",
            i === lines - 1 && lines > 1 && `w-[${lastLineWidth}]`
          )}
          variant="shimmer"
          aria-label={`Loading text line ${i + 1} of ${lines}`}
        />
      ))}
    </div>
  );
}

/**
 * Skeleton for avatar/profile images
 */
function SkeletonAvatar({ 
  size = 40,
  className,
  ...props 
}: SkeletonProps & { size?: number }) {
  return (
    <Skeleton
      className={cn("rounded-full", className)}
      style={{ width: size, height: size }}
      variant="pulse"
      aria-label="Loading profile picture"
      {...props}
    />
  );
}

/**
 * Player card skeleton
 */
function SkeletonPlayerCard({ className, ...props }: SkeletonProps) {
  return (
    <div className={cn("p-4 border rounded-lg space-y-3 bg-gray-800 border-gray-700", className)} {...props}>
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <SkeletonAvatar size={48} />
          <div className="space-y-2">
            <Skeleton className="h-4 w-24" variant="shimmer" />
            <Skeleton className="h-3 w-16" variant="shimmer" />
          </div>
        </div>
        <div className="text-right space-y-2">
          <Skeleton className="h-6 w-12" variant="shimmer" />
          <Skeleton className="h-3 w-16" variant="shimmer" />
        </div>
      </div>
      <div className="flex justify-between items-center">
        <Skeleton className="h-3 w-20" variant="shimmer" />
        <Skeleton className="h-6 w-8 rounded-full" variant="pulse" />
      </div>
    </div>
  );
}

/**
 * Score card skeleton (for dashboard)
 */
function SkeletonScoreCard({ className, ...props }: SkeletonProps) {
  return (
    <div className={cn("p-4 border rounded-lg space-y-4 bg-gray-800 border-gray-700", className)} {...props}>
      <div className="flex justify-between items-start">
        <Skeleton className="h-4 w-24" variant="shimmer" />
        <Skeleton className="h-5 w-5 rounded" variant="pulse" />
      </div>
      <Skeleton className="h-8 w-20" variant="shimmer" />
      <Skeleton className="h-3 w-32" variant="shimmer" />
    </div>
  );
}

/**
 * Chart skeleton
 */
function SkeletonChart({ 
  height = 200,
  className,
  ...props 
}: SkeletonProps & { height?: number }) {
  return (
    <div className={cn("p-4 border rounded-lg bg-gray-800 border-gray-700", className)} {...props}>
      <div className="flex justify-between items-center mb-4">
        <Skeleton className="h-5 w-32" variant="shimmer" />
        <Skeleton className="h-8 w-24 rounded" variant="pulse" />
      </div>
      <Skeleton 
        className="w-full rounded" 
        style={{ height }}
        variant="shimmer"
        aria-label="Loading chart data"
      />
    </div>
  );
}

// Export all variants
export {
  Skeleton,
  SkeletonText,
  SkeletonAvatar,
  SkeletonPlayerCard,
  SkeletonScoreCard,
  SkeletonChart,
};
