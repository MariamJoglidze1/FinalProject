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
                print("Favourite tapped")
            } label: {
                Image(systemName: "heart.fill")
                    .foregroundColor(.gray)
                    .imageScale(.large)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical, 4)
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

#Preview {
    CountriesListView()
}

