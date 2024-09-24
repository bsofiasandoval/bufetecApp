//
//  ExploreView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/13/24.
//
import SwiftUI
import FirebaseAuth

struct ExploreView: View {
    @Binding var isLoggedOut: Bool
    @State private var showingLogoutAlert = false
    @State private var errorMessage: String?
    @State private var showingErrorAlert = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Hello, World!")
                if let user = Auth.auth().currentUser {
                    Text("Logged in as: \(user.email ?? "Unknown")")
                }
            }
            .navigationBarTitle("Explora", displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    showingLogoutAlert = true
                }) {
                    Text("Logout")
                }
            )
        }
        .alert(isPresented: $showingLogoutAlert) {
            Alert(
                title: Text("Logout"),
                message: Text("Are you sure you want to logout?"),
                primaryButton: .destructive(Text("Logout")) {
                    logout()
                },
                secondaryButton: .cancel()
            )
        }
        .alert("Error", isPresented: $showingErrorAlert, presenting: errorMessage) { _ in
            Button("OK", role: .cancel) {}
        } message: { error in
            Text(error)
        }
    }

    func logout() {
        do {
            print("Attempting to sign out...")
            try Auth.auth().signOut()
            print("Firebase sign out successful")
            isLoggedOut = true
            print("isLoggedOut set to true")
        } catch {
            print("Error signing out: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            showingErrorAlert = true
        }
        
        // Double-check the authentication state
        if Auth.auth().currentUser == nil {
            print("Auth.auth().currentUser is nil after logout")
        } else {
            print("Warning: Auth.auth().currentUser is not nil after logout")
        }
    }
}
