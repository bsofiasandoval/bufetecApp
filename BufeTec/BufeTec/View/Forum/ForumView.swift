//
//  ForumView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/13/24.
//

// Claudia

import SwiftUI

struct ForumView: View {
    @EnvironmentObject var authState: AuthState
    @StateObject private var apiData = APIData()
    @State private var showingAddPostView = false
    @State private var selectedPost: WelcomeElement?

    var body: some View {
            ZStack {
                // Main content
                VStack {
                    ScrollView {
                        ForEach(apiData.posts.sorted(by: { post1, post2 in
                            // Compare creation dates
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
                                                //.font(.headline)
                                                .font(.system(size: 14))
                                                .bold()
                                                .lineLimit(1)
                                                .foregroundColor(.black)
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
                                            .foregroundColor(.black)
                                        
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
                                .background(Color.white)
                                .cornerRadius(15)
                                .padding(.horizontal)
                                .padding(.top, 16)
                            }
                        }
                    }
                    .background(Color(.systemGray6))
                    .navigationTitle("Foro")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Image(systemName: "person")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                        }
                    }
                    .toolbarBackground(.white, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                }
                .background(Color(.white))
                
                // Floating button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: AskQuestionView()) {
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
    }
    
    class APIData: ObservableObject {
        @Published var posts: [WelcomeElement] = []
        @Published var userNames: [String: String] = [:] // Store user names
        
        func fetchPosts() {
            NetworkManager.shared.fetchPosts { result in
                switch result {
                case .success(let posts):
                    DispatchQueue.main.async {
                        self.posts = posts
                        print("Posts fetched: \(posts.count)")
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
            timeFormatter.timeZone = TimeZone(identifier: "America/Mexico") // CST (UTC-6)
            
            let formattedTime = timeFormatter.string(from: date)
            return formattedTime
        } else {
            print("Error: Could not parse date string: \(dateString)") // Debugging message
        }
        
        return dateString
    }
    
    private func fetchUserData(userId: String) {
        // Try to fetch as a lawyer first
        NetworkManager.shared.fetchUserAbogadoById(userId) { result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self.apiData.userNames[userId] = user.nombre // Store lawyer's name
                }
            case .failure:
                // If it fails as a lawyer, try as an intern
                self.fetchBecarioData(userId: userId)
            }
        }
    }

    private func fetchBecarioData(userId: String) {
        NetworkManager.shared.fetchUserBecarioById(userId) { result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self.apiData.userNames[userId] = user.nombre // Store intern's name
                }
            case .failure:
                DispatchQueue.main.async {
                    self.apiData.userNames[userId] = "Bufetec" // Fallback name
                }
            }
        }
    }
}


struct ForumView_Previews: PreviewProvider {
    static var previews: some View {
        ForumView()
    }
}
