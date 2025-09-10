import Foundation
import UIKit
import Combine

// MARK: - AvatarLoader

/// Utility for managing user avatar storage, caching, and loading
@MainActor
final class AvatarLoader: ObservableObject {
    static let shared = AvatarLoader()
    
    // MARK: - Published Properties
    
    @Published var currentAvatarImage: UIImage?
    @Published var isLoading = false
    
    // MARK: - Private Properties
    
    private let fileManager = FileManager.default
    private let maxAvatarSize: CGFloat = 200 // Max dimension in points
    private let maxFileSize = 200_000 // 200 KB
    private var cancellables = Set<AnyCancellable>()
    
    private var avatarDirectory: URL {
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return cachesDirectory.appendingPathComponent("avatars", isDirectory: true)
    }
    
    private init() {
        createAvatarDirectoryIfNeeded()
        loadCurrentAvatar()
    }
    
    // MARK: - Public Methods
    
    /// Save avatar data locally and return file URL
    func saveAvatarLocally(data: Data) async throws -> String {
        // Create image from data
        guard let originalImage = UIImage(data: data) else {
            throw AvatarError.invalidImageData
        }
        
        // Resize image to appropriate size
        let resizedImage = await resizeImage(originalImage, to: maxAvatarSize)
        
        // Convert to JPEG with compression
        guard let jpegData = resizedImage.jpegData(compressionQuality: 0.8) else {
            throw AvatarError.compressionFailed
        }
        
        // Check file size
        let finalData: Data
        if jpegData.count > maxFileSize {
            // Try with lower compression
            guard let compressedData = resizedImage.jpegData(compressionQuality: 0.6),
                  compressedData.count <= maxFileSize else {
                throw AvatarError.fileSizeExceeded
            }
            finalData = compressedData
        } else {
            finalData = jpegData
        }
        
        let fileURL = saveAvatarData(finalData)
        return fileURL.path
    }
    
    /// Load avatar from URL (local or remote)
    func loadAvatar(from url: String) async throws -> UIImage {
        isLoading = true
        defer { isLoading = false }
        
        // Check if it's a local file first
        if url.hasPrefix("/") {
            let localURL = URL(fileURLWithPath: url)
            if let data = try? Data(contentsOf: localURL),
               let image = UIImage(data: data) {
                currentAvatarImage = image
                return image
            }
        }
        
        // Handle remote URL
        guard let remoteURL = URL(string: url) else {
            throw AvatarError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: remoteURL)
        guard let image = UIImage(data: data) else {
            throw AvatarError.invalidImageData
        }
        
        currentAvatarImage = image
        return image
    }
    
    /// Get placeholder image for when no avatar is set
    func getPlaceholderImage(for initials: String) -> UIImage {
        let size = CGSize(width: maxAvatarSize, height: maxAvatarSize)
        let backgroundColor = UIColor.systemBlue
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        // Draw background circle
        backgroundColor.setFill()
        let rect = CGRect(origin: .zero, size: size)
        UIBezierPath(ovalIn: rect).fill()
        
        // Draw initials
        let font = UIFont.systemFont(ofSize: size.width * 0.4, weight: .semibold)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white
        ]
        
        let text = initials.prefix(2).uppercased()
        let textSize = (text as NSString).size(withAttributes: attributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        (text as NSString).draw(in: textRect, withAttributes: attributes)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
    
    /// Clear cached avatar
    func clearAvatar() {
        do {
            let files = try fileManager.contentsOfDirectory(at: avatarDirectory, includingPropertiesForKeys: nil)
            for file in files {
                try fileManager.removeItem(at: file)
            }
            currentAvatarImage = nil
        } catch {
            print("Error clearing avatar cache: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    private func createAvatarDirectoryIfNeeded() {
        do {
            try fileManager.createDirectory(at: avatarDirectory, withIntermediateDirectories: true)
        } catch {
            print("Error creating avatar directory: \(error)")
        }
    }
    
    private func saveAvatarData(_ data: Data) -> URL {
        let filename = "user_avatar.jpg"
        let fileURL = avatarDirectory.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
        } catch {
            print("Error saving avatar: \(error)")
        }
        
        return fileURL
    }
    
    private func resizeImage(_ image: UIImage, to maxDimension: CGFloat) async -> UIImage {
        let size = image.size
        let maxSize = max(size.width, size.height)
        
        if maxSize <= maxDimension {
            return image
        }
        
        let scale = maxDimension / maxSize
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        image.draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }
    
    private func loadCurrentAvatar() {
        let keychainManager = KeychainManager()
        guard let avatarURL = keychainManager.getAvatarURL() else { return }
        
        Task {
            do {
                _ = try await loadAvatar(from: avatarURL)
            } catch {
                print("Error loading current avatar: \(error)")
            }
        }
    }
}

// MARK: - AvatarError

enum AvatarError: LocalizedError {
    case invalidImageData
    case compressionFailed
    case fileSizeExceeded
    case invalidURL
    
    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            return "Invalid image data provided"
        case .compressionFailed:
            return "Failed to compress image"
        case .fileSizeExceeded:
            return "Avatar file size too large (max 200KB)"
        case .invalidURL:
            return "Invalid avatar URL"
        }
    }
}
