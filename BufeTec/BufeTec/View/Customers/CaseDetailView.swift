//
//  CaseView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 10/1/24.
//

import SwiftUI
import FirebaseStorage
import UniformTypeIdentifiers

struct CaseDetailView: View {
    let legalCase: Case
    let isClient: Bool
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    @State private var isShowingDocumentPicker = false
    @State private var selectedDocumentURL: URL?
    @State private var personnelNames: [String: String] = [:]  // To store names keyed by ID
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                caseInfoSection
                statusSection
                lawyersSection
                documentsSection
                updatesSection
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear{
            fetchPersonnelNames()
        }
        .navigationBarTitle("Mi Caso", displayMode: .inline)
    }
    
    private var caseInfoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(legalCase.tipo_de_caso)
                .font(.title)
                .fontWeight(.bold)
            
            detailRow(icon: "number", title: "ID del Caso", content: legalCase.id)
            
            Text("Descripción")
                .font(.headline)
                .padding(.top, 5)
            Text(legalCase.descripcion)
                .font(.body)
            
            if !isClient, let notas = legalCase.notas, !notas.isEmpty {
                Text("Notas")
                    .font(.headline)
                    .padding(.top, 5)
                Text(notas)
                    .font(.body)
                    .foregroundColor(.secondary)
            }

        }
        .sectionStyle()
    }
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("Estado: ")
                    .fontWeight(.semibold)
                Text(legalCase.estado)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .cornerRadius(8)
            }
            
            detailRow(icon: "calendar", title: "Fecha de inicio", content: formatDate(legalCase.fecha_inicio))
            
            if let fechaCierre = legalCase.fecha_cierre {
                detailRow(icon: "flag.checkered", title: "Fecha de cierre", content: formatDate(fechaCierre))
            }
        }
        .sectionStyle()
    }
    
    private var lawyersSection: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text("Abogados y Becarios Asignados")
                    .font(.headline)
                ForEach(legalCase.abogados_becarios_id, id: \.self) { id in
                    if let name = personnelNames[id] {
                        personnelRow(name: name, id: id)
                    } else {
                        Text("Loading...")  // Show a loading text or an activity indicator
                    }
                }
            }
            .sectionStyle()
        }
        
        private func personnelRow(name: String, id: String) -> some View {
            NavigationLink(destination: MyPersonnelView(internalId: id)) {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.blue)
                    Text(name)  // Display the fetched name
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 5)
            .buttonStyle(PlainButtonStyle())
        }
        
    @ViewBuilder
    private func personDetailView(for id: String) -> some View {
        if id.hasPrefix("abogado") {
            LawyerDetailView(lawyerId: id)
        } else if id.hasPrefix("becario") {
            BecarioDetailView(becarioId: id)
        } else {
            Text("Perfil no disponible")
        }
    }
    
    private var documentsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Documentos")
                    .font(.headline)
                Spacer()
                Button(action: {
                    // Trigger document picker
                    isShowingDocumentPicker = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            
            if legalCase.documentos.isEmpty {
                Text("No hay documentos disponibles")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(legalCase.documentos, id: \.name) { documento in
                    HStack {
                        Image(systemName: "doc.fill")
                            .foregroundColor(.blue)
                        Text(documento.name)
                        Spacer()
                        Button("Ver") {
                        // Safely attempt to open the URL
                        if let url = URL(string: documento.url), UIApplication.shared.canOpenURL(url) {
                            openURL(url)
                        } else {
                            print("Documento Inválido")
                        }
                    }
                    .foregroundColor(.blue)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .sectionStyle()
        .sheet(isPresented: $isShowingDocumentPicker) {
            DocumentPicker(selectedDocumentURL: $selectedDocumentURL, onUpload: uploadDocumentToFirebase)
        }
    }
    
    private func fetchPersonnelNames() {
        for id in legalCase.abogados_becarios_id {
            // Assuming your IDs start with "abogado" or "becario" to differentiate the roles
            let endpoint = id.hasPrefix("abogado") ? "abogados" : "becarios"
            let urlString = "http://10.14.255.51:4000/\(endpoint)/\(id)"
            
            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                continue
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Failed to fetch data: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                do {
                    if endpoint == "abogados" {
                        let result = try JSONDecoder().decode(AbogadoName.self, from: data)
                        DispatchQueue.main.async {
                            self.personnelNames[id] = result.nombre
                        }
                    } else {
                        let result = try JSONDecoder().decode(BecarioName.self, from: data)
                        DispatchQueue.main.async {
                            self.personnelNames[id] = result.nombre
                        }
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
            }.resume()
        }
    }
    
    private func uploadDocumentToFirebase(documentURL: URL) {
        do {
            // If the URL is from a security-scoped resource, start accessing it
            if documentURL.startAccessingSecurityScopedResource() {
                defer { documentURL.stopAccessingSecurityScopedResource() }
                
                // Copy file to a temporary directory
                let tempDirectory = FileManager.default.temporaryDirectory
                let targetURL = tempDirectory.appendingPathComponent(documentURL.lastPathComponent)
                
                if FileManager.default.fileExists(atPath: targetURL.path) {
                    try FileManager.default.removeItem(at: targetURL)
                }
                
                try FileManager.default.copyItem(at: documentURL, to: targetURL)
                print("File copied to temporary location: \(targetURL.path)")
                
                let storage = Storage.storage()
                let storageRef = storage.reference().child("documents/\(targetURL.lastPathComponent)")
                
                // Upload the file
                storageRef.putFile(from: targetURL, metadata: nil) { metadata, error in
                    if let error = error {
                        print("Error uploading file: \(error.localizedDescription)")
                        return
                    }
                    
                    // Retrieve the download URL after upload succeeds
                    storageRef.downloadURL { (url, error) in
                        if let error = error {
                            print("Error getting download URL: \(error.localizedDescription)")
                        } else if let downloadURL = url {
                            print("File uploaded successfully. Download URL: \(downloadURL)")
                                   
                               // Prepare the URL with both cliente_id and case_id
                               guard let postURL = URL(string: "http://10.14.255.51:4000/upload_document_case/\(legalCase.cliente_id)/\(legalCase.id)") else {
                                   print("Invalid URL")
                                   return
                               }
                               
                               // Prepare the request body - removed case_id since it's now in the URL
                               let documentInfo: [String: Any] = [
                                   "document_url": downloadURL.absoluteString,
                                   "document_name": targetURL.lastPathComponent
                               ]
                               
                               guard let jsonData = try? JSONSerialization.data(withJSONObject: documentInfo) else {
                                   print("Error: Unable to serialize JSON")
                                   return
                               }
                               
                               // Create the request
                               var request = URLRequest(url: postURL)
                               request.httpMethod = "POST"
                               request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                               request.httpBody = jsonData
                               
                               // Make the network call
                               URLSession.shared.dataTask(with: request) { data, response, error in
                                   if let error = error {
                                       print("Error making POST request: \(error.localizedDescription)")
                                       return
                                   }
                                   
                                   guard let httpResponse = response as? HTTPURLResponse else {
                                       print("Error: Invalid response")
                                       return
                                   }
                                   
                                   if (200...299).contains(httpResponse.statusCode) {
                                       print("Document successfully registered with server")
                                   } else {
                                       print("Server error: \(httpResponse.statusCode)")
                                   }
                                   
                                   if let data = data, let responseString = String(data: data, encoding: .utf8) {
                                       print("Server response: \(responseString)")
                                   }
                               }.resume()
                        }
                    }
                }
            } else {
                print("Could not access security-scoped resource")
            }
        } catch {
            print("Error processing file for upload: \(error.localizedDescription)")
        }
    }

    
    private var updatesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Actualizaciones")
                .font(.headline)
            ForEach(legalCase.actualizaciones, id: \.fecha) { actualizacion in
                VStack(alignment: .leading, spacing: 5) {
                    Text(formatDate(actualizacion.fecha))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(actualizacion.descripcion)
                        .font(.body)
                }
                .padding(.vertical, 5)
            }
        }
        .sectionStyle()
    }
    
    
    private var statusColor: Color {
        switch legalCase.estado.lowercased() {
        case "en proceso":
            return .blue
        case "finalizado":
            return .green
        case "en espera":
            return .orange
        default:
            return .gray
        }
    }
    
    private func detailRow(icon: String, title: String, content: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(title)
                .fontWeight(.semibold)
            Spacer()
            Text(content)
                .foregroundColor(.secondary)
        }
    }
    
    
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        inputFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        outputFormatter.timeZone = TimeZone.current
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString  // Return original string if parsing fails
    }
}
struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedDocumentURL: URL?
    var onUpload: (URL) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let selectedURL = urls.first else { return }
            parent.selectedDocumentURL = selectedURL
            parent.onUpload(selectedURL)
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.selectedDocumentURL = nil
        }
    }
}

struct CaseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CaseDetailView(
                legalCase: Case(
                    id: "case_001",
                    tipo_de_caso: "Divorcio",
                    cliente_id: "client123",
                    abogados_becarios_id: ["abogado_001", "becario_001"],
                    estado: "En proceso",
                    fecha_inicio: "2024-08-15T10:00:00Z",
                    fecha_cierre: nil,
                    documentos: [
                        Documento(name: "Acta de matrimonio", url: "https://example.com/acta_matrimonio.pdf"),
                        Documento(name: "Demanda de divorcio", url: "https://example.com/demanda_divorcio.pdf")
                    ],
                    actualizaciones: [
                        Actualizacion(fecha: "2024-08-20T14:30:00Z", descripcion: "Presentación de la demanda de divorcio"),
                        Actualizacion(fecha: "2024-09-05T11:00:00Z", descripcion: "Notificación al cónyuge")
                    ],
                    descripcion: "Divorcio por mutuo consentimiento",
                    notas: "El cliente desea un proceso rápido y amistoso"
                ),
                isClient: true  // Set to false to see the notes in the preview
            )
        }
    }
}


extension View {
    func sectionStyle() -> some View {
        self
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.secondarySystemGroupedBackground)))
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct AbogadoName: Codable {
    let nombre: String
}

struct BecarioName: Codable {
    let nombre: String
}
