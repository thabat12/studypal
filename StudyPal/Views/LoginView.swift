//
//  LoginView.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/18/25.
//

import SwiftUI
import GoogleSignIn
import FirebaseAuth
import FirebaseCore
import Foundation

enum AuthenticationError: Error {
    case runtimeError(String)
}

struct LoginView: View {
    
    var body: some View {
        
        VStack(alignment: .center) {
            VStack {
                Text("Welcome to StudyPal!")
                    .font(.system(size: 30))
                    .fontWeight(.semibold)
                Text("Your personal study assistant")
                    .foregroundStyle(Color.gray.opacity(0.8))
            }
            .padding(.bottom, 50)
            .padding(.top, 50)
            
            Image(systemName: "book.pages")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .padding(.bottom, 50)
            
            Spacer()
            
            Button(action: {
                
                Task {
                    do {
                        try await googleOAuth()
                    } catch AuthenticationError.runtimeError(let runtimeErrMsg){
                        print("Error signing into Google: \(runtimeErrMsg)")
//                        fatalError("):")
                    }
                    
                    
                }
                
            }) {
                Text("Continue with Google")
                    .padding()
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @MainActor
    func googleOAuth() async throws {
        // First thing we need the google client id
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("no firbase clientID found")
        }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        //get rootView
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let rootViewController = scene?.windows.first?.rootViewController
        else {
            fatalError("There is no root view controller!")
        }
        
        //google sign in authentication response
        let result = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: rootViewController,
            hint: nil,
            additionalScopes: [
                "https://www.googleapis.com/auth/documents",
                "https://www.googleapis.com/auth/drive.file",
                "https://www.googleapis.com/auth/drive.metadata.readonly",
                "https://www.googleapis.com/auth/drive.readonly"
            ]
        )
        let user = result.user
        
        guard let idToken = user.idToken?.tokenString else {
            throw AuthenticationError.runtimeError("Unexpected error occurred, please retry")
        }
        
        //Firebase auth
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken, accessToken: user.accessToken.tokenString
        )
        
        // Bind the google user for persistence even with GoogleSignIn
//        GoogleSignInPersistence.bindGoogleUser(user: user)
        
        try await Auth.auth().signIn(with: credential)
        let _ = await StudyPalAPI.updateUserDetailsFirestore()
    }
    
    func logout() async throws {
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
    }
}

#Preview {
    LoginView()
}
