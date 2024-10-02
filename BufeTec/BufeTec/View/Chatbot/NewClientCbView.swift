//
//  NewClientCbView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/13/24.
//

import SwiftUI

// Add this struct to handle the API response
struct ClassificationResponse: Codable {
    let classification: Classification
    
    struct Classification: Codable {
        let label: String
        let score: Double
    }
}

struct NewClientCbView: View {
    @State private var chat: String = ""
    @State private var messages: [CbMessageModel] = []
    @FocusState private var isFocused: Bool
    @State private var tipoDeCaso: String = ""
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authState: AuthState
    @State private var shouldNavigateToRegister = false
    @State private var isLoggedOut: Bool = true
    @State private var messageCount: Int = 0
    
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
                NavigationLink(destination: ClientRegisterView(tramite: $tipoDeCaso, isLoggedOut: $isLoggedOut).environmentObject(authState)) {
                    Text("Continuar")
                        .foregroundColor(.blue)
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            sendInitialMessage()
        }
    }
    
    private func sendInitialMessage() {
        let initialMessage = CbMessageModel(
            text: "¡Hola! Soy BufeBot. Por favor, descríbeme tu caso legal.",
            isFromCurrentUser: false,
            citations: nil
        )
        messages.append(initialMessage)
    }
    
    private func sendMessage() {
        guard !chat.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = chat
        let newMessage = CbMessageModel(text: userMessage, isFromCurrentUser: true, citations: nil)
        messages.append(newMessage)
        chat = ""
        
        // Prepare URL with the user's message
        guard let encodedText = userMessage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://chatbot-production-d7fc.up.railway.app/classify-text?text=\(encodedText)") else {
            handleError()
            return
        }
        
        // Make API call
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    handleError()
                    return
                }
                
                guard let data = data else {
                    handleError()
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(ClassificationResponse.self, from: data)
                    tipoDeCaso = decodedResponse.classification.label
                    let botResponse = CbMessageModel(
                        text: "Tu caso parece ser un caso \(decodedResponse.classification.label).",
                        isFromCurrentUser: false,
                        citations: nil
                    )
                    messages.append(botResponse)
                    
                    // Navigate to register view after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        shouldNavigateToRegister = true
                    }
                } catch {
                    print("Decoding error: \(error)")
                    handleError()
                }
            }
        }.resume()
    }
    
    private func handleError() {
        let errorMessage = CbMessageModel(
            text: "Lo siento, ha ocurrido un error. Por favor, intenta de nuevo más tarde.",
            isFromCurrentUser: false,
            citations: nil
        )
        messages.append(errorMessage)
    }
}

#Preview {
    NewClientCbView().environmentObject(AuthState())
}
