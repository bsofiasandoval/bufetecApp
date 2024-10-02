//
//  ClientRegisterView.swift
//  BufeTec
//
//  Created by Lorna on 9/25/24.
//

import SwiftUI
import FirebaseAuth
import os

struct ClientRegisterView: View {
    @State private var nombre: String = ""
    @State private var telefono: String = ""
    @State private var correo: String = ""
    @State private var tramite: String = "Caso Legal"
    @State private var folio: String = ""
    @State private var shouldNavigateToCases = false
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showVerificationSheet = false
    @EnvironmentObject var authState: AuthState
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "kovomie.BufeTec", category: "ClientRegisterView")
    
    var body: some View {
        Form {
            Section(header: Text("Información del Cliente")) {
                HStack {
                    Text("Nombre")
                    TextField("Nombre", text: $nombre)
                }
                
                HStack {
                    Text("# Teléfono")
                    TextField("+52XXXXXXXX", text: $telefono)
                        .keyboardType(.phonePad)
                }
                
                HStack {
                    Text("Correo Electrónico")
                    TextField("Correo Electrónico", text: $correo)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            }
            
            Section(header: Text("Detalles del Caso")) {
                HStack {
                    Text("Tramite")
                    TextField("Trámite", text: $tramite)
                        .disabled(true)
                }
                
                HStack {
                    Text("ID del Caso")
                    TextField("Folio", text: $folio)
                        .disabled(true)
                }
            }
        }
        .navigationTitle("Crear Cuenta")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Guardar") {
                    // Initiate phone verification and registration process
                    startPhoneVerification()
                }
                .disabled(isLoading)
            }
        }
        .sheet(isPresented: $showVerificationSheet) {
            PhoneVerificationView(phoneNumber: telefono, shouldNavigateToCases: $shouldNavigateToCases, onVerificationComplete: registerClient)
                
        }
        .onChange(of: showVerificationSheet) { newValue in
            logger.info("showVerificationSheet changed to: \(newValue)")
        }
        .fullScreenCover(isPresented: $shouldNavigateToCases) {
            NavigationView {
                CasesView()
                    .environmentObject(authState)
            }
        }
    }
    
    // Function to start phone verification
    private func startPhoneVerification() {
        // Initiate phone verification process
        showVerificationSheet = true
    }
    
    // Function to register client with Firebase UID
    private func registerClient(uid: String) {
        isLoading = true
        logger.info("Starting client registration with Firebase UID: \(uid)")
        
        // Prepare the client data
        let clientData: [String: Any] = [
            "_id": uid,  // Firebase UID as MongoDB _id
            "nombre": nombre,
            "numero_telefonico": telefono,
            "correo": correo,
            "tramite": tramite,
            "expediente": "",
            "juzgado": "",
            "seguimiento": "",
            "alumno": "",
            "folio": folio,
            "ultimaVezInf": Date().ISO8601Format(),
            "rol": "cliente"
        ]
        
        guard let url = URL(string: "http://10.14.255.51:4000/clientes") else {
            logger.error("Invalid URL")
            showError(message: "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: clientData)
        } catch {
            logger.error("Error encoding client data: \(error.localizedDescription)")
            showError(message: "Error encoding client data")
            return
        }
        
        logger.info("Sending POST request to API")
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    logger.error("Network error: \(error.localizedDescription)")
                    showError(message: "Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    logger.error("Invalid response")
                    showError(message: "Invalid response from server")
                    return
                }
                
                logger.info("Received response with status code: \(httpResponse.statusCode)")
                
                if (200...299).contains(httpResponse.statusCode) {
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        logger.info("Response body: \(responseString)")
                    }
                    
                    logger.info("API call successful, showing verification sheet")
                    self.showVerificationSheet = true
                } else {
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        logger.error("Server error. Status: \(httpResponse.statusCode), Body: \(responseString)")
                        showError(message: "Server error: \(responseString)")
                    } else {
                        logger.error("Server error. Status: \(httpResponse.statusCode)")
                        showError(message: "Server error: Status \(httpResponse.statusCode)")
                    }
                }
            }
        }.resume()
    }
    
    private func showError(message: String) {
        logger.error("Error: \(message)")
        errorMessage = message
        showError = true
        isLoading = false
    }
}


struct PhoneVerificationView: View {
    let phoneNumber: String
    @Binding var shouldNavigateToCases: Bool
    var onVerificationComplete: (String) -> Void
    @State private var verificationCode: String = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.presentationMode) var presentationMode
    
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "kovomie.BufeTecApp", category: "PhoneVerificationView")
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Verifica tu número telefonico")
                .font(.title)
            
            Text("Ingresa el código de verificación que se envío a \(phoneNumber)")
            
            TextField("Verification Code", text: $verificationCode)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Verify") {
                verifyPhoneNumber()
            }
            .disabled(isLoading)
            
            if isLoading {
                ProgressView()
            }
        }
        .padding()
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func verifyPhoneNumber() {
        isLoading = true
        logger.info("Starting phone verification for number: \(phoneNumber)")
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    logger.error("Verification failed: \(error.localizedDescription)")
                    showError(message: "Verification failed: \(error.localizedDescription)")
                    return
                }
                
                guard let verificationID = verificationID else {
                    logger.error("Verification ID is missing")
                    showError(message: "Verification ID is missing")
                    return
                }
                
                logger.info("Verification ID received, attempting to sign in")
                let credential = PhoneAuthProvider.provider().credential(
                    withVerificationID: verificationID,
                    verificationCode: verificationCode
                )
                
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        logger.error("Authentication failed: \(error.localizedDescription)")
                        showError(message: "Authentication failed: \(error.localizedDescription)")
                        return
                    }
                    
                    logger.info("Authentication successful")
                    if let uid = authResult?.user.uid {
                        onVerificationComplete(uid)
                    }
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}


#Preview {
    ClientRegisterView()
        .environmentObject(AuthState())
}

