import SwiftUI
import Combine

extension Publisher {
    func sinkToResult(_ result: @escaping (Result<Output, Failure>) -> Void) -> AnyCancellable {
        sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    result(.failure(error))
                case .finished:
                    break
                }
            },
            receiveValue: { value in
                result(.success(value))
            }
        )
    }
    
    func mapToResult() -> AnyPublisher<Result<Output, Failure>, Never> {
        map { value -> Result<Output, Failure> in
            .success(value)
        }
        .catch { error -> AnyPublisher<Result<Output, Failure>, Never> in
            Just(.failure(error))
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    func asyncMap<T>(_ transform: @escaping (Output) async throws -> T) -> AnyPublisher<T, Error> {
        mapError { $0 as Error }
            .flatMap { value -> Future<T, Error> in
                Future { promise in
                    Task {
                        do {
                            let transformed = try await transform(value)
                            promise(.success(transformed))
                        } catch {
                            promise(.failure(error))
                        }
                    }
                }
            }
            .eraseToAnyPublisher()
    }
    
    func asyncFilter(_ isIncluded: @escaping (Output) async -> Bool) -> AnyPublisher<Output, Failure> {
        flatMap { value -> AnyPublisher<Output, Failure> in
            Future { promise in
                Task {
                    if await isIncluded(value) {
                        promise(.success(value))
                    }
                }
            }
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    func handleEvents(
        receiveOutput: ((Output) -> Void)? = nil,
        receiveError: ((Failure) -> Void)? = nil
    ) -> AnyPublisher<Output, Failure> {
        handleEvents(
            receiveSubscription: nil,
            receiveOutput: receiveOutput,
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    receiveError?(error)
                }
            },
            receiveCancel: nil,
            receiveRequest: nil
        )
        .eraseToAnyPublisher()
    }
}

extension Publisher where Failure == Never {
    func assignWeak<Root: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<Root, Output>,
        on object: Root
    ) -> AnyCancellable {
        sink { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
}

extension Publisher where Output == Bool {
    func toggled() -> AnyPublisher<Bool, Failure> {
        map { !$0 }.eraseToAnyPublisher()
    }
    
    func filter(is value: Bool) -> AnyPublisher<Bool, Failure> {
        filter { $0 == value }.eraseToAnyPublisher()
    }
}

// Extension removed due to type conflicts with switchToLatest

extension Publisher {
    func sinkToLoadable(_ completion: @escaping (Loadable<Output>) -> Void) -> AnyCancellable {
        return sink(
            receiveCompletion: { subscriptionCompletion in
                if let error = subscriptionCompletion.error {
                    completion(.failed(error))
                }
            },
            receiveValue: { value in
                completion(.loaded(value))
            }
        )
    }
    
    func asLoadable() -> AnyPublisher<Loadable<Output>, Never> {
        map { Loadable<Output>.loaded($0) }
            .catch { Just(Loadable<Output>.failed($0)) }
            .eraseToAnyPublisher()
    }
}

// Helper for handling loading states
enum Loadable<T> {
    case notLoaded
    case loading
    case loaded(T)
    case failed(Error)
    
    var value: T? {
        switch self {
        case .loaded(let value): return value
        default: return nil
        }
    }
    
    var error: Error? {
        switch self {
        case .failed(let error): return error
        default: return nil
        }
    }
    
    var isLoading: Bool {
        switch self {
        case .loading: return true
        default: return false
        }
    }
}

// Helper for working with Combine subscriptions
final class Subscriptions {
    private var subscriptions = Set<AnyCancellable>()
    
    func store(_ subscription: AnyCancellable) {
        subscriptions.insert(subscription)
    }
    
    func cancel() {
        subscriptions.removeAll()
    }
}

// Helper for Completion errors
extension Subscribers.Completion {
    var error: Failure? {
        switch self {
        case .failure(let error): return error
        case .finished: return nil
        }
    }
}

// Helper for debouncing user input
extension Published.Publisher where Value == String {
    func debouncedSearch(
        for dueTime: TimeInterval = 0.5
    ) -> AnyPublisher<String, Never> {
        debounce(
            for: .seconds(dueTime),
            scheduler: DispatchQueue.main
        )
        .filter { !$0.isEmpty }
        .eraseToAnyPublisher()
    }
}

// Helper for view presentation states
enum PresentationState<Value> {
    case presenting(Value)
    case dismissing(Value)
    case dismissed
    
    var value: Value? {
        switch self {
        case .presenting(let value), .dismissing(let value):
            return value
        case .dismissed:
            return nil
        }
    }
    
    var isDismissed: Bool {
        if case .dismissed = self { return true }
        return false
    }
    
    var isPresenting: Bool {
        if case .presenting = self { return true }
        return false
    }
}

extension PresentationState: Equatable where Value: Equatable {}
