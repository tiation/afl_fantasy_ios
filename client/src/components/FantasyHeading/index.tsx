import React from 'react';
import { cn } from '@/lib/utils';

type HeadingLevel = 'h1' | 'h2' | 'h3' | 'h4' | 'h5' | 'h6';

export interface FantasyHeadingProps extends React.HTMLAttributes<HTMLHeadingElement> {
  /**
   * The semantic heading level to render
   * @default "h1"
   */
  as?: HeadingLevel;
  /**
   * Size variant for the heading
   * @default "default"
   */
  size?: 'sm' | 'default' | 'lg' | 'xl' | '2xl';
  /**
   * Additional CSS classes to apply
   */
  className?: string;
  /**
   * Content to render inside the heading
   */
  children: React.ReactNode;
}

/**
 * A semantic heading component with fantasy-themed styling using the font-fantasy class.
 * 
 * @example
 * ```tsx
 * <FantasyHeading as="h1" size="2xl">
 *   AFL Fantasy Dashboard
 * </FantasyHeading>
 * 
 * <FantasyHeading as="h2" size="lg">
 *   Team Analysis
 * </FantasyHeading>
 * ```
 */
export const FantasyHeading = React.forwardRef<HTMLHeadingElement, FantasyHeadingProps>(
  ({ as = 'h1', size = 'default', className, children, ...props }, ref) => {
    const Component = as;

    const sizeClasses = {
      sm: 'text-lg',
      default: 'text-xl',  
      lg: 'text-2xl',
      xl: 'text-3xl',
      '2xl': 'text-4xl'
    };

    return (
      <Component
        ref={ref}
        className={cn(
          'font-fantasy font-bold tracking-wide text-foreground',
          sizeClasses[size],
          className
        )}
        {...props}
      >
        {children}
      </Component>
    );
  }
);

FantasyHeading.displayName = 'FantasyHeading';

export default FantasyHeading;
