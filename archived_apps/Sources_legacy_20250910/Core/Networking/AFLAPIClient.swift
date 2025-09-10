import Foundation
import Combine

// MARK: - AFL API Client

@available(iOS 15.0, *)
protocol AFLAPIClientProtocol {
    func request<T: Decodable>(_ endpoint: AFLEndpoint) async throws -> T
    func requestPublisher<T: Decodable>(_ endpoint: AFLEndpoint, responseType: T.Type) -> AnyPublisher<T, Error>
}

@available(iOS 15.0, *)
final class AFLAPIClient: AFLAPIClientProtocol {
    private let baseURL: String
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(baseURL: String = "http://localhost:4000", session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = JSONDecoder()
        setupDecoder()
    }
    
    private func setupDecoder() {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            // Fallback to simple ISO format
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateString)")
        }
    }
    
    func request<T: Decodable>(_ endpoint: AFLEndpoint) async throws -> T {
        let url = try buildURL(for: endpoint)
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = endpoint.body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AppError.networkError(URLError(.badServerResponse))
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw AppError.serverError("HTTP \(httpResponse.statusCode)")
            }
            
            let decodedResponse = try decoder.decode(T.self, from: data)
            return decodedResponse
        } catch let error as DecodingError {
            throw AppError.decodingError(error)
        } catch {
            throw AppError.networkError(error)
        }
    }
    
    func requestPublisher<T: Decodable>(_ endpoint: AFLEndpoint, responseType: T.Type) -> AnyPublisher<T, Error> {
        do {
            let url = try buildURL(for: endpoint)
            var request = URLRequest(url: url)
            request.httpMethod = endpoint.method.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            if let body = endpoint.body {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            }
            
            return session.dataTaskPublisher(for: request)
                .tryMap { data, response in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw AppError.networkError(URLError(.badServerResponse))
                    }
                    
                    guard (200...299).contains(httpResponse.statusCode) else {
                        throw AppError.serverError("HTTP \(httpResponse.statusCode)")
                    }
                    
                    return data
                }
                .decode(type: T.self, decoder: decoder)
                .mapError { error in
                    if error is DecodingError {
                        return AppError.decodingError(error)
                    } else {
                        return AppError.networkError(error)
                    }
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    private func buildURL(for endpoint: AFLEndpoint) throws -> URL {
        guard let baseURL = URL(string: baseURL) else {
            throw AppError.invalidInput
        }
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        components?.path = "/api" + endpoint.path
        components?.queryItems = endpoint.queryItems
        
        guard let url = components?.url else {
            throw AppError.invalidInput
        }
        
        return url
    }
}

// MARK: - Mock Implementation

@available(iOS 15.0, *)
final class MockAFLAPIClient: AFLAPIClientProtocol {
    private var mockResponses: [String: Any] = [:]
    private var shouldFail = false
    private var failureError: Error = AppError.serverError("Mock error")
    
    func setMockResponse<T: Encodable>(_ response: T, for endpoint: AFLEndpoint) {
        mockResponses[endpoint.path] = response
    }
    
    func setShouldFail(_ shouldFail: Bool, error: Error = AppError.serverError("Mock error")) {
        self.shouldFail = shouldFail
        self.failureError = error
    }
    
    func request<T: Decodable>(_ endpoint: AFLEndpoint) async throws -> T {
        if shouldFail {
            throw failureError
        }
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        guard let mockResponse = mockResponses[endpoint.path] else {
            throw AppError.notFound
        }
        
        // Convert to Data and back to simulate real JSON decoding
        let data = try JSONSerialization.data(withJSONObject: mockResponse)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
    func requestPublisher<T: Decodable>(_ endpoint: AFLEndpoint, responseType: T.Type) -> AnyPublisher<T, Error> {
        if shouldFail {
            return Fail(error: failureError)
                .eraseToAnyPublisher()
        }
        
        return Future<T, Error> { promise in
            Task {
                do {
                    let result: T = try await self.request(endpoint)
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
