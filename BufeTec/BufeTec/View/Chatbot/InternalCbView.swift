//
//  InternalCbView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/13/24.
//

import SwiftUI

struct InternalCbView: View {
    @State private var chat: String = ""
    @State private var messages: [CbMessageModel] = []
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    ScrollViewReader { proxy in
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
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
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    private func sendMessage() {
        guard !chat.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newMessage = CbMessageModel(text: chat, isFromCurrentUser: true)
        messages.append(newMessage)
        chat = ""
        
        // Simulate a response from BufeBot
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let botResponse = CbMessageModel(text: "Thanks for your message! This is a simulated response.", isFromCurrentUser: false)
            messages.append(botResponse)
        }
    }
}

struct MessageBubble: View {
    let message: CbMessageModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            if message.isFromCurrentUser {
                Spacer()
                Text(message.text)
                    .padding(12)
                    .background(Color.userMessageBackground)
                    .foregroundColor(Color.userMessageText)
                    .clipShape(BubbleShape(isFromCurrentUser: true))
            } else {
                Text(message.text)
                    .padding(12)
                    .background(Color.botMessageBackground)
                    .foregroundColor(Color.botMessageText)
                    .clipShape(BubbleShape(isFromCurrentUser: false))
                Spacer()
            }
        }
    }
}

struct BubbleShape: Shape {
    let isFromCurrentUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                    byRoundingCorners: [.topLeft, .topRight, isFromCurrentUser ? .bottomLeft : .bottomRight],
                    cornerRadii: CGSize(width: 16, height: 16))
        return Path(path.cgPath)
    }
}


#Preview {
    InternalCbView()
}
