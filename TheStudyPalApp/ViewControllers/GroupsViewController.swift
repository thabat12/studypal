//
//  GroupsViewController.swift
//  TheStudyPalApp
//
//  Created by Abhi Bichal on 3/10/25.
//

import UIKit

class GroupsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView = UITableView()
    private let emptyStateLabel = UILabel()
    
    private var buttonWidthConstraint: NSLayoutConstraint!
    private var buttonHeightConstraint: NSLayoutConstraint!
    
    
    private let createGroupVC: CreateGroupViewController = CreateGroupViewController()
    
    private let joinGroupVC: JoinGroupViewController = JoinGroupViewController()
    
    
    static let DIM = 50.0
    static let OPTIONS_HEIGHT = 150.0
    static let OPTIONS_WIDTH = 300.0
    static let BOTTOM_ANCHOR = -25.0
    static let TRAILING_ANCHOR = -35.0
    static let ANIM_DURATION = 0.3
    
    private let addGroupButton = {
        
        let addButton: UIButton = UIButton()
        let buttonConfig: UIImage.SymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .default)
        guard let plusIcon: UIImage = UIImage(systemName: "plus", withConfiguration: buttonConfig)?.withRenderingMode(.alwaysTemplate) else {
            fatalError("Plus icon is not found!")
        }
        addButton.setImage(plusIcon, for: .normal)
        addButton.setImage(plusIcon, for: .highlighted)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        addButton.backgroundColor = .systemBlue
        addButton.tintColor = .white
        
        addButton.layer.cornerRadius = GroupsViewController.DIM / 2
        addButton.layer.masksToBounds = true
        
        return addButton
    }()
    
    private var buttonToggled = false
    
    private let blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.alpha = 0
        
        return view
    }()
    
    private var optionsView: UIStackView!
    
    private func tapButtonAnimation() {
        
        UIView.animate(withDuration: GroupsViewController.ANIM_DURATION) {
            if self.buttonToggled {
                self.blurView.alpha = 0
                self.addGroupButton.transform = .identity
                self.addGroupButton.layer.cornerRadius = GroupsViewController.DIM / 2
                
                let buttonConfig: UIImage.SymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .default)
                guard let plusIcon: UIImage = UIImage(systemName: "plus", withConfiguration: buttonConfig)?.withRenderingMode(.alwaysTemplate) else {
                    fatalError("Plus icon is not found!")
                }
                self.addGroupButton.setImage(plusIcon, for: .normal)
                self.addGroupButton.setImage(plusIcon, for: .highlighted)
                
                self.buttonWidthConstraint.constant = GroupsViewController.DIM
                self.buttonHeightConstraint.constant = GroupsViewController.DIM
                
                self.optionsView.alpha = 0
                
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func tapFunction() {
        if buttonToggled {
            tapButtonAnimation()
        }
    }
    
    private func setupView() {
        self.blurView.frame = self.view.frame
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapFunction))
        
        self.blurView.addGestureRecognizer(tapGesture)
        
        self.view.addSubview(self.blurView)
    }
    
    private func setupTopBar() {
        let topBar = UIView()
        
        topBar.translatesAutoresizingMaskIntoConstraints = false
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(blurView)
        
        
        let titleLabel = UILabel()
        titleLabel.text = "Groups"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(titleLabel)
        
        self.view.addSubview(topBar)
        
        NSLayoutConstraint.activate([
                topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                topBar.heightAnchor.constraint(equalToConstant: 60),

                blurView.topAnchor.constraint(equalTo: topBar.topAnchor),
                blurView.leadingAnchor.constraint(equalTo: topBar.leadingAnchor),
                blurView.trailingAnchor.constraint(equalTo: topBar.trailingAnchor),
                blurView.bottomAnchor.constraint(equalTo: topBar.bottomAnchor),

                titleLabel.centerXAnchor.constraint(equalTo: topBar.centerXAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor)
            ])
    }
    
    private func setupGroupsTableView() {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(GroupChatUITableViewCell.self, forCellReuseIdentifier: GroupChatUITableViewCell.identifier)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
    
    private func setupOptionsView() {
        // constraints will fill in for where the button would be at anyways
        
        self.view.addSubview(self.optionsView)
        NSLayoutConstraint.activate([
                self.optionsView.widthAnchor.constraint(equalToConstant: GroupsViewController.OPTIONS_WIDTH),
                self.optionsView.heightAnchor.constraint(equalToConstant: GroupsViewController.OPTIONS_HEIGHT),
                self.optionsView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: GroupsViewController.TRAILING_ANCHOR),
                self.optionsView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: GroupsViewController.BOTTOM_ANCHOR) // Use safeAreaLayoutGuide
            ])
    }
    
    private func setupAddGroupChatButton() {
        self.view.addSubview(self.addGroupButton)
        setupOptionsView()
        // we will need the button width and height constraints later...
        self.buttonWidthConstraint = self.addGroupButton.widthAnchor.constraint(equalToConstant: GroupsViewController.DIM)
        
        self.buttonHeightConstraint = self.addGroupButton.heightAnchor.constraint(equalToConstant: GroupsViewController.DIM)
        
        let buttonConstraints = [
            self.addGroupButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
            self.addGroupButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -35),
            self.buttonWidthConstraint!, self.buttonHeightConstraint!
        ]
        
        NSLayoutConstraint.activate(buttonConstraints)
        
        
        // Animations for fluidity
        self.addGroupButton.addAction(
            UIAction {
                [weak addGroupButton = self.addGroupButton] _ in
                guard let button = addGroupButton else { return }
                
                UIView.animate(withDuration: GroupsViewController.ANIM_DURATION) {
                    button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }
            },
            for: .touchDown
        )
        
        self.addGroupButton.addAction(
            UIAction {
                [weak addGroupButton = self.addGroupButton] _ in
                guard let button = addGroupButton else { return }
                
                UIView.animate(withDuration: GroupsViewController.ANIM_DURATION) {
                    self.blurView.alpha = 1
                    button.layer.cornerRadius = 20
                    button.setImage(nil, for: .normal)
                    button.setImage(nil, for: .highlighted)
                    self.buttonToggled = true
                    
                    self.optionsView.alpha = 1
                    
                    self.buttonWidthConstraint.constant = GroupsViewController.OPTIONS_WIDTH
                    self.buttonHeightConstraint.constant = GroupsViewController.OPTIONS_HEIGHT
                    self.view.layoutIfNeeded() // apply changes
                }
            },
            for: [.touchUpInside, .touchUpOutside]
        )
    }
    
    private func setupUI() {
        setupView()
        setupTopBar()
        setupAddGroupChatButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         I will have to refactor a lot of things later..
         
         this is optionsview
         */
        
        let createGroupBtn = UIButton(type: .system, primaryAction: UIAction(title: "Create a Group", handler: { _ in
            
            self.navigationController?.pushViewController(self.createGroupVC, animated: true)
            
        }))
        
        createGroupBtn.setTitleColor(.black, for: .normal)
        createGroupBtn.setTitleColor(.black, for: .highlighted)
        
        let joinGroupBtn = UIButton(type: .system, primaryAction: UIAction(title: "Join a Group", handler: { _ in
            self.navigationController?.pushViewController(self.joinGroupVC, animated: true)
        }))
            
        joinGroupBtn.setTitleColor(.black, for: .normal)
        joinGroupBtn.setTitleColor(.black, for: .highlighted)
        
        let stackView = UIStackView(arrangedSubviews: [createGroupBtn, joinGroupBtn])
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alpha = 0
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill

        
        self.optionsView = stackView
        
        
        setupUI()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupChatUITableViewCell.identifier, for: indexPath)
        
        return cell
    }
}
