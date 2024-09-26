//
//  GeneralLoginView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/13/24.
//

import SwiftUI

struct GeneralLoginView: View {
    @State private var isLoggedOut = true
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(hex: "#13295D"), Color(hex: "#2756C3")]),
                               startPoint: .top,
                               endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    
                    Image(.bufeTecLogo)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                      
                    Text("Tu derecho, nuestra vocación.")
                        .foregroundColor(.white)
                        .fontDesign(.serif)
                        .font(.title3)
                    
                    
                    Spacer()
                    Spacer()
                    
                    VStack(spacing: 20) {
                        NavigationLink(destination: NewClientCbView()) {
                            Text("Requiero Asesoría Legal")
                                .frame(minWidth: 200)
                                .fontWeight(.medium)
                                .padding()
                                .background(.white)
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                        }
                        
                        NavigationLink(destination: ClientLoginView(isLoggedOut: $isLoggedOut)) {
                            Text("Consultar Caso Existente")
                                .frame(minWidth: 200)
                                .fontWeight(.medium)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                        }
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: InternalLoginView()) {
                        Text("Soy LED o Bufetec")
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                    }
                    .padding(.bottom, 10)
                }
            }
        }
    }
}




extension Color {
    init(hex: String) {
        let hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red, green, blue, alpha: Double
        
        switch hexSanitized.count {
        case 3: // RGB (12-bit)
            (red, green, blue, alpha) = (
                Double((rgb >> 8) & 0xF) / 15.0,
                Double((rgb >> 4) & 0xF) / 15.0,
                Double(rgb & 0xF) / 15.0,
                1.0
            )
        case 6: // RGB (24-bit)
            (red, green, blue, alpha) = (
                Double((rgb >> 16) & 0xFF) / 255.0,
                Double((rgb >> 8) & 0xFF) / 255.0,
                Double(rgb & 0xFF) / 255.0,
                1.0
            )
        case 8: // ARGB (32-bit)
            (red, green, blue, alpha) = (
                Double((rgb >> 16) & 0xFF) / 255.0,
                Double((rgb >> 8) & 0xFF) / 255.0,
                Double(rgb & 0xFF) / 255.0,
                Double((rgb >> 24) & 0xFF) / 255.0
            )
        default:
            (red, green, blue, alpha) = (0, 0, 0, 1)
        }
        
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

#Preview {
    GeneralLoginView()
}



