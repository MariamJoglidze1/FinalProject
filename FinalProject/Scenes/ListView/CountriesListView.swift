import SwiftUI

struct CountriesListView: View {
    
    private var viewModel: CountriesViewModel
    
    @State private var navigationPath = NavigationPath()
    
    init() {
        viewModel = CountriesViewModel(service: CountriesService())
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                ForEach(viewModel.countries) { country in
                    countryRow(for: country)
                        .makeWholeViewTapable()
                        .onTapGesture {
                            navigationPath.append(country)
                        }
                        .task { await viewModel.loadMoreIfNeeded(current: country) }
                }
            }
            .navigationTitle(LocalizedStringKey("countries_title"))
            .progressView(isShowing: viewModel.isLoading)
            .alert(parameters: viewModel.alertParameters)
            .navigationDestination(
                for: Country.self,
                destination: { country in
                    CountryDetailsView(country: country)
                }
            )
            .refreshable {
                Task { await viewModel.retry() }
            }
            .task {
                if viewModel.countries.isEmpty {
                    await viewModel.fetchCountries()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        ProfileView(profile: .mock)
                            .force(orientation: .all)
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .font(.title2)
                    }
                }
            }
        }
    }
    
    private func countryRow(for country: Country) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(country.name)
                    .font(.headline)
                
                let localizedCurrencies = country.currencyCodes
                    .compactMap { Locale.current.localizedString(forCurrencyCode: $0) }
                    .joined(separator: ", ")
                
                Text("\(NSLocalizedString("currencies_prefix", comment: "")) \(localizedCurrencies)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            favouriteButton(with: country)
        }
    }
    
    private func favouriteButton(with country: Country)-> some View {
        Button {
            viewModel.favouriteButtonDidTap(country: country)
        } label: {
            Image(systemName: FavouritesManager.shared.contains(country) ? "heart.fill" : "heart")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(.red)
        }
        .buttonStyle(.plain)
        .padding()
    }
}
