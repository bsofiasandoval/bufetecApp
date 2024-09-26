import SwiftUI

struct AskQuestionView: View {
    @State private var title: String = ""
    @State private var question: String = ""
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Spacer()
            Form {
                HStack {
                    Text("Título")
                    Spacer()
                    TextField("Título de tu pregunta", text: $title)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 30)
                }
                
                HStack(alignment: .top) {
                    Text("Pregunta")
                    Spacer()
                    
                    TextEditor(text: $question)
                        .frame(minHeight: 200)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .background(colorScheme == .dark ? Color(.systemBackground) : Color(.systemGray6))
        .navigationTitle("Nuevo Hilo")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Publicar") {
                    // Add your action here when the "Publicar" button is pressed
                    print("Pregunta publicada: \(title) - \(question)")
                }
            }
        }
        .toolbarBackground(colorScheme == .dark ? .clear : .white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
