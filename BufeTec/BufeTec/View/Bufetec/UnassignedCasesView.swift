//
//  UnassignedCasesView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 10/10/24.
//

//import SwiftUI
//import FirebaseAuth
//
//struct UnassignedCasesView: View {
//    @State private var showingProfile = false
//    @State private var showingNewCaseView = false
//    @EnvironmentObject var authState: AuthState
//    @StateObject private var viewModel = UnassignedCasesViewModel()
//    
//    
//    var body: some View {
//        Group {
//            if authState.isLoggedIn {
//                ZStack {
//                    if viewModel.cases.isEmpty && !viewModel.isLoading {
//                        Text("No se encontrar on casos")
//                            .font(.headline)
//                    } else {
//                        List(viewModel.cases) { legalCase in
//                            NavigationLink(destination: CaseDetailView(legalCase: legalCase, isClient: authState.userRole == .client)) {
//                                VStack(alignment: .leading, spacing: 5) {
//                                    Text(legalCase.tipo_de_caso)
//                                        .font(.headline)
//                                    Text("Estado: \(legalCase.estado)")
//                                        .font(.subheadline)
//                                    Text("Fecha de inicio: \(formatDate(legalCase.fecha_inicio))")
//                                        .font(.caption)
//                                }
//                                .padding(.vertical, 5)
//                            }
//                        }
//                        .refreshable {
//                            await viewModel.fetchCases()
//                        }
//                    }
//                    
//                    if viewModel.isLoading {
//                        LoadingView()
//                    }
//                    
//                    if let errorMessage = viewModel.errorMessage {
//                        Text(errorMessage)
//                            .foregroundColor(.red)
//                            .padding()
//                            .background(Color.white.opacity(0.8))
//                            .cornerRadius(10)
//                    }
//                }
//                .navigationTitle("Mis Casos")
//                .navigationBarBackButtonHidden(true)
//                .toolbar {
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        Button(action: { showingProfile = true }) {
//                            Image(systemName: "person.fill")
//                        }
//                    }
//                    ToolbarItem(placement: .navigationBarLeading) {
//                        Button(action: {
//                            showingNewCaseView = true
//                        }) {
//                            Image(systemName: "plus")
//                        }
//                    }
//                }
//                .sheet(isPresented: $showingProfile) {
//                    ProfileView()
//                        .environmentObject(authState)
//                }
//                .task {
//                    await viewModel.fetchCases()
//                }
//            } else {
//                GeneralLoginView()
//                    .environmentObject(authState)
//                    .transition(.slide)
//            }
//        }
//        .animation(.easeInOut, value: authState.isLoggedIn)
//    }
//    
//    
//    private func formatDate(_ dateString: String) -> String {
//        let inputFormatter = DateFormatter()
//        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
//        inputFormatter.timeZone = TimeZone(abbreviation: "UTC")
//        
//        let outputFormatter = DateFormatter()
//        outputFormatter.dateFormat = "dd/MM/yyyy"
//        outputFormatter.timeZone = TimeZone.current
//        
//        if let date = inputFormatter.date(from: dateString) {
//            return outputFormatter.string(from: date)
//        }
//        return dateString  // Return original string if parsing fails
//    }
//    
//}
//
//
//
//#Preview {
//    UnassignedCasesView()
//        .environmentObject(AuthState())
//}
