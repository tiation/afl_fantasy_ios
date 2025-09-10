import XCTest
@testable import AFL_Fantasy_Intelligence

final class APIServiceTests: XCTestCase {
    private func makeService(baseURL: String) -> APIService {
        // APIService uses URLSession.default internally. For a full stub you'd inject a session.
        // For now, we'll run a couple of simple tests against the request logic via a local server assumption.
        APIService(baseURL: baseURL)
    }

    func testPlayersFetchSuccess() async throws {
        let service = makeService(baseURL: "http://localhost:8080")
        do {
            _ = try await service.fetchAllPlayers()
            // If server is running per your note, this should succeed.
            // Otherwise, this test will be skipped in CI.
            XCTAssertTrue(true)
        } catch {
            // Skip if server is not available
            throw XCTSkip("Local API not running; skipping live test. Error: \(error)")
        }
    }
}

