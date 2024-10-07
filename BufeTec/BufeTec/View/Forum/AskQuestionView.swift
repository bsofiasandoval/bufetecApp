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
    
    // Estado para manejar el pop-up de alerta
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // Binding para cerrar la hoja
    @Binding var isPresented: Bool
    var onPostSave: () -> Void

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Nuevo Hilo")) {
                        HStack {
                            Text("Título")
                            Spacer()
                            TextField("Título del post", text: $titulo)
                                .multilineTextAlignment(.leading)
                                .padding(.leading, 30)
                        }

                        HStack(alignment: .top) {
                            Text("Contenido")
                            Spacer()
                            TextEditor(text: $contenido)
                                .frame(minHeight: 200)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
                .background(Color(.systemGray6))
            }
            .navigationBarItems(
                leading: Button("Cancelar") {
                    isPresented = false // Cerrar la vista
                },
                trailing: Button("Publicar") {
                    validateAndSavePost()
                }
            )
            // Mostrar el alert si es necesario
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error en la publicación"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .onAppear {
            if let user = Auth.auth().currentUser {
                self.autorID = user.uid
            } else {
                print("No user is signed in")
            }
        }
    }
    
    // Función para validar el formulario y mostrar la alerta si no es válido
    private func validateAndSavePost() {
        if titulo.count <= 10 || titulo.count >= 50 {
            alertMessage = "El título debe tener entre 10 y 50 caracteres."
            showAlert = true
        } else if contenido.count <= 10 || contenido.count >= 350 {
            alertMessage = "El contenido debe tener entre 10 y 350 caracteres."
            showAlert = true
        } else {
            savePost() // Guardar el post si todo está bien
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
                onPostSave()
                isPresented = false // Cierra la hoja después de publicar
            case .failure(let error):
                print("Error creating post: \(error.localizedDescription)")
            }
        }
    }
}
