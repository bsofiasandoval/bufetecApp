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
                .navigationTitle("Explora")
                .tabItem {
                    Label("Explora", systemImage: "magnifyingglass")
                }
            
            ForumView()
                .navigationTitle("Foro")
                .tabItem {
                    Label("Foro", systemImage: "person.2")
                }
            
            GenCbView()
                .navigationTitle("BufeBot")
                .tabItem {
                    Label("BufeBot",systemImage: "sparkles")
                }
        }
    }
}

#Preview {
    ContentView()
}
