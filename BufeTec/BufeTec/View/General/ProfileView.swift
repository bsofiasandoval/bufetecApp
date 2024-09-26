//
//  ProfileView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/13/24.
//
import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @Binding var isLoggedOut: Bool
    @State private var showingLogoutAlert = false
    let userData: UserData
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Image
                    Image("profile") // Replace with image from API
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140, height: 140)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                        .padding(.top, 40)
                    
                    // Name
                    Text(userData.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Info Cards
                    VStack(spacing: 15) {
                        infoCard(title: "Cédula Profesional", value: userData.cedulaProfesional)
                        infoCard(title: "Especialidad", value: userData.especialidad)
                        infoCard(title: "Años de Experiencia", value: "\(userData.yearsOfExperience)")
                        infoCard(title: "Email", value: userData.email)
                    }
                    .padding()
                    
                    Button("Logout") {
                        showingLogoutAlert = true
                    }
                    .foregroundColor(.red)
                    .padding()
                }
            }
            .navigationTitle("Perfil")
            .background(Color(UIColor.systemGroupedBackground))
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
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func logout() {
        do {
            try Auth.auth().signOut()
            isLoggedOut = true
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

struct UserData {
    let name: String
    let cedulaProfesional: String
    let especialidad: String
    let yearsOfExperience: Int
    let email: String
}
