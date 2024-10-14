//
//  myClientsView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 10/10/24.
//

import SwiftUI
import FirebaseAuth

struct MyClientsView: View {
    @StateObject private var viewModel = AssignedCasesViewModel()
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
                    CaseRow(legalCase: legalCase)
                }
            }
        }
        .navigationTitle("Tus casos asignados")
        .onAppear {
            viewModel.fetchCases(for: Auth.auth().currentUser!.uid)
        }
    }
}

struct CaseRow: View {
    let legalCase: Case

    var body: some View {
        VStack(alignment: .leading) {
            Text(legalCase.tipo_de_caso)
                .font(.headline)
            Text("Estado: \(legalCase.estado)")
                .font(.subheadline)
            Text("Fecha de inicio: \(formatDate(legalCase.fecha_inicio))")
                .font(.caption)
        }
        .padding(.vertical, 5)
    }

    // A helper function to format dates
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

