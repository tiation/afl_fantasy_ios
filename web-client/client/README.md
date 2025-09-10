# AFL Fantasy Platform - Frontend/Client

## Overview

The `client` directory contains the frontend application code for the AFL Fantasy Platform. This React-based application provides an intuitive and responsive user interface, developed following **Tiation's** enterprise-grade DevOps standards and modern web development best practices.

## Technology Stack

### 🎨 **Frontend Framework**
- **React 18**: Modern React with hooks and concurrent features
- **TypeScript**: Type-safe development for better code quality
- **Vite**: Lightning-fast build tool and development server
- **Tailwind CSS**: Utility-first CSS framework for rapid UI development

### 🏗️ **Architecture**
- **Component-Based**: Modular, reusable React components
- **State Management**: React Query for server state, React hooks for local state
- **Routing**: Wouter for lightweight client-side routing
- **Forms**: React Hook Form with Zod validation

### 🎯 **UI/UX Components**
- **Radix UI**: Accessible, unstyled UI primitives
- **Shadcn/UI**: Beautiful component library built on Radix
- **Lucide React**: Consistent and beautiful icons
- **Framer Motion**: Smooth animations and transitions

## Directory Structure

```
client/
├── src/
│   ├── components/      # Reusable UI components
│   ├── pages/          # Route-specific page components
│   ├── hooks/          # Custom React hooks
│   ├── utils/          # Utility functions
│   ├── types/          # TypeScript type definitions
│   └── styles/         # Global styles and themes
├── public/             # Static assets
├── index.html          # Main HTML template
└── README.md          # This file
```

## Tiation DevOps Standards

### 🚀 **Development Excellence**
- **Type Safety**: 100% TypeScript coverage for robust code
- **Component Testing**: Comprehensive test coverage with React Testing Library
- **Code Quality**: ESLint and Prettier for consistent code formatting
- **Performance**: Bundle optimization and lazy loading strategies

### 🎨 **Design System**
- **Consistent UI**: Design tokens and component library
- **Accessibility**: WCAG 2.1 AA compliance across all components
- **Responsive Design**: Mobile-first approach with progressive enhancement
- **Dark Mode**: Built-in theme switching capability

### 🔄 **CI/CD Integration**
- **Automated Testing**: Unit and integration tests in CI pipeline
- **Build Optimization**: Production builds with asset optimization
- **Deployment**: Automated deployment with environment-specific configs
- **Performance Monitoring**: Real user monitoring and Core Web Vitals tracking

## Development Setup

### Prerequisites
- Node.js 18+ (recommended: use nvm)
- npm or yarn package manager

### Local Development

1. **Install Dependencies**
   ```bash
   cd client
   npm install
   ```

2. **Start Development Server**
   ```bash
   npm run dev
   ```

3. **Access Application**
   - Development: http://localhost:3000
   - Hot reloading enabled for instant feedback

### Build Commands

```bash
# Development build
npm run dev

# Production build
npm run build

# Type checking
npm run check

# Linting
npm run lint

# Testing
npm run test
```

## Component Architecture

### 🧩 **Component Guidelines**
- **Single Responsibility**: Each component has one clear purpose
- **Composition over Inheritance**: Use composition patterns
- **Props Interface**: Well-defined TypeScript interfaces for all props
- **Documentation**: JSDoc comments for complex components

### 🎨 **Styling Standards**
- **Tailwind First**: Use Tailwind utilities for styling
- **CSS Variables**: Custom properties for theming
- **Mobile First**: Responsive design from mobile up
- **Accessibility**: Focus states, ARIA labels, semantic HTML

### 🔧 **State Management**
- **Server State**: React Query for API data management
- **Local State**: useState and useReducer for component state
- **Form State**: React Hook Form for form management
- **Global State**: Context API for app-wide state when needed

## Performance Optimization

### 🚀 **Bundle Optimization**
- **Code Splitting**: Route-based and component-based splitting
- **Tree Shaking**: Eliminate unused code
- **Asset Optimization**: Image optimization and compression
- **CDN Integration**: Static asset delivery via CDN

### 📊 **Monitoring**
- **Core Web Vitals**: LCP, FID, CLS monitoring
- **Error Tracking**: Automated error reporting
- **Performance Metrics**: Real user monitoring
- **Bundle Analysis**: Regular bundle size monitoring

## Testing Strategy

### 🧪 **Testing Approach**
- **Unit Tests**: Component behavior and utility functions
- **Integration Tests**: User interaction flows
- **E2E Tests**: Critical user journeys
- **Visual Regression**: Automated screenshot testing

### 🎯 **Coverage Goals**
- **Unit Test Coverage**: > 80%
- **Integration Test Coverage**: Critical user flows
- **Accessibility Tests**: Automated a11y testing
- **Performance Tests**: Core Web Vitals thresholds

## Contributing

### 📝 **Code Contribution**
1. **Branch Strategy**: Feature branches from main
2. **Commit Convention**: Conventional commits for clear history
3. **Code Review**: Minimum two reviewers for all changes
4. **Testing**: All new features require test coverage

### 🎨 **Design Contribution**
1. **Design System**: Use existing components when possible
2. **New Components**: Follow established patterns
3. **Accessibility**: Ensure WCAG compliance
4. **Mobile Experience**: Test on various device sizes

## Quality Assurance

### ✅ **Pre-deployment Checklist**
- [ ] All tests passing
- [ ] TypeScript compilation successful
- [ ] Accessibility audit passed
- [ ] Performance budget met
- [ ] Cross-browser testing completed
- [ ] Mobile responsiveness verified

### 🔍 **Code Quality Tools**
- **ESLint**: Code quality and consistency
- **Prettier**: Code formatting
- **TypeScript**: Type checking
- **Husky**: Git hooks for quality gates

## Support & Resources

### 📚 **Documentation**
- [Component Storybook](./storybook) - Interactive component documentation
- [Design System](./design-system.md) - Design tokens and guidelines
- [API Integration](./api-integration.md) - Backend integration patterns

### 🆘 **Support**
- **Frontend Team**: Tiation UI/UX Engineering
- **DevOps Support**: Tiation Infrastructure Team
- **Design System**: ChaseWhiteRabbit NGO Design Team

---

*Frontend application developed by **Tiation** following enterprise-grade development standards, ensuring exceptional user experience and robust performance for the AFL Fantasy Platform.*
