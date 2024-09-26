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
        NavigationView {
            VStack(spacing: 0) {
                GeometryReader { geometry in
                    ZStack {
                        LinearGradient(gradient: Gradient(colors: [Color(hex: "#13295D"), Color(hex: "#2756C3")]),
                                       startPoint: .top,
                                       endPoint: .bottom)
                        
                        VStack {
                            Spacer()
                            Text("Iniciar sesión")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height / 2)
                    }
                    .frame(height: UIScreen.main.bounds.height / 3)
                }
                .frame(height: UIScreen.main.bounds.height / 3)
                
                ScrollView {
                    VStack(spacing: 20) {
                        if isCodeSent {
                            TextField("Enter verification code", text: $verificationCode)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .keyboardType(.numberPad)

                            Button(action: verifyCode) {
                                Text("Verify Code")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .disabled(isLoading)
                        } else {
                            VStack(spacing: 20) {
                                Spacer()
                                
                                HStack {
                                    CustomCountryPicker(selectedCountry: $selectedCountry, countries: countries)
                                        .frame(width: 100)
                                    
                                    Spacer()
                                    TextField("Ingresa tu número tel.", text: $phoneNumber)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                        .keyboardType(.phonePad)
                                }
                                .padding()
                                    
                                VStack {
                                    Spacer()
                                    Button(action: sendOTP) {
                                        Text("Enviar Verificación")
                                            .foregroundColor(.white)
                                            .fontWeight(.medium)
                                            .padding()
                                            .frame(minWidth: 200)
                                            .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#13295D"), Color(hex: "#2756C3")]),
                                                                       startPoint: .top,
                                                                       endPoint: .bottom))
                                            .cornerRadius(10)
                                    }
                                    .disabled(isLoading)
                                }
                                .padding(.top,300)
                            }
                        }
                        
                        if isLoading {
                            ProgressView()
                                .padding()
                        }
                    }
                    .padding()
                }
            }
            .edgesIgnoringSafeArea(.top)
            .alert(item: $errorMessage) { error in
                Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
            }
        }
        .navigationBarBackButtonHidden(true)
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
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
        }
    }
}



#Preview {
    ClientLoginView(isLoggedOut: .constant(true))
}
