//
//  ProfileView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/13/24.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Image
                    Image("profile") // Replace with image from API
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        
                        .shadow(radius: 10)
                        .padding(.top, 40)
                    
                    // Name
                    Text("Natalie Garcia") // Replace with name from API
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Info Cards
                    VStack(spacing: 15) {
                        infoCard(title: "Cédula Profesional", value: "LXXXXXX")
                        infoCard(title: "Especialidad", value: "Derecho Penal")
                        infoCard(title: "Años de Experiencia", value: "10")
                        infoCard(title: "Email", value: "natalie.garcia@bufetec.com")
                    }
                    .padding()
                }
            }
            .navigationTitle("Perfil")
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
    
    private func infoCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}



#Preview {
    ProfileView()
}
