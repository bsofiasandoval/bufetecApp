//
//  CasesView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/25/24.
//

import SwiftUI
import FirebaseAuth

struct CasesView: View {
    @State private var showingProfile = false
    @State private var showingNewCaseView = false
    @EnvironmentObject var authState: AuthState
    @StateObject private var viewModel = CasesViewModel()
    let clientId: String
    
    var body: some View {
        Group {
            caseContent
        }
        .animation(.easeInOut, value: authState.isLoggedIn)
    }
    
    @ViewBuilder
    private var caseContent: some View {
        ZStack {
            if viewModel.cases.isEmpty && !viewModel.isLoading {
                Text("No se encontraron casos")
                    .font(.headline)
            } else {
                caseList
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
        .navigationTitle("Mis Casos")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingProfile = true }) {
                    Image(systemName: "person.fill")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { showingNewCaseView = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView()
                .environmentObject(authState)
        }
        .sheet(isPresented: $showingNewCaseView) {
            NewCaseView()
        }
        .task {
            await viewModel.fetchCases(for: clientId)
        }
    }
    
    private var caseList: some View {
        List(viewModel.cases) { legalCase in
            NavigationLink(destination: CaseDetailView(legalCase: legalCase, isClient: authState.userRole == .cliente)) {
                CaseRowView(legalCase: legalCase)
            }
        }
        .refreshable {
            await viewModel.fetchCases(for: clientId)
        }
    }
}

struct CaseRowView: View {
    let legalCase: Case
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(legalCase.tipo_de_caso)
                .font(.headline)
            Text("Estado: \(legalCase.estado)")
                .font(.subheadline)
            Text("Fecha de inicio: \(formatDate(legalCase.fecha_inicio))")
                .font(.caption)
        }
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

struct LoadingViewCase: View {
    var body: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
            Text("Cargando casos...")
                .font(.headline)
                .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.opacity(0.8))
    }
}

