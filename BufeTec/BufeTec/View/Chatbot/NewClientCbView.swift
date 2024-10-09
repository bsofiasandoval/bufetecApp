//
//  NewClientCbView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/13/24.
//

import SwiftUI

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
    @State private var keyboardHeight: CGFloat = 0
    @State private var bottomPadding: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
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
                        .padding(7)
                        .background(Color.textFieldBackground)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.textFieldBorder, lineWidth: 1)
                        )
                        .focused($isFocused)
                        .onSubmit {
                            sendMessage()
                        }
                    
                    Button(action: sendMessage) {
                        Text("↑")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
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
//                    if !tipoDeCaso.isEmpty {
                        NavigationLink(destination: ClientRegisterView(tramite: $tipoDeCaso, isLoggedOut: $isLoggedOut).environmentObject(authState)) {
                            Text("Continuar")
                                .foregroundColor(.blue)
                        }
//                    }
                }
            }
            .padding(.bottom, bottomPadding)
            .animation(.default, value: bottomPadding)
            .onAppear {
                setupKeyboardObservers()
                sendInitialMessage()
            }
            .onChange(of: keyboardHeight) { newValue in
                let bottomSafeArea = geometry.safeAreaInsets.bottom
                bottomPadding = max(newValue - bottomSafeArea, 0)
            }
        }
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                keyboardHeight = keyboardRectangle.height
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            keyboardHeight = 0
        }
    }
    
    private func sendInitialMessage() {
            let initialMessage = CbMessageModel(
                text: "¡Hola! Soy BufeBot. Por favor, descríbeme tu caso legal.".trimmingCharacters(in: .whitespacesAndNewlines),
                isFromCurrentUser: false,
                citations: nil
            )
            messages.append(initialMessage)
        }
        
        private func sendMessage() {
            guard !chat.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
            
            let userMessage = chat.trimmingCharacters(in: .whitespacesAndNewlines)
            let newMessage = CbMessageModel(text: userMessage, isFromCurrentUser: true, citations: nil)
            messages.append(newMessage)
            chat = ""
            
            classifyText(userMessage)
        }
    
    private func classifyText(_ text: String) {
            guard let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let url = URL(string: "http://127.0.0.1:8080/classify-text?text=\(encodedText)") else {
                handleError()
                return
            }
            
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
                            text: "Tu caso parece ser un caso \(decodedResponse.classification.label).".trimmingCharacters(in: .whitespacesAndNewlines),
                            isFromCurrentUser: false,
                            citations: nil
                        )
                        messages.append(botResponse)
                    } catch {
                        print("Decoding error: \(error)")
                        handleError()
                    }
                }
            }.resume()
        }
        
    
    private func handleError() {
        let errorMessage = CbMessageModel(
            text: "Lo siento, ha ocurrido un error. Por favor, intenta de nuevo más tarde.".trimmingCharacters(in: .whitespacesAndNewlines),
            isFromCurrentUser: false,
            citations: nil
        )
        messages.append(errorMessage)
    }
}


struct MessageBubble: View {
    let message: CbMessageModel
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if message.isFromCurrentUser { Spacer() }
            
            Text(message.text)
                .padding(10)
                .background(message.isFromCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(message.isFromCurrentUser ? .white : .primary)
                .cornerRadius(10)
                .fixedSize(horizontal: false, vertical: true)
            
            if !message.isFromCurrentUser { Spacer() }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}



#Preview {
    NewClientCbView().environmentObject(AuthState())
}
