import SwiftUI

struct ProfileView: View {
    let profile: Profile
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                ProfileImageView(imageName: "profile-photo")
                ProfileNameView(name: profile.name, description: profile.description)
                Divider()
                AboutMeSection(text: profile.about)
                Divider()
                SocialLinksSection(links: profile.socialLinks)
            }
            .padding(.horizontal)
            .padding(.top, 40)
        }
        .navigationTitle("Profile")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView(profile: .mock)
        }
    }
}
