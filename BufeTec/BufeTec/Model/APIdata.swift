//
//  APIdata.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/26/24.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "http://10.14.255.51:4000"
    //private let baseURL = "http://127.0.0.1:5000"

    private init() {}

    // Method to create a new post
    func createNewPost(titulo: String, contenido: String, autorID: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/posts") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let post = [
            "titulo": titulo,
            "contenido": contenido,
            "autor_id": autorID
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: post, options: [])
            request.httpBody = jsonData

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response or status code not 201"])
                    completion(.failure(error))
                    return
                }

                let message = String(data: data, encoding: .utf8) ?? "Post creado"
                completion(.success(message))
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }

    // Method to fetch posts
    func fetchPosts(completion: @escaping (Result<[WelcomeElement], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/posts") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response or status code not 200"])
                completion(.failure(error))
                return
            }

            do {
                let decoder = JSONDecoder()
                let posts = try decoder.decode([WelcomeElement].self, from: data)
                completion(.success(posts))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // Method to delete a post
    func deletePost(postID: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/posts/\(postID)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response or status code not 204"])
                completion(.failure(error))
                return
            }

            completion(.success("Post eliminado"))
        }.resume()
    }
    
    //Method to get the data of the author of a post
    func fetchUserBecarioById(_ id: String, completion: @escaping (Result<BecarioInformationElement, Error>) -> Void) {
            let urlString = "http://10.14.255.51:4000/becarios/\(id)"
            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                completion(.failure(NSError(domain: "NetworkManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }

            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    completion(.failure(NSError(domain: "NetworkManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                    return
                }

                print("HTTP Status Code: \(httpResponse.statusCode)")

                guard let data = data else {
                    print("No data received")
                    completion(.failure(NSError(domain: "NetworkManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }

                do {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Received JSON: \(jsonString)")
                    }
                    
                    let decoder = JSONDecoder()
                    let user = try decoder.decode(BecarioInformationElement.self, from: data)
                    completion(.success(user))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                }
            }.resume()
        }
    
    //Method to fetch abogados by id
    func fetchUserAbogadoById(_ id: String, completion: @escaping (Result<LawyerInformationElement, Error>) -> Void) {
        let urlString = "http://10.14.255.51:4000/abogados/\(id)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let decoder = JSONDecoder()
                let user = try decoder.decode(LawyerInformationElement.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
        
    // Method to add a response to a post
    func addResponse(postID: String, contenido: String, autorID: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/posts/\(postID)/responses") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let response = [
            "contenido": contenido,
            "autor_id": autorID
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: response, options: [])
            request.httpBody = jsonData

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response or status code not 201"])
                    completion(.failure(error))
                    return
                }

                let message = String(data: data, encoding: .utf8) ?? "Respuesta agregada"
                completion(.success(message))
            }.resume()
        } catch {
            completion(.failure(error))
        }
        
    }
    
    func fetchResponses(for postID: String, completion: @escaping (Result<[Respuesta], Error>) -> Void) {
            // Aquí va tu lógica para obtener las respuestas de la base de datos usando el postID
            guard let url = URL(string: "\(baseURL)/posts/\(postID)/responses") else { return }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    completion(.failure(error))
                    return
                }
                
                do {
                    let respuestas = try JSONDecoder().decode([Respuesta].self, from: data)
                    completion(.success(respuestas))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    
    // Add this to your NetworkManager
    func fetchUserClienteById(_ id: String, completion: @escaping (Result<ClientInformationElement, Error>) -> Void) {
        let urlString = "\(baseURL)/clientes/\(id)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601 // Assuming your Date format is ISO8601
                let client = try decoder.decode(ClientInformationElement.self, from: data)
                completion(.success(client))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

}

