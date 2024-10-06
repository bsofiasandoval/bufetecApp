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
    @State private var titulo: String = ""
    @State private var contenido: String = ""
    @State private var autorID: String = ""
    
    // Binding para cerrar la hoja
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
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
                .background(Color(.systemGray6)) // Fondo de la sección del formulario
            }
            .navigationBarItems(
                leading: Button("Cancelar") {
                    isPresented = false // Close the view
                },
                trailing: Button("Publicar") {
                    savePost()
                }
            )
        }
        .onAppear {
            if let user = Auth.auth().currentUser {
                self.autorID = user.uid
            } else {
                print("No user is signed in")
            }
        }
    }
    
    private func savePost() {
        guard !autorID.isEmpty else {
            print("Author ID is missing")
            return
        }
        
        NetworkManager.shared.createNewPost(titulo: titulo, contenido: contenido, autorID: autorID) { result in
            switch result {
            case .success(let message):
                print(message)
                isPresented = false // Cierra la hoja después de publicar
            case .failure(let error):
                print("Error creating post: \(error.localizedDescription)")
            }
        }
    }
}

struct AskQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        AskQuestionView(isPresented: .constant(true))
    }
}
