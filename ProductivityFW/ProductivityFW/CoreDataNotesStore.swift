//
//  CoreDataNotesStore.swift
//  ProductivityFW
//
//  Created by Patricio Sepúlveda Heise on 14-09-22.
//

import CoreData

public class CoreDataNotesStore {
    private static let modelName = "NotesStore"
    private static let model = Bundle(for: CoreDataNotesStore.self)
        .url(forResource: modelName, withExtension: "momd")
        .flatMap { NSManagedObjectModel(contentsOf: $0) }

    private let container: NSPersistentContainer

    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }

    public init(storeURL: URL) throws {
        guard let model = CoreDataNotesStore.model else {
            throw StoreError.modelNotFound
        }

        do {
            container = try NSPersistentContainer.load(url: storeURL, name: CoreDataNotesStore.modelName, model: model)
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }
}

private extension NSPersistentContainer {
    static func load(url: URL, name: String, model: NSManagedObjectModel) throws -> NSPersistentContainer {
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]

        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw $0 }

        container.newBackgroundContext()

        return container
    }
}
