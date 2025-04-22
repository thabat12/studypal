//
//  GoogleSignInPersistence.swift
//  StudyPal
//
//  Created by Abhi Bichal on 4/21/25.
//

/*
 Problem being solved here: FirebaseAuth and Google Sign In are decoupled, but in order to use the google apis you need to have a GIDSignIn current user instance. We will set this up here...
 */

import GoogleSignIn
import Firebase

class GoogleSignInPersistence {
    private init() { }
    
    // Very simple function to restore the sign-in
    static func restoreUserSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            
            if let user = user {
                print("Restored: \(user.profile?.name ?? "")")
            } else {
                print("Error restoring: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
