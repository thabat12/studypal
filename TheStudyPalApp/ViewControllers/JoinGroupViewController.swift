//
//  JoinGroupViewController.swift
//  TheStudyPalApp
//
//  Created by Abhi Bichal on 3/10/25.
//

import UIKit
import SwiftUI

class JoinGroupViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        // the screen is actually giong to be a SwifUI view
        let hostingVC = UIHostingController(rootView: JoinGroupView(joinGroupAction: joinGroupAlertController))
        
        self.addChild(hostingVC)
        self.view.addSubview(hostingVC.view)
        hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            hostingVC.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            hostingVC.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            hostingVC.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            hostingVC.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        hostingVC.didMove(toParent: self)
    }
    
    private func joinGroupAlertController(groupId: String, groupName: String) {
        
        let alertController = UIAlertController(title: "Join \(groupName)", message: "Are you sure you want to join?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) {
            _ in
            
            Task {
                
                do {
                    let _ = try await StudyPalAPI.joinGroupChat(groupChatId: groupId)
                } catch FirebaseAPIErrors.userAlreadyInGroup {
                    
                    let alreadyInGroupAlertController = UIAlertController(title: "User already in group!", message: "We will need to filter these group chats out but for testing purposes we are displaying them. Basically the point of this page is to just display all public group chats. Go back and click on a group chat to check it out!", preferredStyle: .alert)
                    alreadyInGroupAlertController.addAction(UIAlertAction(title: "OK", style: .default))
                    
                    self.present(alreadyInGroupAlertController, animated: true)
                } catch {
                    fatalError("error joining the group chat!")
                }
                
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        let noAction = UIAlertAction(title: "Cancel", style: .cancel) {
            _ in
            
            print("the user changed his/ her mind")
        }
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        self.present(alertController, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
}
