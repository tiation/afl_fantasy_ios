import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { FantasyHeading } from './index';

describe('FantasyHeading', () => {
  it('renders children correctly', () => {
    render(
      <FantasyHeading>
        Fantasy Heading Content
      </FantasyHeading>
    );
    
    expect(screen.getByText('Fantasy Heading Content')).toBeInTheDocument();
  });

  it('renders as h1 by default', () => {
    render(
      <FantasyHeading data-testid="heading">
        Default Heading
      </FantasyHeading>
    );
    
    const heading = screen.getByTestId('heading');
    expect(heading.tagName).toBe('H1');
  });

  it('renders with specified heading level', () => {
    render(
      <FantasyHeading as="h2" data-testid="heading">
        H2 Heading
      </FantasyHeading>
    );
    
    const heading = screen.getByTestId('heading');
    expect(heading.tagName).toBe('H2');
  });

  it('renders all heading levels correctly', () => {
    const headingLevels = ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'] as const;
    
    headingLevels.forEach((level) => {
      render(
        <FantasyHeading as={level} data-testid={`heading-${level}`}>
          {level.toUpperCase()} Heading
        </FantasyHeading>
      );
      
      const heading = screen.getByTestId(`heading-${level}`);
      expect(heading.tagName).toBe(level.toUpperCase());
    });
  });

  it('applies default fantasy font classes', () => {
    render(
      <FantasyHeading data-testid="heading">
        Test Heading
      </FantasyHeading>
    );
    
    const heading = screen.getByTestId('heading');
    expect(heading).toHaveClass(
      'font-fantasy',
      'font-bold',
      'tracking-wide',
      'text-foreground',
      'text-xl' // default size
    );
  });

  it('applies small size classes', () => {
    render(
      <FantasyHeading size="sm" data-testid="heading">
        Small Heading
      </FantasyHeading>
    );
    
    const heading = screen.getByTestId('heading');
    expect(heading).toHaveClass('text-lg');
  });

  it('applies large size classes', () => {
    render(
      <FantasyHeading size="lg" data-testid="heading">
        Large Heading
      </FantasyHeading>
    );
    
    const heading = screen.getByTestId('heading');
    expect(heading).toHaveClass('text-2xl');
  });

  it('applies extra large size classes', () => {
    render(
      <FantasyHeading size="xl" data-testid="heading">
        XL Heading
      </FantasyHeading>
    );
    
    const heading = screen.getByTestId('heading');
    expect(heading).toHaveClass('text-3xl');
  });

  it('applies 2xl size classes', () => {
    render(
      <FantasyHeading size="2xl" data-testid="heading">
        2XL Heading
      </FantasyHeading>
    );
    
    const heading = screen.getByTestId('heading');
    expect(heading).toHaveClass('text-4xl');
  });

  it('forwards custom className', () => {
    render(
      <FantasyHeading className="custom-class" data-testid="heading">
        Test Heading
      </FantasyHeading>
    );
    
    const heading = screen.getByTestId('heading');
    expect(heading).toHaveClass('custom-class');
  });

  it('forwards HTML attributes', () => {
    render(
      <FantasyHeading id="test-id" role="banner" data-testid="heading">
        Test Heading
      </FantasyHeading>
    );
    
    const heading = screen.getByTestId('heading');
    expect(heading).toHaveAttribute('id', 'test-id');
    expect(heading).toHaveAttribute('role', 'banner');
  });

  it('combines size and as props correctly', () => {
    render(
      <FantasyHeading as="h3" size="2xl" data-testid="heading">
        H3 with 2XL size
      </FantasyHeading>
    );
    
    const heading = screen.getByTestId('heading');
    expect(heading.tagName).toBe('H3');
    expect(heading).toHaveClass('text-4xl');
  });

  it('maintains all fantasy styling with custom props', () => {
    render(
      <FantasyHeading 
        as="h4" 
        size="lg" 
        className="text-green-500" 
        data-testid="heading"
      >
        Styled Heading
      </FantasyHeading>
    );
    
    const heading = screen.getByTestId('heading');
    expect(heading.tagName).toBe('H4');
    expect(heading).toHaveClass(
      'font-fantasy',
      'font-bold',
      'tracking-wide',
      'text-2xl',
      'text-green-500'
    );
  });
});
