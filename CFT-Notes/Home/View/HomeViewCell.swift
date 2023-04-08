//
//  HomeViewCell.swift
//  CFT-Notes
//
//  Created by Valentina Divina on 05.04.2023.
//

import UIKit

class HomeViewCell: UITableViewCell {
    
    lazy var cellBackground: UIView = {
        let v = UIView()
        v.backgroundColor = .blue
        v.layer.cornerRadius = 15
        v.clipsToBounds = true
        return v
    }()
    
    private lazy var noteTitleLb: UILabel = {
        var l = UILabel()
        l.font = UIFont.systemFont(ofSize: 15, weight: .light)
        l.textColor = .white
        l.numberOfLines = 2
        
        return l
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initializeView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeView()
    }
    
    func configure(with model: HomeViewCellModel) {
        self.backgroundColor = .clear
        noteTitleLb.text = model.text
        cellBackground.layer.backgroundColor = colors[abs(model.text.hash)%10].cgColor
    }
    
    // MARK: - Initialize
    
    private func initializeView() {
       
        addSubview(cellBackground)
        addSubview(noteTitleLb)
        homeNotesLabelConstraints()
        cellBackgroundConstraints()
    }
    
    private let colors = [
        UIColor.init(red: 60/255, green: 16/255, blue: 67/255, alpha: 0.9),
        UIColor.init(red: 20/255, green: 11/255, blue: 153/255, alpha: 0.9),
        UIColor.init(red: 40/255, green: 51/255, blue: 153/255, alpha: 0.9),
        UIColor.init(red: 50/255, green: 1/255, blue: 153/255, alpha: 0.9),
        UIColor.init(red: 100/255, green: 51/255, blue: 153/255, alpha: 0.9),
        UIColor.init(red: 120/255, green: 20/255, blue: 153/255, alpha: 0.9),
        UIColor.init(red: 25/255, green: 132/255, blue: 101/255, alpha: 0.9),
        UIColor.init(red: 255/255, green: 51/255, blue: 3/255, alpha: 0.9),
        UIColor.init(red: 51/255, green: 51/255, blue: 153/255, alpha: 0.9),
        UIColor.init(red: 12/255, green: 73/255, blue: 97/255, alpha: 0.9)
    ]
}

    // MARK: - Constraints

extension HomeViewCell {
    
    func homeNotesLabelConstraints() {
        noteTitleLb.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noteTitleLb.topAnchor.constraint(equalTo: cellBackground.topAnchor, constant: 10 ),
            noteTitleLb.bottomAnchor.constraint(equalTo: cellBackground.bottomAnchor, constant: -10 ),
            noteTitleLb.leadingAnchor.constraint(equalTo: cellBackground.leadingAnchor, constant: 10 ),
            noteTitleLb.trailingAnchor.constraint(equalTo: cellBackground.trailingAnchor, constant: -10 )
        ])
    }
    
    func cellBackgroundConstraints() {
        cellBackground.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cellBackground.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            cellBackground.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            cellBackground.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            cellBackground.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            cellBackground.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
