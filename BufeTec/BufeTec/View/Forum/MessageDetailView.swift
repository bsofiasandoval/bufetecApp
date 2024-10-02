//
//  MessageDetailView.swift
//  Foro
//
//  Created by Ximena Tobias on 12/09/24.
//

import SwiftUI
struct MessageDetailView: View {
    @Binding var message: Message
    @State private var replyTitle: String = ""
    @State private var replyMessage: String = ""
    @State private var replies: [Message] = []
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Spacer()
            Spacer()
            Spacer()
            VStack(alignment: .leading, spacing: 10) {
                Text(message.title)
                    .font(.headline)
                
                Text(message.description)
                    .font(.subheadline)
                
                Text("From: \(message.senderName) at \(message.time)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(colorScheme == .dark ? Color(.systemGray5) : Color.white)
            .cornerRadius(15)
            .padding(.horizontal)
            Spacer()
            
            Form {
                HStack {
                    Text("Título")
                    Spacer()
                    TextField("Título de tu respuesta", text: $replyTitle)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 40)
                }
                
                HStack(alignment: .top) {
                    Text("Respuesta")
                    Spacer()
                    
                    TextEditor(text: $replyMessage)
                        .frame(minHeight: 200)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .background(colorScheme == .dark ? Color(.systemBackground) : Color(.systemGray6))
        .navigationTitle("Responder a \(message.senderName)")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Publicar") {
                    // action here when the "Publicar" button is pressed
                    print("Pregunta publicada: ")
                }
            }
        }
        .toolbarBackground(colorScheme == .dark ? .clear : .white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
