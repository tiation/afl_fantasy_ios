# Layout Component

A minimal layout component that provides consistent page structure across the AFL Fantasy Manager application.

## Features

- **Integrated TooltipProvider**: Automatically wraps all content with TooltipProvider for consistent tooltip functionality
- **Enhanced Navbar**: Includes the existing Header component plus a Quick Links navigation bar
- **Responsive Design**: Works on both desktop (with sidebar) and mobile (with bottom navigation)
- **Consistent Structure**: Ensures all pages have the same layout structure

## Usage

The Layout component is now automatically applied to all routes in `App.tsx`:

```tsx
function Router() {
  return (
    <Layout>
      <Switch>
        <Route path="/" component={Dashboard} />
        <Route path="/player-stats" component={PlayerStats} />
        // ... other routes
      </Switch>
    </Layout>
  );
}
```

## Quick Links

The Layout component includes a Quick Links navigation bar with the following links:
- Dashboard (/)
- Lineup (/lineup)  
- Stats (/player-stats)
- Tools (/tools-simple)
- Trades (/trade-analyzer)
- Leagues (/leagues)

The active link is highlighted with a blue background and border.

## Progressive Page Updates

Since all pages now use the shared Layout component, individual pages can be updated without needing to handle layout concerns:

### Before (Old Pattern)
```tsx
// Each page needed to handle its own layout
export default function MyPage() {
  return (
    <div className="some-layout-classes">
      <Header />
      <div className="content">
        {/* Page content */}
      </div>
    </div>
  );
}
```

### After (New Pattern)
```tsx
// Pages only need to focus on their content
export default function MyPage() {
  return (
    <div>
      <h1>My Page Title</h1>
      {/* Page content - layout is automatically handled */}
    </div>
  );
}
```

## Components Structure

```
Layout.tsx
├── TooltipProvider (wraps everything)
├── Sidebar (desktop only)
├── Main Content Area
│   ├── Navbar
│   │   ├── Header (search, notifications, profile)
│   │   └── QuickLinks (navigation shortcuts)
│   └── Page Content (children)
└── BottomNav (mobile only)
```

## Benefits

1. **Consistency**: All pages have the same layout structure
2. **DRY Principle**: Layout code is not duplicated across pages
3. **Maintainability**: Changes to layout only need to be made in one place
4. **Progressive Enhancement**: Existing pages work without modification
5. **Accessibility**: TooltipProvider is consistently available on all pages
6. **Performance**: Layout components are reused rather than recreated

## Implementation Status

✅ Layout component created
✅ Integrated with App.tsx  
✅ TooltipProvider automatically included
✅ Quick Links navigation added
✅ All existing routes updated to use Layout
✅ Build tested and working

All pages are now using the new Layout component without requiring individual page modifications.
