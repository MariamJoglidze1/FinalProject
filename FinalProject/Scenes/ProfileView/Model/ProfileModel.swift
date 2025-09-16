import SwiftUI

struct Profile {
    let name: String
    let description: String
    let about: String
    let socialLinks: [SocialLink]
}

struct SocialLink: Identifiable {
    let id = UUID()
    let url: String
    let systemImage: String
    let color: Color
}

