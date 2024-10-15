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
    
    @Binding var isPresented: Bool // Para cerrar la hoja
    var post: WelcomeElement // Información del post pasado desde la vista padre
    var onPostSave: () -> Void // Callback cuando la respuesta es guardada
    
    // Estados para el pop-up de error
    @State private var showAlert = false
    @State private var alertMessage = ""
    
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
                .background(Color.forumBack)
            }
            .navigationTitle("Responder al Hilo")
            .dismissKeyboardOnTap() 
            .navigationBarItems(
                leading: Button("Cancelar") {
                    isPresented = false // Cerrar la hoja
                },
                trailing: Button("Publicar") {
                    validateAndAddComment()
                }
            )
            // Mostrar alerta si es necesario
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error en la respuesta"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                if let user = Auth.auth().currentUser {
                    self.autorID = user.uid
                } else {
                    print("No user is signed in")
                }
            }
        }
    }
    
    // Función para validar el contenido y mostrar la alerta si no es válido
    private func validateAndAddComment() {
        if respuesta.count <= 10 {
            alertMessage = "La respuesta debe tener más de 10 caracteres."
            showAlert = true
        } else {
            addComment() // Si la validación es exitosa, se procede a agregar el comentario
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
                onPostSave() // Notificar a la vista padre
                isPresented = false // Cerrar la hoja
            case .failure(let error):
                print("Error al crear la respuesta: \(error.localizedDescription)")
            }
        }
    }
}
