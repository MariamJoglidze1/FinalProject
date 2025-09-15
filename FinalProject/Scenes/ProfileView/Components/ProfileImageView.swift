import SwiftUI

struct ProfileImageView: View {
    let imageName: String
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: 150, height: 150)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.blue, lineWidth: 3))
            .shadow(radius: 5)
    }
}
