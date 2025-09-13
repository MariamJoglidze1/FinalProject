import SwiftUI

struct DetailsView: View {
    let country: Country
    @StateObject private var viewModel = DetailsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    ProgressView("Loading details…")
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
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
                    
                    if let population = details.population {
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
