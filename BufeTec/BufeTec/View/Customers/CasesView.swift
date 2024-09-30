//
//  CasesView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/25/24.
//

import SwiftUI
import FirebaseAuth

struct CasesView: View {
    @State private var showingProfile = false
    @EnvironmentObject var authState: AuthState  // Use global authState
    
    // Example user data
    let userData = UserData(
        id: "client123",
        name: "Sofia Sandoval",
        email: nil,
        userType: .client,
        phoneNumber: "+19566000773",
        cedulaProfesional: nil,
        especialidad: nil,
        yearsOfExperience: nil,
        clientId: "CL001"
    )
    
    var body: some View {
        Group {
            if authState.isLoggedIn {
                // Display cases when the user is logged in
                VStack {
                    List {
                        Text("Case 1")
                        Text("Case 2")
                        Text("Case 3")
                    }
                }
                .navigationBarTitle("Mis Casos", displayMode: .inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingProfile = true }) {
                            Image(systemName: "person.fill")
                        }
                    }
                }
                .sheet(isPresented: $showingProfile) {
                    ProfileView(userData: userData)
                        .environmentObject(authState)  // Pass authState to ProfileView
                }
            } else {
                // Show the GeneralLoginView when the user is not logged in
                GeneralLoginView()
                    .environmentObject(authState)
                    .transition(.slide)  // Optional: Add a smooth transition
            }
        }
        .animation(.easeInOut, value: authState.isLoggedIn)  // Smooth transition between states
    }
}

#Preview {
    CasesView()
        .environmentObject(AuthState())  // Provide a sample authState for previews
}
