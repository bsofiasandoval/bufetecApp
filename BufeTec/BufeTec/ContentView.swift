//
//  ContentView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/13/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView{
            ExploreView()
                .tabItem {
                    Label("Explora", systemImage: "magnifyingglass")
                }
            ForumView()
                .tabItem {
                    Label("Foro", systemImage: "person.2")
                }
            GenCbView()
                .tabItem {
                    Label("BufeBot",systemImage: "sparkles")
                }
        }
    }
}

#Preview {
    ContentView()
}
