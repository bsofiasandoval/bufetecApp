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
    @State private var viewModel = CasesViewModel()
    let clientId: String
    
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
            if authState.isLoggedIn && authState.userRole == .client {
                List(viewModel.cases) { legalCase in
                    VStack(alignment: .leading) {
                        Text(legalCase.tipo_de_caso)
                            .font(.headline)
                        Text("Estado: \(legalCase.estado)")
                            .font(.subheadline)
                        Text("Fecha de inicio: \(legalCase.fecha_inicio)")
                            .font(.caption)
                        Text(legalCase.descripcion)
                            .font(.body)
                    }
                }
                .navigationTitle("Mis Casos")
                .onAppear {
                    viewModel.fetchCases(for: clientId)
                }
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
    CasesView(clientId: "c7BH89up7bNXLKou3RTyvBP3Lmr1")
        .environmentObject(AuthState())  // Provide a sample authState for previews
}
