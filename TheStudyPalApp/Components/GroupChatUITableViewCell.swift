//
//  GroupChatUITableViewCell.swift
//  Project-GroupScreen
//
//  Created by Abhi Bichal on 3/9/25.
//
import UIKit

class GroupChatUITableViewCell: UITableViewCell {
    static let identifier = "GroupChatUITableViewCell"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func setupUI() {
        self.contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with title: String) {
        self.titleLabel.text = title
    }
}
