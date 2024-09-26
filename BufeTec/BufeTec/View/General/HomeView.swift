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
    @State private var isLoggedOut = true
    
    var body: some View {
        Group {
            if authState.isLoggedIn {
                ContentView(isLoggedOut: $isLoggedOut)
            } else {
                GeneralLoginView()
            }
        }
        .navigationBarHidden(true)
        .onChange(of: authState.isLoggedIn) { newValue in
                isLoggedOut = !newValue
        }
    }
}

