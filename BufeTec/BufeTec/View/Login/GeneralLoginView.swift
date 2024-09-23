//
//  GeneralLoginView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/13/24.
//

import SwiftUI

struct GeneralLoginView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome")
                    .font(.largeTitle)
                    .padding()
                
                NavigationLink(destination: NewClientCbView()) {
                    Text("New Client")
                        .frame(minWidth: 200)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: ClientLoginView()) {
                    Text("Seguimiento")
                        .frame(minWidth: 200)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: InternalLoginView()) {
                    Text("I'm a Worker")
                        .frame(minWidth: 200)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
    }
}

#Preview {
    GeneralLoginView()
}



