import SwiftUI

extension Profile {
    static let mock = Profile(
        name: "Mariam Joglidze",
        description: "iOS Developer • Tech Enthusiast • Gym Lover",
        about: "I’m a passionate iOS developer with experience in Swift, SwiftUI, and building apps that solve real-world problems. I enjoy learning new technologies, contributing to projects, and improving user experience.",
        socialLinks: [
            SocialLink(url: "https://github.com/MariamJoglidze1", systemImage: "chevron.left.slash.chevron.right", color: .black),
            SocialLink(url: "https://www.linkedin.com/in/MariamJoglidze", systemImage: "link", color: .blue),
            SocialLink(url: "mailto:mariamjoglidze1@gmail.com", systemImage: "envelope.fill", color: .red)
        ]
    )
}
