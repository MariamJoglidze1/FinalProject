import Foundation

protocol WikidataServiceProtocol {
    func fetchCountryDetails(for wikiDataId: String) async throws -> CountryDetails
    func fetchLabel(for entityId: String) async throws -> String
}

struct WikidataService: WikidataServiceProtocol {
    func fetchCountryDetails(for wikiDataId: String) async throws -> CountryDetails {
        guard let url = URL(string: "https://www.wikidata.org/wiki/Special:EntityData/\(wikiDataId).json") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { throw URLError(.badServerResponse) }
        
        var details = CountryDetails()
        
        if let entities = json["entities"] as? [String: Any],
           let entity = entities[wikiDataId] as? [String: Any],
           let claims = entity["claims"] as? [String: Any] {
            
            // Flag
            if let flagArray = claims["P41"] as? [[String: Any]],
               let mainsnak = flagArray.first?["mainsnak"] as? [String: Any],
               let datavalue = mainsnak["datavalue"] as? [String: Any],
               let filename = datavalue["value"] as? String {
                let filePath = filename.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? filename
                details.flagURL = URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/\(filePath)?width=300")
            }
            
            
            // Capital
            if let capitalArray = claims["P36"] as? [[String: Any]],
               let mainsnak = capitalArray.first?["mainsnak"] as? [String: Any],
               let datavalue = mainsnak["datavalue"] as? [String: Any],
               let capitalId = datavalue["value"] as? [String: Any],
               let id = capitalId["id"] as? String {
                details.capital = try? await fetchLabel(for: id)
            }
            
            // Population
            if let popArray = claims["P1082"] as? [[String: Any]],
               let mainsnak = popArray.first?["mainsnak"] as? [String: Any],
               let datavalue = mainsnak["datavalue"] as? [String: Any],
               let amount = datavalue["value"] as? [String: Any],
               let populationValue = amount["amount"] as? String {
               let cleaned = populationValue.replacingOccurrences(of: "+", with: "")
               details.population = Int(cleaned)

            }
            
            // Coordinates
            if let coordsArray = claims["P625"] as? [[String: Any]],
               let mainsnak = coordsArray.first?["mainsnak"] as? [String: Any],
               let datavalue = mainsnak["datavalue"] as? [String: Any],
               let value = datavalue["value"] as? [String: Any],
               let latitude = value["latitude"] as? Double,
               let longitude = value["longitude"] as? Double {
                details.latitude = latitude
                details.longitude = longitude
            }
            
            // Continent
            if let contArray = claims["P30"] as? [[String: Any]],
               let mainsnak = contArray.first?["mainsnak"] as? [String: Any],
               let datavalue = mainsnak["datavalue"] as? [String: Any],
               let contId = datavalue["value"] as? [String: Any],
               let id = contId["id"] as? String {
                details.continent = try? await fetchLabel(for: id)
            }
        }
        
        return details
    }
    
    func fetchLabel(for entityId: String) async throws -> String {
        guard let url = URL(string: "https://www.wikidata.org/wiki/Special:EntityData/\(entityId).json") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        if let entities = json["entities"] as? [String: Any],
           let entity = entities[entityId] as? [String: Any],
           let labels = entity["labels"] as? [String: Any],
           let en = labels["en"] as? [String: Any],
           let value = en["value"] as? String {
            return value
        }
        throw URLError(.cannotParseResponse)
    }
}
