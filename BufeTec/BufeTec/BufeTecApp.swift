//
//  BufeTecApp.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/13/24.
//

// arreglar la parte de que cuando hago pruebas en flows de client login me sale view de casos al meterme desde internal login view.

import SwiftUI
import Firebase
import FirebaseAuth

@main
struct BufeTecApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authState = AuthState()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
                    .environmentObject(authState)  // Pass the global authState to HomeView
            }
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
