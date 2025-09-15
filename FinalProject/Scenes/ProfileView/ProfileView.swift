import SwiftUI

struct ProfileView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                ProfileImageView(imageName: "profile-photo")
                
                ProfileNameView(
                    name: "Mariam Joglidze",
                    description: "iOS Developer • Tech Enthusiast • Gym Lover"
                )
                
                Divider()
                
                AboutMeSection(
                    text: "I’m a passionate iOS developer with experience in Swift, SwiftUI, and building apps that solve real-world problems. I enjoy learning new technologies, contributing to projects, and improving user experience."
                )
                
                Divider()
                
                SocialLinksSection(
                    links: [
                        SocialLink(
                            url: "https://github.com/MariamJoglidze1",
                            systemImage: "chevron.left.slash.chevron.right",
                            color: .black
                        ),
                        SocialLink(
                            url: "https://www.linkedin.com/in/MariamJoglidze",
                            systemImage: "link",
                            color: .blue
                        ),
                        SocialLink(
                            url: "mailto:mariamjoglidze1@gmail.com",
                            systemImage: "envelope.fill",
                            color: .red
                        )
                    ]
                )
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 40)
        }
        .navigationTitle("Profile")
    }
}
