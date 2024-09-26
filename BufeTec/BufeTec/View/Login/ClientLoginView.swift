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
    @Binding var isLoggedOut: Bool
    @State private var isLoading: Bool = false
    @State private var shouldNavigateToCases: Bool = false
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
        .fullScreenCover(isPresented: $shouldNavigateToCases) {
            NavigationView {
                CasesView(isLoggedOut: $isLoggedOut)
            }
        }
    }
    
    private var phoneNumberView: some View {
        VStack(spacing: 20) {
            HStack {
                CustomCountryPicker(selectedCountry: $selectedCountry, countries: countries)
                    .frame(width: 100)
                
                TextField("Ingresa tu número tel.", text: $phoneNumber)
                    .keyboardType(.phonePad)
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
        
        print("Configuring Firebase Auth settings")
        Auth.auth().settings?.appVerificationDisabledForTesting = false // Set to true only for testing
        
        print("Initiating phone number verification")
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(fullPhoneNumber, uiDelegate: nil) { verificationID, error in
                isLoading = false
                if let error = error {
                    print("Error sending OTP: \(error.localizedDescription)")
                    print("Error details: \(error)")
                    if let errorCode = AuthErrorCode(rawValue: error._code) {
                        print("Firebase Auth Error Code: \(errorCode)")
                    }
                    errorMessage = LoginErrorMessage(message: "Failed to send verification code: \(error.localizedDescription)")
                    return
                }
                guard let verificationID = verificationID else {
                    print("Verification ID is nil")
                    errorMessage = LoginErrorMessage(message: "Failed to send verification code.")
                    return
                }
                print("Verification ID received: \(verificationID)")
                self.verificationID = verificationID
                isCodeSent = true
            }
    }
    
    func verifyCode() {
        logger.info("Attempting to verify code")
        isLoading = true
        guard let verificationID = verificationID else {
            logger.error("Verification ID is missing")
            errorMessage = LoginErrorMessage(message: "Verification ID is missing. Please try sending the code again.")
            isLoading = false
            return
        }
        
        guard !verificationCode.isEmpty else {
            logger.error("Verification code is empty")
            errorMessage = LoginErrorMessage(message: "Please enter the verification code.")
            isLoading = false
            return
        }
        
        logger.info("Verifying code: \(verificationCode) with ID: \(verificationID)")
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )
        
        Auth.auth().signIn(with: credential) { authResult, error in
            isLoading = false
            if let error = error {
                logger.error("Sign in error: \(error.localizedDescription)")
                errorMessage = LoginErrorMessage(message: error.localizedDescription)
                return
            }
            if let user = authResult?.user {
                logger.info("Successfully signed in with UID: \(user.uid)")
                DispatchQueue.main.async {
                    self.isLoggedOut = false
                    self.authState.isLoggedIn = true
                    self.shouldNavigateToCases = true
                }
            } else {
                logger.error("No user returned after sign in")
                errorMessage = LoginErrorMessage(message: "Failed to sign in. Please try again.")
            }
        }
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
}
