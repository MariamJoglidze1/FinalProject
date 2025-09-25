import SwiftUI
import MapKit

struct DetailsView: View {
    @Environment(FavouritesManager.self) private var favourites
    
    private let country: Country
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
                    ProgressView(LocalizedStringKey("loading_details"))
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: LocalizedStringKey(error)) {
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
                    HStack(alignment: .top, spacing: 12) {
                        Text(country.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .fixedSize(horizontal: false, vertical: true)
                            .layoutPriority(1)
                        
                        Spacer()
                        
                        Button {
                            toggleFavourite()
                        } label: {
                            Image(systemName: favourites.contains(country) ? "heart.fill" : "heart")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(favourites.contains(country) ? LocalizedStringKey("unfavourite") : LocalizedStringKey("favourite"))
                    }
                    
                    // MARK: - Info Rows
                    VStack(spacing: 8) {
                        if let capital = details.capital {
                            infoRow(label: LocalizedStringKey("capital"), value: capital)
                        }
                        if let population = viewModel.populationText {
                            infoRow(label: LocalizedStringKey("population"), value: population)
                        }
                        if let continent = details.continent {
                            infoRow(label: LocalizedStringKey("continent"), value: continent)
                        }
                    }
                    .padding(.top, 8)
                    
                    // MARK: - Map
                    if let coordinate = mapCoordinate(from: details) {
                        CountryMapView(coordinate: coordinate)
                            .padding(.top, 16)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle(LocalizedStringKey("details_title"))
        .task {
            await viewModel.load(for: country.wikiDataId)
        }
    }
    
    private func toggleFavourite() {
        if favourites.contains(country) {
            favourites.remove(country)
        } else {
            favourites.add(country)
        }
    }
    
    @ViewBuilder
    private func infoRow(label: LocalizedStringKey, value: String) -> some View {
        HStack {
            Text(label)
                .fontWeight(.semibold)
            Spacer()
            Text(value)
        }
        .frame(maxWidth: .infinity)
    }
    
    
    func mapCoordinate(from details: CountryDetails?) -> CLLocationCoordinate2D? {
        guard let lat = details?.latitude,
              let lon = details?.longitude else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}
