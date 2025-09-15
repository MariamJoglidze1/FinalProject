import SwiftUI

struct SocialLink: Identifiable {
    let id = UUID()
    let url: String
    let systemImage: String
    let color: Color
}

struct SocialLinksSection: View {
    let links: [SocialLink]
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Connect with me")
                .font(.headline)
            
            HStack(spacing: 30) {
                ForEach(links) { link in
                    if let url = URL(string: link.url) {
                        SwiftUI.Link(destination: url) {
                            Image(systemName: link.systemImage)
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(link.color))
                                .shadow(radius: 3)
                        }
                    }
                }
            }
        }
        .padding(.bottom, 40)
    }
}
