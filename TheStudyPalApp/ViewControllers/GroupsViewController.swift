//
//  GroupsViewController.swift
//  TheStudyPalApp
//
//  Created by Abhi Bichal on 3/10/25.
//

import UIKit
import SwiftUI

class GroupsViewController: UIViewController {

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
    
    private var optionsView: UIStackView!
    
    private func tapButtonAnimation() {
        
        UIView.animate(withDuration: GroupsViewController.ANIM_DURATION) {
            if self.buttonToggled {
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapFunction))
        self.view.addGestureRecognizer(tapGesture)
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
    
    
    /*
     We will be moving away from UIKit because as these files have revealed to us, this stuff gets very messy and hard to manage.
     so from now on we are going to be doing things with SwiftUI and integrating the components. Soon, all these files will eventually just become SwiftUI as well.
     */
    private func setupTableView() {
        print("setup table view is called")
        let messageListView = GroupChatUITableView(action: {
            _ in
            
            let alertController = UIAlertController(title: "Not implemented yet", message: "We all have exams this week so this is unfortunately the best we can do. Our codebase is already pretty large, like nearly 3k lines of code. we got a lot of the framework set up for how to work on this project, and spring break will allow us to polish what we already have and do more things", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            
            self.present(alertController, animated: true)
        })
        
        let hostingController = UIHostingController(rootView: messageListView)
        
        self.addChild(hostingController)
        self.view.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        hostingController.didMove(toParent: self)
        
        print("the hosting controller is all set up and it should work...")
    }
    
    
    private func setupUI() {
        setupTableView()
        setupView()
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
}
