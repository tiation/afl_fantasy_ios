import CryptoKit
import Foundation
import os.log

// MARK: - CacheStorage

final class CacheStorage {
    static let shared = CacheStorage()

    private let fileManager: FileManager
    private let cacheDirectory: URL
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "CacheStorage")

    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private let queue = DispatchQueue(label: "com.aflfantasy.cache")

    private init() {
        fileManager = .default
        decoder = JSONDecoder()
        encoder = JSONEncoder()

        // Setup cache directory
        let cachePath = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDirectory = cachePath.appendingPathComponent("APICache")

        // Create directory if needed
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }

    // MARK: - Cache Operations

    /// Saves data to cache with expiry
    func cache(_ data: some Encodable, for key: String, expiry: TimeInterval = 3600) throws {
        let cacheItem = CacheItem(data: data, expiryDate: Date().addingTimeInterval(expiry))
        let fileURL = cacheURL(for: key)

        let data = try encoder.encode(cacheItem)
        try data.write(to: fileURL)

        logger.debug("Cached data for key: \(key)")
    }

    /// Retrieves data from cache if not expired
    func retrieve<T: Decodable>(_ type: T.Type, for key: String) throws -> T? {
        let fileURL = cacheURL(for: key)

        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }

        let cacheItem = try decoder.decode(CacheItem<T>.self, from: data)

        guard cacheItem.isValid else {
            // Clean up expired item
            try? fileManager.removeItem(at: fileURL)
            return nil
        }

        return cacheItem.data
    }

    /// Removes specific cached data
    func removeCache(for key: String) throws {
        let fileURL = cacheURL(for: key)
        try fileManager.removeItem(at: fileURL)
        logger.debug("Removed cache for key: \(key)")
    }

    /// Cleans all expired cache items
    func cleanExpiredCache() {
        queue.async { [weak self] in
            guard let self else { return }

            do {
                let contents = try fileManager.contentsOfDirectory(
                    at: cacheDirectory,
                    includingPropertiesForKeys: [.contentModificationDateKey]
                )

                for url in contents {
                    guard let data = try? Data(contentsOf: url),
                          let item = try? JSONDecoder().decode(AnyCacheItem.self, from: data)
                    else {
                        continue
                    }

                    if !item.isValid {
                        try? fileManager.removeItem(at: url)
                        logger.debug("Cleaned expired cache item: \(url.lastPathComponent)")
                    }
                }
            } catch {
                logger.error("Cache cleaning error: \(error.localizedDescription)")
            }
        }
    }

    /// Clears all cached data
    func clearAllCache() throws {
        let contents = try fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: nil
        )

        for url in contents {
            try fileManager.removeItem(at: url)
        }

        logger.debug("Cleared all cache")
    }

    // MARK: - Cache Path Generation

    private func cacheURL(for key: String) -> URL {
        let hashedKey = SHA256.hash(data: key.data(using: .utf8)!)
            .compactMap { String(format: "%02x", $0) }
            .joined()

        return cacheDirectory.appendingPathComponent(hashedKey)
    }
}

// MARK: - CacheItem

private struct CacheItem<T: Codable>: Codable {
    let data: T
    let expiryDate: Date

    var isValid: Bool {
        Date() < expiryDate
    }
}

// MARK: - AnyCacheItem

private struct AnyCacheItem: Codable {
    let expiryDate: Date

    var isValid: Bool {
        Date() < expiryDate
    }
}
