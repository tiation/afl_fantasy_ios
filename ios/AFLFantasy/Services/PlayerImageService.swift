//
//  PlayerImageService.swift
//  AFL Fantasy Intelligence Platform
//
//  Service for handling player images with caching and fallback support
//  Created by AI Assistant on 6/9/2025.
//

import Combine
import Foundation
import SwiftUI

// MARK: - PlayerImageService

@MainActor
class PlayerImageService: ObservableObject {
    static let shared = PlayerImageService()

    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private var loadingTasks: [String: Task<UIImage?, Error>] = [:]

    @Published private var imageCache: [String: UIImage] = [:]

    init() {
        // Setup cache directory
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = urls.first?.appendingPathComponent("PlayerImages") ?? URL(filePath: "/tmp/PlayerImages")

        // Create cache directory if needed
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

        // Configure memory cache
        cache.countLimit = 200 // Max 200 images in memory
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB memory limit
    }

    // MARK: - Public API

    /// Load an image for a player with fallback support
    func loadImage(for playerId: String, playerName: String? = nil) async -> UIImage? {
        // Check memory cache first
        if let cachedImage = cache.object(forKey: NSString(string: playerId)) {
            return cachedImage
        }

        // Check if already loading
        if let existingTask = loadingTasks[playerId] {
            return try? await existingTask.value
        }

        // Create loading task
        let task = Task<UIImage?, Error> {
            // Try to load from disk cache
            if let diskImage = loadFromDisk(playerId: playerId) {
                cache.setObject(diskImage, forKey: NSString(string: playerId))
                return diskImage
            }

            // Try to load from remote
            if let remoteImage = await loadFromRemote(playerId: playerId) {
                // Cache in memory and disk
                cache.setObject(remoteImage, forKey: NSString(string: playerId))
                saveToDisk(image: remoteImage, playerId: playerId)
                return remoteImage
            }

            // Generate fallback image
            let fallbackImage = generateFallbackImage(playerId: playerId, playerName: playerName)
            cache.setObject(fallbackImage, forKey: NSString(string: playerId))
            return fallbackImage
        }

        loadingTasks[playerId] = task

        defer {
            loadingTasks.removeValue(forKey: playerId)
        }

        return try? await task.value
    }

    /// Preload images for a batch of players
    func preloadImages(for players: [EnhancedPlayer]) {
        Task {
            await withTaskGroup(of: Void.self) { group in
                for player in players.prefix(20) { // Limit concurrent downloads
                    group.addTask {
                        _ = await self.loadImage(for: player.id, playerName: player.name)
                    }
                }
            }
        }
    }

    /// Clear all cached images
    func clearCache() {
        cache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    /// Get cache statistics
    func getCacheStatistics() -> ImageCacheStatistics {
        let diskSize = directorySize(at: cacheDirectory)
        let memoryCount = cache.totalCount

        return ImageCacheStatistics(
            memoryImageCount: memoryCount,
            diskCacheSize: diskSize,
            totalImagesOnDisk: diskImageCount()
        )
    }

    // MARK: - Private Methods

    private func loadFromDisk(playerId: String) -> UIImage? {
        let fileURL = cacheDirectory.appendingPathComponent("\(playerId).jpg")
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data)
        else {
            return nil
        }
        return image
    }

    private func saveToDisk(image: UIImage, playerId: String) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let fileURL = cacheDirectory.appendingPathComponent("\(playerId).jpg")
        try? data.write(to: fileURL)
    }

    private func loadFromRemote(playerId: String) async -> UIImage? {
        // Simulate different image sources
        let imageSources = [
            "https://api.afl.com.au/players/\(playerId)/headshot.jpg",
            "https://aflphotos.com.au/player/\(playerId)/portrait.jpg",
            "https://resources.afl.com.au/photo-resources/2024/player/hi-res/\(playerId).jpg",
            "https://www.afl.com.au/playerimages/\(playerId).jpg"
        ]

        for imageURL in imageSources {
            if let image = await downloadImage(from: imageURL) {
                return image
            }
        }

        return nil
    }

    private func downloadImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let image = UIImage(data: data)
            else {
                return nil
            }

            return image
        } catch {
            print("Failed to download image from \(urlString): \(error)")
            return nil
        }
    }

    private func generateFallbackImage(playerId: String, playerName: String?) -> UIImage {
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            // Background circle
            let colors = [
                UIColor.systemBlue,
                UIColor.systemGreen,
                UIColor.systemOrange,
                UIColor.systemPurple,
                UIColor.systemRed,
                UIColor.systemTeal
            ]

            let colorIndex = abs(playerId.hashValue) % colors.count
            let backgroundColor = colors[colorIndex]

            backgroundColor.setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))

            // Initials text
            let initials = getInitials(from: playerName)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36, weight: .medium),
                .foregroundColor: UIColor.white
            ]

            let attributedString = NSAttributedString(string: initials, attributes: attributes)
            let textSize = attributedString.size()
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )

            attributedString.draw(in: textRect)
        }
    }

    private func getInitials(from name: String?) -> String {
        guard let name, !name.isEmpty else {
            return "?"
        }

        let words = name.components(separatedBy: .whitespaces)
        let initials = words.compactMap(\.first).map { String($0) }
        return initials.prefix(2).joined().uppercased()
    }

    private func directorySize(at url: URL) -> Int64 {
        var size: Int64 = 0

        if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey]) {
            for case let fileURL as URL in enumerator {
                if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    size += Int64(fileSize)
                }
            }
        }

        return size
    }

    private func diskImageCount() -> Int {
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            return files.filter { $0.pathExtension == "jpg" }.count
        } catch {
            return 0
        }
    }
}

// MARK: - ImageCacheStatistics

struct ImageCacheStatistics {
    let memoryImageCount: Int
    let diskCacheSize: Int64
    let totalImagesOnDisk: Int

    var formattedDiskCacheSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB, .useBytes]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: diskCacheSize)
    }
}

// MARK: - PlayerImageView

struct PlayerImageView: View {
    let playerId: String
    let playerName: String?
    let size: CGFloat

    @StateObject private var imageService = PlayerImageService.shared
    @State private var image: UIImage?
    @State private var isLoading = true

    init(playerId: String, playerName: String? = nil, size: CGFloat = 50) {
        self.playerId = playerId
        self.playerName = playerName
        self.size = size
    }

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .secondary))
                    .scaleEffect(0.8)
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .foregroundColor(.secondary)
                    .font(.system(size: size * 0.8))
            }
        }
        .frame(width: size, height: size)
        .background(Color(.systemGray6))
        .clipShape(Circle())
        .onAppear {
            loadImage()
        }
        .onChange(of: playerId) { _, _ in
            loadImage()
        }
    }

    private func loadImage() {
        isLoading = true
        image = nil

        Task {
            let loadedImage = await imageService.loadImage(for: playerId, playerName: playerName)

            await MainActor.run {
                image = loadedImage
                isLoading = false
            }
        }
    }
}

// MARK: - CachedImageModifier

struct CachedImageModifier: ViewModifier {
    let playerId: String
    let playerName: String?

    @StateObject private var imageService = PlayerImageService.shared
    @State private var image: UIImage?

    func body(content: Content) -> some View {
        content
            .onAppear {
                Task {
                    let loadedImage = await imageService.loadImage(for: playerId, playerName: playerName)
                    await MainActor.run {
                        image = loadedImage
                    }
                }
            }
    }
}

extension View {
    func preloadPlayerImage(playerId: String, playerName: String? = nil) -> some View {
        modifier(CachedImageModifier(playerId: playerId, playerName: playerName))
    }
}

// MARK: - Player Image Loading State

enum PlayerImageLoadingState {
    case loading
    case loaded(UIImage)
    case failed
    case placeholder(UIImage)
}

// MARK: - Preview

#Preview("Single Image") {
    PlayerImageView(
        playerId: "123456",
        playerName: "Max Gawn",
        size: 60
    )
    .padding()
}

#Preview("Multiple Images") {
    HStack(spacing: 12) {
        PlayerImageView(playerId: "1", playerName: "Clayton Oliver", size: 40)
        PlayerImageView(playerId: "2", playerName: "Christian Petracca", size: 40)
        PlayerImageView(playerId: "3", playerName: "Jack Viney", size: 40)
        PlayerImageView(playerId: "4", playerName: "Steven May", size: 40)
    }
    .padding()
}
