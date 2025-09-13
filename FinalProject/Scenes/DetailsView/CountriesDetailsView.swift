import SwiftUI

struct DetailsView: View {
    let country: Country
    @State private var flagURL: URL?
    @State private var capital: String?
    @State private var population: String?
    @State private var continent: String?
    @State private var isLoading = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let flagURL = flagURL {
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
                
                if let capital = capital {
                    HStack {
                        Text("Capital:")
                            .fontWeight(.semibold)
                        Text(capital)
                    }
                }
                
                if let population = population {
                    HStack {
                        Text("Population:")
                            .fontWeight(.semibold)
                        Text(population)
                    }
                }
                
                if let continent = continent {
                    HStack {
                        Text("Continent:")
                            .fontWeight(.semibold)
                        Text(continent)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Details")
    }
    
}
