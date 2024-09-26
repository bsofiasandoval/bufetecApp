//
//  ForumView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/13/24.
//

// Claudia

import SwiftUI

struct ForumView: View {
    @StateObject private var apiData = APIData()
    @State private var showingAddPostView = false
    @State private var selectedPost: WelcomeElement?

    var body: some View {
            List {
                ForEach(apiData.posts, id: \.id) { post in
                    VStack(alignment: .leading) {
                        Text(post.titulo)
                            .font(.headline)
                        Text(post.contenido)
                            .font(.subheadline)
                        ForEach(post.respuestas, id: \.autorID) { respuesta in
                            VStack(alignment: .leading) {
                                Text(respuesta.contenido)
                                    .font(.body)
                                Text("Autor: \(respuesta.autorID)")
                                    .font(.caption)
                            }
                        }
                    }
                    .onTapGesture {
                        selectedPost = post
                    }
                }
                .onDelete(perform: deletePost)
            }
            .navigationTitle("Foro")
            .navigationBarItems(trailing: Button(action: {
                showingAddPostView = true
            }) {
                Image(systemName: "plus")
            })
            .onAppear {
                apiData.fetchPosts()
            }
            .sheet(isPresented: $showingAddPostView) {
                
            }
            .background(
                NavigationLink(destination: selectedPost.map { PostDetailView(apiData: apiData, post: $0) }, isActive: Binding<Bool>(
                    get: { selectedPost != nil },
                    set: { if !$0 { selectedPost = nil } }
                )) {
                    EmptyView()
                }
            )
    }

    private func deletePost(at offsets: IndexSet) {
        offsets.forEach { index in
            let post = apiData.posts[index]
            NetworkManager.shared.deletePost(postID: post.id) { result in
                switch result {
                case .success(let message):
                    print(message)
                    apiData.fetchPosts()
                case .failure(let error):
                    print("Error deleting post: \(error.localizedDescription)")
                }
            }
        }
    }
}

class APIData: ObservableObject {
    @Published var posts: [WelcomeElement] = []

    func fetchPosts() {
        NetworkManager.shared.fetchPosts { result in
            switch result {
            case .success(let posts):
                DispatchQueue.main.async {
                    self.posts = posts
                }
            case .failure(let error):
                print("Error fetching posts: \(error.localizedDescription)")
            }
        }
    }
}



#Preview {
    ForumView()
}
