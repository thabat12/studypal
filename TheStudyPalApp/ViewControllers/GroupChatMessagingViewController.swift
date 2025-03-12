//
//  GroupChatMessagingViewController.swift
//  TheStudyPalApp
//
//  Created by Abhi Bichal on 3/12/25.
//
import UIKit

class GroupChatViewController: UIViewController {

    var inputTextField: UITextField!
    var bottomConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the text field dynamically
        inputTextField = UITextField()
        inputTextField.placeholder = "Type your message"
        inputTextField.borderStyle = .roundedRect
        inputTextField.translatesAutoresizingMaskIntoConstraints = false

        // Add the text field to the view
        view.addSubview(inputTextField)

        // Add constraints for the text field
        NSLayoutConstraint.activate([
            inputTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            inputTextField.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            inputTextField.heightAnchor.constraint(equalToConstant: 50) // Adjust height as needed
        ])

        // Keep a reference to the bottom constraint for later adjustments
        bottomConstraint = inputTextField.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)

        // Register for keyboard notifications
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // When the keyboard will show, adjust the input field's position
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let keyboardHeight = keyboardFrame.height
        
        // Animate the bottom constraint to push the input field above the keyboard
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint.constant = -keyboardHeight - 16 // Adjust the bottom constraint for padding
            self.view.layoutIfNeeded() // Apply the updated layout
        }
    }

    // When the keyboard will hide, reset the bottom constraint
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint.constant = -16 // Reset to the original bottom constraint
            self.view.layoutIfNeeded() // Apply the updated layout
        }
    }

    deinit {
        // Remove observers to prevent memory leaks
        NotificationCenter.default.removeObserver(self)
    }
}
