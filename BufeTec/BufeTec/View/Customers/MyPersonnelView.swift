//
//  MyLawyerView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 10/10/24.
//

import SwiftUI

struct MyPersonnelView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String = ""
    @State private var email: String?
    @State private var phoneNumber: String?
    @State private var cedulaProfesional: String?
    @State private var especialidad: String?
    @State private var clientId: String?
    @State private var errorMessage: String?
    
    let internalId: String
    
    var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.blue)
                        .padding(.top, 40)
                    
                    Text(name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let email = email {
                        infoCard(title: "Email", value: email)
                    }
                    if let phoneNumber = phoneNumber {
                        infoCard(title: "Teléfono", value: phoneNumber)
                    }
                    if let cedulaProfesional = cedulaProfesional {
                        infoCard(title: "Cédula Profesional", value: cedulaProfesional)
                    }
                    if let especialidad = especialidad {
                        infoCard(title: "Especialidad", value: especialidad)
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                .padding()
            }
            .navigationBarTitle("Detalles del Personal", displayMode: .inline)
            .onAppear {
                fetchData(internalId: internalId)
            }
        
    }
    
    private func fetchData(internalId: String) {
        fetchLawyerData(userId: internalId) { success in
            if !success {
                self.fetchBecarioData(userId: internalId) { success in
                    if !success {
                        self.errorMessage = "Error fetching data. Please try again."
                    }
                }
            }
        }
    }
    
    private func fetchLawyerData(userId: String, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.fetchUserAbogadoById(userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.name = user.nombre
                    self.email = user.correo
                    self.phoneNumber = user.telefono
                    self.cedulaProfesional = user.cedula
                    self.especialidad = user.areaEspecializacion
                    completion(true)
                case .failure:
                    completion(false)
                }
            }
        }
    }
    
    private func fetchBecarioData(userId: String, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.fetchUserBecarioById(userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.name = user.nombre
                    self.email = user.correo
                    self.phoneNumber = nil
                    self.cedulaProfesional = nil
                    self.especialidad = nil
                    completion(true)
                case .failure:
                    completion(false)
                }
            }
        }
    }
    
    private func infoCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct MyPersonnelView_Previews: PreviewProvider {
    static var previews: some View {
        MyPersonnelView(internalId: "12345")
    }
}
