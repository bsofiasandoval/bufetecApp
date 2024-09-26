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
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authState: AuthState
    
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
                    Text(userData.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Common Info Cards
                    VStack(spacing: 15) {
                        infoCard(title: "Email", value: userData.email)
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
                            if let years = userData.yearsOfExperience {
                                infoCard(title: "Years of Experience", value: "\(years)")
                            }
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
            .navigationBarTitle("Profile", displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .alert(isPresented: $showingLogoutAlert) {
            Alert(
                title: Text("Logout"),
                message: Text("Are you sure you want to logout?"),
                primaryButton: .destructive(Text("Logout")) {
                    demoLogout()
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
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
    
//    private func logout() {
//            do {
//                try Auth.auth().signOut()
//                DispatchQueue.main.async {
//                    authState.isLoggedIn = false
//                    authState.user = nil
//                    isLoggedOut = true
//                    presentationMode.wrappedValue.dismiss()
//                }
//            } catch {
//                print("Error signing out: \(error.localizedDescription)")
//            }
//        }
    private func demoLogout() {
        // For demo purposes, always "log out" regardless of the actual session state
        DispatchQueue.main.async {
            authState.isLoggedIn = false
            authState.user = nil
            isLoggedOut = true
            presentationMode.wrappedValue.dismiss()
        }
        
        // Attempt to sign out from Firebase if a session exists
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out from Firebase: \(error.localizedDescription)")
            // Continue with the demo logout even if Firebase signout fails
        }
    }
}

//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView(isLoggedOut: .constant(false), userData: UserData(
//            name: "Natalie Garcia",
//            cedulaProfesional: "LXXXXXX",
//            especialidad: "Derecho Penal",
//            yearsOfExperience: 10,
//            email: "natalie.garcia@bufetec.com"
//        ))
//        .environmentObject(AuthState())
//    }
//}
