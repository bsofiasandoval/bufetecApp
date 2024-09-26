//
//  ClientRegisterView.swift
//  BufeTec
//
//  Created by Lorna on 9/25/24.
//

import SwiftUI

struct ClientRegisterView: View {
    @State private var nombre: String = ""
    @State private var telefono: String = ""
    @State private var correo: String = ""
    @State private var tramite: String = "Caso Legal"
    @State private var folio: String = ""
    @Binding var isLoggedOut: Bool
    @State private var shouldNavigateToCases = false
    @Environment(\.presentationMode) var presentationMode

    
    var body: some View {
        Form {
            Section(header: Text("Información del Cliente")) {
                HStack {
                    Text("Nombre")
                    TextField("Nombre", text: $nombre)
                }
                
                HStack {
                    Text("# Teléfono")
                    TextField("+52XXXXXXXX", text: $telefono)
                        .keyboardType(.phonePad)
                        // hacer validaciones
                }
                
                HStack {
                    Text("Correo Electrónico")
                    TextField("Correo Electrónico", text: $correo)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            }
            
            Section(header: Text("Detalles del Caso")) {
                HStack {
                    Text("Tramite")
                    TextField("Trámite", text: $tramite)
                        .disabled(true)
                }
                
                HStack {
                    Text("ID del Caso")
                    TextField("Folio", text: $folio)
                        .disabled(true)
                }
            }
        }
        .navigationTitle("Crear Cuenta")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
               Button("Guardar") {
                   saveAndNavigate()
               }
           }
        }
        .fullScreenCover(isPresented: $shouldNavigateToCases) {
           NavigationView {
               CasesView(isLoggedOut: $isLoggedOut)
           }
       }
    }
    
    private func saveAndNavigate() {
        // Perform save operation here
        // For example, you might want to validate the fields and send the data to a server
        
        // Simulate a successful save operation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Update the logged-in state
            isLoggedOut = false
            
            // Navigate to ContentView
            shouldNavigateToCases = true
        }
    }
    
}



#Preview {
    ClientRegisterView(isLoggedOut: .constant(true))
}
