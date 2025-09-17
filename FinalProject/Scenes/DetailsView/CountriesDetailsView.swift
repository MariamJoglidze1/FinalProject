import SwiftUI
import MapKit

struct DetailsView: View {
    private let country: Country
    @Environment(Favourites.self) private var favourites
    private var viewModel: DetailsViewModel
    
    init(country: Country) {
        self.country = country
        viewModel = DetailsViewModel(country: country)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: - Loading & Error
                if viewModel.isLoading {
                    ProgressView("Loading details…")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error) {
                        Task { await viewModel.load(for: country.wikiDataId) }
                    }
                } else if let details = viewModel.details {
                    
                    // MARK: - Flag Image
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
                    
                    // MARK: - Country Name & Favorite
                    HStack {
                        Text(country.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Button {
                            toggleFavourite()
                        } label: {
                            Image(systemName: favourites.contains(country) ? "heart.fill" : "heart")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    VStack(spacing: 8) {
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
                    .padding(.top, 8)
                    
                    // MARK: - Map
                    if let lat = details.latitude,
                       let lon = details.longitude {
                        CountryMapView(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                            .padding(.top, 16)
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
    
    // MARK: - Helpers
    private func toggleFavourite() {
        if favourites.contains(country) {
            favourites.remove(country)
        } else {
            favourites.add(country)
        }
    }
    
    @ViewBuilder
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text("\(label):")
                .fontWeight(.semibold)
            Spacer()
            Text(value)
        }
        .frame(maxWidth: .infinity)
    }
}
