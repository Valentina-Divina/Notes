//
//  CoreDataService.swift
//  CFT-Notes
//
//  Created by Valentina Divina on 07.04.2023.
//

import CoreData
import Foundation

protocol CoreDataServiceProtocol: AnyObject {
    func fetchNotesCollections() throws -> [NoteDTO]
    func fetchNoteById(id: UUID) throws -> NoteDTO?
    func deleteNoteById(id: UUID) throws
    func saveNote(block: @escaping (NSManagedObjectContext) throws -> Void)
}

class CoreDataService {
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: "Notes")
        persistentContainer.loadPersistentStores { _, error in
            guard let error else { return }
            print(error)
        }
        return persistentContainer
    }()
    
    private var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    init() {}
}

extension CoreDataService: CoreDataServiceProtocol {
    func fetchNotesCollections() throws -> [NoteDTO] {
        // обращение к кор дате сохраняем в констунту для дальейшего использования
        let fetchNotes = NoteDTO.fetchRequest()
        
        let result = try viewContext.fetch(fetchNotes)
        if (result.isEmpty) {
           return try createFirstMockedNote()
        }
        return result
    }
    
    func fetchNoteById(id: UUID) throws -> NoteDTO? {
        let fetchNote = NoteDTO.fetchRequest()
        fetchNote.predicate = NSPredicate(format: "%K == %@", "id", id as CVarArg)
        let items = try viewContext.fetch(fetchNote)
        return items.first
    }
    
    func saveNote(block: @escaping (NSManagedObjectContext) throws -> Void) {
        viewContext.performAndWait {
            do {
                try block(viewContext)
                try viewContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    func deleteNoteById(id: UUID) throws {
        let fetchNote = NoteDTO.fetchRequest()
        fetchNote.predicate = NSPredicate(format: "%K == %@", "id", id as CVarArg)
        let items = try viewContext.fetch(fetchNote)
        if let foundItem = items.first {
            viewContext.delete(foundItem)
            try viewContext.save()
        }
    }
    
    private func createFirstMockedNote() throws -> [NoteDTO]  {
        let backgroundContext = persistentContainer.newBackgroundContext()
        return try backgroundContext.performAndWait {
            let newObject = NoteDTO(context: backgroundContext)
            newObject.id = UUID()
            newObject.title = "None"
            newObject.message = ""
            try backgroundContext.save()
            let fetchNotes = NoteDTO.fetchRequest()
            return try viewContext.fetch(fetchNotes)
        }
    }
}
