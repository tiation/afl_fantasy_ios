import Foundation
import Combine

// MARK: - Core Architecture Protocols

/// Base protocol for all Use Cases
protocol UseCase {
    associatedtype Input
    associatedtype Output
    
    func execute(_ input: Input) async throws -> Output
}

/// Protocol for ViewModels in MVVM architecture
@MainActor
protocol ViewModel: ObservableObject {
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    
    func refresh() async
}

/// Protocol for Repository layer
protocol Repository {
    associatedtype Entity
    associatedtype ID: Hashable
    
    func fetch(id: ID) async throws -> Entity?
    func fetchAll() async throws -> [Entity]
    func save(_ entity: Entity) async throws
    func delete(id: ID) async throws
}

// MARK: - Service Locator (Simple DI)

final class ServiceLocator {
    static let shared = ServiceLocator()
    private var services: [String: Any] = [:]
    
    private init() {}
    
    func register<T>(_ service: T, for type: T.Type) {
        let key = String(describing: type)
        services[key] = service
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        guard let service = services[key] as? T else {
            fatalError("Service \(key) not registered")
        }
        return service
    }
    
    func resolveOptional<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        return services[key] as? T
    }
}

// MARK: - Base Use Case Implementation

/// Generic base implementation for simple Use Cases
open class BaseUseCase<Input, Output>: UseCase {
    open func execute(_ input: Input) async throws -> Output {
        fatalError("Must override execute method")
    }
}

// MARK: - Common Result Types

enum AppError: LocalizedError {
    case networkError(Error)
    case decodingError(Error)
    case notFound
    case invalidInput
    case unauthorized
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .notFound:
            return "Resource not found"
        case .invalidInput:
            return "Invalid input provided"
        case .unauthorized:
            return "Unauthorized access"
        case .serverError(let message):
            return "Server error: \(message)"
        }
    }
}

// MARK: - Loading State

enum LoadingState<T> {
    case idle
    case loading
    case loaded(T)
    case error(Error)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var data: T? {
        if case .loaded(let data) = self { return data }
        return nil
    }
    
    var error: Error? {
        if case .error(let error) = self { return error }
        return nil
    }
}
