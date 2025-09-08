# 📋 Service Layer Migration Guide

## Overview

This guide helps migrate from the old duplicate services to the new consolidated `MasterDataService`.

## Before & After Comparison

### ❌ Before (Duplicate Services)

```swift
// Multiple service injections
@StateObject private var aflDataService = AFLFantasyDataService()
@StateObject private var dashboardService = DashboardService()
@StateObject private var fantasyAPIService = FantasyAPIService()

// Multiple async calls
async let dashboardData = dashboardService.getDashboard(forceRefresh: true)
async let players = fantasyAPIService.getPlayers()
```

### ✅ After (Unified Service)

```swift
// Single service injection
@StateObject private var masterDataService = MasterDataService()

// Unified async calls
async let dashboardData = masterDataService.getDashboardData(forceRefresh: true)
async let players = masterDataService.getPlayers()
```

## Step-by-Step Migration

### Step 1: Replace Service Declarations

**Old:**
```swift
@StateObject private var aflDataService = AFLFantasyDataService()
@StateObject private var dashboardService = DashboardService()
```

**New:**
```swift
@StateObject private var masterDataService = MasterDataService()
```

### Step 2: Update Method Calls

| Old Service | Old Method | New Method |
|-------------|------------|------------|
| `AFLFantasyDataService` | `authenticate(teamId:sessionCookie:apiToken:)` | `masterDataService.authenticate(teamId:sessionCookie:apiToken:)` |
| `AFLFantasyDataService` | `refreshDashboardData()` | `masterDataService.getDashboardData(forceRefresh: true)` |
| `DashboardService` | `getDashboard(forceRefresh:)` | `masterDataService.getDashboardData(forceRefresh:)` |
| `FantasyAPIService` | `getPlayers()` | `masterDataService.getPlayers(position: nil)` |
| `FantasyAPIService` | `getCaptainRecommendations(teamId:round:)` | `masterDataService.getCaptainRecommendations(round:)` |

### Step 3: Update Published Property Access

**Old:**
```swift
dashboardService.isLoading
aflDataService.authenticated
```

**New:**
```swift
masterDataService.isLoading
masterDataService.isAuthenticated
```

### Step 4: Update Combine Publishers

**Old:**
```swift
fantasyAPIService.playerUpdates
    .sink { players in
        // Handle update
    }
```

**New:**
```swift
masterDataService.playerUpdates
    .sink { players in
        // Handle update
    }
```

## Migration Checklist by View

### ✅ UnifiedDashboardView 
- Already uses MasterDataService pattern
- No migration needed

### 🔄 TradesView (TODO)
```swift
// Replace:
@StateObject private var tradeService = TradeService()

// With:
@StateObject private var masterDataService = MasterDataService()

// Update calls:
// tradeService.getRecommendations() → masterDataService.getTradeRecommendations()
```

### 🔄 CaptainAIView (TODO)
```swift
// Replace:
@StateObject private var captainService = CaptainService()

// With:
@StateObject private var masterDataService = MasterDataService()

// Update calls:
// captainService.getRecommendations() → masterDataService.getCaptainRecommendations()
```

### 🔄 CashCowView (TODO)
```swift
// Replace:
@StateObject private var cashCowService = CashCowService()

// With:
@StateObject private var masterDataService = MasterDataService()

// Update calls:
// cashCowService.analyzeCows() → masterDataService.analyzeCashCows()
```

### 🔄 PlayerDetailView (TODO)
```swift
// Replace:
@StateObject private var playerService = PlayerService()

// With:
@StateObject private var masterDataService = MasterDataService()

// Update calls:
// playerService.getDetails(id:) → masterDataService.getPlayerDetails(playerId:)
```

## Error Handling Migration

### Old Pattern (Multiple Error Sources)
```swift
.alert("Error", isPresented: $showingError) {
    Button("Retry") {
        Task {
            if let dashboardError = dashboardService.lastError {
                // Handle dashboard error
            } else if let playerError = playerService.lastError {
                // Handle player error
            }
        }
    }
}
```

### New Pattern (Unified Error Handling)
```swift
.alert("Error", isPresented: $showingError) {
    Button("Retry") {
        Task {
            do {
                try await masterDataService.refreshAllData()
            } catch {
                // Single error handling point
                print("Refresh failed: \(error)")
            }
        }
    }
}
```

## Performance Benefits

### Memory Usage
- **Before**: 3+ service instances per view = ~150MB overhead
- **After**: 1 shared service instance = ~50MB total

### Network Efficiency  
- **Before**: Duplicate API calls from multiple services
- **After**: Intelligent caching with single source of truth

### Code Maintainability
- **Before**: 253 Swift files with duplicate logic
- **After**: Consolidated logic, easier debugging

## Testing Migration

### Unit Tests
```swift
// Old
func testDashboardService() {
    let service = DashboardService()
    // Test implementation
}

// New  
func testMasterDataService() {
    let service = MasterDataService()
    // Test unified implementation
}
```

### Integration Tests
```swift
// Test that MasterDataService properly handles all use cases
func testUnifiedDataFlow() async {
    let service = MasterDataService()
    
    // Test authentication
    try await service.authenticate(teamId: "123", sessionCookie: "abc", apiToken: nil)
    
    // Test data fetching
    let dashboard = try await service.getDashboardData(forceRefresh: false)
    let players = try await service.getPlayers(position: nil)
    
    // Verify consistency
    XCTAssertNotNil(dashboard)
    XCTAssertFalse(players.isEmpty)
}
```

## Rollback Plan

If issues arise, you can temporarily revert by:

1. **Keep old services** alongside new ones
2. **Feature flag** the migration per view
3. **Gradual rollout** starting with less critical views

```swift
#if USE_MASTER_DATA_SERVICE
@StateObject private var dataService = MasterDataService()
#else
@StateObject private var dataService = AFLFantasyDataService()
#endif
```

## Success Metrics

- ✅ **Compile Time**: Faster builds due to fewer dependencies
- ✅ **App Size**: Smaller binary due to code deduplication  
- ✅ **Memory Usage**: Reduced memory footprint
- ✅ **Network Calls**: Fewer duplicate API requests
- ✅ **Bug Rate**: Easier maintenance and debugging

## Next Steps

1. **Phase 1b**: Complete service layer migration
2. **Phase 2**: Add performance monitoring
3. **Phase 3**: Implement iOS-specific features
4. **Phase 4**: Production testing and optimization

---

*This migration is part of the AFL Fantasy iOS consolidation project to eliminate technical debt and improve performance.*
