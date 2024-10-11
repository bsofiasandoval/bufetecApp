//
//  GenCBView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/13/24.
//

import SwiftUI

struct GenCbView: View {
    @State private var isInternalUser: Bool = true
    @EnvironmentObject var authState: AuthState
    @State private var showingProfile = false
    
    
   var body: some View {
       Group{
           if isInternalUser {
               InternalCbView()
           } else {
               NewClientCbView()
           }
       }
       .navigationTitle("BufeBot")
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
   }
}

#Preview {
    GenCbView()
        .environmentObject(AuthState())
}
