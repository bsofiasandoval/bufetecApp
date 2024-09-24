//
//  BufeTecApp.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/13/24.
//


import SwiftUI
import Firebase
import FirebaseAuth

@main
struct BufeTecApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authState = AuthState()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(authState)
        }
    }
}





class AuthState: ObservableObject {
    @Published var isLoggedIn: Bool
    @Published var user: User?
    
    init() {
        self.isLoggedIn = Auth.auth().currentUser != nil
        self.user = Auth.auth().currentUser
        
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            DispatchQueue.main.async {
                self?.isLoggedIn = user != nil
                self?.user = user
            }
        }
    }
}
