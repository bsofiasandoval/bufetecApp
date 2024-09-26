//
//  CasesView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/25/24.
//

import SwiftUI

struct CasesView: View {
    @Binding var isLoggedOut: Bool
    @State private var showingProfile = false
    @EnvironmentObject var authState: AuthState
    
    // This is a placeholder. In a real app, you'd fetch this data from your backend or local storage.
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
        VStack {
            
            // Add your cases list or grid here
            List {
                Text("Case 1")
                Text("Case 2")
                Text("Case 3")
            }
        }
        .navigationBarTitle("Mis Casos")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingProfile = true }) {
                    Image(systemName: "person.fill")
                }
            }
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView(isLoggedOut: $isLoggedOut, userData: userData)
        }
        .onChange(of: isLoggedOut) { newValue in
            if newValue {
                authState.isLoggedIn = false
                // Additional logic to navigate back to login view if needed
            }
        }
    }
}

#Preview {
    CasesView(isLoggedOut: .constant(false))
}
