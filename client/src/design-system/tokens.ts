/**
 * AFL Fantasy Design System - Design Tokens
 * 
 * Centralized design tokens following the AFL branding and 
 * ensuring consistency across the entire application.
 * 
 * Based on:
 * - AFL official colors and branding
 * - WCAG 2.1 AA compliance (4.5:1 contrast ratio)
 * - Scale-based design (4px grid system)
 */

export const designTokens = {
  // SPACING SYSTEM (4px base grid)
  spacing: {
    '0': '0px',
    '1': '4px',   // 0.25rem
    '2': '8px',   // 0.5rem  
    '3': '12px',  // 0.75rem
    '4': '16px',  // 1rem
    '5': '20px',  // 1.25rem
    '6': '24px',  // 1.5rem
    '8': '32px',  // 2rem
    '10': '40px', // 2.5rem
    '12': '48px', // 3rem
    '16': '64px', // 4rem
    '20': '80px', // 5rem
  } as const,

  // TYPOGRAPHY SCALE
  typography: {
    fontFamily: {
      sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
      fantasy: ['Cinzel', 'serif'], // AFL themed headers
      mono: ['JetBrains Mono', 'Consolas', 'monospace'],
    },
    fontSize: {
      'xs': ['12px', '16px'],   // 0.75rem
      'sm': ['14px', '20px'],   // 0.875rem  
      'base': ['16px', '24px'], // 1rem
      'lg': ['18px', '28px'],   // 1.125rem
      'xl': ['20px', '28px'],   // 1.25rem
      '2xl': ['24px', '32px'],  // 1.5rem
      '3xl': ['30px', '36px'],  // 1.875rem
      '4xl': ['36px', '40px'],  // 2.25rem
      '5xl': ['48px', '1'],     // 3rem
    },
    fontWeight: {
      normal: '400',
      medium: '500',
      semibold: '600', 
      bold: '700',
      extrabold: '800',
    },
  } as const,

  // COLOR SYSTEM
  colors: {
    // AFL Primary Colors
    afl: {
      red: {
        50: '#fef2f2',
        100: '#fee2e2', 
        200: '#fecaca',
        300: '#fca5a5',
        400: '#f87171',
        500: '#ef4444',  // AFL Red primary
        600: '#dc2626',
        700: '#b91c1c',
        800: '#991b1b',
        900: '#7f1d1d',
      },
      blue: {
        50: '#eff6ff',
        100: '#dbeafe',
        200: '#bfdbfe',
        300: '#93c5fd',
        400: '#60a5fa',
        500: '#3b82f6',  // AFL Blue primary
        600: '#2563eb',
        700: '#1d4ed8',
        800: '#1e40af',
        900: '#1e3a8a',
      },
      gold: {
        50: '#fffbeb',
        100: '#fef3c7',
        200: '#fde68a',
        300: '#fcd34d',
        400: '#fbbf24',
        500: '#f59e0b',  // AFL Gold accent
        600: '#d97706',
        700: '#b45309',
        800: '#92400e',
        900: '#78350f',
      }
    },

    // Semantic Colors
    semantic: {
      success: {
        light: '#22c55e',
        DEFAULT: '#16a34a',
        dark: '#15803d',
      },
      warning: {
        light: '#f59e0b',
        DEFAULT: '#d97706', 
        dark: '#b45309',
      },
      error: {
        light: '#f87171',
        DEFAULT: '#dc2626',
        dark: '#b91c1c',
      },
      info: {
        light: '#60a5fa',
        DEFAULT: '#3b82f6',
        dark: '#1d4ed8',
      }
    },

    // Neutral Scale (optimized for dark theme)
    neutral: {
      0: '#ffffff',     // Pure white
      50: '#f9fafb',    // Lightest gray
      100: '#f3f4f6',   
      200: '#e5e7eb',
      300: '#d1d5db',   // Light mode text-muted
      400: '#9ca3af',   // Light mode text-secondary  
      500: '#6b7280',   // Light mode text-tertiary
      600: '#4b5563',   // Dark mode text-secondary
      700: '#374151',   // Dark mode text-primary
      800: '#1f2937',   // Dark mode bg-secondary
      900: '#111827',   // Dark mode bg-primary
      950: '#0a0a0b',   // Darkest background
    },

    // Position Colors (AFL Fantasy specific)
    position: {
      defender: '#3b82f6',   // Blue
      midfielder: '#22c55e', // Green  
      ruck: '#8b5cf6',       // Purple
      forward: '#ef4444',    // Red
    }
  } as const,

  // ELEVATION SYSTEM (box shadows)
  elevation: {
    none: 'none',
    sm: '0 1px 2px 0 rgb(0 0 0 / 0.05)',
    base: '0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1)',
    md: '0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)',
    lg: '0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)',
    xl: '0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1)',
    '2xl': '0 25px 50px -12px rgb(0 0 0 / 0.25)',
    
    // Dark theme shadows (with subtle glow)
    dark: {
      sm: '0 1px 2px 0 rgb(0 0 0 / 0.3)',
      base: '0 1px 3px 0 rgb(0 0 0 / 0.4), 0 1px 2px -1px rgb(0 0 0 / 0.4)',
      md: '0 4px 6px -1px rgb(0 0 0 / 0.4), 0 2px 4px -2px rgb(0 0 0 / 0.4)',
      lg: '0 10px 15px -3px rgb(0 0 0 / 0.4), 0 4px 6px -4px rgb(0 0 0 / 0.4)',
      glow: {
        red: '0 0 20px rgb(239 68 68 / 0.3)',
        blue: '0 0 20px rgb(59 130 246 / 0.3)',
        green: '0 0 20px rgb(34 197 94 / 0.3)',
        purple: '0 0 20px rgb(139 92 246 / 0.3)',
      }
    }
  } as const,

  // BORDER RADIUS
  borderRadius: {
    none: '0px',
    sm: '4px',      // 0.25rem
    base: '6px',    // 0.375rem
    md: '8px',      // 0.5rem
    lg: '12px',     // 0.75rem
    xl: '16px',     // 1rem
    '2xl': '20px',  // 1.25rem
    full: '9999px', // Pills/badges
  } as const,

  // MOTION SYSTEM
  motion: {
    // Transition durations
    duration: {
      fast: '150ms',
      base: '200ms', 
      slow: '300ms',
      slower: '500ms',
    },
    
    // Easing curves
    easing: {
      linear: 'linear',
      out: 'cubic-bezier(0.0, 0.0, 0.2, 1)',      // Ease out
      in: 'cubic-bezier(0.4, 0.0, 1, 1)',         // Ease in  
      inOut: 'cubic-bezier(0.4, 0.0, 0.2, 1)',    // Ease in-out
      bounce: 'cubic-bezier(0.68, -0.55, 0.265, 1.55)', // Bounce
    },

    // Prefers-reduced-motion handling
    reducedMotion: {
      duration: '0.01ms',
      easing: 'linear',
    }
  } as const,

  // BREAKPOINTS (mobile-first)
  breakpoints: {
    sm: '640px',   // Small tablets
    md: '768px',   // Large tablets  
    lg: '1024px',  // Laptops
    xl: '1280px',  // Desktops
    '2xl': '1536px', // Large desktops
  } as const,

  // Z-INDEX SCALE
  zIndex: {
    hide: -1,
    auto: 'auto',
    base: 0,
    docked: 10,
    dropdown: 1000,
    sticky: 1100, 
    banner: 1200,
    overlay: 1300,
    modal: 1400,
    popover: 1500,
    skipLink: 1600,
    toast: 1700,
    tooltip: 1800,
  } as const,
} as const;

// Type exports for TypeScript
export type SpacingScale = keyof typeof designTokens.spacing;
export type ColorScale = keyof typeof designTokens.colors.neutral;
export type FontSizeScale = keyof typeof designTokens.typography.fontSize;

// CSS Custom Properties (for runtime theming)
export const cssVariables = {
  // Colors that can be switched between light/dark
  '--color-bg-primary': 'var(--bg-primary)',
  '--color-bg-secondary': 'var(--bg-secondary)', 
  '--color-text-primary': 'var(--text-primary)',
  '--color-text-secondary': 'var(--text-secondary)',
  '--color-border': 'var(--border)',
  '--color-accent': 'var(--accent)',
  
  // Motion (respects prefers-reduced-motion)
  '--motion-duration-fast': 'var(--motion-fast)',
  '--motion-duration-base': 'var(--motion-base)',
  '--motion-easing': 'var(--motion-easing)',
} as const;

// Utility functions
export const getSpacing = (scale: SpacingScale) => designTokens.spacing[scale];
export const getFontSize = (scale: FontSizeScale) => designTokens.typography.fontSize[scale];

// Dark theme color mapping
export const darkThemeColors = {
  '--bg-primary': designTokens.colors.neutral[900],
  '--bg-secondary': designTokens.colors.neutral[800], 
  '--text-primary': designTokens.colors.neutral[50],
  '--text-secondary': designTokens.colors.neutral[400],
  '--border': designTokens.colors.neutral[700],
  '--accent': designTokens.colors.afl.red[500],
} as const;

// Light theme color mapping  
export const lightThemeColors = {
  '--bg-primary': designTokens.colors.neutral[0],
  '--bg-secondary': designTokens.colors.neutral[50],
  '--text-primary': designTokens.colors.neutral[900], 
  '--text-secondary': designTokens.colors.neutral[600],
  '--border': designTokens.colors.neutral[200],
  '--accent': designTokens.colors.afl.red[600],
} as const;
