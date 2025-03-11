//
//  FirebaseManager.swift
//  Project-GroupScreen
//
//  Created by Abhi Bichal on 3/9/25.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FacebookLogin

class FirebaseManager {
    
    static func configureFirebase() {
        FirebaseApp.configure()
        
        // Configure Google Sign In
        if let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }
        
        // Configure Facebook Sign In
        ApplicationDelegate.shared.application(
            UIApplication.shared,
            didFinishLaunchingWithOptions: nil
        )
    }
    
    // MARK: - Authentication State
    
    static func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    static func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
    
    static func signOut() throws {
        try Auth.auth().signOut()
    }
    
    // MARK: - Error Handling
    
    static func handleAuthError(_ error: Error) -> String {
        let authError = error as NSError
        switch authError.code {
        case AuthErrorCode.wrongPassword.rawValue:
            return "Invalid password. Please try again."
        case AuthErrorCode.invalidEmail.rawValue:
            return "Invalid email address. Please check and try again."
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "This email is already registered. Please try logging in."
        case AuthErrorCode.weakPassword.rawValue:
            return "Password is too weak. Please use a stronger password."
        case AuthErrorCode.userNotFound.rawValue:
            return "Account not found. Please check your email or sign up."
        default:
            return "An error occurred. Please try again later."
        }
    }
}
