//
//  AskQuestionView.swift
//  Foro
//
//  Created by Ximena Tobias on 12/09/24.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import Firebase

struct AskQuestionView: View {
    @EnvironmentObject var authState: AuthState
    @Environment(\.presentationMode) var presentationMode
    @State private var titulo: String = ""
    @State private var contenido: String = ""
    @State private var autorID: String = ""
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Nuevo Hilo")) {
                    HStack {
                        Text("Título")
                        Spacer()
                        TextField("Título de tu respuesta", text: $titulo)
                            .multilineTextAlignment(.leading)
                            .padding(.leading, 30)
                    }
                    
                    HStack(alignment: .top) {
                        Text("Pregunta")
                        Spacer()
                        TextEditor(text: $contenido)
                            .frame(minHeight: 200)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
        }
        .navigationTitle("Nuevo Hilo")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Publicar") {
                    savePost()
                }
            }
        }
        .onAppear {
            // Automatically get the current user's ID (autorID)
            if let user = Auth.auth().currentUser {
                self.autorID = user.uid
            } else {
                print("No user is signed in")
            }
        }
        .background(Color(.systemGray6))
        .toolbarBackground(.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
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

struct AskQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        AskQuestionView()
    }
}

