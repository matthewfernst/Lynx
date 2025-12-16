import SwiftUI

struct ProfileButton: View {
  @Environment(ProfileManager.self) private var profileManager
  @Binding var showProfile: Bool

  var body: some View {
    Button {
      showProfile = true
    } label: {
      if let profilePicture = profileManager.profilePicture {
        profilePicture
          .resizable()
          .scaledToFill()
          .clipShape(Circle())
          .frame(width: 32, height: 32)
      } else {
        Image(systemName: "person.crop.circle.fill")
          .resizable()
          .scaledToFit()
          .frame(width: 32, height: 32)
      }
    }
  }
}
