import SwiftUI

struct AboutMeSection: View {
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("About Me")
                .font(.headline)
            
            Text(text)
                .font(.body)
        }
    }
}
