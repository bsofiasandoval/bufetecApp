//
//  RespondMessage.swift
//  BufeTec
//
//  Created by Ximena Tobias on 05/10/24.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import Firebase

struct RespondMessage: View {
    @EnvironmentObject var authState: AuthState
    @State private var respuesta: String = ""
    @State private var autorID: String = ""
    
    @Binding var isPresented: Bool // To dismiss the sheet
    var post: WelcomeElement // Post info passed from the parent view
    var onPostSave: () -> Void // Callback when post is saved
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Nueva respuesta")) {
                        TextEditor(text: $respuesta)
                            .frame(minHeight: 200)
                            .multilineTextAlignment(.leading)
                            .padding()
                    }
                }
                .background(Color(.systemGray6))
            }
            .navigationBarItems(
                leading: Button("Cancelar") {
                    isPresented = false // Close the sheet
                },
                trailing: Button("Publicar") {
                    addComment()
                }
            )
            .onAppear {
                if let user = Auth.auth().currentUser {
                    self.autorID = user.uid
                } else {
                    print("No user is signed in")
                }
            }
        }
    }
    
    private func addComment() {
        guard !autorID.isEmpty else {
            print("Author ID is missing")
            return
        }
        
        NetworkManager.shared.addResponse(postID: post.id, contenido: respuesta, autorID: autorID) { result in
            switch result {
            case .success(let message):
                print("Respuesta publicada: \(message)")
                onPostSave() // Notify parent view
                isPresented = false // Close the sheet
            case .failure(let error):
                print("Error creating response: \(error.localizedDescription)")
            }
        }
    }
}
