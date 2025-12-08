import SwiftUI

struct ProfileSummaryView: View {
    @Environment(ProfileManager.self) private var profileManager
    var logbookStats: LogbookStats

    var body: some View {
        HStack(spacing: 16) {
            profilePicture
            VStack(alignment: .leading, spacing: 8) {
                if let firstName = profileManager.profile?.firstName {
                    Text(firstName)
                        .font(.system(size: 24, weight: .bold))
                }
                HStack(spacing: 16) {
                    statPill(
                        icon: "arrow.down",
                        value: logbookStats.lifetimeVertical,
                        label: profileManager.measurementSystem.feetOrMeters.lowercased()
                    )

                    statPill(
                        icon: "figure.snowboarding",
                        value: logbookStats.lifetimeRuns,
                        label: "runs"
                    )

                    statPill(
                        icon: "calendar",
                        value: logbookStats.lifetimeDaysOnMountain,
                        label: "days"
                    )
                }
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
        .padding(.horizontal)
    }

    @ViewBuilder
    private var profilePicture: some View {
        if let profilePic = profileManager.profilePicture {
            profilePic
                .resizable()
                .scaledToFill()
                .frame(width: Constants.Profile.imageSize, height: Constants.Profile.imageSize)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .strokeBorder(Color.accentColor, lineWidth: 2)
                )
        } else {
            Circle()
                .fill(Color(uiColor: .tertiarySystemGroupedBackground))
                .frame(width: Constants.Profile.imageSize, height: Constants.Profile.imageSize)
                .overlay(
                    ProgressView()
                )
        }
    }

    private func statPill(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                Text(label)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(uiColor: .tertiarySystemGroupedBackground))
        )
    }

    private struct Constants {
        struct Profile {
            static let imageSize: CGFloat = 60
        }
    }

}

#Preview {
    ProfileSummaryView(logbookStats: LogbookStats())
}
