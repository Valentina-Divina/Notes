//
//  DetailsViewController.swift
//  CFT-Notes
//
//  Created by Valentina Divina on 05.04.2023.
//

import UIKit
import Combine

extension UITextView {
    
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextView.textDidChangeNotification, object: self)
            .compactMap { $0.object as? UITextView }
            .compactMap(\.text)
            .eraseToAnyPublisher()
    }
}

class DetailsViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIStackView()
    
    private let titleTextView: UITextView = {
        let v = UITextView()
        v.font = UIFont.systemFont(ofSize: 20, weight: .bold )
        v.layer.masksToBounds = true
        return v
    }()
    
    private let messageTextView: UITextView = {
        let v = UITextView()
        v.layer.masksToBounds = true
        v.font = UIFont.systemFont(ofSize: 15)
        
        return v
    }()
    
    private let titleTextViewPlaceholder: UILabel = {
        let v = UILabel()
        v.text = Texts.Placeholder.title
        v.font = UIFont.systemFont(ofSize: 20, weight: .bold )
        v.textColor = UIColor.lightGray
        return v
    }()
    
    private let messageTextViewPlaceholder: UILabel = {
        let v = UILabel()
        v.text = Texts.Placeholder.message
        v.font = UIFont.systemFont(ofSize: 15)
        v.textColor = UIColor.lightGray
        return v
    }()
    
    private let saveBottomButton: UIButton = {
        let v = UIButton()
        v.setTitle(Texts.Buttons.save, for: .normal)
        v.backgroundColor = .black
        v.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        v.layer.cornerRadius = 15
        return v
    }()
    
    private lazy var logoutBarButtonItem = UIBarButtonItem(title: Texts.Buttons.save, style: .plain, target: self, action: #selector(saveButtonClick))
    
    private let viewModel: DetailsViewModelProtocol
    
    private let isJustCreation: Bool
    
    private var bindings: Set<AnyCancellable> = Set()
    
    // MARK: - Lifecycle
    
    init(isJustCreation: Bool, viewModel: DetailsViewModelProtocol) {
        self.isJustCreation = isJustCreation
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(titleTextView)
        view.addSubview(messageTextView)
        view.addSubview(titleTextViewPlaceholder)
        view.addSubview(messageTextViewPlaceholder)
        view.addSubview(saveBottomButton)
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem  = logoutBarButtonItem
        saveBottomButton.isHidden = !isJustCreation
        titleTextView.delegate = self
        messageTextView.delegate = self
        setupToolBar()
        keyboardObserve()
        titleTextViewConstraints()
        messageTextViewConstraints()
        saveBottomButtonConstraints()
        observeViewModel()
        
        saveBottomButton.addTarget(self, action: #selector(saveButtonClick), for: .touchUpInside)
    }
    
    private func observeViewModel() {
        viewModel.message
            .receive(on: RunLoop.main)
            .map({ input in
                self.messageTextViewPlaceholder.isHidden = !input.isEmpty
                return input
            })
            .assign(to: \.text, on: messageTextView)
            .store(in: &bindings)
        
        viewModel.title
            .receive(on: RunLoop.main)
            .map({ input in
                self.titleTextViewPlaceholder.isHidden = !input.isEmpty
                return input
            })
            .assign(to: \.text, on: titleTextView)
            .store(in: &bindings)
        
        titleTextView.textPublisher
            .receive(on: RunLoop.main)
            .map({ input in
                self.titleTextViewPlaceholder.isHidden = !input.isEmpty
                return input
            })
            .assign(to: \.title.value, on: viewModel)
            .store(in: &bindings)
        
        messageTextView.textPublisher
            .receive(on: RunLoop.main)
            .map({ input in
                self.messageTextViewPlaceholder.isHidden = !input.isEmpty
                return input
            })
            .assign(to: \.message.value, on: viewModel)
            .store(in: &bindings)
    }
    
    // MARK: - Toolbar
    
    private func setupToolBar() {
        let numberToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        
        numberToolbar.barStyle = .default
        
        numberToolbar.items = [
            UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"), style: .plain, target: self, action: #selector(doneWithNumberPad)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneWithNumberPad))
        ]
        
        numberToolbar.sizeToFit()
        
        titleTextView.inputAccessoryView = numberToolbar
        messageTextView.inputAccessoryView = numberToolbar
    }
    
    // MARK: - Cliks
    @objc
    func doneWithNumberPad() {
        titleTextView.resignFirstResponder()
        messageTextView.resignFirstResponder()
    }
    
    @objc
    func saveButtonClick(){
        if titleTextView.text.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Title cannot be empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        viewModel.save()
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }
}

    // MARK: - Keyboard

extension DetailsViewController {
    
    private func keyboardObserve() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc
    func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            messageTextView.contentInset = .zero
        } else {
            messageTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        messageTextView.scrollIndicatorInsets = messageTextView.contentInset
        
        let selectedRange = messageTextView.selectedRange
        messageTextView.scrollRangeToVisible(selectedRange)
    }
}

    // MARK: - UITextView
extension DetailsViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == titleTextView && text.contains("\n") {
            messageTextView.becomeFirstResponder()
            return false
        }
        
        switch textView {
        case titleTextView:
            return textView.text.count + (text.count - range.length) <= 140
        default:
            return true
        }
    }
}

    // MARK: - Constraints

extension DetailsViewController {
    
    func titleTextViewConstraints() {
        
        titleTextView.translatesAutoresizingMaskIntoConstraints = false
        titleTextViewPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            titleTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            titleTextViewPlaceholder.centerYAnchor.constraint(equalTo: titleTextView.centerYAnchor),
            titleTextViewPlaceholder.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            titleTextViewPlaceholder.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
        titleTextView.sizeToFit()
        titleTextView.isScrollEnabled = false
    }
    
    func messageTextViewConstraints() {
        
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        messageTextViewPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            messageTextView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 15),
            messageTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            messageTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
    
            messageTextViewPlaceholder.firstBaselineAnchor.constraint(equalTo: messageTextView.firstBaselineAnchor, constant: 23),
            messageTextViewPlaceholder.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageTextViewPlaceholder.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    func saveBottomButtonConstraints() {
        saveBottomButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveBottomButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            saveBottomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveBottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveBottomButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
