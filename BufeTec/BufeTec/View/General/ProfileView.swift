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
    @State private var userData = UserData(name: "", email: nil, phoneNumber: nil, userType: .client)
    @EnvironmentObject var authState: AuthState
    @Environment(\.presentationMode) var presentationMode  // To dismiss the view
    
    var body: some View {
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
                Text(userData.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                // Common Info Cards
                VStack(spacing: 15) {
                    
                    if let email = userData.email {
                        infoCard(title: "Email", value: email)
                    }
                    
                    // Phone number only for "clientes" and "abogados"
                    if let phoneNumber = userData.phoneNumber, userData.userType == .client || userData.userType == .lawyer {
                        infoCard(title: "Phone Number", value: phoneNumber)
                    }
                    
                    // User Type Specific Info
                    switch userData.userType {
                    case .lawyer:
                        if let cedula = userData.cedulaProfesional {
                            infoCard(title: "Cédula Profesional", value: cedula)
                        }
                        if let especialidad = userData.especialidad {
                            infoCard(title: "Especialidad", value: especialidad)
                        }
                    case .client:
                        if let clientId = userData.clientId {
                            infoCard(title: "Client ID", value: clientId)
                        }
                    case .becario:
                        Text("Becario Information")
                    default:
                        Text("User type not supported")
                    }
                }
                .padding()
                
                Button("Logout") {
                    showingLogoutAlert = true
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .cornerRadius(10)
            }
        }
        .onAppear {
            if let role = authState.userRole {
                switch role {
                case .abogado:
                    fetchLawyerData(userId: Auth.auth().currentUser?.uid ?? "")
                case .cliente:
                    fetchClientData(userId: Auth.auth().currentUser?.uid ?? "")
                case .becario:
                    fetchBecarioData(userId: Auth.auth().currentUser?.uid ?? "")
                }
            }
        }
        .navigationBarTitle("Profile", displayMode: .inline)
        .navigationBarItems(trailing: Button("Close") {
            presentationMode.wrappedValue.dismiss()
        })
        .alert(isPresented: $showingLogoutAlert) {
            Alert(
                title: Text("Logout"),
                message: Text("Are you sure you want to logout?"),
                primaryButton: .destructive(Text("Logout")) {
                    authState.logout()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func fetchLawyerData(userId: String) {
        NetworkManager.shared.fetchUserAbogadoById(userId) { result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    userData.name = user.nombre
                    userData.email = user.correo
                    userData.phoneNumber = user.telefono  // Lawyers have phone numbers
                    userData.cedulaProfesional = user.cedula
                    userData.especialidad = user.areaEspecializacion
                    userData.userType = .lawyer
                }
            case .failure(let error):
                print("Error fetching lawyer data: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchBecarioData(userId: String) {
        NetworkManager.shared.fetchUserBecarioById(userId) { result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    userData.name = user.nombre
                    userData.email = user.correo
                    userData.phoneNumber = nil  // Becarios don’t have phone numbers
                    userData.userType = .becario
                }
            case .failure(let error):
                print("Error fetching becario data: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchClientData(userId: String) {
        NetworkManager.shared.fetchUserClienteById(userId) { result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    userData.name = user.nombre
                    userData.email = user.correo
                    userData.clientId = user.id
                    userData.phoneNumber = user.telefono  // Clients have phone numbers
                    userData.userType = .client
                }
            case .failure(let error):
                print("Error fetching client data: \(error.localizedDescription)")
            }
        }
    }
    
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
