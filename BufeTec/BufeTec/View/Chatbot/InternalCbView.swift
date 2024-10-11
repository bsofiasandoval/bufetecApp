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
        }
        
        // Clear the input field
        DispatchQueue.main.async {
            self.chat = ""
        }
        
        // Create message via API
        let createMessageURL = "\(baseURL)/create-message?thread_id=\(threadId)&content=\(trimmedChat.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        guard let url = URL(string: createMessageURL) else {
            print("Invalid URL for creating message")
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response when creating message")
                return
            }
            
            if httpResponse.statusCode != 200 {
                if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                   let errorMessage = errorResponse["error"] {
                    print("Error creating message: \(errorMessage)")
                } else {
                    print("Unknown error creating message.")
                }
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
        
        // Run the thread via API
        let runThreadURL = "\(baseURL)/run-thread?thread_id=\(threadId)&assistant_id=\(assistantId)"
        
        guard let runURL = URL(string: runThreadURL) else {
            print("Invalid URL for running thread")
            return
        }
        
        var runId: String?
        var runStatus: String = "queued"
        
        do {
            let (data, response) = try await URLSession.shared.data(from: runURL)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response when running thread")
                return
            }
            
            if httpResponse.statusCode != 200 {
                if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                   let errorMessage = errorResponse["error"] {
                    print("Error running thread: \(errorMessage)")
                } else {
                    print("Unknown error running thread.")
                }
                return
            }
            
            let runResponse = try JSONDecoder().decode(RunResponse.self, from: data)
            let retrievedRunId = runResponse.run.id
            runId = retrievedRunId
            runStatus = runResponse.run.status
            print("Run initiated with ID: \(runId!)")
            
        } catch {
            print("Error running thread: \(error)")
            return
        }
        
        guard let finalRunId = runId else { return }
        
        // Polling to check run status
        var runCompleted = (runStatus == "completed")
        var pollCount = 0
        let maxPollAttempts = 30 // Adjust as needed (e.g., max 60 seconds if polling every 2 seconds)
        
        while !runCompleted && pollCount < maxPollAttempts {
            try? await Task.sleep(nanoseconds: 2 * 1_000_000_000) // Wait for 2 seconds before polling
            pollCount += 1
            
            let getRunURL = "\(baseURL)/get-run?thread_id=\(threadId)&run_id=\(finalRunId)"
            guard let url = URL(string: getRunURL) else {
                print("Invalid URL for getting run status")
                continue
            }
            
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response when getting run status")
                    continue
                }
                
                if httpResponse.statusCode != 200 {
                    if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                       let errorMessage = errorResponse["error"] {
                        print("Error getting run status: \(errorMessage)")
                    } else {
                        print("Unknown error getting run status.")
                    }
                    continue
                }
                
                let runStatusResponse = try JSONDecoder().decode(RunResponse.self, from: data)
                runStatus = runStatusResponse.run.status
                print("Current run status: \(runStatus)")
                
                if runStatus == "completed" {
                    runCompleted = true
                }
                
            } catch {
                print("Error checking run status: \(error)")
            }
        }
        
        if !runCompleted {
            print("Run did not complete within the expected time.")
            return
        }
        
        // Retrieve the last message from the API
        let getLastMessageURL = "\(baseURL)/retrieve-message?thread_id=\(threadId)"
        
        guard let lastMessageURL = URL(string: getLastMessageURL) else {
              print("Invalid URL for getting last message")
              return
          }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: lastMessageURL)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                        print("Invalid response when getting last message")
                        return
                    }
            
            if httpResponse.statusCode != 200 {
                        if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                           let errorMessage = errorResponse["error"] {
                            print("Error getting last message: \(errorMessage)")
                        } else {
                            print("Unknown error getting last message.")
                        }
                        return
                    }

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
            }
            
        } catch {
            print("Error retrieving last message: \(error)")
        }
    }
}

struct MessageBubbleInternal: View {
    let message: CbMessageModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 8) {
            HStack(alignment: .bottom, spacing: 0) {
                if message.isFromCurrentUser {
                    formatMessageText(message.text)
                        .padding(10)
                        .background(Color.userMessageBackground)
                        .foregroundColor(Color.userMessageText)
                        .clipShape(BubbleShape(isFromCurrentUser: true))
                } else {
                    formatMessageText(message.text)
                        .padding(10)
                        .background(Color.botMessageBackground)
                        .foregroundColor(Color.botMessageText)
                        .clipShape(BubbleShape(isFromCurrentUser: false))
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }

            // Display unique citations
            if let citations = message.citations {
                let uniqueCitations = removeDuplicateCitations(citations)
                ForEach(uniqueCitations) { citation in
                    CitationBox(citation: citation)
                }
            }
        }
    }

    // Function to remove duplicate citations based on fileName
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
