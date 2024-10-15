import SwiftUI
import Combine

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
    @Published var searchText: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var allArticles: [Article] = []
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                self?.filterArticles()
            }
            .store(in: &cancellables)
    }
    
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
                self.allArticles = response.articles.results
                self.filterArticles()
            }
            .store(in: &cancellables)
    }
    
    private func filterArticles() {
        if searchText.isEmpty {
            articles = allArticles
        } else {
            articles = allArticles.filter { article in
                article.title.lowercased().contains(searchText.lowercased()) ||
                article.body.lowercased().contains(searchText.lowercased())
            }
        }
    }
}

struct NewsView: View {
    @StateObject private var viewModel = NewsViewModel()
    
    var body: some View {
            VStack {
                SearchBar(text: $viewModel.searchText)
                List {
                    if viewModel.isLoading {
                        ProgressView()
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    } else {
                        ForEach(viewModel.articles) { article in
                            NavigationLink(destination: ArticleDetailView(article: article)) {
                                HStack(spacing: 16) {
                                    AsyncImage(url: URL(string: article.image ?? "")) { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 80, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    } placeholder: {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 80, height: 80)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(article.title)
                                            .font(.headline)
                                            .lineLimit(2)
                                        Text(article.dateTime)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Noticias")
            .onAppear {
                viewModel.fetchNews()
            }
            .dismissKeyboardOnTap() 
        
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Buscar...", text: $text)
                .padding(8)
                .padding(.horizontal, 24)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if !text.isEmpty {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
        }
        .padding(.horizontal)
    }
}

struct ArticleDetailView: View {
    let article: Article
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let imageUrl = article.image {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image.resizable().aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 200)
                }
                Text(article.title)
                    .font(.title)
                Text(article.dateTime)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(article.body)
                    .font(.body)
                Link("Leer el articulo", destination: URL(string: article.url)!)
                    .font(.headline)
            }
            .padding()
        }
    }
}

#Preview {
    NewsView()
}
