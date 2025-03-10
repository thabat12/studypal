//
//  JoinGroupViewController.swift
//  TheStudyPalApp
//
//  Created by Abhi Bichal on 3/10/25.
//

import UIKit

class JoinGroupViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
}
