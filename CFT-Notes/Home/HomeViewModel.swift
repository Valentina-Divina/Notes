//
//  HomeViewModel.swift
//  CFT-Notes
//
//  Created by Valentina Divina on 07.04.2023.
//

import Foundation
import Combine

protocol HomeViewModelProtocol {
    var notes: AnyPublisher<[HomeViewCellModel], Error> { get }
    func load()
}

class HomeViewModel : HomeViewModelProtocol {
    
    lazy var notes: AnyPublisher<[HomeViewCellModel], Error> = notesSubject.eraseToAnyPublisher()
    
    private var notesSubject: CurrentValueSubject<[HomeViewCellModel], Error> = CurrentValueSubject([])
    
    private let repository: NotesRepositoryProtocol
    
    private var cancelable: Set<AnyCancellable> = Set()
    
    init(repository: NotesRepositoryProtocol) {
        self.repository = repository
        load()
    }
    
    func load() {
        repository.allNotes
            .subscribe(on: DispatchQueue.global())
            .receive(on: RunLoop.main)
            .sink { _ in
                
            } receiveValue: { models in
                self.notesSubject.value = models
            }.store(in: &cancelable)
        repository.loadAllNotes()
    }
}
