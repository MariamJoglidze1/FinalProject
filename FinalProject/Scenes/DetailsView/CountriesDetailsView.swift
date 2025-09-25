import SwiftUI

struct CountryDetailsView: View {
    private var viewModel: CountryDetailsViewModel
    
    init(country: Country) {
        viewModel = CountryDetailsViewModel(country: country)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let details = viewModel.details {
                    if let flagURL = details.flagURL {
                        headerImageView(url: flagURL)
                    }
                    
                    countryTitleView
                    
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.countryInfoDataSource) { info in
                            infoRow(label: info.title, value: info.value)
                        }
                    }
                    
                    if let coordinate = viewModel.mapCoordinate() {
                        MapView(coordinate: coordinate)
                            .padding(.top, 16)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(LocalizedStringKey("details_title"))
        .progressView(isShowing: viewModel.isLoading)
        .alert(parameters: viewModel.alertParameters)
        .task {
            await viewModel.loadData()
        }
    }
    
    private func headerImageView(url: URL)-> some View {
        AsyncImage(url: url) { image in
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
    
    private var countryTitleView: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(viewModel.selectedCountry.name)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .truncationMode(.tail)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)
            
            Spacer()
            
            Button {
                viewModel.toggleFavourite()
            } label: {
                Image(systemName: FavouritesManager.shared.contains(viewModel.selectedCountry) ? "heart.fill" : "heart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(FavouritesManager.shared.contains(viewModel.selectedCountry) ? LocalizedStringKey("unfavourite") : LocalizedStringKey("favourite"))
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
    }
}
