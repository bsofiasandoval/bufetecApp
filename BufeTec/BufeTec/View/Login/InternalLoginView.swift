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
//
//struct InternalLoginView: View {
//    @State private var err: String = ""
//    @Environment(\.dismiss) var dismiss
//    @Environment(\.presentationMode) var presentationMode
//
//    var body: some View {
//        VStack(spacing: 0) {
//            GeometryReader { geometry in
//                ZStack {
//                    LinearGradient(gradient: Gradient(colors: [Color(hex: "#13295D"), Color(hex: "#2756C3")]),
//                                   startPoint: .top,
//                                   endPoint: .bottom)
//                    
//                    VStack {
//                        Spacer()
//                        Text("Iniciar sesión")
//                            .font(.largeTitle)
//                            .fontWeight(.bold)
//                            .foregroundColor(.white)
//                    }
//                    .frame(width: geometry.size.width, height: geometry.size.height / 2)
//                }
//                .frame(height: UIScreen.main.bounds.height / 3)
//            }
//            .frame(height: UIScreen.main.bounds.height / 3)
//            
//            ScrollView {
//                VStack(spacing: 20) {
//                    Spacer(minLength: 50)
//                    
//                    GoogleSignInBtn {
//                        Task {
//                            do {
//                                try await Authentication().googleOauth()
//                                dismiss()
//                            } catch AuthenticationError.runtimeError(let errorMessage) {
//                                err = errorMessage
//                            }
//                        }
//                    }
//                    .padding()
//                    
//                    Text(err)
//                        .foregroundColor(.red)
//                        .font(.caption)
//                    
//                    Spacer()
//                }
//                .padding()
//            }
//        }
//        .edgesIgnoringSafeArea(.top)
//        .navigationBarBackButtonHidden(true)
//        .navigationBarItems(leading: Button(action: {
//            self.presentationMode.wrappedValue.dismiss()
//        }) {
//            Image(systemName: "chevron.left")
//                .foregroundColor(.white)
//        })
//    }
//}

//






struct InternalLoginView: View {
    @State private var err: String = ""
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(hex: "#13295D") , Color(hex: "#2756C3")]),
                               startPoint: .top,
                               endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Spacer()
                    Text("Bienvenid@ a BufeTec")
                        .font(.title)
                       
                        .foregroundColor(.white)
                    
                    HStack{
                        Spacer()
                        Text("Al iniciar sesión, no solo accedes a tu profesión, accedes a cambiar vidas.")
                            .font(.title3)
                            .fontDesign(.serif)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        
                        Spacer()
                    }
                    .padding()
                    .padding()
                   
                    Spacer()
                    Spacer()
                    GoogleSignInBtn {
                        Task {
                            do {
                                try await Authentication().googleOauth()
                                dismiss()
                            } catch AuthenticationError.runtimeError(let errorMessage) {
                                err = errorMessage
                            }
                        }
                    }
                    .padding(.bottom,50)
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.white)
        })
    }
}

#Preview {
    InternalLoginView()
}

