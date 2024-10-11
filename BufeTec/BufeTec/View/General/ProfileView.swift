//
//  ProfileView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/13/24.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @State private var showingLogoutAlert = false
    @EnvironmentObject var authState: AuthState
    @Environment(\.presentationMode) var presentationMode  // To dismiss the view
    
    // State variables to hold user-specific data
    @State private var name: String = ""
    @State private var email: String?
    @State private var phoneNumber: String?
    @State private var cedulaProfesional: String?
    @State private var especialidad: String?
    @State private var clientId: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Image
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.blue)
                        .padding(.top, 40)
                    
                    // Name
                    Text(name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Common Info Cards
                    VStack(spacing: 15) {
                        // Phone number (for clients and lawyers only)
                        if let phoneNumber = phoneNumber, authState.userRole == .cliente || authState.userRole == .abogado {
                            infoCard(title: "Número de Teléfono", value: phoneNumber)
                        }
                        
                        if let email = email, authState.userRole == .abogado || authState.userRole == .becario {
                            infoCard(title: "Correo Electrónico", value: email )
                        }
                        
                        // User Type Specific Info
                        if let role = authState.userRole {
                            switch role {
                            case .abogado:
                                if let cedula = cedulaProfesional {
                                    infoCard(title: "Cédula Profesional", value: cedula)
                                }
                                if let especialidad = especialidad {
                                    infoCard(title: "Especialidad", value: especialidad)
                                }
                            case .cliente:
                                if let clientId = clientId {
                                    infoCard(title: "ID del Cliente", value: clientId)
                                }
                            case .becario:
                                infoCard(title: "Rol", value: "Becario")
                            }
                        }
                        // Logout Button
                        Button("Cerrar Sesión") {
                            showingLogoutAlert = true
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gradientEnd)
                        .cornerRadius(10)
                    }
                    .padding()
                }
                .onAppear {
                    let userId = Auth.auth().currentUser?.uid ?? ""
                    fetchData(userId: userId)
                }
                .navigationBarItems(trailing: Button("Cerrar") {
                    presentationMode.wrappedValue.dismiss()
                })
                .alert(isPresented: $showingLogoutAlert) {
                    Alert(
                        title: Text("Cerrar Sesión"),
                        message: Text("¿Estás seguro de cerrar sesión?"),
                        primaryButton: .destructive(Text("Cerrar Sesión")) {
                            authState.logout()
                        },
                        secondaryButton: .cancel(Text("Cancelar"))
                    )
                }
            }
        }
    }
    
    // Fetching Data
    private func fetchData(userId: String) {
        if let role = authState.userRole {
            switch role {
            case .abogado:
                fetchLawyerData(userId: userId)
                
            case .cliente:
                fetchClientData(userId: userId)
                
            case .becario:
                fetchBecarioData(userId: userId)
            }
        }
    }
    
    // Fetching Lawyer Data
    private func fetchLawyerData(userId: String) {
        NetworkManager.shared.fetchUserAbogadoById(userId) { result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self.name = user.nombre
                    self.email = user.correo
                    self.phoneNumber = user.telefono  // Lawyers have phone numbers
                    self.cedulaProfesional = user.cedula
                    self.especialidad = user.areaEspecializacion
                }
            case .failure(let error):
                print("Error fetching lawyer data: \(error.localizedDescription)")
            }
        }
    }
    
    // Fetching Client Data
    private func fetchClientData(userId: String) {
        NetworkManager.shared.fetchUserClienteById(userId) { result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self.name = user.nombre
                    self.clientId = user.id
                    self.phoneNumber = user.numeroTelefonico // Clients have phone numbers
                }
            case .failure(let error):
                print("Error fetching client data: \(error.localizedDescription)")
            }
        }
    }
    
    // Fetching Becario Data
    private func fetchBecarioData(userId: String) {
        NetworkManager.shared.fetchUserBecarioById(userId) { result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self.name = user.nombre
                    self.email = user.correo
                }
            case .failure(let error):
                print("Error fetching becario data: \(error.localizedDescription)")
            }
        }
    }
    
    // Info Card for displaying user details
    private func infoCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

