//
//  CasesViewModel.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 10/1/24.
//

import SwiftUI

class CasesViewModel: ObservableObject {
    @Published var cases: [Case] = []
    @Published var errorMessage: String?

    func fetchCases(for clientId: String) {
        guard let url = URL(string: "http://10.14.255.51:4000/casos_legales/cliente/\(clientId)") else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        print("Fetching cases for client ID: \(clientId)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Error fetching cases: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }
                
                print("Received data: \(String(data: data, encoding: .utf8) ?? "")")
                
                do {
                    let decodedCases = try JSONDecoder().decode([Case].self, from: data)
                    print("Decoded \(decodedCases.count) cases")
                    self.cases = decodedCases
                    print("Updated cases: \(self.cases)")
                } catch {
                    if let decodingError = error as? DecodingError {
                        switch decodingError {
                        case .dataCorrupted(let context):
                            self.errorMessage = "Data corrupted: \(context.debugDescription)"
                        case .keyNotFound(let key, let context):
                            self.errorMessage = "Key '\(key.stringValue)' not found: \(context.debugDescription)"
                        case .typeMismatch(let type, let context):
                            self.errorMessage = "Type '\(type)' mismatch: \(context.debugDescription)"
                        case .valueNotFound(let type, let context):
                            self.errorMessage = "Value of type '\(type)' not found: \(context.debugDescription)"
                        @unknown default:
                            self.errorMessage = "Unknown decoding error"
                        }
                    } else {
                        self.errorMessage = "Error decoding cases: \(error.localizedDescription)"
                    }
                    print("Error decoding cases: \(error)")
                }
            }
        }.resume()
    }
}
