//
//  GenCBView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/13/24.
//

import SwiftUI

struct GenCbView: View {
    @State private var isInternalUser: Bool = true
    @Binding var isLoggedOut: Bool
    @State private var showingProfile = false
    
    let userData = UserData(
        id: "lawyer789",
        name: "Natalie Garcia",
        email: "natalie.garcia@bufetec.com",
        userType: .lawyer,
        phoneNumber: "+52 1 55 1234 5678",
        cedulaProfesional: "LXXXXXX",
        especialidad: "Derecho Penal",
        yearsOfExperience: 10,
        clientId: nil // This is nil for lawyers
    )
    
   var body: some View {
       Group{
           if isInternalUser {
               InternalCbView()
           } else {
               NewClientCbView(isLoggedOut: $isLoggedOut)
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
           ProfileView(isLoggedOut: $isLoggedOut, userData: userData)
       }
   }
}

#Preview {
    GenCbView(isLoggedOut: .constant(false))
}
