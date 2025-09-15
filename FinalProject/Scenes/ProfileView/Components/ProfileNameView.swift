import SwiftUI

struct ProfileNameView: View {
    let name: String
    let description: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(name)
                .font(.title)
                .fontWeight(.bold)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}
