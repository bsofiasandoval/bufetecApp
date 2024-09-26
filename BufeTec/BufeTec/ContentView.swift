//
//  ContentView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/13/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int
    @Binding var isLoggedOut: Bool
    @State private var showingProfile = false

    init(initialTab: Int = 0, isLoggedOut: Binding<Bool>) {
        _selectedTab = State(initialValue: initialTab)
        self._isLoggedOut = isLoggedOut
        
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                ExploreView(isLoggedOut: $isLoggedOut)
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
                GenCbView(isLoggedOut: $isLoggedOut)
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
    
    private func getNavigationTitle() -> String {
        switch selectedTab {
        case 0:
            return "Explora"
        case 1:
            return "Foro"
        case 2:
            return "BufeBot"
        default:
            return ""
        }
    }
    
}

#Preview {
    ContentView(isLoggedOut: .constant(false))  // Provide a default value for the preview
}



