import SwiftUI

struct ProfileView: View {
    let profile: Profile
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                profileImageView(name: "profile-photo")
                ProfileNameView(name: profile.name, description: profile.description)
                Divider()
                AboutMeSection(text: profile.about)
                Divider()
                SocialLinksSection(links: profile.socialLinks)
            }
            .padding(.horizontal)
            .padding(.top, 40)
        }
        .navigationTitle(LocalizedStringKey("profile_title"))
    }
    
    private func profileImageView(name: String) -> some View {
        Image(name)
            .resizable()
            .scaledToFill()
            .frame(width: 150, height: 150)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.blue, lineWidth: 3))
            .shadow(radius: 5)
    }
    
    private func AboutMeSection(text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(LocalizedStringKey("about_me_title"))
                .font(.headline)
            
            Text(text)
                .font(.body)
        }
    }
    
    private func ProfileNameView(name: String, description: String) -> some View {
        VStack(spacing: 5) {
            Text(name) // dynamic, not localized
                .font(.title)
                .fontWeight(.bold)
            
            Text(description) // dynamic, not localized
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private func SocialLinksSection(links: [SocialLink])-> some View {
        VStack(spacing: 15) {
            Text(LocalizedStringKey("connect_with_me"))
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
