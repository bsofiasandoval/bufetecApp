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
                if authState.userRole == .abogado || authState.userRole == .becario {
                    ContentView()
                } else if authState.userRole == .cliente {
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
    
    private func getUserRole(_ user: User?) -> UserRole? {
        if(user == nil) {
            return nil
        }
        else if(user?.email?.hasSuffix("@tec.mx") == true && user?.email?.hasPrefix("A") == true || user?.email?.hasPrefix("a") == true  ) {
            return .becario
        }
        else if((user?.email?.hasSuffix("@tec.mx")) == true || (user?.email?.hasSuffix("@gmail.com") == true)){
            return .abogado
        }
        else{
            return .cliente
        }
    }
}

