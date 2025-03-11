//
//  CreateGroupViewController.swift
//  TheStudyPalApp
//
//  Created by Abhi Bichal on 3/10/25.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

class CreateGroupViewController: UIViewController {
    
    static let BAR_HEIGHT = 80.0
    private var privacyToggled = false
    
    private var db: Firestore!
    
    // references to the UI elements as I create them here...
    private var topBar: UIView!
    private var textField: UITextField!
    
    private func setupTopBar() {
        let bar = UIView()
        self.topBar = bar
    
        bar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(bar)
        
        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            bar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            bar.heightAnchor.constraint(equalToConstant: CreateGroupViewController.BAR_HEIGHT)
        ])
        
        let label = UILabel()
        
        label.text = "Create Group"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 40)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        bar.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: bar.bottomAnchor),
        ])
    }
    
    private func setupUIBody() {
        
        // text field
        let textField = UITextField()
        textField.placeholder = "Enter Group Name"
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 8
        textField.clipsToBounds = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        // set the reference here
        self.textField = textField
        
        let horizontalStack = UIStackView()
        horizontalStack.axis = .horizontal
        horizontalStack.alignment = .center
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        let privacySettingLabel = UILabel()
        privacySettingLabel.text = "Privacy Setting"
        privacySettingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let privacyToggle = UISwitch()
        privacyToggle.translatesAutoresizingMaskIntoConstraints = false
        
        privacyToggle.addAction(UIAction {
            action in
            if let toggle = action.sender as? UISwitch {
                self.privacyToggled = toggle.isOn
            }
        }, for: .valueChanged
        )
        
        
        horizontalStack.addArrangedSubview(privacySettingLabel)
        horizontalStack.addArrangedSubview(privacyToggle)
        
        let createGroupButton = UIButton()
        createGroupButton.setTitle("Create Group", for: .normal)
        createGroupButton.layer.borderColor = UIColor.black.cgColor
        createGroupButton.layer.borderWidth = 1.5
        createGroupButton.layer.cornerRadius = 10
        createGroupButton.setTitleColor(.black, for: .normal)
        
        // padding formatting
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.titlePadding = 5
        createGroupButton.configuration = buttonConfig
        
        createGroupButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(textField)
        self.view.addSubview(horizontalStack)
        self.view.addSubview(createGroupButton)
                
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 30),
            textField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            textField.topAnchor.constraint(equalTo: self.topBar.bottomAnchor, constant: 15),
            textField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            horizontalStack.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            horizontalStack.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            horizontalStack.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 50),
            createGroupButton.topAnchor.constraint(equalTo: horizontalStack.bottomAnchor, constant: 10),
            createGroupButton.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor)
        ])
        
        createGroupButton.addAction(UIAction {
            action in
            
            
            // one generic alert controller for now
            let errorAlertController = UIAlertController(title: "Cannot Create Group Chat", message: "Ensure that the name is not an empty string and also that you have internet connection", preferredStyle: .alert)
            let errorAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            errorAlertController.addAction(errorAlertAction)
            
            if self.db == nil {
                self.present(errorAlertController, animated: true)
                return
            }
            
            if self.textField.text! == "" {
                self.present(errorAlertController, animated: true)
                return
            }
            
            do {
                Task {
                    
                    do {
                        try await self.db.collection("groupChats").document(self.textField.text!).setData([
                            "name": self.textField.text!,
                            "private": self.privacyToggled
                        ])
                        
                        self.navigationController?.popViewController(animated: true)
                    } catch {
                        self.present(errorAlertController, animated: true)
                    }
                }
            }
            
            
        }, for: .touchUpInside)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // you need this to make the lag go away ???
        self.view.backgroundColor = .white
        
        setupTopBar()
        setupUIBody()
        
        self.db = Firestore.firestore()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
}
