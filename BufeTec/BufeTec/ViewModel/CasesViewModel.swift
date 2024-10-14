//
//  CasesViewModel.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 10/1/24.
//

import SwiftUI

class CasesViewModel: ObservableObject {
    @Published var cases: [Case] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchCases(for clientId: String) {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "http://10.14.255.51:4000/casos_legales/internal/\(clientId)") else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Invalid URL"
            }
            return
        }
        
        print("Fetching cases for clie nt ID: \(clientId)")
        let startTime = Date()
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                let endTime = Date()
                let timeElapsed = endTime.timeIntervalSince(startTime)
                print("Network request took \(timeElapsed) seconds")
                
                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    return
                }
                
                do {
                    let decodedCases = try JSONDecoder().decode([Case].self, from: data)
                    self?.cases = decodedCases
                    print("Fetched and decoded \(decodedCases.count) cases")
                } catch {
                    self?.errorMessage = "Decoding error: \(error.localizedDescription)"
                    print("JSON decoding error: \(error)")
                    if let decodingError = error as? DecodingError {
                        switch decodingError {
                        case .keyNotFound(let key, let context):
                            print("Key '\(key.stringValue)' not found:", context.debugDescription)
                            print("codingPath:", context.codingPath)
                        case .valueNotFound(let value, let context):
                            print("Value '\(value)' not found:", context.debugDescription)
                            print("codingPath:", context.codingPath)
                        case .typeMismatch(let type, let context):
                            print("Type '\(type)' mismatch:", context.debugDescription)
                            print("codingPath:", context.codingPath)
                        case .dataCorrupted(let context):
                            print("Data corrupted:", context.debugDescription)
                            print("codingPath:", context.codingPath)
                        @unknown default:
                            print("Unknown decoding error")
                        }
                    }
                    if let dataString = String(data: data, encoding: .utf8) {
                        print("Received data: \(dataString)")
                    }
                }
            }
        }.resume()
    }
}

