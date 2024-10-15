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
    @Binding var tramite: String
    @State private var folio: String = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoading = false
    @Binding var isLoggedOut: Bool
    @State private var shouldNavigateToCases = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showVerificationSheet = false
    @State private var clientRegistered = false
    @EnvironmentObject var authState: AuthState
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "kovomie.BufeTec", category: "ClientRegisterView")
    
    var body: some View {
  
            Form {
                Section("Información Personal"){
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.textFieldText)
                        TextField("Nombre", text: $nombre)
                            .foregroundColor(.textFieldText)
                    }
                   
                    
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.textFieldText)
                        TextField("+52XXXXXXXX", text: $telefono)
                            .keyboardType(.phonePad)
                            .foregroundColor(.textFieldText)
                    }
                    
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.textFieldText)
                        TextField("Correo Electrónico", text: $correo)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .foregroundColor(.textFieldText)
                    }
        
                }
                
                Section("Detalles del caso") {
                    HStack {
                        Text("Tramite")
                        Spacer()
                        Text(tramite.isEmpty ? "Caso Legal" : tramite)
                    }
                    
                    HStack {
                        Text("ID del Caso")
                        Spacer()
                        Text(folio.isEmpty ? "No asignado" : folio)

                    }
                }
            }
            .navigationTitle("Crear Cuenta")
            .toolbar{
                ToolbarItem{
                    Button("Continuar"){
                        startPhoneVerification()
                    }
                }
            }
            .dismissKeyboardOnTap() 
            .sheet(isPresented: $showVerificationSheet) {
                PhoneVerificationView(
                    phoneNumber: telefono,
                    shouldNavigateToCases: $shouldNavigateToCases,
                    onVerificationComplete: { uid in
                        registerClient(uid: uid)
                        createCase(for: uid)
                        showVerificationSheet = false
                    },
                    isLoggedOut: $isLoggedOut
                )
            }
            .onChange(of: clientRegistered) { newValue in
               if newValue {
                   shouldNavigateToCases = true
               }
            }
            .navigate(to: CasesView(clientId: Auth.auth().currentUser?.uid ?? "").environmentObject(authState), when: $shouldNavigateToCases)
        
    }
    
    // Function to register client with Firebase UID
    private func registerClient(uid: String) {
        logger.info("registerClient called with UID: \(uid)")
        isLoading = true
        
        // Prepare the client data
        var clientData: [String: Any] = [
            "_id": uid,  // Use "_id" to match the API expectation
            "nombre": nombre,
            "numero_telefonico": telefono,
            "correo": correo,
            "expediente": "",
            "juzgado": "",
            "seguimiento": "",
            "alumno": "",
            "folio": folio,
            "ultimaVezInf": Date().ISO8601Format(),
            "rol": "cliente"
        ]
        
        // Remove empty fields
        clientData = clientData.filter { !($0.value is String) || !($0.value as! String).isEmpty }
        
        guard let url = URL(string: "http://10.14.255.51:4000/clientes") else {
            showError(message: "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: clientData)
        } catch {
            showError(message: "Error encoding client data: \(error.localizedDescription)")
            return
        }
        
        logger.info("Sending POST request to API with data: \(clientData)")
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.showError(message: "Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.showError(message: "Invalid response from server")
                    return
                }
                
                self.logger.info("Received response with status code: \(httpResponse.statusCode)")
                
                if (200...299).contains(httpResponse.statusCode) {
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        self.logger.info("Response body: \(responseString)")
                    }
                    
                    self.logger.info("Client registration successful")
                    self.shouldNavigateToCases = true
                } else {
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        self.showError(message: "Server error: \(responseString)")
                    } else {
                        self.showError(message: "Server error: Status \(httpResponse.statusCode)")
                    }
                }
            }
        }.resume()
    }
    
    private func createCase(for clientId: String) {
        let tramiteValue = tramite.isEmpty ? "Caso Legal" : tramite
        
        let caseData: [String: Any] = [
            "tipo_de_caso": tramiteValue,
            "cliente_id": clientId,
            "estado": "Abierto",
            "fecha_inicio": Date().ISO8601Format(),
            "notas": "",
            "descripcion": ""
        ]
        
        guard let url = URL(string: "http://10.14.255.51:4000/casos_legales") else {
            showError(message: "Invalid URL for case creation")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: caseData)
        } catch {
            showError(message: "Error encoding case data: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.showError(message: "Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    self.showError(message: "Server error during case creation")
                    return
                }
                
                self.logger.info("Client and case creation successful")
                self.clientRegistered = true
            }
        }.resume()
    }
    
    
    private func showError(message: String) {
        logger.error("Error: \(message)")
        errorMessage = message
        showError = true
        isLoading = false
    }
    
    // Phone Number Validation
    func isValidPhoneNumber(_ phone: String) -> Bool {
        let phoneRegex = "^[+]?[0-9]{10,14}$"
        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: phone)
    }
    func isValidEmailAddress(_ email: String) -> Bool {
        let emailRegex = "^$|^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    private func startPhoneVerification() {
        guard canProceedWithRegistration() else { return }
        showVerificationSheet = true
    }
    
    func canProceedWithRegistration() -> Bool {
        if nombre.isEmpty || telefono.isEmpty {
            showError(message: "Please fill all required fields.")
            return false
        }
        
        if !isValidPhoneNumber(telefono) {
            showError(message: "Please provide a valid phone number.")
            return false
        }
        if !correo.isEmpty && !isValidEmailAddress(correo) {
                   showError(message: "Please provide a valid email address or leave it empty.")
                   return false
               }
        
        return true
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
    @Binding var isLoggedOut: Bool
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authState : AuthState
    
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "kovomie.BufeTecApp", category: "PhoneVerificationView")
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "lock.shield")
                .font(.system(size: 60))
                .foregroundColor(.text)
            
            Text("Verifica tu número telefónico")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.text)
            
            Text("Ingresa el código de verificación que se envió a \(phoneNumber)")
                .multilineTextAlignment(.center)
                .foregroundColor(.textFieldText)
                .padding(.horizontal)
            
            TextField("Código de verificación", text: $verificationCode)
                .keyboardType(.numberPad)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.textFieldBackground)
                .cornerRadius(10)
                .foregroundColor(.textFieldText)

            Button("Verify") {
                verifyPhoneNumber()
            }
            .disabled(isLoading || verificationCode.count != 6)
            .opacity((isLoading || verificationCode.count != 6) ? 0.5 : 1)
            .shadow(radius: 5)
            
            if isLoading {
                ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .text))
                .scaleEffect(1.5)
            }
        }
        .padding()
        .background(Color.background)
        .cornerRadius(20)
        .shadow(radius: 10)
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
                    if let user = authResult?.user {
                        self.authState.isLoggedIn = true
                        self.authState.user = user
                        self.authState.setUserRole(.cliente)
                        self.isLoggedOut = false
                        onVerificationComplete(user.uid)
                        self.presentationMode.wrappedValue.dismiss()
                    }
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
    ClientRegisterView(tramite: .constant("Caso Civil"), isLoggedOut: .constant(false))
        .environmentObject(AuthState())
}


extension View {
    func navigate<NewView: View>(to view: NewView, when binding: Binding<Bool>) -> some View {
        ZStack {
            self
            NavigationLink(
                destination: view
                    .navigationBarTitle("")
                    .navigationBarHidden(true),
                isActive: binding
            ) {
                EmptyView()
            }
        }
    }
}

