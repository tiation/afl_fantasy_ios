import Foundation

// MARK: - HTTPMethod

public enum HTTPMethod: String, Codable, CaseIterable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// MARK: - NetworkError

public enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case serverError(String)
    case noData
    case unauthorized
    case offline
    case rateLimited(retryAfter: TimeInterval)
    case timeout
    case cancelled
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Invalid URL"
        case .invalidResponse:
            "Invalid server response"
        case let .httpError(code):
            "HTTP error: \(code)"
        case let .decodingError(error):
            "Failed to decode response: \(error.localizedDescription)"
        case let .serverError(message):
            "Server error: \(message)"
        case .noData:
            "No data received"
        case .unauthorized:
            "Unauthorized access"
        case .offline:
            "No internet connection"
        case let .rateLimited(retryAfter):
            "Rate limited. Try again in \(Int(retryAfter)) seconds"
        case .timeout:
            "Request timed out"
        case .cancelled:
            "Request cancelled"
        case let .unknown(error):
            "Unknown error: \(error.localizedDescription)"
        }
    }

    public var isRetryable: Bool {
        switch self {
        case .offline, .timeout, .serverError:
            true
        case let .httpError(code):
            code >= 500 // Retry server errors
        default:
            false
        }
    }

    public var shouldLogout: Bool {
        switch self {
        case .unauthorized:
            true
        default:
            false
        }
    }
}

// MARK: - APIEndpoint

public protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem]? { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
    var cachePolicy: URLRequest.CachePolicy { get }
    var timeoutInterval: TimeInterval { get }
}

public extension APIEndpoint {
    var baseURL: URL {
        URL(string: "https://api.fantasy.afl.com.au/v1")!
    }

    var queryItems: [URLQueryItem]? { nil }
    var headers: [String: String]? { nil }
    var body: Data? { nil }
    var cachePolicy: URLRequest.CachePolicy { .useProtocolCachePolicy }
    var timeoutInterval: TimeInterval { 30 }

    func urlRequest() throws -> URLRequest {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)
        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(
            url: url,
            cachePolicy: cachePolicy,
            timeoutInterval: timeoutInterval
        )
        request.httpMethod = method.rawValue
        request.httpBody = body

        // Default headers
        var defaultHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "X-App-Version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        ]

        // Add custom headers
        headers?.forEach { defaultHeaders[$0.key] = $0.value }

        // Set all headers
        defaultHeaders.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        return request
    }
}

// MARK: - APIResponse

public struct APIResponse<T: Codable>: Codable {
    public let data: T?
    public let error: String?
    public let timestamp: Date

    public init(data: T?, error: String? = nil, timestamp: Date = Date()) {
        self.data = data
        self.error = error
        self.timestamp = timestamp
    }
}
