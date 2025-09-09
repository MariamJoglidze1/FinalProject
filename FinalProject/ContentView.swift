import SwiftUI

struct CountriesListView: View {
    @StateObject private var viewModel = CountriesViewModel()

    var body: some View {
        NavigationView {
            List {
                if let error = viewModel.errorMessage {
                    ErrorView(message: error) {
                        Task { await viewModel.retry() }
                    }
                }
                
                ForEach(viewModel.countries) { country in
                    CountryRow(country: country)
                        .task { await viewModel.loadMoreIfNeeded(current: country) }
                }
                
                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            .navigationTitle("Countries")
            .task {
                if viewModel.countries.isEmpty {
                    await viewModel.fetchCountries()
                }
            }
        }
    }
}

// MARK: - Subviews

struct CountryRow: View {
    let country: Country
    @Environment(Favourites.self) var favourites
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(country.name)
                    .font(.headline)
                Text("Currencies: \(country.currencyCodes.joined(separator: ", "))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
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
                    .frame(width: 24, height: 24)
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
            .padding()
            
            
        }
    }
}
    struct ErrorView: View {
        let message: String
        let retryAction: () -> Void
        
        var body: some View {
            VStack(spacing: 16) {
                Text(message)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                
                Button("Retry", action: retryAction)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
    }

    
//    #Preview {
//        CountriesListView()
//    }
