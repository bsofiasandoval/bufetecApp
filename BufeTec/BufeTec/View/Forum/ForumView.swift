//
//  ForumView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/13/24.
//

import SwiftUI
import FirebaseAuth

struct ForumView: View {
    @EnvironmentObject var authState: AuthState
    @StateObject private var apiData = APIData()
    @State private var showingProfile = false
    @State private var showingAddPostView = false
    @State private var selectedPost: WelcomeElement?
    @State private var showingAskQuestionView = false
    
    // New state for search
    @State private var searchText: String = ""
    
    var body: some View {
        ZStack {
            // Main content
            VStack {
                // Search bar
                HStack {
                    TextField("Buscar...", text: $searchText)
                        .padding(8)
                        .padding(.horizontal, 24)
                        .background(.textFieldBackground)
                        .cornerRadius(8)
                        .overlay(
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(Color(.systemGray2))
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 8)
                                
                                if !searchText.isEmpty {
                                    Button(action: {
                                        self.searchText = ""
                                    }) {
                                        Image(systemName: "multiply.circle.fill")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 8)
                                    }
                                }
                            }
                        )
                }
                .padding(.horizontal)
                
                ScrollView {
                    // Filtered posts based on the search text
                    ForEach(filteredPosts.sorted(by: { post1, post2 in
                        guard let date1 = dateFromString(post1.fechaCreacion),
                              let date2 = dateFromString(post2.fechaCreacion) else {
                            return false
                        }
                        return date1 > date2 // Sort from most recent to oldest
                    }), id: \.id) { post in
                        NavigationLink(destination: MessageDetailView(post: post)) {
                            HStack(alignment: .top) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.5))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.blue)
                                }
                                .padding(.top, 8)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        Text(apiData.userNames[post.autorID] ?? "Cargando...") // Load the username
                                            .font(.system(size: 14))
                                            .bold()
                                            .lineLimit(1)
                                            .foregroundColor(.text)
                                        Spacer()
                                        
                                        HStack(spacing: 5) {
                                            Text(formatTime(post.fechaCreacion))
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            Image(systemName: "chevron.right").foregroundColor(.gray)
                                                .font(.system(size: 12))
                                        }
                                    }
                                    
                                    Text(post.titulo)
                                        .font(.subheadline)
                                        .foregroundColor(.text)
                                    
                                    Text(post.contenido)
                                        .font(.subheadline)
                                        .lineLimit(2)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding(.leading, 8)
                                .onAppear {
                                    fetchUserData(userId: post.autorID)
                                }
                            }
                            .padding()
                            .background(Color.cajitas)
                            .cornerRadius(15)
                            .padding(.horizontal)
                            .padding(.top, 16)
                        }
                    }
                }
                .navigationTitle("Foro")
                .dismissKeyboardOnTap() 
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingProfile = true }) {
                            Image(systemName: "person.fill")
                        }
                    }
                }
                .sheet(isPresented: $showingProfile) {
                    ProfileView()
                        .environmentObject(authState)
                }
            }
            .background(Color.forumBack)
            
            // Floating button for asking a question
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showingAskQuestionView.toggle()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "message")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            apiData.fetchPosts() // Fetch posts when the view appears
        }
        .sheet(isPresented: $showingAskQuestionView) {
            AskQuestionView(isPresented: $showingAskQuestionView, onPostSave: {
                apiData.fetchPosts()
            })
            .environmentObject(authState)
        }
    }
    
    // Filter the posts based on the search text
    var filteredPosts: [WelcomeElement] {
        if searchText.isEmpty {
            return apiData.posts
        } else {
            return apiData.posts.filter { post in
                post.titulo.lowercased().contains(searchText.lowercased()) ||
                post.contenido.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    class APIData: ObservableObject {
        @Published var posts: [WelcomeElement] = []
        @Published var userNames: [String: String] = [:]
        
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
    
    // Helper function to convert date string to Date
    func dateFromString(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.date(from: dateString)
    }

    // Helper function to format time using DateFormatter and converting to the local timezone (CST/CDT)
    func formatTime(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.timeZone = TimeZone(abbreviation: "UTC")

        if let date = formatter.date(from: dateString) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            timeFormatter.timeZone = TimeZone(identifier: "America/Mexico")
            return timeFormatter.string(from: date)
        } else {
            return dateString
        }
    }
    
    private func fetchUserData(userId: String) {
        NetworkManager.shared.fetchUserAbogadoById(userId) { result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self.apiData.userNames[userId] = user.nombre
                }
            case .failure:
                self.fetchBecarioData(userId: userId)
            }
        }
    }

    private func fetchBecarioData(userId: String) {
        NetworkManager.shared.fetchUserBecarioById(userId) { result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self.apiData.userNames[userId] = user.nombre
                }
            case .failure:
                DispatchQueue.main.async {
                    self.apiData.userNames[userId] = "Bufetec"
                }
            }
        }
    }
}



struct ForumView_Previews: PreviewProvider {
    static var previews: some View {
        ForumView()
            .environmentObject(AuthState())
    }
}

