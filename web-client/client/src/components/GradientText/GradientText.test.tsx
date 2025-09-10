import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { GradientText } from './index';

describe('GradientText', () => {
  it('renders children correctly', () => {
    render(
      <GradientText>
        Gradient Text Content
      </GradientText>
    );
    
    expect(screen.getByText('Gradient Text Content')).toBeInTheDocument();
  });

  it('applies default primary gradient classes', () => {
    render(
      <GradientText data-testid="gradient-text">
        Test content
      </GradientText>
    );
    
    const element = screen.getByTestId('gradient-text');
    expect(element).toHaveClass(
      'bg-clip-text',
      'text-transparent',
      'font-semibold',
      'bg-gradient-to-r',
      'from-blue-500',
      'to-purple-600'
    );
  });

  it('applies fantasy variant gradient classes', () => {
    render(
      <GradientText variant="fantasy" data-testid="gradient-text">
        Fantasy Text
      </GradientText>
    );
    
    const element = screen.getByTestId('gradient-text');
    expect(element).toHaveClass(
      'from-purple-500',
      'via-pink-500',
      'to-red-500'
    );
  });

  it('applies secondary variant gradient classes', () => {
    render(
      <GradientText variant="secondary" data-testid="gradient-text">
        Secondary Text
      </GradientText>
    );
    
    const element = screen.getByTestId('gradient-text');
    expect(element).toHaveClass(
      'from-gray-400',
      'to-gray-600'
    );
  });

  it('applies accent variant gradient classes', () => {
    render(
      <GradientText variant="accent" data-testid="gradient-text">
        Accent Text
      </GradientText>
    );
    
    const element = screen.getByTestId('gradient-text');
    expect(element).toHaveClass(
      'from-green-400',
      'to-blue-500'
    );
  });

  it('applies success variant gradient classes', () => {
    render(
      <GradientText variant="success" data-testid="gradient-text">
        Success Text
      </GradientText>
    );
    
    const element = screen.getByTestId('gradient-text');
    expect(element).toHaveClass(
      'from-green-400',
      'to-emerald-500'
    );
  });

  it('applies warning variant gradient classes', () => {
    render(
      <GradientText variant="warning" data-testid="gradient-text">
        Warning Text
      </GradientText>
    );
    
    const element = screen.getByTestId('gradient-text');
    expect(element).toHaveClass(
      'from-yellow-400',
      'to-orange-500'
    );
  });

  it('forwards custom className', () => {
    render(
      <GradientText className="custom-class" data-testid="gradient-text">
        Test content
      </GradientText>
    );
    
    const element = screen.getByTestId('gradient-text');
    expect(element).toHaveClass('custom-class');
  });

  it('forwards HTML attributes', () => {
    render(
      <GradientText id="test-id" title="test-title" data-testid="gradient-text">
        Test content
      </GradientText>
    );
    
    const element = screen.getByTestId('gradient-text');
    expect(element).toHaveAttribute('id', 'test-id');
    expect(element).toHaveAttribute('title', 'test-title');
  });

  it('renders as span element', () => {
    render(
      <GradientText data-testid="gradient-text">
        Test content
      </GradientText>
    );
    
    const element = screen.getByTestId('gradient-text');
    expect(element.tagName).toBe('SPAN');
  });
});
