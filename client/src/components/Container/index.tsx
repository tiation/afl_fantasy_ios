import React from 'react';
import { cn } from '@/lib/utils';

export interface ContainerProps extends React.HTMLAttributes<HTMLDivElement> {
  /**
   * Size variant for the container
   * @default "default"
   */
  size?: 'sm' | 'default' | 'lg' | 'xl' | 'full';
  /**
   * Whether to center the container content
   * @default true
   */
  center?: boolean;
  /**
   * Additional CSS classes to apply
   */
  className?: string;
  /**
   * Content to render inside the container
   */
  children: React.ReactNode;
}

/**
 * A responsive container component that provides consistent spacing and centering.
 * 
 * @example
 * ```tsx
 * <Container size="lg" className="bg-gray-800">
 *   <h1>AFL Fantasy Dashboard</h1>
 * </Container>
 * ```
 */
export const Container = React.forwardRef<HTMLDivElement, ContainerProps>(
  ({ size = 'default', center = true, className, children, ...props }, ref) => {
    const sizeClasses = {
      sm: 'max-w-2xl',
      default: 'max-w-4xl',
      lg: 'max-w-6xl', 
      xl: 'max-w-7xl',
      full: 'max-w-none'
    };

    return (
      <div
        ref={ref}
        className={cn(
          'w-full px-4 sm:px-6 lg:px-8',
          sizeClasses[size],
          center && 'mx-auto',
          className
        )}
        {...props}
      >
        {children}
      </div>
    );
  }
);

Container.displayName = 'Container';

export default Container;
