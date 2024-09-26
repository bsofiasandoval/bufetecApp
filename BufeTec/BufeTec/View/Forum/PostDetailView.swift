//
//  PostDetailView.swift
//  ForumTest
//
//  Created by Ximena Tobias on 23/09/24.
//
import SwiftUI

struct PostDetailView: View {
    @ObservedObject var apiData: APIData
    var post: WelcomeElement
    @State private var newResponseContent: String = ""
    @State private var newResponseAuthorID: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text(post.titulo)
                .font(.largeTitle)
                .padding(.bottom, 5)
            Text(post.contenido)
                .font(.body)
                .padding(.bottom, 5)
            Text("Autor: \(post.autorID)")
                .font(.subheadline)
                .padding(.bottom, 5)
            Text("Fecha de creación: \(post.fechaCreacion)")
                .font(.subheadline)
                .padding(.bottom, 5)
            
            Divider()
            
            Text("Respuestas")
                .font(.headline)
                .padding(.bottom, 5)
            
            List {
                ForEach(post.respuestas, id: \.autorID) { respuesta in
                    VStack(alignment: .leading) {
                        Text(respuesta.contenido)
                            .font(.body)
                        Text("Autor: \(respuesta.autorID)")
                            .font(.caption)
                        Text("Fecha: \(respuesta.fechaCreacion)")
                            .font(.caption)
                    }
                }
            }
            
            Divider()
            
            Text("Agregar Respuesta")
                .font(.headline)
                .padding(.bottom, 5)
            
            TextField("Contenido", text: $newResponseContent)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 5)
            
            TextField("Autor ID", text: $newResponseAuthorID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 5)
            
            Button(action: addResponse) {
                Text("Agregar Respuesta")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .navigationTitle("Detalles del Post")
    }

    private func addResponse() {
        NetworkManager.shared.addResponse(postID: post.id, contenido: newResponseContent, autorID: newResponseAuthorID) { result in
            switch result {
            case .success(let message):
                print(message)
                apiData.fetchPosts()  // Fetch posts after adding a new response
            case .failure(let error):
                print("Error adding response: \(error.localizedDescription)")
            }
        }
    }
}

struct PostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PostDetailView(apiData: APIData(), post: WelcomeElement(autorID: "69", contenido: "Contenido de prueba", fechaCreacion: "2024-09-22T02:19:56.604000", id: "66ef7eccf12e947ef51194fa", readUsers: [], respuestas: [], titulo: "Título de prueba"))
    }
}
