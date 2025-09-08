import Combine
import CoreData
import Foundation
import os.log

// MARK: - PersistentStore

class PersistentStore {
    static let shared = PersistentStore()

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "AFLFantasy",
        category: "PersistentStore"
    )

    // MARK: - Core Data Stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AFLFantasy")

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve persistent store description")
        }

        // Enable automatic cloud sync
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

        container.loadPersistentStores { [weak self] _, error in
            if let error {
                self?.logger.error("Persistent store loading error: \(error.localizedDescription)")
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }

        // Merge changes from other contexts automatically
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        // Save automatically when changes occur
        NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextObjectsDidChange,
            object: container.viewContext,
            queue: .main
        ) { [weak self] _ in
            self?.saveIfNeeded()
        }

        return container
    }()

    // MARK: - Contexts

    /// Main context for UI updates
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    /// Background context for data imports
    func backgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    // MARK: - Saving

    private func saveIfNeeded() {
        let context = persistentContainer.viewContext
        guard context.hasChanges else { return }

        do {
            try context.save()
            logger.debug("Context saved successfully")
        } catch {
            logger.error("Context save error: \(error.localizedDescription)")
            context.rollback()
        }
    }

    // MARK: - Batch Operations

    /// Efficiently updates multiple entities using batch update
    func batchUpdate(entityName: String, propertiesToUpdate: [AnyHashable: Any]) async throws {
        let context = backgroundContext()
        let request = NSBatchUpdateRequest(entityName: entityName)
        request.propertiesToUpdate = propertiesToUpdate
        request.resultType = .updatedObjectIDsResultType

        let result = try await context.perform {
            try context.execute(request) as? NSBatchUpdateResult
        }

        guard let objectIDs = result?.result as? [NSManagedObjectID] else {
            return
        }

        let changes = [NSUpdatedObjectsKey: objectIDs]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [viewContext])
    }

    /// Efficiently deletes multiple entities using batch delete
    func batchDelete(fetchRequest: NSFetchRequest<NSFetchRequestResult>) async throws {
        let context = backgroundContext()
        let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        request.resultType = .resultTypeObjectIDs

        let result = try await context.perform {
            try context.execute(request) as? NSBatchDeleteResult
        }

        guard let objectIDs = result?.result as? [NSManagedObjectID] else {
            return
        }

        let changes = [NSDeletedObjectsKey: objectIDs]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [viewContext])
    }

    // MARK: - Import/Export

    /// Imports data in background, optimized for large datasets
    func importData<T: Codable>(
        _ data: [T],
        entityName: String,
        uniqueKey: String,
        transform: @escaping (T) -> [String: Any]
    ) async throws {
        let context = backgroundContext()

        let batchSize = 1000
        for batch in data.chunked(into: batchSize) {
            try await context.perform {
                for item in batch {
                    let dictionary = transform(item)
                    guard let uniqueValue = dictionary[uniqueKey] else {
                        throw NSError(
                            domain: "Import",
                            code: 1,
                            userInfo: [NSLocalizedDescriptionKey: "Missing unique key"]
                        )
                    }

                    // Find or create entity
                    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
                    fetchRequest.predicate = NSPredicate(format: "%K == %@", uniqueKey, uniqueValue as! CVarArg)
                    fetchRequest.fetchLimit = 1

                    let object = (try? context.fetch(fetchRequest).first) ?? NSEntityDescription.insertNewObject(
                        forEntityName: entityName,
                        into: context
                    )

                    // Update properties
                    dictionary.forEach { object.setValue($1, forKey: $0) }
                }

                try context.save()
            }
        }
    }
}

// MARK: - Array Extension

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
