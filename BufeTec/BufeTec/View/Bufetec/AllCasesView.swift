//
//  UnassignedCasesView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 10/10/24.
//

import SwiftUI
import FirebaseAuth

struct AllCasesView: View {
    @StateObject private var viewModel = AllCasesViewModel()
    @EnvironmentObject var authState: AuthState
    
    // Picker state to track the selected case type
    @State private var selectedCaseType: CaseType = .unassigned
    
    var body: some View {
        VStack {
            if viewModel.cases.isEmpty && !viewModel.isLoading {
                Text("No se encontraron casos")
                    .font(.headline)
            } else {
                VStack {
                    // Segmented Picker with styled background
                    Picker("Casos", selection: $selectedCaseType) {
                        Text("Asignados a mí").tag(CaseType.assignedToMe) // New option for cases assigned to the current user
                        Text("Asignados").tag(CaseType.assigned)
                        Text("Sin Asignar").tag(CaseType.unassigned)
                       
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .pickerStyle(SegmentedPickerStyle())
                    
                    List(filteredCases) { legalCase in
                        NavigationLink(destination: CaseDetailView(legalCase: legalCase, isClient: false)) {
                            CaseRowView(legalCase: legalCase)
                        }
                    }
                    .refreshable {
                        await viewModel.fetchCases()
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6)) // Adaptive background color
                )
            }
            
            if viewModel.isLoading {
                LoadingViewCase()
            }
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
            }
        }
        .navigationTitle("Casos Bufetec")
        .task {
            await viewModel.fetchCases()
        }
    }
    
    // Filter cases based on the selected picker option
    private var filteredCases: [Case] {
        switch selectedCaseType {
        case .unassigned:
            return viewModel.cases.filter { $0.abogados_becarios_id.isEmpty }
        case .assigned:
            return viewModel.cases.filter { !$0.abogados_becarios_id.isEmpty }
        case .assignedToMe:
            // Filter cases where the current user's ID is in abogados_becarios_id
            return viewModel.cases.filter { $0.abogados_becarios_id.contains(authState.user?.uid ?? " ") }
        }
    }
}

// Enum to represent case type for picker
enum CaseType: String {
    case assigned = "Assigned"
    case unassigned = "Unassigned"
    case assignedToMe = "AssignedToMe"  // New case type for cases assigned to the current user
}
