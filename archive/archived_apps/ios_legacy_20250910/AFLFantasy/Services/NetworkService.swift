import Combine
import Foundation
import Network

// MARK: - NetworkServiceProtocol

protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
    func requestWithProgress<T: Decodable>(_ endpoint: APIEndpoint) -> AnyPublisher<Result<T, NetworkError>, Never>
    var isConnected: Bool { get }
}

// MARK: - NetworkService

final class NetworkService: NSObject, NetworkServiceProtocol, URLSessionTaskDelegate {
    static let shared = NetworkService()

    // MARK: - Properties

    @Published private(set) var isConnected: Bool = true

    private let session: URLSession
    private let decoder: JSONDecoder
    private let networkMonitor: NWPathMonitor
    private let cache: URLCache
    private let retryLimit = 3
    private let retryDelay: TimeInterval = 2.0

    // Combine subscriptions
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    override private init() {
        // Configure cache
        let cacheSize = 50 * 1024 * 1024 // 50MB
        cache = URLCache(
            memoryCapacity: cacheSize,
            diskCapacity: cacheSize * 5,
            diskPath: "fantasy_api_cache"
        )

        // Configure session
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.urlCache = cache
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 30

        session = URLSession(configuration: configuration)
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        // Network monitoring
        networkMonitor = NWPathMonitor()

        super.init()

        setupNetworkMonitoring()
    }

    // MARK: - NetworkServiceProtocol

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        var retryCount = 0

        while true {
            do {
                return try await performRequest(endpoint)
            } catch let error as NetworkError where error.isRetryable && retryCount < retryLimit {
                retryCount += 1
                try await Task.sleep(nanoseconds: UInt64(retryDelay * pow(2.0, Double(retryCount)) * 1_000_000_000))
                continue
            } catch {
                throw error
            }
        }
    }

    func requestWithProgress<T: Decodable>(_ endpoint: APIEndpoint) -> AnyPublisher<Result<T, NetworkError>, Never> {
        guard isConnected else {
            return Just(.failure(.offline)).eraseToAnyPublisher()
        }

        return Future { promise in
            Task {
                do {
                    let result: T = try await self.request(endpoint)
                    promise(.success(.success(result)))
                } catch {
                    promise(.success(.failure(error as? NetworkError ?? .unknown(error))))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    // MARK: - Private Methods

    private func performRequest<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        guard isConnected else {
            throw NetworkError.offline
        }

        let request = try endpoint.urlRequest()
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        // Handle HTTP status codes
        switch httpResponse.statusCode {
        case 200 ... 299:
            break // Success
        case 401:
            throw NetworkError.unauthorized
        case 429:
            if let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After").flatMap(Double.init) {
                throw NetworkError.rateLimited(retryAfter: retryAfter)
            }
            throw NetworkError.rateLimited(retryAfter: 60)
        case 400 ... 499:
            throw NetworkError.httpError(httpResponse.statusCode)
        case 500 ... 599:
            throw NetworkError.serverError("Server error: \(httpResponse.statusCode)")
        default:
            throw NetworkError.httpError(httpResponse.statusCode)
        }

        do {
            let decodedResponse = try decoder.decode(T.self, from: data)
            return decodedResponse
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.handleNetworkStatusChange(path.status)
            }
        }

        let queue = DispatchQueue(label: "NetworkMonitor")
        networkMonitor.start(queue: queue)
    }

    private func handleNetworkStatusChange(_ status: NWPath.Status) {
        NotificationCenter.default.post(
            name: status == .satisfied ? .networkConnected : .networkDisconnected,
            object: nil
        )
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let networkConnected = Notification.Name("NetworkServiceConnected")
    static let networkDisconnected = Notification.Name("NetworkServiceDisconnected")
}
