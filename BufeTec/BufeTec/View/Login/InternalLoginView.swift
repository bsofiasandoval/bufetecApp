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
    @State var username: String = ""
    @State var password: String = ""
    @State private var errorMessage: ErrorMessage? = nil
    
    var body: some View {
        ZStack {
            // Degradado de fondo
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
                        FireBaseAuth.shared.signinWithGoogle(presenting: getRootViewController()) { error in
                            if let error = error {
                                errorMessage = ErrorMessage(message: error.localizedDescription)
                            } else {
                                print("Successfully signed in with Google")
                            }
                        }
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
    }
}

// Estructura para manejar el mensaje de error
struct ErrorMessage: Identifiable {
    let id = UUID() // Proporcionar un ID único
    let message: String
}

// Extensión para convertir el hex a Color
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

#Preview {
    InternalLoginView()
}




