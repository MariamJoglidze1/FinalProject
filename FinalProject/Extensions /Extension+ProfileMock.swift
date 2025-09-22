import SwiftUI

extension Profile {
    static let mock = Profile(
        name: NSLocalizedString("profile_name", comment: ""),
        description: NSLocalizedString("profile_description", comment: ""),
        about: NSLocalizedString("profile_about", comment: ""),
        socialLinks: [
            SocialLink(url: "https://github.com/MariamJoglidze1", systemImage: "chevron.left.slash.chevron.right", color: .black),
            SocialLink(url: "https://www.linkedin.com/in/MariamJoglidze", systemImage: "link", color: .blue),
            SocialLink(url: "mailto:mariamjoglidze1@gmail.com", systemImage: "envelope.fill", color: .red)
        ]
    )
}
