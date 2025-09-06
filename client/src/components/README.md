# UI Components

This directory contains reusable UI components for the AFL Fantasy Dashboard.

## Components

### Container

A responsive wrapper component that provides consistent spacing and centering.

**Props:**
- `size?: 'sm' | 'default' | 'lg' | 'xl' | 'full'` - Size variant for the container (default: 'default')
- `center?: boolean` - Whether to center the container content (default: true)
- `className?: string` - Additional CSS classes to apply
- `children: React.ReactNode` - Content to render inside the container

**Example:**
```tsx
<Container size="lg" className="bg-gray-800">
  <h1>AFL Fantasy Dashboard</h1>
</Container>
```

### GradientText

A utility component that applies gradient text effects to its children.

**Props:**
- `variant?: 'primary' | 'secondary' | 'accent' | 'success' | 'warning' | 'fantasy'` - Gradient variant to apply (default: 'primary')
- `className?: string` - Additional CSS classes to apply
- `children: React.ReactNode` - Content to render inside the gradient text

**Example:**
```tsx
<GradientText variant="fantasy">
  AFL Fantasy Champion
</GradientText>
```

**Gradient Variants:**
- `primary`: Blue to purple gradient
- `secondary`: Gray gradient
- `accent`: Green to blue gradient
- `success`: Green to emerald gradient
- `warning`: Yellow to orange gradient
- `fantasy`: Purple to pink to red gradient

### FantasyHeading

A semantic heading component with fantasy-themed styling using the font-fantasy class.

**Props:**
- `as?: 'h1' | 'h2' | 'h3' | 'h4' | 'h5' | 'h6'` - The semantic heading level to render (default: 'h1')
- `size?: 'sm' | 'default' | 'lg' | 'xl' | '2xl'` - Size variant for the heading (default: 'default')
- `className?: string` - Additional CSS classes to apply
- `children: React.ReactNode` - Content to render inside the heading

**Example:**
```tsx
<FantasyHeading as="h1" size="2xl">
  AFL Fantasy Dashboard
</FantasyHeading>

<FantasyHeading as="h2" size="lg">
  Team Analysis
</FantasyHeading>
```

**Size Variants:**
- `sm`: text-lg
- `default`: text-xl
- `lg`: text-2xl
- `xl`: text-3xl
- `2xl`: text-4xl

## Testing

All components include comprehensive unit tests using Vitest and React Testing Library.

Run tests with:
```bash
npm test
```

Watch mode:
```bash
npm run test:watch
```

Coverage report:
```bash
npm run test:coverage
```

## Enterprise-Grade Features

- ✅ Full TypeScript support with proper type definitions
- ✅ Comprehensive unit test coverage
- ✅ Consistent API design with forwarded refs
- ✅ Prop forwarding for HTML attributes
- ✅ Accessibility-friendly semantic markup
- ✅ Responsive design with Tailwind CSS
- ✅ Component composition support
- ✅ Documentation with examples
