import React from 'react';
import { cn } from '@/lib/utils';

export interface GradientTextProps extends React.HTMLAttributes<HTMLSpanElement> {
  /**
   * Gradient variant to apply
   * @default "primary"
   */
  variant?: 'primary' | 'secondary' | 'accent' | 'success' | 'warning' | 'fantasy';
  /**
   * Additional CSS classes to apply
   */
  className?: string;
  /**
   * Content to render inside the gradient text
   */
  children: React.ReactNode;
}

/**
 * A utility component that applies gradient text effects to its children.
 * 
 * @example
 * ```tsx
 * <GradientText variant="fantasy">
 *   AFL Fantasy Champion
 * </GradientText>
 * ```
 */
export const GradientText = React.forwardRef<HTMLSpanElement, GradientTextProps>(
  ({ variant = 'primary', className, children, ...props }, ref) => {
    const gradientClasses = {
      primary: 'bg-gradient-to-r from-blue-500 to-purple-600',
      secondary: 'bg-gradient-to-r from-gray-400 to-gray-600',
      accent: 'bg-gradient-to-r from-green-400 to-blue-500',
      success: 'bg-gradient-to-r from-green-400 to-emerald-500',
      warning: 'bg-gradient-to-r from-yellow-400 to-orange-500',
      fantasy: 'bg-gradient-to-r from-purple-500 via-pink-500 to-red-500'
    };

    return (
      <span
        ref={ref}
        className={cn(
          'bg-clip-text text-transparent font-semibold',
          gradientClasses[variant],
          className
        )}
        {...props}
      >
        {children}
      </span>
    );
  }
);

GradientText.displayName = 'GradientText';

export default GradientText;
