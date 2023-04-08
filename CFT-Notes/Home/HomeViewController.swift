//
//  HomeViewController.swift
//  CFT-Notes
//
//  Created by Valentina Divina on 05.04.2023.
//

import UIKit
import Combine

class HomeViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: UITableView.Style.plain)
    private var data: [HomeViewCellModel] = []
    private let repository: NotesRepositoryProtocol = NotesRepository()
    private lazy var viewModel: HomeViewModelProtocol = HomeViewModel(repository: repository)
    private var bindings: Set<AnyCancellable> = Set<AnyCancellable>()
    
    private let addNoteButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "plus"), for: .normal)
        b.tintColor = .black
        b.backgroundColor = .white
        b.layer.cornerRadius = 35
        
        b.layer.shadowColor = UIColor.black.cgColor
        b.layer.shadowOffset = CGSize(width: 4, height: 4)
        b.layer.shadowOpacity = 0.2
        b.layer.shadowRadius = 4.0
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = Texts.Home.notes
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        view.addSubview(addNoteButton)
        setupTableView()
        addNothesButtonConstraint()
        view.bringSubviewToFront(addNoteButton)
        addNoteButton.addTarget(self, action: #selector(createNewNote), for: .touchUpInside)
        
        observeViewModel()
    }
    
    private func observeViewModel() {
        viewModel.notes
            .receive(on: RunLoop.main)
            .sink { _ in
                
            } receiveValue: { [weak self] notes in
                self?.data = notes
                self?.tableView.reloadData()
            }.store(in: &bindings)
    }
    
    @objc
    private func createNewNote() {
        let secondVC = DetailsViewController(isJustCreation: true, viewModel: DetailsViewModel(repository: repository, noteId: nil))
        self.navigationController?.present(secondVC, animated: true)
    }
}

    // MARK: - Table view delegate

extension HomeViewController: UITableViewDelegate {
    
    // действие при нажатии на ячейку
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedItem = data[indexPath.row]
        let detailsViewController = DetailsViewController(isJustCreation: false, viewModel: DetailsViewModel(repository: repository, noteId: selectedItem.id))
        navigationController?.pushViewController(detailsViewController, animated: true)
    }
}

    // MARK: - Table view data source

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "HomeViewCell", for: indexPath) as? HomeViewCell else {
            return HomeViewCell(style: .default, reuseIdentifier: "HomeViewCell")
        }
        cell.configure(with: data[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            repository.deleteNoteById(id: data[indexPath.row].id)
            data.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

    // MARK: - Constraints + setup tableView
extension HomeViewController {
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HomeViewCell.self, forCellReuseIdentifier: "HomeViewCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
    }
    
    private func addNothesButtonConstraint() {
        addNoteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addNoteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            addNoteButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            addNoteButton.heightAnchor.constraint(equalToConstant: 70),
            addNoteButton.widthAnchor.constraint(equalToConstant: 70)
        ])
    }
}

