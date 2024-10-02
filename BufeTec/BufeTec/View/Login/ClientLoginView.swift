//
//  ClientLoginView.swift
//  BufeTec
//
//  Created by Sofia Sandoval y Diego Sabillon on 9/13/24.
//


import SwiftUI
import FirebaseAuth
import os

struct Country: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let code: String
    let flag: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Country, rhs: Country) -> Bool {
        lhs.id == rhs.id
    }
}


struct ClientLoginView: View {
    @State private var selectedCountry: Country
    @State private var phoneNumber: String = ""
    @State private var verificationCode: String = ""
    @State private var verificationID: String? = nil
    @State private var errorMessage: LoginErrorMessage? = nil
    @State private var isCodeSent: Bool = false
    @State private var isLoading: Bool = false
    @Binding var isLoggedOut: Bool
    @EnvironmentObject var authState: AuthState
    @Environment(\.presentationMode) var presentationMode
    
    private let countries = [
        Country(name: "Mexico", code: "+52", flag: "🇲🇽"),
        Country(name: "United States", code: "+1", flag: "🇺🇸")
    ]
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "kovomie.BufeTecApp", category: "ClientLoginView")
    
    init(isLoggedOut: Binding<Bool>) {
        self._isLoggedOut = isLoggedOut
        self._selectedCountry = State(initialValue: Country(name: "Mexico", code: "+52", flag: "🇲🇽"))
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#13295D"), Color(hex: "#2756C3")]),
                           startPoint: .top,
                           endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Iniciar sesión")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 50)
                
                Spacer()
                
                if !isCodeSent {
                    phoneNumberView
                } else {
                    verificationCodeView
                }
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .alert(item: $errorMessage) { error in
            Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private var phoneNumberView: some View {
        VStack(spacing: 20) {
            HStack {
                CustomCountryPicker(selectedCountry: $selectedCountry, countries: countries)
                    .frame(width: 100)
                
                TextField("Ingresa tu número tel.", text: $phoneNumber)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
            
            Button(action: sendOTP) {
                Text("Enviar Verificación")
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .frame(width:250)
            }
            .disabled(isLoading || phoneNumber.isEmpty)
        }
    }
    
    private var verificationCodeView: some View {
        VStack(spacing: 20) {
            TextField("Enter verification code", text: $verificationCode)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
                .foregroundColor(.white)
            
            Button(action: verifyCode) {
                Text("Verify Code")
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .frame(width:250)
            }
            .disabled(isLoading || verificationCode.isEmpty)
        }
    }
    
    func sendOTP() {
        let fullPhoneNumber = selectedCountry.code + phoneNumber
        print("Attempting to send OTP to: \(fullPhoneNumber)")
        isLoading = true
        guard !phoneNumber.isEmpty else {
            print("Phone number is empty")
            errorMessage = LoginErrorMessage(message: "Phone number cannot be empty.")
            isLoading = false
            return
        }
        
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(fullPhoneNumber, uiDelegate: nil) { verificationID, error in
                isLoading = false
                if let error = error {
                    errorMessage = LoginErrorMessage(message: error.localizedDescription)
                    return
                }
                self.verificationID = verificationID
                isCodeSent = true
            }
    }
    
    func verifyCode() {
        isLoading = true
        guard let verificationID = verificationID else {
            errorMessage = LoginErrorMessage(message: "Verification ID is missing. Please try sending the code again.")
            isLoading = false
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )
        
        // After successful login:
        Auth.auth().signIn(with: credential) { authResult, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    print("Error during login: \(error.localizedDescription)")
                    self.errorMessage = LoginErrorMessage(message: error.localizedDescription)
                    return
                }
                
                if let user = authResult?.user {
                    self.authState.isLoggedIn = true
                    self.authState.user = user
                    self.authState.setUserRole(.client)
                    self.isLoggedOut = false
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }


    
    func pushClientToMongoDB(uid: String, phoneNumber: String, name:String) {
        let url = URL(string: "http://10.14.255.51:4000/clientes")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Pass the Firebase uid as _id
        let userInfo: [String: Any] = [
            "_id": uid,  // Use Firebase uid as MongoDB _id
            "nombre": name,
            "numero_telefonico": phoneNumber,
            "correo": "",   // Add email if needed
            "tramite": "Caso Legal",  // Example tramite, replace with actual data
            "expediente": "",
            "juzgado": "",
            "seguimiento": "",
            "alumno": "",
            "folio": "",
            "ultimaVezInf": ISO8601DateFormatter().string(from: Date()),  // Set current date in ISO format
            "rol": "cliente"
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: userInfo, options: []) else { return }
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error pushing user to MongoDB: \(error)")
                return
            }
            
            guard let data = data else { return }
            if let responseString = String(data: data, encoding: .utf8) {
                print("MongoDB response: \(responseString)")
            }
        }.resume()
    }
}



struct LoginErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}

struct CustomCountryPicker: View {
    @Binding var selectedCountry: Country
    let countries: [Country]
    
    var body: some View {
        Menu {
            Picker("", selection: $selectedCountry) {
                ForEach(countries) { country in
                    Text("\(country.flag) \(country.code)").tag(country)
                }
            }
        } label: {
            HStack {
                Text(selectedCountry.flag)
                    .font(.title3)  // Increased font size
                Image(systemName: "chevron.down")
                    .font(.caption)
                
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(10)
        }
    }
}



#Preview {
    ClientLoginView(isLoggedOut: .constant(true))
        .environmentObject(AuthState())
}
