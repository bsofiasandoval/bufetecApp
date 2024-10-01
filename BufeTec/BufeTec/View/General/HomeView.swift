//
//  HomeView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/23/24.
//
import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @EnvironmentObject var authState: AuthState
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                ProgressView() // Show loading indicator while checking auth state
            } else if authState.isLoggedIn {
                if authState.userRole == .internalUser {
                    ContentView()
                } else if authState.userRole == .client {
                    CasesView(clientId: Auth.auth().currentUser!.uid)
                } else {
                    Text("Unknown user role")
                }
            } else {
                GeneralLoginView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear(perform: setupAuthStateListener)
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { auth, user in
            DispatchQueue.main.async {
                if let user = user {
                    self.authState.isLoggedIn = true
                    self.authState.user = user
                    self.authState.userRole = self.getUserRole(user)
                } else {
                    self.authState.isLoggedIn = false
                    self.authState.user = nil
                    self.authState.userRole = nil
                }
                self.isLoading = false
            }
        }
    }
    
    private func getUserRole(_ user: User) -> UserRole? {
        if user.email?.contains("tec.mx") == true {
            return .internalUser
        } else {
            return .client
        }
    }
}
