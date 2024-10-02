//
//  ForumView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/13/24.
//

// Claudia

import SwiftUI

struct ForumView: View {
    @State private var messages = [
        Message(avatar: "sun.max.fill", senderName: "Bienvenido", time: "9:41 AM", title: "Primeros pasos", description: "Lee las reglas del foro antes de empezar a publicar. 1) Usar lenguaje apropiado", isRead: false),
        Message(avatar: "person.fill", senderName: "Claudia Ximena", time: "10:30 AM", title: "Consulta urgente", description: "Necesito ayuda para resolver un caso urgente.", isRead: true),
        Message(avatar: "person.fill", senderName: "Claudia Ximena", time: "10:30 AM", title: "Consulta urgente", description: "HEllo HElloHElloHElloHElloHEllo HElloHEllo HElloHEllo HEllo HEllo ayuda para resolver un caso urgente.", isRead: true)
    ]
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Main content
            VStack {
                ScrollView {
                    ForEach($messages) { $message in
                        NavigationLink(destination: MessageDetailView(message: $message)) {
                            HStack(alignment: .top) {
                                ZStack {
                                    Circle()
                                        .fill(Color.yellow.opacity(0.5))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: message.avatar)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.blue)
                                }
                                .padding(.top, 8)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        Text(message.senderName)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        
                                        HStack(spacing: 5) {
                                            if !message.isRead {
                                                Circle()
                                                    .fill(Color.blue)
                                                    .frame(width: 8, height: 8)
                                            }
                                            Text(message.time)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Image(systemName: "chevron.right").foregroundColor(.secondary)
                                                .font(.system(size: 12))
                                        }
                                    }
                                    
                                    Text(message.title)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    
                                    Text(message.description)
                                        .font(.subheadline)
                                        .lineLimit(2)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding(.leading, 8)
                            }
                            .padding()
                            .background(colorScheme == .dark ? Color(.systemGray5) : Color.white)
                            .cornerRadius(15)
                            .padding(.horizontal)
                            .padding(.top, 16)
                        }
                    }
                }
                .background(colorScheme == .dark ? Color(.systemBackground) : Color(.systemGray6))
                .navigationTitle("Foro")
            }
            .background(colorScheme == .dark ? Color(.systemBackground) : Color.white)

            // Floating button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    NavigationLink(destination: AskQuestionView()) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "message")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}
