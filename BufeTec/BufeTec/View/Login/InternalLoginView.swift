//
//  InternalLoginView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/13/24.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import Firebase

struct InternalLoginView: View {
    @State var email: String = ""
    @State var password: String = ""
    @State private var errorMessage: ErrorMessage? = nil
    @State private var isLoggedIn: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [Color(hex: "#13295D") ?? .blue, Color(hex: "#2756C3") ?? .blue]),
                               startPoint: .top,
                               endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Image("LogoTec")
                        .resizable()
                        .frame(width: 100, height: 100)
                    
                    VStack {
                        GoogleSignInBtn {
                            signInWithGoogle()
                        }
                    }
                    .padding(.top, 52)
                    .alert(item: $errorMessage) { error in
                        Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
                    }
                    Spacer()
                }
                .padding()
            }
            .navigationDestination(isPresented: $isLoggedIn) {
                // Navigate to your home screen or dashboard
                Text("Welcome! You are logged in.")
                    .navigationBarBackButtonHidden(true)
            }
        }
    }

    
    private func signInWithGoogle() {
        FireBAuth.shared.signInWithGoogle(presenting: getRootViewController()) { error in
            if let error = error {
                errorMessage = ErrorMessage(message: error.localizedDescription)
            } else {
                print("Successfully signed in with Google")
                isLoggedIn = true
            }
        }
    }
}

struct ErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

// Helper function to get the root view controller
func getRootViewController() -> UIViewController {
    guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
        return .init()
    }

    guard let root = screen.windows.first?.rootViewController else {
        return .init()
    }
    
    return root
}

struct InternalLoginView_Previews: PreviewProvider {
    static var previews: some View {
        InternalLoginView()
    }
}
