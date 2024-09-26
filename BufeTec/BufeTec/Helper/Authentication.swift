//
//  Authentication.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/23/24.
//

import Foundation
import Firebase
import FirebaseAuth
import GoogleSignIn

struct Authentication {
    @MainActor
    func googleOauth() async throws {
        // google sign in
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("no firebase clientID found")
        }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        //get rootView
        #if os(iOS)
            // Get rootView for iOS
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            guard let rootViewController = scene?.windows.first?.rootViewController else {
                fatalError("There is no root view controller!")
            }
        #elseif os(macOS)
            // Get the key window from the shared application
            guard let window = NSApplication.shared.windows.first else {
                fatalError("There is no window!")
            }

            // Get the root view controller from the window's content view controller
            guard let rootViewController = window.contentViewController else {
                fatalError("There is no root view controller!")
            }

        // Now you can work with rootViewController as needed
        #endif
        
        //google sign in authentication response
        #if os(iOS)
            //google sign in authentication response for iOS
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        #elseif os(macOS)
            //google sign in authentication response for macOS
        // Assuming you already have the root window
            guard let window = NSApplication.shared.windows.first else {
                fatalError("There is no window!")
            }

            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: window)
        #endif
            
        let user = result.user
        guard let idToken = user.idToken?.tokenString else {
            throw AuthenticationError.runtimeError("Unexpected error occurred, please retry")
        }
        
        //Firebase auth
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken, accessToken: user.accessToken.tokenString
        )
        try await Auth.auth().signIn(with: credential)
    }
    
    func logout() async throws {
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
    }
}

enum AuthenticationError: Error {
    case runtimeError(String)
}
