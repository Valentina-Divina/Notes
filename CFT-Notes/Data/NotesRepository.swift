//
//  NotesRepository.swift
//  CFT-Notes
//
//  Created by Valentina Divina on 07.04.2023.
//

import Foundation
import Combine
import CoreData

protocol NotesRepositoryProtocol {
    var allNotes: AnyPublisher<[HomeViewCellModel], Error> { get }
    func loadAllNotes()
    func deleteNoteById(id: UUID)
    func loadNote(by id: UUID) -> AnyPublisher<DetailsModel, Error>
    func saveNote(with detailsModel: DetailsModel)
}

class NotesRepository: NotesRepositoryProtocol {
    
    private let coreDataService: CoreDataServiceProtocol = CoreDataService()
    
    private let allNotesSubject: CurrentValueSubject<[HomeViewCellModel], Error> = CurrentValueSubject([])
    
    lazy var allNotes: AnyPublisher<[HomeViewCellModel], Error> = allNotesSubject
        .filter({ models in
            return !models.isEmpty
        })
        .eraseToAnyPublisher()
}

extension NotesRepository {
    func loadAllNotes() {
        DispatchQueue.global().async {
            do {
                let notesObjects = try self.coreDataService.fetchNotesCollections()
                self.allNotesSubject.value = notesObjects.map { noteDTO in
                    return HomeViewCellModel(id: noteDTO.id ?? UUID.init(), text: noteDTO.title ?? "")
                }
            } catch {
                print(error)
            }
        }
    }
    
    func loadNote(by id: UUID) -> AnyPublisher<DetailsModel, Error> {
        return Future<DetailsModel, Error> { promise in
            do {
                let noteObject = try self.coreDataService.fetchNoteById(id: id)
                if let object = noteObject {
                    promise(.success(
                        DetailsModel(
                            id: object.id ?? UUID(),
                            title: object.title ?? "",
                            message: object.message ?? ""
                        )
                    ))
                } else {
                    promise(.failure(NotFoundObject()))
                }
            } catch {
                promise(.failure(NotFoundObject()))
            }
        }.eraseToAnyPublisher()
    }
   
    func saveNote(with detailsModel: DetailsModel) {
        coreDataService.saveNote { context in
            let noteObject = try self.coreDataService.fetchNoteById(id: detailsModel.id)
            if let object = noteObject {
                object.title = detailsModel.title
                object.message = detailsModel.message
            } else {
                let newObject = NoteDTO(context: context)
                newObject.id = detailsModel.id
                newObject.title = detailsModel.title
                newObject.message = detailsModel.message
            }
        }
        loadAllNotes()
    }
    
    func deleteNoteById(id: UUID) {
        do {
            try coreDataService.deleteNoteById(id: id)
        } catch {
            print(error)
        }
    }
}

class NotFoundObject: Error {
}
