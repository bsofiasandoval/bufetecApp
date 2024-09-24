//
//  ClientLoginView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/13/24.
//

import SwiftUI
import FirebaseAuth
import os

struct ClientLoginView: View {
    @State private var phoneNumber: String = ""
    @State private var verificationCode: String = ""
    @State private var verificationID: String? = nil
    @State private var errorMessage: LoginErrorMessage? = nil
    @State private var isCodeSent: Bool = false
    @Binding var isLoggedOut: Bool
    @State private var isLoading: Bool = false
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.yourapp", category: "ClientLoginView")
    
    var body: some View {
        NavigationView {
            VStack {
                if isCodeSent {
                    TextField("Enter verification code", text: $verificationCode)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                        .keyboardType(.numberPad)

                    Button(action: verifyCode) {
                        Text("Verify Code")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(5)
                    }
                    .disabled(isLoading)
                } else {
                    TextField("Enter phone number", text: $phoneNumber)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                        .keyboardType(.phonePad)

                    Button(action: sendOTP) {
                        Text("Send SMS")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(5)
                    }
                    .disabled(isLoading)
                }
                
                if isLoading {
                    ProgressView()
                        .padding()
                }
            }
            .padding(.top, 52)
            .alert(item: $errorMessage) { error in
                Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
            }
            .padding()
            .navigationBarTitle("Login", displayMode: .inline)
        }
    }
    
    func sendOTP() {
        print("Attempting to send OTP to: \(phoneNumber)")
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
            .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
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




struct ClientLoginView_Previews: PreviewProvider {
    static var previews: some View {
        ClientLoginView(isLoggedOut: .constant(true))
    }
}

