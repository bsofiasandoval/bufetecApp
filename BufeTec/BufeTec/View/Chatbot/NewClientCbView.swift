//
//  NewClientCbView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/13/24.
//


import SwiftUI

struct NewClientCbView: View {
    @State private var chat: String = ""
    @State private var messages: [CbMessageModel] = []
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) var colorScheme
    @Binding var isLoggedOut: Bool
    @State private var shouldNavigateToRegister = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                }
                .onChange(of: messages) { _ in
                    withAnimation {
                        proxy.scrollTo(messages.last?.id, anchor: .bottom)
                    }
                }
            }
            
            HStack {
                TextField("Escribe tu mensaje aquí", text: $chat)
                    .padding(10)
                    .background(Color.textFieldBackground)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.textFieldBorder, lineWidth: 1)
                    )
                    .focused($isFocused)
                
                Button(action: sendMessage) {
                    Text("↑")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 35, height: 35)
                        .background(chat.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.sendButtonDisabled : Color.sendButtonEnabled)
                        .clipShape(Circle())
                }
                .disabled(chat.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .navigationTitle("BufeBot")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ClientRegisterView(isLoggedOut: $isLoggedOut)) {
                    Text("Continuar")
                        .foregroundColor(.blue)
                    
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    private func sendMessage() {
        guard !chat.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newMessage = CbMessageModel(text: chat, isFromCurrentUser: true, citations: nil)
        messages.append(newMessage)
        chat = ""
        
        // Simulate a response from BufeBot
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let botResponse = CbMessageModel(text: "Thanks for your message! This is a simulated response.", isFromCurrentUser: false, citations: nil)
            messages.append(botResponse)
        }
    }
}


#Preview {
    NewClientCbView(isLoggedOut: .constant(false))
}
