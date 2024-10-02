//
//  LawyerDetailView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 10/1/24.
//

import SwiftUI

struct LawyerDetailView: View {
    let lawyerId: String
    @State private var lawyer: Lawyer?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView("Cargando información del abogado...")
            } else if let lawyer = lawyer {
                VStack(spacing: 20) {
                    personalInfoSection
                    professionalInfoSection
                }
                .padding()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Detalles del Abogado")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: fetchLawyerData)
    }

    private var personalInfoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack{
                Text(lawyer?.nombre ?? "")
                    .font(.title)
                    .fontWeight(.bold)
                Text(lawyer?.apellido ?? "")
                    .font(.title)
                    .fontWeight(.bold)
            }
            detailRow(icon: "envelope", title: "Correo", content: lawyer?.correo ?? "")
            detailRow(icon: "phone", title: "Teléfono", content: lawyer?.telefono ?? "")
        }
        .sectionStyle()
    }

    private var professionalInfoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Información Profesional")
                .font(.headline)
            detailRow(icon: "briefcase", title: "Área de Especialización", content: lawyer?.area_especializacion ?? "")
            detailRow(icon: "doc.text", title: "Cédula", content: lawyer?.cedula ?? "")
            if let estado = lawyer?.estado_cuenta {
                detailRow(icon: "checkmark.seal", title: "Estado de Cuenta", content: estado)
            }
        }
        .sectionStyle()
    }

    private func detailRow(icon: String, title: String, content: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(title)
                .fontWeight(.semibold)
            Spacer()
            Text(content)
                .foregroundColor(.secondary)
        }
    }

    private func fetchLawyerData() {
        // Replace this with your actual API call
        isLoading = true
        // Simulating API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Replace this with actual data from your API
            self.lawyer = Lawyer(id: lawyerId, nombre: "Juan", apellido: "Pérez", correo: "juan@example.com", telefono: "123-456-7890", rol: "abogado", area_especializacion: "Derecho Civil", cedula: "ABC123", casos_asignados: ["Case1", "Case2"], estado_cuenta: "Activo")
            self.isLoading = false
        }
    }
}

struct Lawyer: Identifiable {
    let id: String
    let nombre: String
    let apellido: String
    let correo: String
    let telefono: String
    let rol: String
    let area_especializacion: String
    let cedula: String
    let casos_asignados: [String]
    let estado_cuenta: String
}

struct LawyerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LawyerDetailView(lawyerId: "lawyer_001")
        }
    }
}
