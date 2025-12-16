import SwiftUI

struct LogDetailView: View {
  @Environment(ProfileManager.self) private var profileManager
  let logbook: Logbook
  let logbookStats: LogbookStats

  var body: some View {
    List {
      Section("Session Overview") {
        DetailRow(label: "Location", value: logbook.locationName)
        DetailRow(label: "Date", value: formattedDate)
        DetailRow(label: "Duration", value: formattedDuration)
        DetailRow(label: "Conditions", value: logbook.conditions.joined(separator: ", "))
      }

      Section("Session Stats") {
        DetailRow(label: "Runs", value: "\(logbook.runCount)")
        DetailRow(label: "Distance", value: formattedDistance)
        DetailRow(
          label: "Vertical",
          value: String(
            format: "%.0f \(profileManager.measurementSystem.feetOrMeters)",
            logbook.verticalDistance))
        DetailRow(
          label: "Top Speed",
          value: String(
            format: "%.1f \(profileManager.measurementSystem.milesOrKilometersPerHour)",
            logbook.topSpeed))
      }

      if !logbook.details.isEmpty {
        Section("Individual Runs (\(logbook.details.count))") {
          ForEach(Array(logbook.details.enumerated()), id: \.offset) { index, detail in
            VStack(alignment: .leading, spacing: 8) {
              HStack {
                Image(
                  systemName: detail.type.rawValue == "LIFT"
                    ? "arrow.up.circle.fill" : "arrow.down.circle.fill"
                )
                .foregroundStyle(detail.type.rawValue == "LIFT" ? .blue : .green)
                Text("Run \(index + 1)")
                  .font(.headline)
                Spacer()
                Text(detail.type.rawValue.capitalized)
                  .font(.caption)
                  .padding(.horizontal, 8)
                  .padding(.vertical, 4)
                  .background(Color.secondary.opacity(0.2))
                  .clipShape(Capsule())
              }

              Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                GridRow {
                  Label(
                    "\(String(format: "%.1f", detail.topSpeed)) \(profileManager.measurementSystem.milesOrKilometersPerHour)",
                    systemImage: "speedometer"
                  )
                  .font(.caption)
                  Label(formatDistance(detail.distance), systemImage: "arrow.left.and.right")
                    .font(.caption)
                }
                GridRow {
                  Label(
                    "\(String(format: "%.0f", detail.verticalDistance)) \(profileManager.measurementSystem.feetOrMeters)",
                    systemImage: "arrow.up.and.down"
                  )
                  .font(.caption)
                  Label(formatDuration(detail.duration), systemImage: "clock")
                    .font(.caption)
                }
              }
              .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
          }
        }
      }
    }
    .navigationTitle(logbook.locationName)
    .navigationBarTitleDisplayMode(.large)
  }

  private var formattedDate: String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"

    guard let date = dateFormatter.date(from: logbook.startDate) else {
      return logbook.startDate
    }

    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .short
    return dateFormatter.string(from: date)
  }

  private var formattedDistance: String {
    switch profileManager.measurementSystem {
    case .imperial:
      return String(format: "%.1f MI", logbook.distance.feetToMiles)
    case .metric:
      return String(format: "%.1f KM", logbook.distance.metersToKilometers)
    }
  }

  private var formattedDuration: String {
    formatDuration(logbook.duration)
  }

  private func formatDistance(_ distance: Double) -> String {
    switch profileManager.measurementSystem {
    case .imperial:
      return String(format: "%.1f MI", distance.feetToMiles)
    case .metric:
      return String(format: "%.1f KM", distance.metersToKilometers)
    }
  }

  private func formatDuration(_ seconds: Double) -> String {
    let hours = Int(seconds) / 3600
    let minutes = (Int(seconds) % 3600) / 60

    if hours > 0 {
      return "\(hours)h \(minutes)m"
    } else {
      return "\(minutes)m"
    }
  }
}

struct DetailRow: View {
  let label: String
  let value: String

  var body: some View {
    HStack {
      Text(label)
        .foregroundStyle(.secondary)
      Spacer()
      Text(value)
        .fontWeight(.medium)
    }
  }
}

#Preview {
  NavigationStack {
    LogDetailView(
      logbook: LogbookStats().logbooks.first!,
      logbookStats: LogbookStats()
    )
    .environment(ProfileManager.shared)
  }
}
