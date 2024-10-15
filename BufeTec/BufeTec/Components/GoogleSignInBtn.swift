//
//  GoogleSignInBtn.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/22/24.
//

import SwiftUI

struct GoogleSignInBtn: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image("google")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .padding(8)
                    .background(Color.white)
                    .clipShape(Circle())
                
                Text("Inicia Sesión")
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                
                Spacer()
            }
            .padding(.horizontal)
            .frame(width:250,height: 50)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 2)
        }
    }
}

#Preview {
    GoogleSignInBtn(action: {})
}


