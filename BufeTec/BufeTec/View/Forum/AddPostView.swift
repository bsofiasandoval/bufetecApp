//
//  AddPostView.swift
//  ForumTest
//
//  Created by Ximena Tobias on 23/09/24.
//

import SwiftUI

struct AddPostView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var titulo: String = ""
    @State private var contenido: String = ""
    @State private var autorID: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Título")) {
                    TextField("Título", text: $titulo)
                }
                Section(header: Text("Contenido")) {
                    TextField("Contenido", text: $contenido)
                }
                Section(header: Text("Autor ID")) {
                    TextField("Autor ID", text: $autorID)
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
        }
    }

    private func savePost() {
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
