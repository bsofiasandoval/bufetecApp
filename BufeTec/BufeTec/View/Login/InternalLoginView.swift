//
//  InternalLoginView.swift
//  BufeTec
//
//  Created by Sofia Sandoval y Lorna on 9/13/24.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import Firebase

struct InternalLoginView: View {
    @State private var err: String = ""
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authState: AuthState
    
    var body: some View {
        VStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(hex: "#13295D"), Color(hex: "#2756C3")]),
                               startPoint: .top,
                               endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Spacer()
                    Text("Bienvenid@ a BufeTec")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    HStack {
                        Spacer()
                        Text("Al iniciar sesión, no solo accedes a tu profesión, accedes a cambiar vidas.")
                            .font(.title3)
                            .fontDesign(.serif)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .padding()
                    .padding()
                    
                    Spacer()
                    Spacer()
                    
                    // Google Sign-In Button
                    GoogleSignInBtn {
                        Task {
                            do {
                                // Perform Google OAuth and get user info
                                try await Authentication().googleOauth()
                                
                                // After successful login, push user to MongoDB
                                if let user = Auth.auth().currentUser {
                                    let uid = user.uid
                                    let email = user.email ?? ""
                                    let name = user.displayName ?? "No Name"
                                    
                                    // Determine role based on email
                                    if (isStudent(email: email) || isLawyer(email: email)) {
                                        if isStudent(email: email) {
                                            self.authState.setUserRole(.becario)
                                            pushStudentToMongoDB(uid: uid, email: email, name: name)
                                        } else if isLawyer(email: email)  {
                                            self.authState.setUserRole(.abogado)
                                            pushLawyerToMongoDB(uid: uid, email: email, name: name)
                                        }
                                        DispatchQueue.main.async {
                                           self.authState.isLoggedIn = true
                                           self.authState.user = user
                                           
                                           self.dismiss()
                                        }
                                    } else {
                                        print("Email format not recognized")
                                    }
                                }
                                dismiss() // Dismiss view after login
                            } catch AuthenticationError.runtimeError(let errorMessage) {
                                err = errorMessage
                            }
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarBackButtonHidden(true)
        .dismissKeyboardOnTap() 
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.white)
        })
    }
    
    // Helper function to check if email belongs to a student
    func isStudent(email: String) -> Bool {
        // Check if the email starts with "A" and ends with "@tec.mx"
        return (email.hasPrefix("A") || email.hasPrefix("a") ) && email.hasSuffix("@tec.mx")
    }
    
    // Helper function to check if email belongs to a lawyer
    func isLawyer(email: String) -> Bool {
        // Check if the email ends with "@tec.mx" but does not start with "A"
        return email.hasSuffix("@tec.mx") && (!email.hasPrefix("A")  || !email.hasPrefix("a")) || email.hasSuffix("@gmail.com")
    }
    
    // Function to push student (becario) to MongoDB
    func pushStudentToMongoDB(uid: String, email: String, name: String) {
        // Include the UID in the URL path
        let url = URL(string: "http://10.14.255.51:4000/becarios/\(uid)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let userInfo: [String: Any] = [
            "nombre": name,  // Remove '_id' since it's now part of the URL
            "correo": email,
            "rol": "becario"  // Role is still set in the body
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: userInfo, options: []) else { return }
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error pushing student to MongoDB: \(error)")
                return
            }
            
            guard let data = data else { return }
            if let responseString = String(data: data, encoding: .utf8) {
                print("MongoDB response for student: \(responseString)")
            }
        }.resume()
    }

    // Function to push lawyer (abogado) to MongoDB
    func pushLawyerToMongoDB(uid: String, email: String, name: String) {
        let url = URL(string: "http://10.14.255.51:4000/abogados/\(uid)")!  // Endpoint for lawyers
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let userInfo: [String: Any] = [
            "nombre": name,
            "correo": email,
            "rol": "abogado"  // Set role to abogado for lawyers
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: userInfo, options: []) else { return }
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error pushing lawyer to MongoDB: \(error)")
                return
            }
            
            guard let data = data else { return }
            if let responseString = String(data: data, encoding: .utf8) {
                print("MongoDB response for lawyer: \(responseString)")
            }
        }.resume()
    }
}

#Preview {
    InternalLoginView()
}

