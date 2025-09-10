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
        .task {
            await loadWikidata(for: country.wikiDataId)
        }
    }
    
    // MARK: - Wikidata Fetch
    func loadWikidata(for wikiDataId: String) async {
        guard let url = URL(string: "https://www.wikidata.org/wiki/Special:EntityData/\(wikiDataId).json") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
            
            if let entities = json["entities"] as? [String: Any],
               let entity = entities[wikiDataId] as? [String: Any],
               let claims = entity["claims"] as? [String: Any] {
                
                if let flagArray = claims["P41"] as? [[String: Any]],
                   let mainsnak = flagArray.first?["mainsnak"] as? [String: Any],
                   let datavalue = mainsnak["datavalue"] as? [String: Any],
                   let filename = datavalue["value"] as? String {
                    let filePath = filename.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? filename
                    flagURL = URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/\(filePath)")
                }
                
                if let capitalArray = claims["P36"] as? [[String: Any]],
                   let mainsnak = capitalArray.first?["mainsnak"] as? [String: Any],
                   let datavalue = mainsnak["datavalue"] as? [String: Any],
                   let capitalId = datavalue["value"] as? [String: Any],
                   let id = capitalId["id"] as? String {
                    capital = await fetchLabel(for: id)
                }
                
                if let popArray = claims["P1082"] as? [[String: Any]],
                   let mainsnak = popArray.first?["mainsnak"] as? [String: Any],
                   let datavalue = mainsnak["datavalue"] as? [String: Any],
                   let amount = datavalue["value"] as? [String: Any],
                   let populationValue = amount["amount"] as? String {
                    population = populationValue.replacingOccurrences(of: "+", with: "")
                }
                
                if let contArray = claims["P30"] as? [[String: Any]],
                   let mainsnak = contArray.first?["mainsnak"] as? [String: Any],
                   let datavalue = mainsnak["datavalue"] as? [String: Any],
                   let contId = datavalue["value"] as? [String: Any],
                   let id = contId["id"] as? String {
                    continent = await fetchLabel(for: id)
                }
            }
        } catch {
            print("Failed to fetch Wikidata: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Fetch Label (for capital & continent)
    func fetchLabel(for entityId: String) async -> String? {
        guard let url = URL(string: "https://www.wikidata.org/wiki/Special:EntityData/\(entityId).json") else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
            if let entities = json["entities"] as? [String: Any],
               let entity = entities[entityId] as? [String: Any],
               let labels = entity["labels"] as? [String: Any],
               let en = labels["en"] as? [String: Any],
               let value = en["value"] as? String {
                return value
            }
        } catch {
            return nil
        }
        
        return nil
    }
}

