//
//  InternalCbView.swift
//  BufeTec
//
//  Created by Sofia Sandoval y Felipe Alonzo on 9/13/24.
//

import SwiftUI

struct InternalCbView: View {
    @State private var chat: String = ""
    @State private var messages: [CbMessageModel] = []
    @State private var threadId: String? = nil
    @FocusState private var isFocused: Bool
    @State private var isWaitingForResponse: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    let assistantId = "asst_yMrGnZxDMUosMEcbOnEJFooo"
    let baseURL = "http://10.14.255.51:8080"
    var body: some View {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { message in
                                MessageBubbleInternal(message: message)
                            }
                            if isWaitingForResponse {
                                HStack {
                                    TypingAnimationView()
                                    Spacer()
                                }
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
                    .onChange(of: isWaitingForResponse) { _ in
                        withAnimation {
                            proxy.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                    .onAppear {
                        sendInitialMessage()
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
                    
                    Button(action: {
                        Task {
                            await sendMessage()
                        }
                    }) {
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
            .task {
                await createThread()
            }
            .dismissKeyboardOnTap() 
    }
    
    private func createThread() async {
        guard let url = URL(string: "\(baseURL)/create-thread") else {
            print("Invalid URL")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(ThreadResponse.self, from: data)
            DispatchQueue.main.async {
                self.threadId = response.thread
                print("Thread created with ID: \(self.threadId ?? "Unknown")")
            }
        } catch {
            print("Error creating thread: \(error)")
        }
    }
    
    private func sendInitialMessage() {
        let initialMessage = CbMessageModel(
            text: "¡Hola! Soy BufeBot. Estoy aquí para ayudarte 😊.".trimmingCharacters(in: .whitespacesAndNewlines),
            isFromCurrentUser: false,
            citations: nil
        )
        messages.append(initialMessage)
    }
    
    private func sendMessage() async {
        guard let threadId = threadId else {
            print("Thread ID is not available.")
            return
        }

        let trimmedChat = chat.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedChat.isEmpty else { return }

        // Append user's message locally
        let userMessage = CbMessageModel(text: trimmedChat, isFromCurrentUser: true, citations: nil)
        DispatchQueue.main.async {
            self.messages.append(userMessage)
            self.chat = ""
            self.isWaitingForResponse = true  // Set this to true while waiting for the response
        }

        // Create message via API
        let createMessageURL = "\(baseURL)/create-message?thread_id=\(threadId)&content=\(trimmedChat.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        guard let url = URL(string: createMessageURL) else {
            print("Invalid URL for creating message")
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error creating message")
                return
            }
            
            let messageResponse = try JSONDecoder().decode([String: String].self, from: data)
            guard let messageId = messageResponse["message"] else {
                print("Message ID not returned.")
                return
            }
            print("Created message with ID: \(messageId)")
            
        } catch {
            print("Error creating message: \(error)")
            return
        }

        // Run the thread via API and wait for the response
        let runThreadURL = "\(baseURL)/run-thread?thread_id=\(threadId)&assistant_id=\(assistantId)"
        
        guard let runURL = URL(string: runThreadURL) else {
            print("Invalid URL for running thread")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: runURL)
            let runResponse = try JSONDecoder().decode(RunResponse.self, from: data)
            let runStatus = runResponse.run.status

            if runStatus == "completed" {
                // Get the chatbot's message
                await getBotResponse()
            }

        } catch {
            print("Error running thread: \(error)")
        }
    }

    private func getBotResponse() async {
        guard let threadId = threadId else { return }
        let getLastMessageURL = "\(baseURL)/retrieve-message?thread_id=\(threadId)"
        
        guard let url = URL(string: getLastMessageURL) else {
            print("Invalid URL for getting last message")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let lastMessageResponse = try JSONDecoder().decode(LastMessageResponse.self, from: data)
            
            guard let assistantMessage = lastMessageResponse.message else {
                print("Assistant message not found.")
                return
            }
            
            // Map citations to Citation structs
            let citations = lastMessageResponse.citations?.map { Citation(fileName: $0.value.file_name, url: $0.value.url) }
            
            // Append assistant's message to the UI
            let botMessage = CbMessageModel(text: assistantMessage, isFromCurrentUser: false, citations: citations)
            
            DispatchQueue.main.async {
                self.messages.append(botMessage)
                self.isWaitingForResponse = false  // Set this to false when the response is received
            }
            
        } catch {
            print("Error retrieving last message: \(error)")
            DispatchQueue.main.async {
                self.isWaitingForResponse = false  // Reset in case of error
            }
        }
    }


}

struct MessageBubbleInternal: View {
    let message: CbMessageModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
            VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 8) {
                HStack {
                    if !message.isFromCurrentUser {
                        messageBubble
                        Spacer()
                    } else {
                        Spacer()
                        messageBubble
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)

                // Display unique citations
                if let citations = message.citations {
                    let uniqueCitations = removeDuplicateCitations(citations)
                    ForEach(uniqueCitations) { citation in
                        CitationBox(citation: citation)
                            .frame(maxWidth: 300)
                            .padding(.horizontal, 8)
                    }
                }
            }
        }
    
        private var messageBubble: some View {
            formatMessageText(message.text)
                .padding(10)
                .background(message.isFromCurrentUser ? Color.userMessageBackground : Color.botMessageBackground)
                .foregroundColor(message.isFromCurrentUser ? Color.userMessageText : Color.botMessageText)
                .clipShape(BubbleShape(isFromCurrentUser: message.isFromCurrentUser))
        }
    
        private func removeDuplicateCitations(_ citations: [Citation]) -> [Citation] {
            var seen = Set<String>()
            return citations.filter { citation in
                guard !seen.contains(citation.fileName) else {
                    return false
                }
                seen.insert(citation.fileName)
                return true
            }
        }
    

    // Function to remove duplicate citations based on fileName
    

    // Function to process the message text and apply bold and bullet formatting
    func formatMessageText(_ text: String) -> Text {
        var finalText = Text("")
        let lines = text.components(separatedBy: "\n").filter { !$0.isEmpty } // Remove empty lines from array

        for (index, line) in lines.enumerated() {
            if line.contains("**") {
                // Splitting text for bold formatting
                let boldParts = line.components(separatedBy: "**")
                for (index, part) in boldParts.enumerated() {
                    if index % 2 == 1 { // Apply bold to text between ** markers
                        finalText = finalText + Text(part).bold()
                    } else {
                        finalText = finalText + Text(part)
                    }
                }
            } else if line.starts(with: "- ") {
                // Formatting for bullet points
                let bulletText = line.replacingOccurrences(of: "- ", with: "• ")
                finalText = finalText + Text(bulletText)
            } else {
                // Normal text
                finalText = finalText + Text(line)
            }

            if index < lines.count - 1 {
                // Add a newline only if it's not the last line
                finalText = finalText + Text("\n")
            }
        }

        return finalText
    }
}

struct CitationBox: View {
    let citation: Citation

    var body: some View {
        Button(action: {
            if let url = URL(string: citation.url) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack {
                Text(citation.fileName)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "arrow.up.right.square")
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.gradientStart)
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
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



struct ThreadResponse: Codable {
    let thread: String
}

struct RunData: Codable {
    let id: String
    let status: String
    // Add other relevant fields if necessary
}

struct RunResponse: Codable {
    let run: RunData
}

struct LastMessageResponse: Codable {
    let message: String?
    let citations: [String: CitationResponse]?

    struct CitationResponse: Codable {
        let file_name: String
        let url: String
    }
}



#Preview {
    InternalCbView()
}
