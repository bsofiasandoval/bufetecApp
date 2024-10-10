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
    
    let userData = UserData(
        id: "lawyer789",
        name: "Sofia Sandoval",
        email: "sofia.sandoval@bufetec.com",
        userType: .lawyer,
        phoneNumber: "+1 956 600 0773",
        cedulaProfesional: "LXXXXXX",
        especialidad: "Derecho Mercantil",
        yearsOfExperience: 10,
        clientId: nil // This is nil for lawyers
    )
    
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
