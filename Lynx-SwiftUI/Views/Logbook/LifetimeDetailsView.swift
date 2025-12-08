import SwiftUI

struct LifetimeDetailsView: View {
    @Environment(ProfileManager.self) private var profileManager
    var logbookStats: LogbookStats

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ForEach(logbookStats.lifetimeAverages.flatMap { $0 }, id: \.self) { stat in
                    statCard(
                        icon: stat.systemImageName,
                        title: stat.label.uppercased(),
                        value: stat.information,
                        color: .blue,
                        showBadge: false
                    )
                }
            }
            HStack(spacing: 12) {
                ForEach(logbookStats.lifetimeBest.flatMap { $0 }, id: \.self) { stat in
                    statCard(
                        icon: stat.systemImageName,
                        title: stat.label.uppercased(),
                        value: stat.information,
                        color: .orange,
                        showBadge: true
                    )
                }
            }
        }
        .padding(.horizontal)
    }

    private func statCard(
        icon: String,
        title: String,
        value: String,
        color: Color,
        showBadge: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color.gradient)

                Spacer()

                if showBadge {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.yellow)
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 85)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    LifetimeDetailsView(logbookStats: LogbookStats())
        .environment(ProfileManager.shared)
}