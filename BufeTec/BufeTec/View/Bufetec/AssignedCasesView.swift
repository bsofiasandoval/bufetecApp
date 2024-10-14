////
////  AssignedCasesView.swift
////  BufeTec
////
////  Created by Sofia Sandoval on 10/10/24.
////
//
//
//
//import SwiftUI
//import FirebaseAuth
//
//struct AssignedCasesView: View {
//    @State private var showingProfile = false
//    @State private var showingNewCaseView = false
//    @EnvironmentObject var authState: AuthState
//    @StateObject private var viewModel = AssignedCasesViewModel()
//    let internalId: String
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
//                            await viewModel.fetchCases(for: internalId)
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
//                .sheet(isPresented: $showingNewCaseView) {
//                    NewCaseView()  // You'll need to create this view
//                }
//                .task {
//                    await viewModel.fetchCases(for: clientId)
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
//struct LoadingView: View {
//    var body: some View {
//        VStack {
//            ProgressView()
//                .scaleEffect(1.5)
//            Text("Cargando casos...")
//                .font(.headline)
//                .padding(.top)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color.white.opacity(0.8))
//    }
//}
//
//#Preview {
//    AssignedCasesView(internalId: "c7BH89up7bNXLKou3RTyvBP3Lmr1")
//        .environmentObject(AuthState())
//}
