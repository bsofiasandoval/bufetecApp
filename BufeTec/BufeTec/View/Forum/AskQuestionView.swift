//
//  AddPostView.swift
//  ForumTest
//
//  Created by Ximena Tobias on 23/09/24.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import Firebase


struct AddPostView: View {
    @EnvironmentObject var authState: AuthState
    @Environment(\.presentationMode) var presentationMode
    @State private var titulo: String = ""
    @State private var contenido: String = ""
    @State private var autorID: String = "" // Declare autorID without initialization
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Título")) {
                    TextField("Título", text: $titulo)
                }
                Section(header: Text("Contenido")) {
                    TextField("Contenido", text: $contenido)
                }
            }
            .navigationTitle("Nuevo Post")
            .navigationBarItems(
                leading: Button("Cancelar") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Guardar") {
                    savePost()
                }
            )
            .onAppear {
                // Automatically get the current user's ID (autorID)
                if let user = Auth.auth().currentUser {
                    self.autorID = user.uid
                } else {
                    print("No user is signed in")
                }
            }
        }
    }

    private func savePost() {
        // Make sure autorID is set before attempting to save the post
        guard !autorID.isEmpty else {
            print("Author ID is missing")
            return
        }
        
        // Send the post data with autorID automatically included
        NetworkManager.shared.createNewPost(titulo: titulo, contenido: contenido, autorID: autorID) { result in
            switch result {
            case .success(let message):
                print(message)
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                print("Error creating post: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    AddPostView()
}
