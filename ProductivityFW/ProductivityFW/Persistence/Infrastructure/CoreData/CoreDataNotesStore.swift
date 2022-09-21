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
    private let context: NSManagedObjectContext

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
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }
}

extension CoreDataNotesStore: NotesStore {
    public func insert(note: LocalNote, completion: @escaping (InsertionResult) -> Void) {
        let context = self.context
        context.perform {
            completion(Result {
                let existingNote = try ManagedNote.find(id: note.id, in: context)

                if let existingNote = existingNote {
                    existingNote.content = note.content
                    existingNote.lastSavedAt = note.lastSavedAt
                    existingNote.lastUpdatedAt = note.lastUpdatedAt
                } else {
                    let newNote = ManagedNote(context: context)
                    newNote.id = note.id
                    newNote.content = note.content
                    newNote.lastSavedAt = note.lastSavedAt
                    newNote.lastUpdatedAt = note.lastUpdatedAt
                }

                try context.save()

                return LocalNote(id: note.id, content: note.content, lastUpdatedAt: note.lastUpdatedAt, lastSavedAt: note.lastSavedAt)
            })
        }
    }

    public func retrieve(id: UUID, completion: @escaping (Result<LocalNote?, Error>) -> Void) {
        let context = self.context
        context.perform {
            completion(Result {
                let retrievedNote = try ManagedNote.find(id: id, in: context)

                guard let retrievedNote = retrievedNote else {
                    return .none
                }

                return LocalNote(id: retrievedNote.id, content: retrievedNote.content, lastUpdatedAt: retrievedNote.lastUpdatedAt, lastSavedAt: retrievedNote.lastSavedAt)
            })
        }
    }

    public func retrieve(lastUpdatedSince date: Date, completion: @escaping (RetrievalResult) -> Void) {}
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
