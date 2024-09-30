//
//  noticias.swift
//  BufeTec
//
//  Created by Felipe Alonzo on 30/09/24.
//
import Combine
import Foundation

struct Article: Codable, Identifiable {
    let id: String
    let lang: String
    let isDuplicate: Bool
    let date: String
    let time: String
    let dateTime: String
    let dateTimePub: String
    let dataType: String
    let sim: Double
    let url: String
    let title: String
    let body: String
    let image: String?
    let eventUri: String?
    let wgt: Int
    let relevance: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "uri"
        case lang, isDuplicate, date, time, dateTime, dateTimePub, dataType, sim, url, title, body, image, eventUri, wgt, relevance
    }
}

struct NewsResponse: Codable {
    let articles: Articles
    
    struct Articles: Codable {
        let results: [Article]
        let totalResults: Int
        let page: Int
        let count: Int
        let pages: Int
    }
}

class NewsViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchNews() {
        isLoading = true
        errorMessage = nil
        
        let urlString = "https://newsapi.ai/api/v1/article/getArticles?query=%7B%22%24query%22%3A%7B%22%24and%22%3A%5B%7B%22%24or%22%3A%5B%7B%22keyword%22%3A%22ley%22%2C%22keywordLoc%22%3A%22body%22%7D%2C%7B%22keyword%22%3A%22abogado%22%2C%22keywordLoc%22%3A%22body%22%7D%5D%7D%2C%7B%22%24or%22%3A%5B%7B%22locationUri%22%3A%22http%3A%2F%2Fen.wikipedia.org%2Fwiki%2FMexico%22%7D%2C%7B%22locationUri%22%3A%22http%3A%2F%2Fen.wikipedia.org%2Fwiki%2FMonterrey%22%7D%5D%7D%2C%7B%22lang%22%3A%22spa%22%7D%5D%7D%2C%22%24filter%22%3A%7B%22forceMaxDataTimeWindow%22%3A%2231%22%7D%7D&resultType=articles&articlesSortBy=date&apiKey=b3bd2abc-b4ed-4200-b807-c4323dc3d346"
        
        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid URL"
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: NewsResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { response in
                self.articles = response.articles.results
            }
            .store(in: &cancellables)
    }
}
