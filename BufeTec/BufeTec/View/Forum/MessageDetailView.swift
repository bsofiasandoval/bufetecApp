//
//  MessageDetailView.swift
//  Foro
//
//  Created by Ximena Tobias on 12/09/24.
//

import SwiftUI

struct MessageDetailView: View {
    var post: WelcomeElement
    @State private var replyTitle: String = ""
    @State private var replyMessage: String = ""

    var body: some View {
        VStack {
            Spacer()
           
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text(post.titulo)
                        .font(.headline)
                    
                    Text(post.contenido)
                        .font(.subheadline)
                    
                    // Aquí se llama a la función formatTime que ahora devuelve el día y el mes
                    Text(formatTime(post.fechaCreacion))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(15)
                .padding(.horizontal)
            }
            
            Spacer()
            
            /*Form {
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
            }*/
        }
        .background(Color(.systemGray6))
        .navigationTitle("Responder a ")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Responder") {
                    // Handle publish action here
                    print("Respuesta publicada: \(replyMessage)")
                }
            }
        }
        .toolbarBackground(.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

func formatTime(_ dateString: String) -> String {
    let formatter = DateFormatter()
    // Define el formato de fecha exacto
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
    // Establece la zona horaria de la cadena de fecha original a UTC
    formatter.timeZone = TimeZone(abbreviation: "UTC")

    // Analiza la cadena de fecha
    if let date = formatter.date(from: dateString) {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d" // Día del mes
        let day = dayFormatter.string(from: date)
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM" // Nombre del mes completo
        monthFormatter.locale = Locale(identifier: "es_ES") // Establece el locale a español
        let month = monthFormatter.string(from: date)

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a" // Hora en formato 12 horas
        timeFormatter.timeZone = TimeZone(identifier: "America/Mexico_City") // CST (UTC-6)
        
        let formattedTime = timeFormatter.string(from: date)
        return "Enviado el \(day) de \(month) a las \(formattedTime)"
    } else {
        print("Error: No se pudo analizar la cadena de fecha: \(dateString)") // Mensaje de depuración
    }
    
    return dateString // Devuelve la cadena original si falla el análisis
}



struct MessageDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MessageDetailView(post: WelcomeElement(autorID: "Claudia Ximena", contenido: "Necesito ayuda para resolver un caso urgente.", fechaCreacion: "2024-09-10T10:30:00.000000", id: "1", readUsers: [], respuestas: [], titulo: "Consulta urgente"))
    }
}
