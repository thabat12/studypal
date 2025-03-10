import UIKit

class TaskTableViewCell: UITableViewCell {
    
    // Task Title
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Task Subtitle
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Right-aligned Activity Label
    let activityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Group Activity"
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Toggle Button (Circle)
    let toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 12 // Makes it circular
        button.clipsToBounds = true
        button.backgroundColor = .gray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var isCompleted = false // Track toggle state

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        toggleButton.addTarget(self, action: #selector(toggleCompletion), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(toggleButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(activityLabel)
        
        NSLayoutConstraint.activate([
            // Toggle Button (Left Side)
            toggleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            toggleButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            toggleButton.widthAnchor.constraint(equalToConstant: 24),
            toggleButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Title Label (IOS Time)
            titleLabel.leadingAnchor.constraint(equalTo: toggleButton.trailingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            // Subtitle Label (ios group)
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            // Activity Label (Right-aligned)
            activityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            activityLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    @objc private func toggleCompletion() {
        isCompleted.toggle()
        toggleButton.backgroundColor = isCompleted ? .green : .gray
    }
    
    func configure(title: String, subtitle: String, completed: Bool) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        isCompleted = completed
        toggleButton.backgroundColor = completed ? .green : .gray
    }
}



