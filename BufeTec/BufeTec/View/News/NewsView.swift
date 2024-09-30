import SwiftUI
import Combine 


struct NewsView: View {
    @StateObject private var viewModel = NewsViewModel()
    
    var body: some View {
        NavigationView {
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
                                    
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle("Noticias Legales")
            .onAppear {
                viewModel.fetchNews()
            }
        }
    }
}

struct ArticleDetailView: View {
    let article: Article
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 16) {
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
        
                Text(article.body)
                    .font(.body)
                Link("Ir al articulo", destination: URL(string: article.url)!)
                    .font(.headline)
            }
            .padding()
        }
        .navigationTitle("Articulo")
    }
}

#Preview {
    NewsView()
}
