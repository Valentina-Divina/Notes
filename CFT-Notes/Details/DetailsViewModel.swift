//
//  DetailsViewModel.swift
//  CFT-Notes
//
//  Created by Valentina Divina on 08.04.2023.
//

import Foundation
import Combine

protocol DetailsViewModelProtocol {
    var title: CurrentValueSubject<String, Never> { get }
    var message: CurrentValueSubject<String, Never> { get }
    
    func load()
    func save()
}

class DetailsViewModel: DetailsViewModelProtocol {
    var title: CurrentValueSubject<String, Never> = CurrentValueSubject("")
    var message: CurrentValueSubject<String, Never> = CurrentValueSubject("")
    
    private let repository: NotesRepositoryProtocol
    private var noteId: UUID?
    
    private var cancelables: Set<AnyCancellable> = Set()
    
    init(repository: NotesRepositoryProtocol, noteId: UUID?) {
        self.repository = repository
        self.noteId = noteId
        load()
    }
    
    func load() {
        guard let id = noteId else {
            return
        }
        repository.loadNote(by: id)
            .subscribe(on: DispatchQueue.global())
            .receive(on: RunLoop.main)
            .sink { _ in
                
            } receiveValue: { model in
                self.title.value = model.title
                self.message.value = model.message
                self.noteId = model.id
            }.store(in: &cancelables)
    }
    
    func save() {
        repository.saveNote(with: DetailsModel(
            id: noteId ?? UUID(),
            title: title.value,
            message: message.value)
        )
    }
}
