//
//  HomeView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/23/24.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @EnvironmentObject var authState: AuthState

    var body: some View {
        NavigationStack {
            Group {
                if authState.isLoggedIn {
                    ContentView(initialTab: 0, isLoggedOut: .constant(false))
                } else {
                    GeneralLoginView()
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthState())
}


