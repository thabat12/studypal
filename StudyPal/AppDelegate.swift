//
//  AppDelegate.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/16/25.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
import UserNotifications
import FirebaseAppCheck
import FirebaseAuth

// Important to enable Firebase storage API calls
class MyAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
  func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
    return AppAttestProvider(app: app)
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      
      
    let providerFactory = MyAppCheckProviderFactory()
      AppCheck.setAppCheckProviderFactory(providerFactory)
    FirebaseManager.configureFirebase()
      
    // Now update yourself to Firestore &
    Task {
        let success = await StudyPalAPI.updateUserDetailsFirestore()
        
        if !success {
            print("update details to firestore failed!")
        } else {
            // There is a user signed in, so also update GID
            GoogleSignInPersistence.restoreUserSignIn()
        }
    }

    // Request notification permissions for the timer features
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if granted {
            print("Notification permission granted")
        } else if let error = error {
            print("Notification permission error: \(error.localizedDescription)")
        }
    }

    return true
  }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
}
