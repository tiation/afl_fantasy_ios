import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { Container } from './index';

describe('Container', () => {
  it('renders children correctly', () => {
    render(
      <Container>
        <span>Test content</span>
      </Container>
    );
    
    expect(screen.getByText('Test content')).toBeInTheDocument();
  });

  it('applies default classes correctly', () => {
    render(
      <Container data-testid="container">
        <span>Test content</span>
      </Container>
    );
    
    const container = screen.getByTestId('container');
    expect(container).toHaveClass('w-full', 'px-4', 'sm:px-6', 'lg:px-8', 'max-w-4xl', 'mx-auto');
  });

  it('applies custom size classes', () => {
    render(
      <Container size="lg" data-testid="container">
        <span>Test content</span>
      </Container>
    );
    
    const container = screen.getByTestId('container');
    expect(container).toHaveClass('max-w-6xl');
  });

  it('applies full size without max-width', () => {
    render(
      <Container size="full" data-testid="container">
        <span>Test content</span>
      </Container>
    );
    
    const container = screen.getByTestId('container');
    expect(container).toHaveClass('max-w-none');
  });

  it('respects center prop when set to false', () => {
    render(
      <Container center={false} data-testid="container">
        <span>Test content</span>
      </Container>
    );
    
    const container = screen.getByTestId('container');
    expect(container).not.toHaveClass('mx-auto');
  });

  it('forwards custom className', () => {
    render(
      <Container className="custom-class" data-testid="container">
        <span>Test content</span>
      </Container>
    );
    
    const container = screen.getByTestId('container');
    expect(container).toHaveClass('custom-class');
  });

  it('forwards HTML attributes', () => {
    render(
      <Container id="test-id" role="main" data-testid="container">
        <span>Test content</span>
      </Container>
    );
    
    const container = screen.getByTestId('container');
    expect(container).toHaveAttribute('id', 'test-id');
    expect(container).toHaveAttribute('role', 'main');
  });

  it('renders with correct default props', () => {
    render(
      <Container data-testid="container">
        <span>Test content</span>
      </Container>
    );
    
    const container = screen.getByTestId('container');
    expect(container).toHaveClass('max-w-4xl'); // default size
    expect(container).toHaveClass('mx-auto'); // center=true by default
  });
});
