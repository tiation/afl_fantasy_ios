import Foundation
import Combine

@MainActor
final class CashCowAnalyzerViewModel: ObservableObject {
    // Simple stub implementation for build compatibility
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    init() {
        // Initialize with empty state
    }
    
    func loadData() {
        // Stub method - does nothing
        isLoading = false
    }
}
