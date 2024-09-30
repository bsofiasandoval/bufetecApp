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
    @State private var showingLoginView = false

    var body: some View {
        Group {
            if authState.isLoggedIn {
                ContentView()  // Show content when logged in
            } else {
                GeneralLoginView()  // Redirect to login view when logged out
            }
        }
        .onAppear {
            checkLoginStatus()
        }
        .onChange(of: authState.isLoggedIn) { isLoggedIn in
            if !authState.isLoggedIn {
                showingLoginView = true  // Show login view when logged out
            }
        }
    }
    
    private func checkLoginStatus() {
        if !authState.isLoggedIn {
            showingLoginView = true
        }
    }
}
