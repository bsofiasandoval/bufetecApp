//
//  ContentView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/13/24.
//

import SwiftUI


struct ContentView: View {
    @State private var selectedTab: Int
    @State private var showingProfile = false
    @EnvironmentObject var authState: AuthState  // Use global authState
    
    init(initialTab: Int = 0) {
        _selectedTab = State(initialValue: initialTab)
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                ExploreView()  // No need for isLoggedOut, use authState inside ExploreView
            }
            .tabItem {
                Label("Explora", systemImage: "magnifyingglass")
            }
            .tag(0)
            
            NavigationView {
                ForumView()
            }
            .tabItem {
                Label("Foro", systemImage: "person.2")
            }
            .tag(1)
            
            NavigationView {
                InternalCbView() // Similarly, remove isLoggedOut from this view as well
            }
            .tabItem {
                Label("BufeBot", systemImage: "sparkles")
            }
            .tag(2)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            selectedTab = 0
        }
    }
}

#Preview {
    ContentView()  // No need for isLoggedOut
        .environmentObject(AuthState())  // Provide a default AuthState for previews
}

