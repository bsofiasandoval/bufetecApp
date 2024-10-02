//
//  BecarioDetailView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 10/1/24.
//

import SwiftUI

struct BecarioDetailView: View {
    let becarioId: String
    @State private var becario: Becario?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView("Cargando información del becario...")
            } else if let becario = becario {
                VStack(spacing: 20) {
                    personalInfoSection
                    scheduleSection
                }
                .padding()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Detalles del Becario")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: fetchBecarioData)
    }

    private var personalInfoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(becario?.nombre ?? "")
                .font(.title)
                .fontWeight(.bold)
            detailRow(icon: "envelope", title: "Correo", content: becario?.correo ?? "")
            detailRow(icon: "person.text.rectangle", title: "Rol", content: becario?.rol ?? "")
        }
        .sectionStyle()
    }


    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Horarios de Atención")
                .font(.headline)
            if let horarios = becario?.horarios_atencion, !horarios.isEmpty {
                ForEach(horarios.sorted(by: { $0.key < $1.key }), id: \.key) { day, hours in
                    HStack {
                        Text(day)
                            .fontWeight(.semibold)
                        Spacer()
                        Text(hours)
                    }
                    .padding(.vertical, 5)
                }
            } else {
                Text("No hay horarios definidos")
                    .italic()
                    .foregroundColor(.secondary)
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

    private func fetchBecarioData() {
        // Replace this with your actual API call
        isLoading = true
        // Simulating API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Replace this with actual data from your API
            self.becario = Becario(id: becarioId, nombre: "Ana García", correo: "ana@example.com", rol: "becario", casos_asignados: ["Case3", "Case4"], horarios_atencion: ["Lunes": "9:00 - 14:00", "Miércoles": "13:00 - 18:00"])
            self.isLoading = false
        }
    }
}

struct Becario: Identifiable {
    let id: String
    let nombre: String
    let correo: String
    let rol: String
    let casos_asignados: [String]
    let horarios_atencion: [String: String]
}

struct BecarioDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BecarioDetailView(becarioId: "becario_001")
        }
    }
}
