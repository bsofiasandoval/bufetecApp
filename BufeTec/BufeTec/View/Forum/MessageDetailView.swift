//
//  MessageDetailView.swift
//  Foro
//
//  Created by Ximena Tobias on 12/09/24.
//

import SwiftUI
import FirebaseAuth

struct MessageDetailView: View {
    @EnvironmentObject var authState: AuthState
    var post: WelcomeElement
    @State private var replyTitle: String = ""
    @State private var replyMessage: String = ""
    @State private var isAbogado: Bool = false
    @State private var isPresented = false
    @State private var respuestas: [Respuesta] = []
    @State private var userNames: [String: String] = [:]

    var body: some View {
        VStack {
            Spacer()
           
            //you can obtain the postid with post.id
                VStack(alignment: .leading, spacing: 10) {
                    Text(post.titulo)
                        .font(.headline)
                        .foregroundColor(Color.text)
                    
                    Text(post.contenido)
                        .font(.subheadline)
                        .foregroundColor(Color.text)
                    
                    // Aquí se llama a la función formatTime que ahora devuelve el día y el mes
                    Text(formatTime(post.fechaCreacion))
                        .font(.caption)
                        .foregroundColor(Color.text)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.cajitas)
                .cornerRadius(15)
                .padding(.horizontal)
            
            HStack {
                VStack(alignment: .leading, spacing: 40 ){
                    Text("Respuestas")
                        .font(.headline)
                        .padding(.leading, 30)
                        .padding(.top, 10)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            //Respuestas de la publicacion (hay que iterar sobre cada respuesta)
            ScrollView {
                ForEach(respuestas, id: \.respuestaID) { respuesta in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(userNames[respuesta.autorID] ?? "Cargando...")
                                        .font(.subheadline)
                                        .bold()
                                        .lineLimit(1)
                                        .foregroundColor(Color.text)
                        
                        Text(respuesta.contenido)
                            .font(.subheadline)
                            .foregroundColor(Color.text)
                        
                        // Aquí se llama a la función formatTime que ahora devuelve el día y el mes
                        Text(formatTime(respuesta.fechaCreacion))
                            .font(.caption)
                            .foregroundColor(Color.text)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.cajitas)
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
            }
            
        }
        .background(Color.forumBack)
        .onAppear {
                    fetchUserData(userId: Auth.auth().currentUser?.uid ?? "")
                    fetchResponses()
                }
        .navigationTitle(
            // Conditional navigation title based on the user role
            post.autorID == Auth.auth().currentUser?.uid || isAbogado
                ? "Responder mensaje"
                : "Detalles del mensaje"
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Conditionally show "Responder" button if user is the post's author or a lawyer
            if post.autorID == Auth.auth().currentUser?.uid || isAbogado {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action:{
                        isPresented = true
                    }) {
                        Image(systemName: "paperplane")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24) // Adjust size as needed
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .sheet(isPresented: $isPresented) {
                    RespondMessage(isPresented: $isPresented, post: post, onPostSave: {
                        fetchResponses()
                        print("Post saved")
                    })
                }
        .onAppear{
            fetchResponses()
        }
    }
    
    private func fetchResponses() {
        NetworkManager.shared.fetchResponses(for: post.id) { result in
            switch result {
            case .success(let fetchedRespuestas):
                DispatchQueue.main.async {
                    self.respuestas = fetchedRespuestas
                    // Buscar nombres de autores
                    for respuesta in fetchedRespuestas {
                        fetchUserData(userId: respuesta.autorID)
                    }
                }
            case .failure(let error):
                print("Error al obtener respuestas: \(error.localizedDescription)")
            }
        }
    }
    private func fetchUserData(userId: String) {
        // Intenta obtener el usuario como abogado primero
        NetworkManager.shared.fetchUserAbogadoById(userId) { result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    isAbogado = true
                }
            case .failure:
                // Si falla, intenta obtener el usuario como becario
                fetchBecarioData(userId: userId)
            }
        }
    }

    private func fetchBecarioData(userId: String) {
        NetworkManager.shared.fetchUserBecarioById(userId) { result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self.userNames[userId] = user.nombre // Almacenar nombre del becario
                }
            case .failure:
                DispatchQueue.main.async {
                    self.userNames[userId] = "Usuario desconocido" // Valor por defecto si falla
                }
            }
        }
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
        monthFormatter.dateFormat = "MMM" // Nombre del mes completo
        monthFormatter.locale = Locale(identifier: "es_ES")
        let month = monthFormatter.string(from: date)

        // Formateador para el año
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy" // Año
        let year = yearFormatter.string(from: date)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a" // Hora en formato 12 horas
        timeFormatter.timeZone = TimeZone(identifier: "America/Mexico_City") // CST (UTC-6)
        
        let formattedTime = timeFormatter.string(from: date)
        return "Enviado \(month) \(day) , \(year) a las \(formattedTime)"
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
