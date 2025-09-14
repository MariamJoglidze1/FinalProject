import SwiftUI

struct DetailsView: View {
    let country: Country
    @StateObject private var viewModel: DetailsViewModel
    @Environment(Favourites.self) private var favourites   // ✅ directly from Environment
    
    init(country: Country) {
        self.country = country
        _viewModel = StateObject(wrappedValue: DetailsViewModel(country: country))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Button {
                    if favourites.contains(country) {
                        favourites.remove(country)
                    } else {
                        favourites.add(country)
                    }
                } label: {
                    Image(systemName: favourites.contains(country) ? "heart.fill" : "heart")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                
                if viewModel.isLoading {
                    ProgressView("Loading details…")
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error) {
                        Task { await viewModel.load(for: country.wikiDataId) }
                    }
                } else if let details = viewModel.details {
                    
                    if let flagURL = details.flagURL {
                        AsyncImage(url: flagURL) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .cornerRadius(8)
                                .shadow(radius: 4)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    
                    Text(country.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if let capital = details.capital {
                        infoRow(label: "Capital", value: capital)
                    }
                    
                    if let population = viewModel.populationText {
                        infoRow(label: "Population", value: population)
                    }
                    
                    if let continent = details.continent {
                        infoRow(label: "Continent", value: continent)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Details")
        .task {
            await viewModel.load(for: country.wikiDataId)
        }
    }
    
    @ViewBuilder
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text("\(label):")
                .fontWeight(.semibold)
            Text(value)
        }
    }
}
