//
//  AssignedCasesView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 10/14/24.
//

import SwiftUI
import FirebaseAuth

struct AssignedCasesView: View {
    @StateObject private var viewModel = AssignedCasesViewModel()
    @State private var showingProfile = false
    @EnvironmentObject var authState: AuthState
    var body: some View {
        VStack {
            if viewModel.isLoading {
                // Show a loading spinner when data is being fetched
                ProgressView("Loading cases...")
            } else if let errorMessage = viewModel.errorMessage {
                // Show an error message if there's a problem fetching the data
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if viewModel.cases.isEmpty {
                // Show a message if no cases are found
                Text("Aun no tienes casos asignados.")
                    .font(.headline)
            } else {
                // Display the list of cases
                
                List(viewModel.cases) { legalCase in
                    NavigationLink(destination: CaseDetailView(legalCase: legalCase, isClient: false)) {
                        CaseRowViewB(legalCase: legalCase)
                    }
                }
            }
        }
        .navigationTitle("Casos asignados")
        .onAppear {
            viewModel.fetchCases(for: Auth.auth().currentUser!.uid)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingProfile = true }) {
                    Image(systemName: "person.fill")
                }
            }
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView()
                .environmentObject(authState)
        }
    }
}

struct CaseRowViewB: View {
    let legalCase: Case
    @State private var nombreCliente: String = "Cargando..."

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(nombreCliente)
                .font(.headline)
            Text("Estado: \(legalCase.estado)")
                .font(.subheadline)
            Text("Fecha de inicio: \(formatDate(legalCase.fecha_inicio))")
                .font(.caption)
        }
        .onAppear {
            fetchClienteName(clienteID: legalCase.cliente_id)
        }
    }

    private func fetchClienteName(clienteID: String) {
        guard let url = URL(string: "http://10.14.255.51:4000/clientes/\(clienteID)") else {
            print("URL inválida")
            nombreCliente = "URL inválida"
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.nombreCliente = "Error al cargar"
                }
                print("Error al realizar la solicitud: \(error?.localizedDescription ?? "Desconocido")")
                return
            }

            if let cliente = try? JSONDecoder().decode(Cliente.self, from: data) {
                DispatchQueue.main.async {
                    self.nombreCliente = cliente.nombre
                    print("Nombre del cliente: \(cliente.nombre)")
                }
            } else {
                DispatchQueue.main.async {
                    self.nombreCliente = "Cliente no encontrado"
                }
            }
        }.resume()
    }

    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        inputFormatter.timeZone = TimeZone(abbreviation: "UTC")

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd/MM/yyyy"
        outputFormatter.timeZone = TimeZone.current

        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }
}

struct Cliente: Decodable {
    let nombre: String
}
