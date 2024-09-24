//
//  InternalLoginView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/13/24.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import Firebase

struct InternalLoginView: View {
    @State private var err: String = ""
    @Environment(\.dismiss) var dismiss  // Used for dismissing the current view if needed

    var body: some View {
        VStack {
            Text("Login")
            Button {
                Task {
                    do {
                        try await Authentication().googleOauth()
                        dismiss()  // This will navigate back to the HomeView and automatically show ContentView
                    } catch AuthenticationError.runtimeError(let errorMessage) {
                        err = errorMessage
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "person.badge.key.fill")
                    Text("Sign in with Google")
                }.padding(8)
            }
            .buttonStyle(.borderedProminent)
            
            Text(err).foregroundColor(.red).font(.caption)
        }
    }
}

#Preview {
    InternalLoginView()
}
