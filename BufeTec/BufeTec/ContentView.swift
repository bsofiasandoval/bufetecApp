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

    init(initialTab: Int = 0, isLoggedOut: Binding<Bool>) {
        _selectedTab = State(initialValue: initialTab)
        self._isLoggedOut = isLoggedOut
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ExploreView(isLoggedOut: $isLoggedOut)
                .tabItem {
                    Label("Explora", systemImage: "magnifyingglass")
                }
                .tag(0)
            
            ForumView()
                .tabItem {
                    Label("Foro", systemImage: "person.2")
                }
                .tag(1)
            
            GenCbView()
                .tabItem {
                    Label("BufeBot", systemImage: "sparkles")
                }
                .tag(2)
        }
        .onAppear {
            selectedTab = 0
        }
    }
}

#Preview {
    ContentView(isLoggedOut: .constant(false))  // Provide a default value for the preview
}



