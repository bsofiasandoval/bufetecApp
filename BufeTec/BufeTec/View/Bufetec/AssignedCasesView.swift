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
                        CaseRowView(legalCase: legalCase)
                    }
                }
            }
        }
        .navigationTitle("Casos asignados")
        .onAppear {
            viewModel.fetchCases(for: Auth.auth().currentUser!.uid)
        }
    }
}

