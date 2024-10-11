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
            Alert(title: Text(error.title), message: Text(error.message), dismissButton: .default(Text("Aceptar")))
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
                    .onChange(of: phoneNumber) { newValue in
                        // Solo permitir hasta 10 dígitos
                        if newValue.count > 10 {
                            phoneNumber = String(newValue.prefix(10))
                        }
                    }
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
        isLoading = true
        guard phoneNumber.count == 10 else {
            errorMessage = LoginErrorMessage(title: "Número Invalido", message: "Intenta de nuevo, recuerda que deben de ser 10 dígitos")
            isLoading = false
            return
        }
        
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(fullPhoneNumber, uiDelegate: nil) { verificationID, error in
                isLoading = false
                if let error = error {
                    errorMessage = LoginErrorMessage(title: "Error", message: error.localizedDescription)
                    return
                }
                self.verificationID = verificationID
                isCodeSent = true
            }
    }
    
    func verifyCode() {
        isLoading = true
        guard let verificationID = verificationID else {
            errorMessage = LoginErrorMessage(title: "Error", message: "Inténtalo de nuevo.")
            isLoading = false
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )
        
        Auth.auth().signIn(with: credential) { authResult, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    if (error as NSError).code == AuthErrorCode.invalidVerificationCode.rawValue {
                        // Mostrar un error específico si el código es incorrecto
                        self.errorMessage = LoginErrorMessage(title: "Código Inválido", message: "El código de verificación es incorrecto. Inténtalo de nuevo.")
                    } else {
                        self.errorMessage = LoginErrorMessage(title: "Error", message: error.localizedDescription)
                    }
                    return
                }
                
                if let user = authResult?.user {
                    self.authState.isLoggedIn = true
                    self.authState.user = user
                    self.authState.setUserRole(.cliente)
                    self.isLoggedOut = false
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct LoginErrorMessage: Identifiable {
    let id = UUID()
    let title: String
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
                    .font(.title3)
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
    ClientLoginView(isLoggedOut: .constant(true)).environmentObject(AuthState())
}
