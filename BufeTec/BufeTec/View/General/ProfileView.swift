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
    @State var userData: UserData
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
                    
                    if var email = userData.email {
                        infoCard(title: "Email", value: email)
                    }
                    if let phoneNumber = userData.phoneNumber {
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
                        //if let years = userData.yearsOfExperience {
                          //  infoCard(title: "Years of Experience", value: "\(years)")
                        //}
                    case .client:
                        if let clientId = userData.clientId {
                            infoCard(title: "Client ID", value: clientId)
                        }
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
            fetchData(userId: Auth.auth().currentUser?.uid ?? "")
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
    
    private func fetchData(userId: String) {
        NetworkManager.shared.fetchUserAbogadoById(userId) { result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    userData.name = user.nombre
                    userData.email = user.correo
                    userData.phoneNumber = user.telefono
                    userData.cedulaProfesional = user.cedula
                    userData.especialidad = user.areaEspecializacion
                    
                    
                }
            case .failure(let error):
                fetchBecarioData(userId: userId)
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
                    userData.phoneNumber = ""
                    
                    
                }
            case .failure(let error):
                fetchClientData(userId: userId)
            }
        }
    }
    
    private func fetchClientData(userId: String) {
        NetworkManager.shared.fetchUserClienteById(userId) { result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    userData.name = user.nombre
                    userData.clientId = Auth.auth().currentUser?.uid ?? ""
                }
            case .failure(let error):
                print("Error fetching user data: \(error.localizedDescription)")
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
