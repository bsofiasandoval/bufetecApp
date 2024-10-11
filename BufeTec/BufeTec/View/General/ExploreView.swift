//
//  ExploreView.swift
//  BufeTec
//
//  Created by Sofia Sandoval y Lorna on 9/13/24.
//

import SwiftUI
import FirebaseAuth

struct ExploreView: View {
    @EnvironmentObject var authState: AuthState
    @State private var showingProfile = false
    @State private var errorMessage: String?
    @State private var showingErrorAlert = false
    
    // Mock user data - replace this with actual user data fetching logic

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 110))], spacing: 20) {
                ExploreButton(title: "Biblioteca Legal", icon: "book.fill", colors: [Color(hex: "4A69BD"), Color(hex: "1E3799")]) {
                    
                }
                ExploreButton(title: "Guías", icon: "map.fill", colors: [Color(hex: "60A3BC"), Color(hex: "3C6382")]) {
                    // Placeholder action
                }
                ExploreButton(title: "Artículos", icon: "doc.text.fill", colors: [Color(hex: "6A89CC"), Color(hex: "4A69BD")]) {
                    // Placeholder action
                }
                NavigationLink(destination: NewsView()) {
                    ExploreButton(title: "Noticias", icon: "newspaper.fill", colors: [Color(hex: "82CCDD"), Color(hex: "60A3BC")]) {
                    }
                }
                ExploreButton(title: "Videos", icon: "video.fill", colors: [Color(hex: "4A69BD"), Color(hex: "1E3799")]) {
                    // Placeholder action
                }
                NavigationLink(destination: ClientsView()) {
                    ExploreButton(title: "Casos", icon: "briefcase.fill", colors: [Color(hex: "60A3BC"), Color(hex: "3C6382")]){
                    }
                }
                NavigationLink(destination: myClientsView()) {
                    ExploreButton(title: "Mis Casos", icon: "briefcase.fill", colors: [Color(hex: "60A3BC"), Color(hex: "3C6382")]){
                    }
                }
            }
            .padding()
        }
        .navigationBarTitle("Explora")
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
        .alert("Error", isPresented: $showingErrorAlert, presenting: errorMessage) { _ in
            Button("OK", role: .cancel) {}
        } message: { error in
            Text(error)
        }
    }
}

struct ExploreButton: View {
    let title: String
    let icon: String
    let colors: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Spacer()
                Text(title)
                    
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .fontWeight(.medium)
                
                Spacer()

                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.white)

                Spacer()
            }
            .frame(width: 110, height: 110)
            .background(
                LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        }
    }
}

struct LogoutButton: View {
    @Binding var showingLogoutAlert: Bool
    
    var body: some View {
        Button(action: {
            showingLogoutAlert = true
        }) {
            Text("Logout")
        }
    }
}

struct BibliotecaLegalView: View {
    var body: some View {
        List {
            Text("Legal Document 1")
            Text("Legal Document 2")
            Text("Legal Document 3")
        }
    }
}




#Preview{
    ExploreView()
        .environmentObject(AuthState())
}
